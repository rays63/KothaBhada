import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/payment_status.dart';
import '../models/portfolio_snapshot.dart';
import '../models/property_models.dart';
import '../services/seed_data.dart';

class AppDatabase {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/kothabhada.db';

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
      },
    );

    await _seedIfNeeded(_database!);
    return _database!;
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE properties(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        total_rooms INTEGER NOT NULL,
        occupied_rooms INTEGER NOT NULL,
        monthly_target REAL NOT NULL,
        total_due REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE rooms(
        id TEXT PRIMARY KEY,
        property_id TEXT NOT NULL,
        label TEXT NOT NULL,
        tenant_name TEXT NOT NULL,
        due_day INTEGER NOT NULL,
        monthly_rent REAL NOT NULL,
        status TEXT NOT NULL,
        note TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE receivables(
        id TEXT PRIMARY KEY,
        property_name TEXT NOT NULL,
        room_label TEXT NOT NULL,
        amount REAL NOT NULL,
        overdue_label TEXT NOT NULL,
        tags TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE revenue_points(
        month TEXT PRIMARY KEY,
        amount REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE utility_usage(
        property_name TEXT PRIMARY KEY,
        electricity REAL NOT NULL,
        water REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE preferences(
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _seedIfNeeded(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM properties'),
    );
    if ((count ?? 0) > 0) return;

    final seed = SeedData.snapshot;
    final batch = db.batch();

    for (final property in seed.properties) {
      batch.insert('properties', {
        'id': property.id,
        'name': property.name,
        'address': property.address,
        'total_rooms': property.totalRooms,
        'occupied_rooms': property.occupiedRooms,
        'monthly_target': property.monthlyTarget,
        'total_due': property.totalDue,
      });

      for (final room in property.rooms) {
        batch.insert('rooms', {
          'id': room.id,
          'property_id': room.propertyId,
          'label': room.label,
          'tenant_name': room.tenantName,
          'due_day': room.dueDay,
          'monthly_rent': room.monthlyRent,
          'status': room.status.name,
          'note': room.note,
        });
      }
    }

    for (final receivable in [
      ...seed.pendingReceivables,
      ...seed.completedReceivables,
    ]) {
      batch.insert('receivables', {
        'id': receivable.id,
        'property_name': receivable.propertyName,
        'room_label': receivable.roomLabel,
        'amount': receivable.amount,
        'overdue_label': receivable.overdueLabel,
        'tags': jsonEncode(receivable.tags),
        'status': receivable.status.name,
      });
    }

    for (final point in seed.revenue) {
      batch.insert('revenue_points', {
        'month': point.month,
        'amount': point.amount,
      });
    }

    for (final usage in seed.utilityUsage) {
      batch.insert('utility_usage', {
        'property_name': usage.propertyName,
        'electricity': usage.electricity,
        'water': usage.water,
      });
    }

    batch.insert('preferences', {
      'key': 'currency_code',
      'value': seed.preferences.currencyCode,
    });
    batch.insert('preferences', {
      'key': 'reminder_day',
      'value': '${seed.preferences.reminderDay}',
    });
    batch.insert('preferences', {
      'key': 'landlord_name',
      'value': seed.preferences.landlordName,
    });

    await batch.commit(noResult: true);
  }

  Future<PortfolioSnapshot> loadSnapshot() async {
    final db = await database;
    final propertyRows = await db.query('properties');
    final roomRows = await db.query('rooms');
    final receivableRows = await db.query('receivables');
    final revenueRows = await db.query('revenue_points');
    final utilityRows = await db.query('utility_usage');
    final preferenceRows = await db.query('preferences');

    final roomsByProperty = <String, List<Room>>{};
    for (final row in roomRows) {
      final room = Room(
        id: row['id']! as String,
        propertyId: row['property_id']! as String,
        label: row['label']! as String,
        tenantName: row['tenant_name']! as String,
        dueDay: row['due_day']! as int,
        monthlyRent: _toDouble(row['monthly_rent']),
        status: PaymentStatus.values.byName(row['status']! as String),
        note: row['note']! as String,
      );
      roomsByProperty.putIfAbsent(room.propertyId, () => []).add(room);
    }

    final properties = propertyRows
        .map(
          (row) => RentalProperty(
            id: row['id']! as String,
            name: row['name']! as String,
            address: row['address']! as String,
            totalRooms: row['total_rooms']! as int,
            occupiedRooms: row['occupied_rooms']! as int,
            monthlyTarget: _toDouble(row['monthly_target']),
            totalDue: _toDouble(row['total_due']),
            rooms: roomsByProperty[row['id']! as String] ?? const [],
          ),
        )
        .toList();

    final receivables = receivableRows
        .map(
          (row) => PaymentReceivable(
            id: row['id']! as String,
            propertyName: row['property_name']! as String,
            roomLabel: row['room_label']! as String,
            amount: _toDouble(row['amount']),
            overdueLabel: row['overdue_label']! as String,
            tags: (jsonDecode(row['tags']! as String) as List<dynamic>)
                .cast<String>(),
            status: PaymentStatus.values.byName(row['status']! as String),
          ),
        )
        .toList();

    final preferencesMap = {
      for (final row in preferenceRows)
        row['key']! as String: row['value']! as String,
    };

    return PortfolioSnapshot(
      properties: properties,
      revenue: revenueRows
          .map(
            (row) => MonthlyRevenuePoint(
              month: row['month']! as String,
              amount: _toDouble(row['amount']),
            ),
          )
          .toList(),
      utilityUsage: utilityRows
          .map(
            (row) => UtilityUsage(
              propertyName: row['property_name']! as String,
              electricity: _toDouble(row['electricity']),
              water: _toDouble(row['water']),
            ),
          )
          .toList(),
      pendingReceivables: receivables
          .where((item) => item.status != PaymentStatus.paid)
          .toList(),
      completedReceivables: receivables
          .where((item) => item.status == PaymentStatus.paid)
          .toList(),
      preferences: AppPreferences(
        currencyCode: preferencesMap['currency_code'] ?? 'NPR',
        reminderDay: int.tryParse(preferencesMap['reminder_day'] ?? '5') ?? 5,
        landlordName: preferencesMap['landlord_name'] ?? 'Aarav',
      ),
    );
  }

  double _toDouble(Object? value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse('$value') ?? 0;
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final db = await database;
    await db.insert('preferences', {
      'key': 'theme_mode',
      'value': mode.name,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<ThemeMode?> loadThemeMode() async {
    final db = await database;
    final rows = await db.query(
      'preferences',
      where: 'key = ?',
      whereArgs: ['theme_mode'],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ThemeMode.values.byName(rows.first['value']! as String);
  }
}
