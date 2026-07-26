import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'seed.dart';

/// The v2 sqflite database, following the PRD v2 schema:
/// houses, rooms, tenants, electricity_readings, utility_charges, payments,
/// documents, plus a key/value `settings` table.
///
/// A fresh database file (`kothabhada_v2.db`) is used so the redesign starts on
/// the clean PRD schema rather than migrating the older denormalized tables.
class AppDatabase {
  AppDatabase({this.seedOnCreate = true});

  final bool seedOnCreate;
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    _db = await openDatabase(
      p.join(dir.path, 'kothabhada_v2.db'),
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) async {
        await _createSchema(db);
        if (seedOnCreate) await seedDatabase(db);
      },
    );
    return _db!;
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE houses(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT NOT NULL DEFAULT '',
        electricity_rate_per_unit REAL NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )''');

    await db.execute('''
      CREATE TABLE rooms(
        id TEXT PRIMARY KEY,
        house_id TEXT NOT NULL REFERENCES houses(id) ON DELETE CASCADE,
        room_number TEXT NOT NULL,
        monthly_rent REAL NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'vacant',
        created_at TEXT NOT NULL
      )''');

    await db.execute('''
      CREATE TABLE tenants(
        id TEXT PRIMARY KEY,
        room_id TEXT NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
        full_name TEXT NOT NULL,
        phone TEXT NOT NULL DEFAULT '',
        move_in_date TEXT NOT NULL,
        move_out_date TEXT,
        id_document_photo_path TEXT,
        citizenship_no TEXT NOT NULL DEFAULT '',
        emergency_contact TEXT NOT NULL DEFAULT '',
        is_active INTEGER NOT NULL DEFAULT 1
      )''');

    await db.execute('''
      CREATE TABLE electricity_readings(
        id TEXT PRIMARY KEY,
        room_id TEXT NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
        billing_month TEXT NOT NULL,
        previous_unit REAL NOT NULL DEFAULT 0,
        current_unit REAL NOT NULL DEFAULT 0,
        units_consumed REAL NOT NULL DEFAULT 0,
        rate_used REAL NOT NULL DEFAULT 0,
        amount REAL NOT NULL DEFAULT 0,
        meter_photo_path TEXT,
        recorded_at TEXT NOT NULL
      )''');

    await db.execute('''
      CREATE TABLE utility_charges(
        id TEXT PRIMARY KEY,
        room_id TEXT NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
        type TEXT NOT NULL,
        billing_month TEXT NOT NULL,
        amount REAL NOT NULL DEFAULT 0,
        note TEXT NOT NULL DEFAULT '',
        recorded_at TEXT NOT NULL
      )''');

    await db.execute('''
      CREATE TABLE payments(
        id TEXT PRIMARY KEY,
        room_id TEXT NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
        tenant_id TEXT NOT NULL,
        billing_month TEXT NOT NULL,
        rent_due REAL NOT NULL DEFAULT 0,
        electricity_due REAL NOT NULL DEFAULT 0,
        utility_due REAL NOT NULL DEFAULT 0,
        total_due REAL NOT NULL DEFAULT 0,
        amount_paid REAL NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'due',
        paid_date TEXT,
        due_date TEXT NOT NULL
      )''');

    await db.execute('''
      CREATE TABLE documents(
        id TEXT PRIMARY KEY,
        tenant_id TEXT,
        house_id TEXT,
        title TEXT NOT NULL,
        file_path TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'other',
        created_at TEXT NOT NULL
      )''');

    await db.execute('''
      CREATE TABLE settings(
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )''');

    // Indexes required by PRD §8.
    await db.execute('CREATE INDEX idx_rooms_house ON rooms(house_id)');
    await db.execute('CREATE INDEX idx_tenants_room ON tenants(room_id)');
    await db.execute(
        'CREATE INDEX idx_elec_room_month ON electricity_readings(room_id, billing_month)');
    await db.execute(
        'CREATE INDEX idx_util_room_month ON utility_charges(room_id, billing_month)');
    await db.execute(
        'CREATE INDEX idx_pay_room_month ON payments(room_id, billing_month)');
    await db.execute('CREATE INDEX idx_pay_month ON payments(billing_month)');
    await db
        .execute('CREATE INDEX idx_docs_tenant ON documents(tenant_id)');
    await db.execute('CREATE INDEX idx_docs_house ON documents(house_id)');
  }
}
