import 'dart:convert';
import 'dart:io';

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
      version: 5,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _migrateToV2(db);
        }
        if (oldVersion < 3) {
          await _migrateToV3(db);
        }
        if (oldVersion < 4) {
          await _migrateToV4(db);
        }
        if (oldVersion < 5) {
          await _migrateToV5(db);
        }
      },
    );

    await _seedIfNeeded(_database!);
    await _ensureCurrentMonthBillingCycles(_database!);
    return _database!;
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS properties(
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
      CREATE TABLE IF NOT EXISTS rooms(
        id TEXT PRIMARY KEY,
        property_id TEXT NOT NULL,
        label TEXT NOT NULL,
        tenant_name TEXT NOT NULL,
        due_day INTEGER NOT NULL,
        monthly_rent REAL NOT NULL,
        electricity_rate REAL NOT NULL,
        water_cost REAL NOT NULL,
        internet_cost REAL NOT NULL,
        status TEXT NOT NULL,
        note TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS tenants(
        id TEXT PRIMARY KEY,
        property_id TEXT NOT NULL,
        room_id TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        citizenship_no TEXT NOT NULL,
        move_in_date TEXT NOT NULL,
        emergency_contact TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS utility_records(
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
      CREATE TABLE IF NOT EXISTS documents(
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
      CREATE TABLE IF NOT EXISTS activities(
        id TEXT PRIMARY KEY,
        property_id TEXT NOT NULL,
        title TEXT NOT NULL,
        detail TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS billing_cycles(
        id TEXT PRIMARY KEY,
        property_id TEXT NOT NULL,
        property_name TEXT NOT NULL,
        room_id TEXT NOT NULL,
        room_label TEXT NOT NULL,
        tenant_id TEXT NOT NULL,
        tenant_name TEXT NOT NULL,
        cycle_year INTEGER NOT NULL,
        cycle_month INTEGER NOT NULL,
        rent_due REAL NOT NULL,
        electricity_due REAL NOT NULL,
        internet_due REAL NOT NULL,
        utility_due REAL NOT NULL,
        total_due REAL NOT NULL,
        total_paid REAL NOT NULL,
        status TEXT NOT NULL,
        due_date TEXT NOT NULL,
        generated_at TEXT NOT NULL,
        closed_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS payments(
        id TEXT PRIMARY KEY,
        billing_cycle_id TEXT NOT NULL,
        tenant_id TEXT NOT NULL,
        amount REAL NOT NULL,
        method TEXT NOT NULL,
        note TEXT NOT NULL,
        is_partial INTEGER NOT NULL,
        paid_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS electricity_readings(
        id TEXT PRIMARY KEY,
        property_id TEXT NOT NULL,
        property_name TEXT NOT NULL,
        room_id TEXT NOT NULL,
        room_label TEXT NOT NULL,
        tenant_name TEXT NOT NULL,
        previous_reading REAL NOT NULL,
        current_reading REAL NOT NULL,
        units_consumed REAL NOT NULL,
        rate REAL NOT NULL,
        total_cost REAL NOT NULL,
        image_path TEXT,
        note TEXT NOT NULL,
        recorded_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS preferences(
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Legacy tables retained for backward compatibility with previous app versions.
    await db.execute('''
      CREATE TABLE IF NOT EXISTS receivables(
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
      CREATE TABLE IF NOT EXISTS revenue_points(
        month TEXT PRIMARY KEY,
        amount REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS utility_usage(
        property_name TEXT PRIMARY KEY,
        electricity REAL NOT NULL,
        water REAL NOT NULL
      )
    ''');
  }

  Future<void> _migrateToV2(Database db) async {
    await _createTables(db);
  }

  Future<void> _migrateToV3(Database db) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    final names = tables.map((row) => row['name']).cast<String>().toSet();

    if (!names.contains('billing_cycles')) {
      await db.execute('''
        CREATE TABLE billing_cycles(
          id TEXT PRIMARY KEY,
          property_id TEXT NOT NULL,
          property_name TEXT NOT NULL,
          room_id TEXT NOT NULL,
          room_label TEXT NOT NULL,
          tenant_id TEXT NOT NULL,
          tenant_name TEXT NOT NULL,
          cycle_year INTEGER NOT NULL,
          cycle_month INTEGER NOT NULL,
          rent_due REAL NOT NULL,
          electricity_due REAL NOT NULL,
          internet_due REAL NOT NULL,
          utility_due REAL NOT NULL,
          total_due REAL NOT NULL,
          total_paid REAL NOT NULL,
          status TEXT NOT NULL,
          due_date TEXT NOT NULL,
          generated_at TEXT NOT NULL,
          closed_at TEXT
        )
      ''');
    }
    if (!names.contains('payments')) {
      await db.execute('''
        CREATE TABLE payments(
          id TEXT PRIMARY KEY,
          billing_cycle_id TEXT NOT NULL,
          tenant_id TEXT NOT NULL,
          amount REAL NOT NULL,
          method TEXT NOT NULL,
          note TEXT NOT NULL,
          is_partial INTEGER NOT NULL,
          paid_at TEXT NOT NULL
        )
      ''');
    }
  }

  Future<void> _migrateToV4(Database db) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    final names = tables.map((row) => row['name']).cast<String>().toSet();
    if (!names.contains('electricity_readings')) {
      await db.execute('''
        CREATE TABLE electricity_readings(
          id TEXT PRIMARY KEY,
          property_id TEXT NOT NULL,
          property_name TEXT NOT NULL,
          room_id TEXT NOT NULL,
          room_label TEXT NOT NULL,
          tenant_name TEXT NOT NULL,
          previous_reading REAL NOT NULL,
          current_reading REAL NOT NULL,
          units_consumed REAL NOT NULL,
          rate REAL NOT NULL,
          total_cost REAL NOT NULL,
          image_path TEXT,
          note TEXT NOT NULL,
          recorded_at TEXT NOT NULL
        )
      ''');
    }
  }

  Future<void> _migrateToV5(Database db) async {
    await _addColumnIfMissing(
      db,
      table: 'rooms',
      column: 'electricity_rate',
      columnSql: 'REAL NOT NULL DEFAULT 12',
    );
    await _addColumnIfMissing(
      db,
      table: 'rooms',
      column: 'water_cost',
      columnSql: 'REAL NOT NULL DEFAULT 50',
    );
    await _addColumnIfMissing(
      db,
      table: 'rooms',
      column: 'internet_cost',
      columnSql: 'REAL NOT NULL DEFAULT 500',
    );
    await _addColumnIfMissing(
      db,
      table: 'tenants',
      column: 'citizenship_no',
      columnSql: "TEXT NOT NULL DEFAULT ''",
    );
  }

  Future<void> _addColumnIfMissing(
    Database db, {
    required String table,
    required String column,
    required String columnSql,
  }) async {
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
      await _backfillTenantsFromRooms(db);
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
        'total_due': 0,
      });
      for (final room in property.rooms) {
        batch.insert('rooms', {
          'id': room.id,
          'property_id': room.propertyId,
          'label': room.label,
          'tenant_name': room.tenantName,
          'due_day': room.dueDay,
          'monthly_rent': room.monthlyRent,
          'electricity_rate': room.electricityRate,
          'water_cost': room.waterCost,
          'internet_cost': room.internetCost,
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
        'citizenship_no': tenant.citizenshipNo,
        'move_in_date': tenant.moveInDate.toIso8601String(),
        'emergency_contact': tenant.emergencyContact,
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

  Future<void> _backfillTenantsFromRooms(Database db) async {
    final rooms = await db.query('rooms');
    for (final room in rooms) {
      final roomId = room['id']! as String;
      final tenantName = (room['tenant_name']! as String).trim();
      if (tenantName.isEmpty) continue;
      final existing = await db.query(
        'tenants',
        where: 'room_id = ?',
        whereArgs: [roomId],
        limit: 1,
      );
      if (existing.isNotEmpty) continue;
      await db.insert('tenants', {
        'id': _id('t'),
        'property_id': room['property_id']! as String,
        'room_id': roomId,
        'name': tenantName,
        'phone': '',
        'citizenship_no': '',
        'move_in_date': DateTime.now().toIso8601String(),
        'emergency_contact': '',
      });
    }
  }

  Future<void> _ensureCurrentMonthBillingCycles(Database db) async {
    final now = DateTime.now();
    final monthRows = await db.rawQuery('''
      SELECT t.id as tenant_id, t.name as tenant_name, t.property_id, t.room_id,
             r.label as room_label, r.monthly_rent, r.due_day, r.internet_cost, r.water_cost, p.name as property_name
      FROM tenants t
      INNER JOIN rooms r ON r.id = t.room_id
      INNER JOIN properties p ON p.id = t.property_id
      WHERE t.room_id != ''
      ''');

    for (final row in monthRows) {
      final tenantId = row['tenant_id']! as String;
      final roomId = row['room_id']! as String;
      final existing = await db.query(
        'billing_cycles',
        where:
            'tenant_id = ? AND room_id = ? AND cycle_year = ? AND cycle_month = ?',
        whereArgs: [tenantId, roomId, now.year, now.month],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        await _syncMonthlyUtilityForCycle(db, existing.first);
        continue;
      }

      final utility = await _calculateMonthlyUtilityForRoom(db, roomId, now);
      final rentDue = _toDouble(row['monthly_rent']);
      final baseInternet = _toDouble(row['internet_cost']);
      final baseWater = _toDouble(row['water_cost']);
      final internetDue = baseInternet + utility.internet;
      final utilityDue = baseWater + utility.other;
      final totalDue = rentDue + utility.electricity + internetDue + utilityDue;
      final dueDay = row['due_day']! as int;
      final dueDate = DateTime(
        now.year,
        now.month,
        _clampDay(now.year, now.month, dueDay),
      );
      final status = _resolveCycleStatus(
        totalDue: totalDue,
        totalPaid: 0,
        dueDate: dueDate,
      );

      await db.insert('billing_cycles', {
        'id': _id('bc'),
        'property_id': row['property_id']! as String,
        'property_name': row['property_name']! as String,
        'room_id': roomId,
        'room_label': row['room_label']! as String,
        'tenant_id': tenantId,
        'tenant_name': row['tenant_name']! as String,
        'cycle_year': now.year,
        'cycle_month': now.month,
        'rent_due': rentDue,
        'electricity_due': utility.electricity,
        'internet_due': internetDue,
        'utility_due': utilityDue,
        'total_due': totalDue,
        'total_paid': 0,
        'status': status.name,
        'due_date': dueDate.toIso8601String(),
        'generated_at': now.toIso8601String(),
        'closed_at': null,
      });
    }

    final properties = await db.query('properties');
    for (final property in properties) {
      await _recalculatePropertyStats(db, property['id']! as String);
    }
  }

  Future<({double electricity, double internet, double other})>
  _calculateMonthlyUtilityForRoom(
    Database db,
    String roomId,
    DateTime now,
  ) async {
    final monthPrefix =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-';
    final rows = await db.query(
      'utility_records',
      where: 'room_id = ? AND recorded_at LIKE ?',
      whereArgs: [roomId, '$monthPrefix%'],
    );
    double electricity = 0;
    double internet = 0;
    double other = 0;
    for (final row in rows) {
      final amount = _toDouble(row['amount']);
      final type = row['type']! as String;
      if (type == UtilityType.electricity.name) {
        electricity += amount;
      } else if (type == UtilityType.internet.name) {
        internet += amount;
      } else {
        other += amount;
      }
    }
    return (electricity: electricity, internet: internet, other: other);
  }

  Future<void> _syncMonthlyUtilityForCycle(
    Database db,
    Map<String, Object?> cycle,
  ) async {
    final now = DateTime.now();
    if (cycle['cycle_year'] != now.year || cycle['cycle_month'] != now.month) {
      return;
    }
    final utility = await _calculateMonthlyUtilityForRoom(
      db,
      cycle['room_id']! as String,
      now,
    );
    final roomRows = await db.query(
      'rooms',
      where: 'id = ?',
      whereArgs: [cycle['room_id']],
      limit: 1,
    );
    final baseInternet = roomRows.isEmpty
        ? 0.0
        : _toDouble(roomRows.first['internet_cost']);
    final baseWater = roomRows.isEmpty
        ? 0.0
        : _toDouble(roomRows.first['water_cost']);
    final rentDue = _toDouble(cycle['rent_due']);
    final internetDue = baseInternet + utility.internet;
    final utilityDue = baseWater + utility.other;
    final totalDue = rentDue + internetDue + utility.electricity + utilityDue;
    final totalPaid = _toDouble(cycle['total_paid']);
    final dueDate = DateTime.parse(cycle['due_date']! as String);
    final status = _resolveCycleStatus(
      totalDue: totalDue,
      totalPaid: totalPaid,
      dueDate: dueDate,
    );
    await db.update(
      'billing_cycles',
      {
        'electricity_due': utility.electricity,
        'internet_due': internetDue,
        'utility_due': utilityDue,
        'total_due': totalDue,
        'status': status.name,
        'closed_at': status == BillingCycleStatus.paid
            ? DateTime.now().toIso8601String()
            : null,
      },
      where: 'id = ?',
      whereArgs: [cycle['id']],
    );
  }

  BillingCycleStatus _resolveCycleStatus({
    required double totalDue,
    required double totalPaid,
    required DateTime dueDate,
  }) {
    final now = DateTime.now();
    if (totalPaid >= totalDue && totalDue > 0) return BillingCycleStatus.paid;
    if (totalDue <= 0) return BillingCycleStatus.paid;
    if (totalPaid > 0 && totalPaid < totalDue) {
      return dueDate.isBefore(DateTime(now.year, now.month, now.day))
          ? BillingCycleStatus.overdue
          : BillingCycleStatus.partial;
    }
    return dueDate.isBefore(DateTime(now.year, now.month, now.day))
        ? BillingCycleStatus.overdue
        : BillingCycleStatus.pending;
  }

  int _clampDay(int year, int month, int day) {
    final nextMonth = month == 12
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);
    final lastDay = nextMonth.subtract(const Duration(days: 1)).day;
    if (day < 1) return 1;
    if (day > lastDay) return lastDay;
    return day;
  }

  Future<PortfolioSnapshot> loadSnapshot() async {
    final db = await database;
    await _ensureCurrentMonthBillingCycles(db);

    final propertyRows = await db.query('properties');
    final roomRows = await db.query('rooms');
    final tenantRows = await db.query('tenants');
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
    final cycleRows = await db.query(
      'billing_cycles',
      orderBy: 'generated_at DESC',
    );
    final paymentRows = await db.query('payments', orderBy: 'paid_at DESC');
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
        electricityRate: _toDouble(row['electricity_rate'] ?? 12),
        waterCost: _toDouble(row['water_cost'] ?? 50),
        internetCost: _toDouble(row['internet_cost'] ?? 500),
        status: PaymentStatus.values.byName(row['status']! as String),
        note: row['note']! as String,
      );
      roomsByProperty.putIfAbsent(room.propertyId, () => []).add(room);
    }

    final properties = propertyRows.map((row) {
      return RentalProperty(
        id: row['id']! as String,
        name: row['name']! as String,
        address: row['address']! as String,
        totalRooms: row['total_rooms']! as int,
        occupiedRooms: row['occupied_rooms']! as int,
        monthlyTarget: _toDouble(row['monthly_target']),
        totalDue: _toDouble(row['total_due']),
        rooms: roomsByProperty[row['id']! as String] ?? const [],
      );
    }).toList();

    final tenants = tenantRows.map((row) {
      return TenantProfile(
        id: row['id']! as String,
        roomId: row['room_id']! as String,
        propertyId: row['property_id']! as String,
        name: row['name']! as String,
        phone: row['phone']! as String,
        citizenshipNo: (row['citizenship_no'] ?? '') as String,
        moveInDate: DateTime.parse(row['move_in_date']! as String),
        emergencyContact: row['emergency_contact']! as String,
      );
    }).toList();

    final utilityRecords = utilityRecordRows.map((row) {
      return UtilityRecord(
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
      );
    }).toList();

    final documents = documentRows.map((row) {
      return DocumentRecord(
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
      );
    }).toList();

    final activities = activityRows.map((row) {
      return ActivityEntry(
        id: row['id']! as String,
        propertyId: row['property_id']! as String,
        title: row['title']! as String,
        detail: row['detail']! as String,
        createdAt: DateTime.parse(row['created_at']! as String),
      );
    }).toList();

    final billingCycles = cycleRows.map((row) {
      return BillingCycle(
        id: row['id']! as String,
        propertyId: row['property_id']! as String,
        propertyName: row['property_name']! as String,
        roomId: row['room_id']! as String,
        roomLabel: row['room_label']! as String,
        tenantId: row['tenant_id']! as String,
        tenantName: row['tenant_name']! as String,
        cycleYear: row['cycle_year']! as int,
        cycleMonth: row['cycle_month']! as int,
        rentDue: _toDouble(row['rent_due']),
        electricityDue: _toDouble(row['electricity_due']),
        internetDue: _toDouble(row['internet_due']),
        utilityDue: _toDouble(row['utility_due']),
        totalDue: _toDouble(row['total_due']),
        totalPaid: _toDouble(row['total_paid']),
        status: BillingCycleStatus.values.byName(row['status']! as String),
        dueDate: DateTime.parse(row['due_date']! as String),
        generatedAt: DateTime.parse(row['generated_at']! as String),
        closedAt: row['closed_at'] == null
            ? null
            : DateTime.parse(row['closed_at']! as String),
      );
    }).toList();

    final payments = paymentRows.map((row) {
      return PaymentRecord(
        id: row['id']! as String,
        billingCycleId: row['billing_cycle_id']! as String,
        tenantId: row['tenant_id']! as String,
        amount: _toDouble(row['amount']),
        method: row['method']! as String,
        note: row['note']! as String,
        isPartial: (row['is_partial']! as int) == 1,
        paidAt: DateTime.parse(row['paid_at']! as String),
      );
    }).toList();

    final revenue = _buildRevenuePointsFromCycles(billingCycles);
    final utilityUsage = _buildUtilityUsageFromRecords(utilityRecords);
    final receivables = _buildReceivablesFromCycles(billingCycles);
    final preferencesMap = {
      for (final row in preferenceRows)
        row['key']! as String: row['value']! as String,
    };

    return PortfolioSnapshot(
      properties: properties,
      tenants: tenants,
      revenue: revenue,
      billingCycles: billingCycles,
      payments: payments,
      utilityUsage: utilityUsage,
      utilityRecords: utilityRecords,
      documents: documents,
      activities: activities,
      pendingReceivables: receivables.pending,
      completedReceivables: receivables.completed,
      preferences: AppPreferences(
        currencyCode: preferencesMap['currency_code'] ?? 'NPR',
        reminderDay: int.tryParse(preferencesMap['reminder_day'] ?? '5') ?? 5,
        landlordName: preferencesMap['landlord_name'] ?? 'Aarav',
      ),
    );
  }

  ({List<PaymentReceivable> pending, List<PaymentReceivable> completed})
  _buildReceivablesFromCycles(List<BillingCycle> cycles) {
    final now = DateTime.now();
    final currentMonth = cycles
        .where(
          (cycle) =>
              cycle.cycleYear == now.year && cycle.cycleMonth == now.month,
        )
        .toList();

    final pending = <PaymentReceivable>[];
    final completed = <PaymentReceivable>[];
    for (final cycle in currentMonth) {
      final status = cycle.status == BillingCycleStatus.paid
          ? PaymentStatus.paid
          : cycle.status == BillingCycleStatus.partial
          ? PaymentStatus.partial
          : PaymentStatus.due;
      final remaining = (cycle.totalDue - cycle.totalPaid)
          .clamp(0.0, double.infinity)
          .toDouble();
      final dueLabel = cycle.status == BillingCycleStatus.paid
          ? 'Collected on ${cycle.closedAt?.toIso8601String().split('T').first ?? now.toIso8601String().split('T').first}'
          : cycle.status == BillingCycleStatus.overdue
          ? 'Overdue since ${cycle.dueDate.toIso8601String().split('T').first}'
          : 'Due on ${cycle.dueDate.toIso8601String().split('T').first}';

      final receivable = PaymentReceivable(
        id: cycle.id,
        propertyId: cycle.propertyId,
        propertyName: cycle.propertyName,
        roomId: cycle.roomId,
        roomLabel: cycle.roomLabel,
        amount: cycle.status == BillingCycleStatus.paid
            ? cycle.totalPaid
            : remaining,
        overdueLabel: dueLabel,
        tags: [
          'Rent ${cycle.rentDue.toStringAsFixed(0)}',
          'Electricity ${cycle.electricityDue.toStringAsFixed(0)}',
          'Internet ${cycle.internetDue.toStringAsFixed(0)}',
          'Utilities ${cycle.utilityDue.toStringAsFixed(0)}',
        ],
        status: status,
      );
      if (cycle.status == BillingCycleStatus.paid) {
        completed.add(receivable);
      } else {
        pending.add(receivable);
      }
    }
    return (pending: pending, completed: completed);
  }

  List<MonthlyRevenuePoint> _buildRevenuePointsFromCycles(
    List<BillingCycle> cycles,
  ) {
    final now = DateTime.now();
    final monthOrder = <DateTime>[
      for (var i = 5; i >= 0; i--) DateTime(now.year, now.month - i, 1),
    ];
    final labels = const [
      '',
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    return monthOrder.map((monthDate) {
      final amount = cycles
          .where(
            (cycle) =>
                cycle.cycleYear == monthDate.year &&
                cycle.cycleMonth == monthDate.month,
          )
          .fold<double>(0, (sum, cycle) => sum + cycle.totalPaid);
      return MonthlyRevenuePoint(
        month: labels[monthDate.month],
        amount: amount,
      );
    }).toList();
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
    } else {
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
    await _ensureCurrentMonthBillingCycles(db);
  }

  Future<void> deleteProperty(String propertyId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'payments',
        where:
            'billing_cycle_id IN (SELECT id FROM billing_cycles WHERE property_id = ?)',
        whereArgs: [propertyId],
      );
      await txn.delete(
        'billing_cycles',
        where: 'property_id = ?',
        whereArgs: [propertyId],
      );
      await txn.delete(
        'electricity_readings',
        where: 'property_id = ?',
        whereArgs: [propertyId],
      );
      await txn.delete(
        'documents',
        where: 'property_id = ?',
        whereArgs: [propertyId],
      );
      await txn.delete(
        'utility_records',
        where: 'property_id = ?',
        whereArgs: [propertyId],
      );
      await txn.delete(
        'activities',
        where: 'property_id = ?',
        whereArgs: [propertyId],
      );
      await txn.delete(
        'tenants',
        where: 'property_id = ?',
        whereArgs: [propertyId],
      );
      await txn.delete(
        'rooms',
        where: 'property_id = ?',
        whereArgs: [propertyId],
      );
      await txn.delete('properties', where: 'id = ?', whereArgs: [propertyId]);
    });
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
        'electricity_rate': draft.electricityRate,
        'water_cost': draft.waterCost,
        'internet_cost': draft.internetCost,
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
          'electricity_rate': draft.electricityRate,
          'water_cost': draft.waterCost,
          'internet_cost': draft.internetCost,
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
    await _ensureCurrentMonthBillingCycles(db);
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

    final now = DateTime.now();
    final cycle = await db.query(
      'billing_cycles',
      where: 'room_id = ? AND cycle_year = ? AND cycle_month = ?',
      whereArgs: [draft.roomId, now.year, now.month],
      limit: 1,
    );
    if (cycle.isNotEmpty) {
      await _syncMonthlyUtilityForCycle(db, cycle.first);
    }

    await _addActivity(
      db,
      propertyId: draft.propertyId,
      title: 'Utility logged',
      detail: '${draft.type.name} bill for room ${draft.roomLabel} recorded.',
    );
    await _recalculatePropertyStats(db, draft.propertyId);
  }

  Future<List<ElectricityReading>> loadElectricityReadingsForRoom(
    String roomId,
  ) async {
    final db = await database;
    final rows = await db.query(
      'electricity_readings',
      where: 'room_id = ?',
      whereArgs: [roomId],
      orderBy: 'recorded_at DESC',
    );
    return rows.map((row) {
      return ElectricityReading(
        id: row['id']! as String,
        propertyId: row['property_id']! as String,
        propertyName: row['property_name']! as String,
        roomId: row['room_id']! as String,
        roomLabel: row['room_label']! as String,
        tenantName: row['tenant_name']! as String,
        previousReading: _toDouble(row['previous_reading']),
        currentReading: _toDouble(row['current_reading']),
        unitsConsumed: _toDouble(row['units_consumed']),
        rate: _toDouble(row['rate']),
        totalCost: _toDouble(row['total_cost']),
        recordedAt: DateTime.parse(row['recorded_at']! as String),
        imagePath: row['image_path'] as String?,
        note: row['note']! as String,
      );
    }).toList();
  }

  Future<void> saveElectricityReading(ElectricityReadingDraft draft) async {
    final db = await database;
    if (draft.currentReading < 0) {
      throw StateError('Current reading cannot be negative.');
    }
    if (draft.rate <= 0) {
      throw StateError('Electricity rate must be greater than zero.');
    }

    final latestRows = await db.query(
      'electricity_readings',
      where: 'room_id = ?',
      whereArgs: [draft.roomId],
      orderBy: 'recorded_at DESC',
      limit: 1,
    );
    final previous = latestRows.isEmpty
        ? 0.0
        : _toDouble(latestRows.first['current_reading']);
    if (draft.currentReading < previous) {
      throw StateError(
        'Current reading cannot be less than previous reading (${previous.toStringAsFixed(1)}).',
      );
    }

    final unitsConsumed = draft.currentReading - previous;
    final totalCost = unitsConsumed * draft.rate;

    await db.insert('electricity_readings', {
      'id': _id('er'),
      'property_id': draft.propertyId,
      'property_name': draft.propertyName,
      'room_id': draft.roomId,
      'room_label': draft.roomLabel,
      'tenant_name': draft.tenantName,
      'previous_reading': previous,
      'current_reading': draft.currentReading,
      'units_consumed': unitsConsumed,
      'rate': draft.rate,
      'total_cost': totalCost,
      'image_path': draft.imagePath,
      'note': draft.note,
      'recorded_at': draft.recordedAt.toIso8601String(),
    });

    await db.insert('utility_records', {
      'id': _id('u'),
      'property_id': draft.propertyId,
      'property_name': draft.propertyName,
      'room_id': draft.roomId,
      'room_label': draft.roomLabel,
      'tenant_name': draft.tenantName,
      'type': UtilityType.electricity.name,
      'meter_reading': draft.currentReading,
      'amount': totalCost,
      'note': draft.note.isEmpty
          ? 'Units ${unitsConsumed.toStringAsFixed(1)} × Rate ${draft.rate.toStringAsFixed(2)}'
          : draft.note,
      'image_path': draft.imagePath,
      'recorded_at': draft.recordedAt.toIso8601String(),
    });

    final now = DateTime.now();
    final cycleRows = await db.query(
      'billing_cycles',
      where: 'room_id = ? AND cycle_year = ? AND cycle_month = ?',
      whereArgs: [draft.roomId, now.year, now.month],
      limit: 1,
    );
    if (cycleRows.isNotEmpty) {
      await _syncMonthlyUtilityForCycle(db, cycleRows.first);
    }

    await _addActivity(
      db,
      propertyId: draft.propertyId,
      title: 'Electricity reading saved',
      detail:
          'Room ${draft.roomLabel} • ${unitsConsumed.toStringAsFixed(1)} units • ${totalCost.toStringAsFixed(0)}',
    );
    await _recalculatePropertyStats(db, draft.propertyId);
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

  Future<void> updateDocument(String documentId, DocumentDraft draft) async {
    final db = await database;
    await db.update(
      'documents',
      {
        'property_id': draft.propertyId,
        'property_name': draft.propertyName,
        'room_id': draft.roomId,
        'room_label': draft.roomLabel,
        'title': draft.title,
        'category': draft.category,
        'file_path': draft.filePath,
        'note': draft.note,
      },
      where: 'id = ?',
      whereArgs: [documentId],
    );
    await _addActivity(
      db,
      propertyId: draft.propertyId,
      title: 'Document updated',
      detail: '${draft.title} updated for room ${draft.roomLabel}.',
    );
  }

  Future<void> deleteDocument(String documentId) async {
    final db = await database;
    final rows = await db.query(
      'documents',
      where: 'id = ?',
      whereArgs: [documentId],
      limit: 1,
    );
    if (rows.isEmpty) return;
    final row = rows.first;
    await db.delete('documents', where: 'id = ?', whereArgs: [documentId]);
    await _addActivity(
      db,
      propertyId: row['property_id']! as String,
      title: 'Document deleted',
      detail: '${row['title']} deleted from room ${row['room_label']}.',
    );
  }

  Future<void> markReceivablePaid(String receivableId) async {
    await _recordCyclePayment(
      receivableId: receivableId,
      amount: null,
      method: 'cash',
      note: 'Marked paid from app',
    );
  }

  Future<void> recordPartialPayment(String receivableId, double amount) async {
    await _recordCyclePayment(
      receivableId: receivableId,
      amount: amount,
      method: 'cash',
      note: 'Partial payment from app',
    );
  }

  Future<void> _recordCyclePayment({
    required String receivableId,
    required double? amount,
    required String method,
    required String note,
  }) async {
    final db = await database;
    final cycleRows = await db.query(
      'billing_cycles',
      where: 'id = ?',
      whereArgs: [receivableId],
      limit: 1,
    );
    if (cycleRows.isEmpty) return;
    final cycle = cycleRows.first;
    final totalDue = _toDouble(cycle['total_due']);
    final totalPaid = _toDouble(cycle['total_paid']);
    final remainder = (totalDue - totalPaid).clamp(0.0, double.infinity);
    if (remainder <= 0) return;
    final paymentAmount = amount ?? remainder;
    if (paymentAmount <= 0) {
      throw StateError('Payment amount must be greater than zero.');
    }
    if (paymentAmount > remainder) {
      throw StateError('Payment amount cannot exceed pending amount.');
    }
    final nextTotalPaid = (totalPaid + paymentAmount).clamp(
      0.0,
      double.infinity,
    );
    final dueDate = DateTime.parse(cycle['due_date']! as String);
    final nextStatus = _resolveCycleStatus(
      totalDue: totalDue,
      totalPaid: nextTotalPaid,
      dueDate: dueDate,
    );
    final isPartial = nextStatus != BillingCycleStatus.paid ? 1 : 0;

    await db.insert('payments', {
      'id': _id('pay'),
      'billing_cycle_id': cycle['id']! as String,
      'tenant_id': cycle['tenant_id']! as String,
      'amount': paymentAmount,
      'method': method,
      'note': note,
      'is_partial': isPartial,
      'paid_at': DateTime.now().toIso8601String(),
    });

    await db.update(
      'billing_cycles',
      {
        'total_paid': nextTotalPaid,
        'status': nextStatus.name,
        'closed_at': nextStatus == BillingCycleStatus.paid
            ? DateTime.now().toIso8601String()
            : null,
      },
      where: 'id = ?',
      whereArgs: [receivableId],
    );

    await _addActivity(
      db,
      propertyId: cycle['property_id']! as String,
      title: 'Payment received',
      detail:
          '${cycle['room_label']} payment of ${paymentAmount.toStringAsFixed(0)} recorded.',
    );
    await _recalculatePropertyStats(db, cycle['property_id']! as String);
  }

  Future<void> _upsertTenantFromRoom(
    Database db,
    String roomId,
    RoomDraft room,
  ) async {
    if (room.tenantName.trim().isEmpty) {
      await db.delete('tenants', where: 'room_id = ?', whereArgs: [roomId]);
      return;
    }
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
        'phone': room.tenantPhone,
        'citizenship_no': room.citizenshipNo,
        'move_in_date': room.moveInDate.toIso8601String(),
        'emergency_contact': '',
      });
      return;
    }
    await db.update(
      'tenants',
      {
        'name': room.tenantName,
        'phone': room.tenantPhone,
        'citizenship_no': room.citizenshipNo,
        'move_in_date': room.moveInDate.toIso8601String(),
      },
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
    final now = DateTime.now();
    final cycles = await db.query(
      'billing_cycles',
      where: 'property_id = ? AND cycle_year = ? AND cycle_month = ?',
      whereArgs: [propertyId, now.year, now.month],
    );

    final occupied = rooms.where((row) {
      final tenant = (row['tenant_name'] as String?)?.trim() ?? '';
      return tenant.isNotEmpty;
    }).length;

    final due = cycles.fold<double>(0, (sum, cycle) {
      final totalDue = _toDouble(cycle['total_due']);
      final paid = _toDouble(cycle['total_paid']);
      return sum + (totalDue - paid).clamp(0, double.infinity);
    });

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

  Future<String> createBackupFile() async {
    return _writeDataFile(prefix: 'backup');
  }

  Future<String> exportDataFile() async {
    return _writeDataFile(prefix: 'export');
  }

  Future<void> restoreDataFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw StateError('Backup file not found.');
    }
    final raw = await file.readAsString();
    final payload = jsonDecode(raw);
    if (payload is! Map<String, dynamic>) {
      throw StateError('Invalid backup format.');
    }
    final tables = payload['tables'];
    if (tables is! Map<String, dynamic>) {
      throw StateError('Invalid backup tables.');
    }

    final db = await database;
    await db.transaction((txn) async {
      const tableNames = [
        'payments',
        'electricity_readings',
        'billing_cycles',
        'documents',
        'utility_records',
        'activities',
        'tenants',
        'rooms',
        'properties',
        'preferences',
        'receivables',
        'revenue_points',
        'utility_usage',
      ];
      for (final table in tableNames) {
        await txn.delete(table);
      }

      for (final table in tableNames.reversed) {
        final rows = tables[table];
        if (rows is! List) continue;
        for (final row in rows) {
          if (row is! Map<String, dynamic>) continue;
          await txn.insert(
            table,
            row.map((key, value) => MapEntry(key, value as Object?)),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
    await _ensureCurrentMonthBillingCycles(db);
  }

  Future<String> _writeDataFile({required String prefix}) async {
    final db = await database;
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final directory = await getApplicationDocumentsDirectory();
    final folder = Directory('${directory.path}/$prefix');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    final file = File('${folder.path}/kothabhada_${prefix}_$timestamp.json');
    final data = await _buildDataPayload(db);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
      flush: true,
    );
    return file.path;
  }

  Future<Map<String, dynamic>> _buildDataPayload(Database db) async {
    Future<List<Map<String, Object?>>> rows(String table) => db.query(table);
    return {
      'version': 1,
      'generated_at': DateTime.now().toIso8601String(),
      'tables': {
        'properties': await rows('properties'),
        'rooms': await rows('rooms'),
        'tenants': await rows('tenants'),
        'utility_records': await rows('utility_records'),
        'documents': await rows('documents'),
        'activities': await rows('activities'),
        'billing_cycles': await rows('billing_cycles'),
        'payments': await rows('payments'),
        'electricity_readings': await rows('electricity_readings'),
        'preferences': await rows('preferences'),
        'receivables': await rows('receivables'),
        'revenue_points': await rows('revenue_points'),
        'utility_usage': await rows('utility_usage'),
      },
    };
  }
}
