import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'database/app_database.dart';
import 'models/models.dart';

/// An immutable snapshot of the whole portfolio, loaded in one pass and held by
/// the [PortfolioNotifier]. Per-room details (electricity/utility/documents)
/// are fetched lazily via the repository.
class PortfolioSnapshot {
  const PortfolioSnapshot({
    required this.houses,
    required this.rooms,
    required this.tenants,
    required this.payments,
    required this.settings,
  });

  final List<House> houses;
  final List<Room> rooms;
  final List<Tenant> tenants;
  final List<Payment> payments;
  final Map<String, String> settings;

  List<Room> roomsOf(String houseId) =>
      rooms.where((r) => r.houseId == houseId).toList();

  Tenant? activeTenantOf(String roomId) {
    for (final t in tenants) {
      if (t.roomId == roomId && t.isActive) return t;
    }
    return null;
  }

  List<Tenant> historyOf(String roomId) =>
      tenants.where((t) => t.roomId == roomId).toList()
        ..sort((a, b) => b.moveInDate.compareTo(a.moveInDate));

  House? houseOf(String houseId) {
    for (final h in houses) {
      if (h.id == houseId) return h;
    }
    return null;
  }

  Room? roomOf(String roomId) {
    for (final r in rooms) {
      if (r.id == roomId) return r;
    }
    return null;
  }

  Tenant? tenantById(String tenantId) {
    for (final t in tenants) {
      if (t.id == tenantId) return t;
    }
    return null;
  }

  House? houseOfRoom(String roomId) {
    final room = roomOf(roomId);
    return room == null ? null : houseOf(room.houseId);
  }

  List<Payment> paymentsForMonth(String billingMonth) =>
      payments.where((p) => p.billingMonth == billingMonth).toList();

  String get currency => settings['currency_code'] ?? 'NPR';
  String get landlordName => settings['landlord_name'] ?? 'Landlord';
}

/// Data-access + business logic over [AppDatabase]. All mutation methods leave
/// the database in a consistent state; the notifier reloads a fresh snapshot
/// after each call.
class RentalRepository {
  RentalRepository(this._database);

  final AppDatabase _database;
  int _counter = 0;

  String _uid(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_counter++}';

  Future<Database> get _db => _database.db;

  // ── Load ────────────────────────────────────────────────────────
  Future<PortfolioSnapshot> loadSnapshot() async {
    final db = await _db;
    // Ensure current-month payment rows exist for every occupied room.
    await _ensureCurrentMonthPayments(db);

    final houses = (await db.query('houses', orderBy: 'created_at'))
        .map(House.fromMap)
        .toList();
    final rooms = (await db.query('rooms', orderBy: 'room_number'))
        .map(Room.fromMap)
        .toList();
    final tenants =
        (await db.query('tenants')).map(Tenant.fromMap).toList();
    final payments = (await db.query('payments', orderBy: 'billing_month DESC'))
        .map(Payment.fromMap)
        .toList();
    final settingsRows = await db.query('settings');
    final settings = {
      for (final row in settingsRows)
        row['key']! as String: row['value']! as String,
    };

    return PortfolioSnapshot(
      houses: houses,
      rooms: rooms,
      tenants: tenants,
      payments: payments,
      settings: settings,
    );
  }

  Future<List<ElectricityReading>> electricityForRoom(String roomId) async {
    final db = await _db;
    final rows = await db.query('electricity_readings',
        where: 'room_id = ?', whereArgs: [roomId], orderBy: 'recorded_at DESC');
    return rows.map(ElectricityReading.fromMap).toList();
  }

  Future<List<UtilityCharge>> utilitiesForRoom(String roomId) async {
    final db = await _db;
    final rows = await db.query('utility_charges',
        where: 'room_id = ?', whereArgs: [roomId], orderBy: 'recorded_at DESC');
    return rows.map(UtilityCharge.fromMap).toList();
  }

  Future<List<Document>> documents() async {
    final db = await _db;
    final rows = await db.query('documents', orderBy: 'created_at DESC');
    return rows.map(Document.fromMap).toList();
  }

