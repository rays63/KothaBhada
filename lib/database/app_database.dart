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
      version: 2,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _migrateToV2(db);
        }
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
      CREATE TABLE tenants(
        id TEXT PRIMARY KEY,
        property_id TEXT NOT NULL,
        room_id TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        move_in_date TEXT NOT NULL,
        emergency_contact TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE receivables(
        id TEXT PRIMARY KEY,
        property_id TEXT NOT NULL,
        property_name TEXT NOT NULL,
        room_id TEXT NOT NULL,
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
      CREATE TABLE utility_records(
        id TEXT PRIMARY KEY,
        property_id TEXT NOT NULL,
        property_name TEXT NOT NULL,
        room_id TEXT NOT NULL,
        room_label TEXT NOT NULL,
        tenant_name TEXT NOT NULL,
        type TEXT NOT NULL,
        meter_reading REAL,
        amount REAL NOT NULL,
        note TEXT NOT NULL,
        image_path TEXT,
        recorded_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE documents(
        id TEXT PRIMARY KEY,
        property_id TEXT NOT NULL,
        property_name TEXT NOT NULL,
        room_id TEXT NOT NULL,
        room_label TEXT NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        file_path TEXT NOT NULL,
        note TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE activities(
        id TEXT PRIMARY KEY,
        property_id TEXT NOT NULL,
        title TEXT NOT NULL,
        detail TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE preferences(
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _migrateToV2(Database db) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    final names = tables.map((row) => row['name']).toSet();

    if (!names.contains('tenants')) {
      await db.execute('''
        CREATE TABLE tenants(
          id TEXT PRIMARY KEY,
          property_id TEXT NOT NULL,
          room_id TEXT NOT NULL,
          name TEXT NOT NULL,
          phone TEXT NOT NULL,
          move_in_date TEXT NOT NULL,
          emergency_contact TEXT NOT NULL
        )
      ''');
    }
    if (!names.contains('utility_records')) {
      await db.execute('''
        CREATE TABLE utility_records(
          id TEXT PRIMARY KEY,
          property_id TEXT NOT NULL,
          property_name TEXT NOT NULL,
          room_id TEXT NOT NULL,
          room_label TEXT NOT NULL,
          tenant_name TEXT NOT NULL,
          type TEXT NOT NULL,
          meter_reading REAL,
          amount REAL NOT NULL,
          note TEXT NOT NULL,
          image_path TEXT,
          recorded_at TEXT NOT NULL
        )
      ''');
    }
    if (!names.contains('documents')) {
      await db.execute('''
        CREATE TABLE documents(
          id TEXT PRIMARY KEY,
          property_id TEXT NOT NULL,
          property_name TEXT NOT NULL,
          room_id TEXT NOT NULL,
          room_label TEXT NOT NULL,
          title TEXT NOT NULL,
          category TEXT NOT NULL,
          file_path TEXT NOT NULL,
          note TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    }
    if (!names.contains('activities')) {
      await db.execute('''
        CREATE TABLE activities(
          id TEXT PRIMARY KEY,
          property_id TEXT NOT NULL,
          title TEXT NOT NULL,
          detail TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    }

    // Backfill old receivables schema from v1.
    await _addColumnIfMissing(
      db,
      'receivables',
      'property_id',
      "TEXT NOT NULL DEFAULT ''",
    );
    await _addColumnIfMissing(
      db,
      'receivables',
      'room_id',
      "TEXT NOT NULL DEFAULT ''",
    );
  }

  Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String columnSql,
  ) async {
    final rows = await db.rawQuery('PRAGMA table_info($table)');
    final hasColumn = rows.any((row) => row['name'] == column);
    if (!hasColumn) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $columnSql');
    }
  }

  Future<void> _seedIfNeeded(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM properties'),
    );
    if ((count ?? 0) > 0) {
      await _seedMissingV2Tables(db);
      return;
    }

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

    for (final tenant in seed.tenants) {
      batch.insert('tenants', {
        'id': tenant.id,
        'property_id': tenant.propertyId,
        'room_id': tenant.roomId,
        'name': tenant.name,
        'phone': tenant.phone,
        'move_in_date': tenant.moveInDate.toIso8601String(),
        'emergency_contact': tenant.emergencyContact,
      });
    }

    for (final receivable in [
      ...seed.pendingReceivables,
      ...seed.completedReceivables,
    ]) {
      batch.insert('receivables', {
        'id': receivable.id,
        'property_id': receivable.propertyId,
        'property_name': receivable.propertyName,
        'room_id': receivable.roomId,
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

    for (final record in seed.utilityRecords) {
      batch.insert('utility_records', {
        'id': record.id,
        'property_id': record.propertyId,
        'property_name': record.propertyName,
        'room_id': record.roomId,
        'room_label': record.roomLabel,
        'tenant_name': record.tenantName,
        'type': record.type.name,
        'meter_reading': record.meterReading,
        'amount': record.amount,
        'note': record.note,
        'image_path': record.imagePath,
        'recorded_at': record.recordedAt.toIso8601String(),
      });
    }

    for (final document in seed.documents) {
      batch.insert('documents', {
        'id': document.id,
        'property_id': document.propertyId,
        'property_name': document.propertyName,
        'room_id': document.roomId,
        'room_label': document.roomLabel,
        'title': document.title,
        'category': document.category,
        'file_path': document.filePath,
        'note': document.note,
        'created_at': document.createdAt.toIso8601String(),
      });
    }

    for (final activity in seed.activities) {
      batch.insert('activities', {
        'id': activity.id,
        'property_id': activity.propertyId,
        'title': activity.title,
        'detail': activity.detail,
        'created_at': activity.createdAt.toIso8601String(),
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

  Future<void> _seedMissingV2Tables(Database db) async {
    final seed = SeedData.snapshot;

    Future<void> seedIfEmpty(
      String table,
      void Function(Batch, PortfolioSnapshot) writer,
    ) async {
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'),
      );
      if ((count ?? 0) > 0) return;
      final batch = db.batch();
      writer(batch, seed);
      await batch.commit(noResult: true);
    }

    await seedIfEmpty('tenants', (batch, data) {
      for (final tenant in data.tenants) {
        batch.insert('tenants', {
          'id': tenant.id,
          'property_id': tenant.propertyId,
          'room_id': tenant.roomId,
          'name': tenant.name,
          'phone': tenant.phone,
          'move_in_date': tenant.moveInDate.toIso8601String(),
          'emergency_contact': tenant.emergencyContact,
        });
      }
    });

    await seedIfEmpty('utility_records', (batch, data) {
      for (final record in data.utilityRecords) {
        batch.insert('utility_records', {
          'id': record.id,
          'property_id': record.propertyId,
          'property_name': record.propertyName,
          'room_id': record.roomId,
          'room_label': record.roomLabel,
          'tenant_name': record.tenantName,
          'type': record.type.name,
          'meter_reading': record.meterReading,
          'amount': record.amount,
          'note': record.note,
          'image_path': record.imagePath,
          'recorded_at': record.recordedAt.toIso8601String(),
        });
      }
    });

    await seedIfEmpty('documents', (batch, data) {
      for (final document in data.documents) {
        batch.insert('documents', {
          'id': document.id,
          'property_id': document.propertyId,
          'property_name': document.propertyName,
          'room_id': document.roomId,
          'room_label': document.roomLabel,
          'title': document.title,
          'category': document.category,
          'file_path': document.filePath,
          'note': document.note,
          'created_at': document.createdAt.toIso8601String(),
        });
      }
    });

    await seedIfEmpty('activities', (batch, data) {
      for (final activity in data.activities) {
        batch.insert('activities', {
          'id': activity.id,
          'property_id': activity.propertyId,
          'title': activity.title,
          'detail': activity.detail,
          'created_at': activity.createdAt.toIso8601String(),
        });
      }
    });

    final receivableRows = await db.query('receivables');
    for (final row in receivableRows) {
      if ((row['property_id'] as String?)?.isNotEmpty == true &&
          (row['room_id'] as String?)?.isNotEmpty == true) {
        continue;
      }
      final propertyName = row['property_name'] as String? ?? '';
      final roomLabel = row['room_label'] as String? ?? '';
      final propertyRow = await db.query(
        'properties',
        where: 'name = ?',
        whereArgs: [propertyName],
        limit: 1,
      );
      final propertyId = propertyRow.isEmpty
          ? ''
          : propertyRow.first['id'] as String;
      final roomRow = await db.query(
        'rooms',
        where: 'property_id = ? AND label LIKE ?',
        whereArgs: [
          propertyId,
          '%${roomLabel.replaceAll('Suite ', '').replaceAll('Flat ', '')}%',
        ],
        limit: 1,
      );
      final roomId = roomRow.isEmpty ? '' : roomRow.first['id'] as String;
      await db.update(
        'receivables',
        {'property_id': propertyId, 'room_id': roomId},
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }
  }

  Future<PortfolioSnapshot> loadSnapshot() async {
    final db = await database;
    final propertyRows = await db.query('properties');
    final roomRows = await db.query('rooms');
    final tenantRows = await db.query('tenants');
    final receivableRows = await db.query('receivables');
    final revenueRows = await db.query('revenue_points');
    final utilityRows = await db.query('utility_usage');
    final utilityRecordRows = await db.query(
      'utility_records',
      orderBy: 'recorded_at DESC',
    );
    final documentRows = await db.query(
      'documents',
      orderBy: 'created_at DESC',
    );
    final activityRows = await db.query(
      'activities',
      orderBy: 'created_at DESC',
    );
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

    final tenants = tenantRows
        .map(
          (row) => TenantProfile(
            id: row['id']! as String,
            roomId: row['room_id']! as String,
            propertyId: row['property_id']! as String,
            name: row['name']! as String,
            phone: row['phone']! as String,
            moveInDate: DateTime.parse(row['move_in_date']! as String),
            emergencyContact: row['emergency_contact']! as String,
          ),
        )
        .toList();

    final receivables = receivableRows
        .map(
          (row) => PaymentReceivable(
            id: row['id']! as String,
            propertyId: row['property_id']! as String,
            propertyName: row['property_name']! as String,
            roomId: row['room_id']! as String,
            roomLabel: row['room_label']! as String,
            amount: _toDouble(row['amount']),
            overdueLabel: row['overdue_label']! as String,
            tags: (jsonDecode(row['tags']! as String) as List<dynamic>)
                .cast<String>(),
            status: PaymentStatus.values.byName(row['status']! as String),
          ),
        )
        .toList();

    final utilityRecords = utilityRecordRows
        .map(
          (row) => UtilityRecord(
            id: row['id']! as String,
            propertyId: row['property_id']! as String,
            propertyName: row['property_name']! as String,
            roomId: row['room_id']! as String,
            roomLabel: row['room_label']! as String,
            tenantName: row['tenant_name']! as String,
            type: UtilityType.values.byName(row['type']! as String),
            meterReading: row['meter_reading'] == null
                ? null
                : _toDouble(row['meter_reading']),
            amount: _toDouble(row['amount']),
            note: row['note']! as String,
            imagePath: row['image_path'] as String?,
            recordedAt: DateTime.parse(row['recorded_at']! as String),
          ),
        )
        .toList();

    final documents = documentRows
        .map(
          (row) => DocumentRecord(
            id: row['id']! as String,
            propertyId: row['property_id']! as String,
            propertyName: row['property_name']! as String,
            roomId: row['room_id']! as String,
            roomLabel: row['room_label']! as String,
            title: row['title']! as String,
            category: row['category']! as String,
            filePath: row['file_path']! as String,
            note: row['note']! as String,
            createdAt: DateTime.parse(row['created_at']! as String),
          ),
        )
        .toList();

    final activities = activityRows
        .map(
          (row) => ActivityEntry(
            id: row['id']! as String,
            propertyId: row['property_id']! as String,
            title: row['title']! as String,
            detail: row['detail']! as String,
            createdAt: DateTime.parse(row['created_at']! as String),
          ),
        )
        .toList();

    final usageFromRecords = _buildUtilityUsageFromRecords(utilityRecords);
    final fallbackUsage = utilityRows
        .map(
          (row) => UtilityUsage(
            propertyName: row['property_name']! as String,
            electricity: _toDouble(row['electricity']),
            water: _toDouble(row['water']),
          ),
        )
        .toList();

    final preferencesMap = {
      for (final row in preferenceRows)
        row['key']! as String: row['value']! as String,
    };

    return PortfolioSnapshot(
      properties: properties,
      tenants: tenants,
      revenue: revenueRows
          .map(
            (row) => MonthlyRevenuePoint(
              month: row['month']! as String,
              amount: _toDouble(row['amount']),
            ),
          )
          .toList(),
      utilityUsage: usageFromRecords.isEmpty ? fallbackUsage : usageFromRecords,
      utilityRecords: utilityRecords,
      documents: documents,
      activities: activities,
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

  List<UtilityUsage> _buildUtilityUsageFromRecords(
    List<UtilityRecord> records,
  ) {
    final grouped = <String, List<UtilityRecord>>{};
    for (final record in records) {
      grouped.putIfAbsent(record.propertyName, () => []).add(record);
    }
    return grouped.entries.map((entry) {
      final electricity = entry.value
          .where((record) => record.type == UtilityType.electricity)
          .fold<double>(0, (sum, record) => sum + record.amount);
      final water = entry.value
          .where((record) => record.type == UtilityType.water)
          .fold<double>(0, (sum, record) => sum + record.amount);
      return UtilityUsage(
        propertyName: entry.key,
        electricity: electricity,
        water: water,
      );
    }).toList();
  }

  Future<void> saveProperty(PropertyDraft draft) async {
    final db = await database;
    final id = draft.id ?? _id('p');
    final existing = await db.query(
      'properties',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert('properties', {
        'id': id,
        'name': draft.name,
        'address': draft.address,
        'total_rooms': 0,
        'occupied_rooms': 0,
        'monthly_target': draft.monthlyTarget,
        'total_due': 0,
      });
      await _addActivity(
        db,
        propertyId: id,
        title: 'Property added',
        detail: '${draft.name} added to offline portfolio.',
      );
      return;
    }

    await db.update(
      'properties',
      {
        'name': draft.name,
        'address': draft.address,
        'monthly_target': draft.monthlyTarget,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    await _addActivity(
      db,
      propertyId: id,
      title: 'Property updated',
      detail: '${draft.name} details were edited.',
    );
  }

  Future<void> saveRoom(RoomDraft draft) async {
    final db = await database;
    final id = draft.id ?? _id('r');
    final existing = await db.query(
      'rooms',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert('rooms', {
        'id': id,
        'property_id': draft.propertyId,
        'label': draft.label,
        'tenant_name': draft.tenantName,
        'due_day': draft.dueDay,
        'monthly_rent': draft.monthlyRent,
        'status': draft.status.name,
        'note': draft.note,
      });
      await _addActivity(
        db,
        propertyId: draft.propertyId,
        title: 'Room added',
        detail: 'Room ${draft.label} was added for ${draft.tenantName}.',
      );
    } else {
      await db.update(
        'rooms',
        {
          'label': draft.label,
          'tenant_name': draft.tenantName,
          'due_day': draft.dueDay,
          'monthly_rent': draft.monthlyRent,
          'status': draft.status.name,
          'note': draft.note,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      await _addActivity(
        db,
        propertyId: draft.propertyId,
        title: 'Room updated',
        detail: 'Room ${draft.label} details were updated.',
      );
    }

    await _upsertTenantFromRoom(db, id, draft);
    await _recalculatePropertyStats(db, draft.propertyId);
  }

  Future<void> addUtilityRecord(UtilityRecordDraft draft) async {
    final db = await database;
    await db.insert('utility_records', {
      'id': _id('u'),
      'property_id': draft.propertyId,
      'property_name': draft.propertyName,
      'room_id': draft.roomId,
      'room_label': draft.roomLabel,
      'tenant_name': draft.tenantName,
      'type': draft.type.name,
      'meter_reading': draft.meterReading,
      'amount': draft.amount,
      'note': draft.note,
      'image_path': draft.imagePath,
      'recorded_at': draft.recordedAt.toIso8601String(),
    });
    await _addActivity(
      db,
      propertyId: draft.propertyId,
      title: 'Utility logged',
      detail: '${draft.type.name} bill for room ${draft.roomLabel} recorded.',
    );
  }

  Future<void> addDocument(DocumentDraft draft) async {
    final db = await database;
    await db.insert('documents', {
      'id': _id('d'),
      'property_id': draft.propertyId,
      'property_name': draft.propertyName,
      'room_id': draft.roomId,
      'room_label': draft.roomLabel,
      'title': draft.title,
      'category': draft.category,
      'file_path': draft.filePath,
      'note': draft.note,
      'created_at': DateTime.now().toIso8601String(),
    });
    await _addActivity(
      db,
      propertyId: draft.propertyId,
      title: 'Document saved',
      detail: '${draft.title} attached to room ${draft.roomLabel}.',
    );
  }

  Future<void> markReceivablePaid(String receivableId) async {
    final db = await database;
    final rows = await db.query(
      'receivables',
      where: 'id = ?',
      whereArgs: [receivableId],
      limit: 1,
    );
    if (rows.isEmpty) return;

    final row = rows.first;
    await db.update(
      'receivables',
      {
        'status': PaymentStatus.paid.name,
        'overdue_label':
            'Collected on ${DateTime.now().toLocal().toIso8601String().split('T').first}',
      },
      where: 'id = ?',
      whereArgs: [receivableId],
    );
    final propertyId = row['property_id']! as String;
    await _addActivity(
      db,
      propertyId: propertyId,
      title: 'Payment received',
      detail:
          '${row['room_label']} payment of ${_toDouble(row['amount']).toStringAsFixed(0)} marked as paid.',
    );
    await _recalculatePropertyStats(db, propertyId);
  }

  Future<void> _upsertTenantFromRoom(
    Database db,
    String roomId,
    RoomDraft room,
  ) async {
    if (room.tenantName.trim().isEmpty) return;
    final rows = await db.query(
      'tenants',
      where: 'room_id = ?',
      whereArgs: [roomId],
      limit: 1,
    );
    if (rows.isEmpty) {
      await db.insert('tenants', {
        'id': _id('t'),
        'property_id': room.propertyId,
        'room_id': roomId,
        'name': room.tenantName,
        'phone': '',
        'move_in_date': DateTime.now().toIso8601String(),
        'emergency_contact': '',
      });
      return;
    }
    await db.update(
      'tenants',
      {'name': room.tenantName},
      where: 'room_id = ?',
      whereArgs: [roomId],
    );
  }

  Future<void> _recalculatePropertyStats(Database db, String propertyId) async {
    final rooms = await db.query(
      'rooms',
      where: 'property_id = ?',
      whereArgs: [propertyId],
    );
    final property = await db.query(
      'properties',
      where: 'id = ?',
      whereArgs: [propertyId],
      limit: 1,
    );
    if (property.isEmpty) return;
    final propertyName = property.first['name']! as String;

    final occupied = rooms.where((row) {
      final tenant = (row['tenant_name'] as String?)?.trim() ?? '';
      return tenant.isNotEmpty;
    }).length;

    final receivables = await db.query(
      'receivables',
      where: 'property_name = ? AND status != ?',
      whereArgs: [propertyName, PaymentStatus.paid.name],
    );
    final due = receivables.fold<double>(
      0,
      (sum, row) => sum + _toDouble(row['amount']),
    );

    await db.update(
      'properties',
      {
        'total_rooms': rooms.length,
        'occupied_rooms': occupied,
        'total_due': due,
      },
      where: 'id = ?',
      whereArgs: [propertyId],
    );
  }

  Future<void> _addActivity(
    Database db, {
    required String propertyId,
    required String title,
    required String detail,
  }) async {
    await db.insert('activities', {
      'id': _id('a'),
      'property_id': propertyId,
      'title': title,
      'detail': detail,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  String _id(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}';

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