  // ── Houses ──────────────────────────────────────────────────────
  Future<void> saveHouse({
    String? id,
    required String name,
    required String address,
    required double electricityRate,
  }) async {
    final db = await _db;
    if (id == null) {
      await db.insert('houses', {
        'id': _uid('h'),
        'name': name,
        'address': address,
        'electricity_rate_per_unit': electricityRate,
        'created_at': DateTime.now().toIso8601String(),
      });
    } else {
      await db.update(
        'houses',
        {
          'name': name,
          'address': address,
          'electricity_rate_per_unit': electricityRate,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> deleteHouse(String houseId) async {
    final db = await _db;
    // ON DELETE CASCADE removes rooms/tenants/readings/charges/payments.
    await db.delete('houses', where: 'id = ?', whereArgs: [houseId]);
  }

  // ── Rooms ───────────────────────────────────────────────────────
  Future<String> saveRoom({
    String? id,
    required String houseId,
    required String roomNumber,
    required double monthlyRent,
  }) async {
    final db = await _db;
    if (id == null) {
      final newId = _uid('r');
      await db.insert('rooms', {
        'id': newId,
        'house_id': houseId,
        'room_number': roomNumber,
        'monthly_rent': monthlyRent,
        'status': 'vacant',
        'created_at': DateTime.now().toIso8601String(),
      });
      return newId;
    }
    await db.update(
      'rooms',
      {'room_number': roomNumber, 'monthly_rent': monthlyRent},
      where: 'id = ?',
      whereArgs: [id],
    );
    return id;
  }

  Future<void> deleteRoom(String roomId) async {
    final db = await _db;
    await db.delete('rooms', where: 'id = ?', whereArgs: [roomId]);
  }

  // ── Tenants ─────────────────────────────────────────────────────
  Future<void> addTenant({
    required String roomId,
    required String fullName,
    required String phone,
    required DateTime moveInDate,
    String? idDocumentPhotoPath,
    String citizenshipNo = '',
    String emergencyContact = '',
  }) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.insert('tenants', {
        'id': _uid('t'),
        'room_id': roomId,
        'full_name': fullName,
        'phone': phone,
        'move_in_date': moveInDate.toIso8601String(),
        'move_out_date': null,
        'id_document_photo_path': idDocumentPhotoPath,
        'citizenship_no': citizenshipNo,
        'emergency_contact': emergencyContact,
        'is_active': 1,
      });
      await txn.update('rooms', {'status': 'occupied'},
          where: 'id = ?', whereArgs: [roomId]);
    });
  }

  Future<void> updateTenant({
    required String tenantId,
    required String fullName,
    required String phone,
    String citizenshipNo = '',
    String emergencyContact = '',
  }) async {
    final db = await _db;
    await db.update(
      'tenants',
      {
        'full_name': fullName,
        'phone': phone,
        'citizenship_no': citizenshipNo,
        'emergency_contact': emergencyContact,
      },
      where: 'id = ?',
      whereArgs: [tenantId],
    );
  }

  /// Move-out: keeps the tenant row (history) but marks it inactive and frees
  /// the room. Per PRD §5.2 tenant history is retained, not deleted.
  Future<void> moveOutTenant(String tenantId) async {
    final db = await _db;
    final rows = await db
        .query('tenants', where: 'id = ?', whereArgs: [tenantId], limit: 1);
    if (rows.isEmpty) return;
    final roomId = rows.first['room_id']! as String;
    await db.transaction((txn) async {
      await txn.update(
        'tenants',
        {
          'is_active': 0,
          'move_out_date': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [tenantId],
      );
      await txn.update('rooms', {'status': 'vacant'},
          where: 'id = ?', whereArgs: [roomId]);
    });
  }

  // ── Electricity ─────────────────────────────────────────────────
  Future<ElectricityReading> saveElectricityReading({
    required String roomId,
    required double currentUnit,
    String? meterPhotoPath,
    DateTime? at,
  }) async {
    final db = await _db;
    final now = at ?? DateTime.now();
    final month = billingMonthOf(now);

    final room = Room.fromMap(
        (await db.query('rooms', where: 'id = ?', whereArgs: [roomId])).first);
    final house = House.fromMap((await db
            .query('houses', where: 'id = ?', whereArgs: [room.houseId]))
        .first);

    // Previous reading = most recent current_unit for this room.
    final prevRows = await db.query('electricity_readings',
        where: 'room_id = ?',
        whereArgs: [roomId],
        orderBy: 'recorded_at DESC',
        limit: 1);
    final previous =
        prevRows.isEmpty ? 0.0 : (prevRows.first['current_unit'] as num).toDouble();
    if (currentUnit < previous) {
      throw StateError(
          'Current reading ($currentUnit) cannot be less than previous ($previous).');
    }
    final rate = house.electricityRatePerUnit;
    if (rate <= 0) {
      throw StateError('Set an electricity rate on the house first.');
    }
    final units = currentUnit - previous;
    final amount = units * rate;

    final reading = ElectricityReading(
      id: _uid('e'),
      roomId: roomId,
      billingMonth: month,
      previousUnit: previous,
      currentUnit: currentUnit,
      unitsConsumed: units,
      rateUsed: rate,
      amount: amount,
      meterPhotoPath: meterPhotoPath,
      recordedAt: now,
    );
    await db.insert('electricity_readings', reading.toMap());
    await _recomputePayment(db, roomId, month);
    return reading;
  }

  // ── Utilities ───────────────────────────────────────────────────
  Future<void> addUtilityCharge({
    required String roomId,
    required UtilityType type,
    required double amount,
    String note = '',
    DateTime? at,
  }) async {
    final db = await _db;
    final now = at ?? DateTime.now();
    final month = billingMonthOf(now);
    await db.insert('utility_charges', {
      'id': _uid('u'),
      'room_id': roomId,
      'type': type.name,
      'billing_month': month,
      'amount': amount,
      'note': note,
      'recorded_at': now.toIso8601String(),
    });
    await _recomputePayment(db, roomId, month);
  }

  // ── Payments ────────────────────────────────────────────────────
  Future<void> markPaid(String paymentId) async {
    final db = await _db;
    final rows = await db
        .query('payments', where: 'id = ?', whereArgs: [paymentId], limit: 1);
    if (rows.isEmpty) return;
    final payment = Payment.fromMap(rows.first);
    await db.update(
      'payments',
      {
        'amount_paid': payment.totalDue,
        'status': PaymentStatus.paid.name,
        'paid_date': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [paymentId],
    );
  }

  Future<void> recordPartialPayment(String paymentId, double amount) async {
    final db = await _db;
    final rows = await db
        .query('payments', where: 'id = ?', whereArgs: [paymentId], limit: 1);
    if (rows.isEmpty) return;
    final payment = Payment.fromMap(rows.first);
    if (amount <= 0) throw StateError('Amount must be greater than zero.');
    final nextPaid = (payment.amountPaid + amount);
    if (nextPaid > payment.totalDue + 0.001) {
      throw StateError('Amount exceeds the pending total.');
    }
    final paid = nextPaid >= payment.totalDue;
    await db.update(
      'payments',
      {
        'amount_paid': nextPaid,
        'status': paid ? PaymentStatus.paid.name : PaymentStatus.partial.name,
        'paid_date': paid ? DateTime.now().toIso8601String() : null,
      },
      where: 'id = ?',
      whereArgs: [paymentId],
    );
  }

  // ── Documents ───────────────────────────────────────────────────
  Future<void> addDocument({
    String? tenantId,
    String? houseId,
    required String title,
    required String filePath,
    required DocumentType type,
  }) async {
    final db = await _db;
    await db.insert('documents', {
      'id': _uid('d'),
      'tenant_id': tenantId,
      'house_id': houseId,
      'title': title,
      'file_path': filePath,
      'type': type.name,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteDocument(String id) async {
    final db = await _db;
    await db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }

  /// Copies a picked file into the app's private `documents/` directory so the
  /// backup/restore and viewer keep working even if the original is removed.
  Future<String> storeDocumentFile(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/documents');
    if (!await folder.exists()) await folder.create(recursive: true);
    final name = sourcePath.split(Platform.pathSeparator).last;
    final dest =
        '${folder.path}/${DateTime.now().microsecondsSinceEpoch}_$name';
    await File(sourcePath).copy(dest);
    return dest;
  }

  // ── Settings ────────────────────────────────────────────────────
  Future<void> setSetting(String key, String value) async {
    final db = await _db;
    await db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final db = await _db;
    final rows =
        await db.query('settings', where: 'key = ?', whereArgs: [key], limit: 1);
    return rows.isEmpty ? null : rows.first['value'] as String?;
  }

  // ── Backup / Restore (PRD §5.8) ─────────────────────────────────
  static const _backupTables = [
    'houses',
    'rooms',
    'tenants',
    'electricity_readings',
    'utility_charges',
    'payments',
    'documents',
    'settings',
  ];

  Future<String> exportToFile() async {
    final db = await _db;
    final data = <String, Object?>{
      'version': 1,
      'generated_at': DateTime.now().toIso8601String(),
      'tables': {
        for (final t in _backupTables) t: await db.query(t),
      },
    };
    final dir = await getApplicationDocumentsDirectory();
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final file = File('${dir.path}/kothabhada_backup_$stamp.json');
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
      flush: true,
    );
    return file.path;
  }

  Future<void> importFromFile(String path) async {
    final file = File(path);
    if (!await file.exists()) throw StateError('Backup file not found.');
    final payload = jsonDecode(await file.readAsString());
    if (payload is! Map || payload['tables'] is! Map) {
      throw StateError('Invalid backup format.');
    }
    final tables = payload['tables'] as Map;
    final db = await _db;
    await db.transaction((txn) async {
      for (final t in _backupTables) {
        await txn.delete(t);
      }
      for (final t in _backupTables) {
        final rows = tables[t];
        if (rows is! List) continue;
        for (final row in rows) {
          if (row is! Map) continue;
          await txn.insert(
            t,
            row.map((k, v) => MapEntry(k.toString(), v as Object?)),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  // ── Internals ───────────────────────────────────────────────────
  Future<void> _ensureCurrentMonthPayments(Database db) async {
    final month = billingMonthOf(DateTime.now());
    final occupiedRooms = await db.rawQuery('''
      SELECT r.id AS room_id, r.monthly_rent, t.id AS tenant_id
      FROM rooms r
      JOIN tenants t ON t.room_id = r.id AND t.is_active = 1
      WHERE r.status = 'occupied'
    ''');
    for (final row in occupiedRooms) {
      final roomId = row['room_id']! as String;
      final existing = await db.query('payments',
          where: 'room_id = ? AND billing_month = ?',
          whereArgs: [roomId, month],
          limit: 1);
      if (existing.isEmpty) {
        await _recomputePayment(db, roomId, month,
            tenantId: row['tenant_id'] as String?);
      } else {
        await _recomputePayment(db, roomId, month);
      }
    }
  }

  /// Recomputes the due amounts for a room's monthly payment from rent +
  /// electricity + utilities, preserving any amount already paid.
  Future<void> _recomputePayment(
    Database db,
    String roomId,
    String month, {
    String? tenantId,
  }) async {
    final roomRows =
        await db.query('rooms', where: 'id = ?', whereArgs: [roomId], limit: 1);
    if (roomRows.isEmpty) return;
    final room = Room.fromMap(roomRows.first);

    final elec = await db.rawQuery(
      'SELECT COALESCE(SUM(amount),0) AS s FROM electricity_readings WHERE room_id = ? AND billing_month = ?',
      [roomId, month],
    );
    final util = await db.rawQuery(
      'SELECT COALESCE(SUM(amount),0) AS s FROM utility_charges WHERE room_id = ? AND billing_month = ?',
      [roomId, month],
    );
    final electricityDue = (elec.first['s'] as num).toDouble();
    final utilityDue = (util.first['s'] as num).toDouble();
    final rentDue = room.monthlyRent;
    final totalDue = rentDue + electricityDue + utilityDue;

    final existing = await db.query('payments',
        where: 'room_id = ? AND billing_month = ?',
        whereArgs: [roomId, month],
        limit: 1);

    final now = DateTime.now();
    final dueDate = DateTime(
        firstDayOfBillingMonth(month).year,
        firstDayOfBillingMonth(month).month,
        5);

    if (existing.isEmpty) {
      final resolvedTenant = tenantId ??
          (await db.query('tenants',
                  where: 'room_id = ? AND is_active = 1',
                  whereArgs: [roomId],
                  limit: 1))
              .let((rows) => rows.isEmpty ? '' : rows.first['id'] as String);
      await db.insert('payments', {
        'id': _uid('p'),
        'room_id': roomId,
        'tenant_id': resolvedTenant,
        'billing_month': month,
        'rent_due': rentDue,
        'electricity_due': electricityDue,
        'utility_due': utilityDue,
        'total_due': totalDue,
        'amount_paid': 0,
        'status': _statusFor(0, totalDue, dueDate, now),
        'paid_date': null,
        'due_date': dueDate.toIso8601String(),
      });
    } else {
      final current = Payment.fromMap(existing.first);
      await db.update(
        'payments',
        {
          'rent_due': rentDue,
          'electricity_due': electricityDue,
          'utility_due': utilityDue,
          'total_due': totalDue,
          'status': _statusFor(current.amountPaid, totalDue, dueDate, now),
          'paid_date': current.amountPaid >= totalDue && totalDue > 0
              ? (current.paidDate ?? now).toIso8601String()
              : null,
        },
        where: 'id = ?',
        whereArgs: [current.id],
      );
    }
  }

  String _statusFor(
      double paid, double total, DateTime dueDate, DateTime now) {
    if (total > 0 && paid >= total) return PaymentStatus.paid.name;
    if (paid > 0) return PaymentStatus.partial.name;
    return PaymentStatus.due.name;
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) op) => op(this);
}
