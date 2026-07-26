import 'package:sqflite/sqflite.dart';

/// Seeds demo data that mirrors the design mockup (Sunrise Apartment,
/// Green Valley House, Riverside Flats). Runs once on database creation.
Future<void> seedDatabase(Database db) async {
  final now = DateTime.now();
  final month =
      '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
  final dueDate = DateTime(now.year, now.month, 5).toIso8601String();

  final batch = db.batch();
  var seq = 0;
  String id(String prefix) => '$prefix-${(seq++).toString().padLeft(3, '0')}';

  // House specs: name, address, rate/unit, and rooms (number, rent, tenant?).
  final houses = <_HouseSpec>[
    _HouseSpec('Sunrise Apartment', 'Baneshwor', 13, [
      _RoomSpec('1A', 12000, 'Sagar Thapa', '9841000001'),
      _RoomSpec('1B', 11000, 'Anita Rai', '9841000002'),
      _RoomSpec('2A', 13500, 'Bikash Gurung', '9841000003'),
      _RoomSpec('2B', 12500, 'Sita Karki', '9841000004'),
      _RoomSpec('3A', 14000, 'Ramesh Shah', '9841000005'),
      _RoomSpec('3B', 12000, null, null),
    ]),
    _HouseSpec('Green Valley House', 'Lalitpur', 12, [
      _RoomSpec('G1', 9000, 'Prakash Lama', '9841000006'),
      _RoomSpec('G2', 9500, 'Mina Tamang', '9841000007'),
      _RoomSpec('F1', 15000, 'Deepak Adhikari', '9841000008'),
      _RoomSpec('F2', 15000, null, null),
    ]),
    _HouseSpec('Riverside Flats', 'Chabahil', 12, [
      _RoomSpec('101', 10000, 'Sunita Magar', '9841000009'),
      _RoomSpec('102', 10500, 'Hari Bhandari', '9841000010'),
      _RoomSpec('201', 11500, 'Gita Sharma', '9841000011'),
      _RoomSpec('202', 11500, 'Kamal Basnet', '9841000012'),
    ]),
  ];

  var occupiedIndex = 0;
  for (final h in houses) {
    final houseId = id('h');
    batch.insert('houses', {
      'id': houseId,
      'name': h.name,
      'address': h.address,
      'electricity_rate_per_unit': h.rate,
      'created_at': now.toIso8601String(),
    });

    for (final r in h.rooms) {
      final roomId = id('r');
      final occupied = r.tenant != null;
      batch.insert('rooms', {
        'id': roomId,
        'house_id': houseId,
        'room_number': r.number,
        'monthly_rent': r.rent,
        'status': occupied ? 'occupied' : 'vacant',
        'created_at': now.toIso8601String(),
      });

      if (!occupied) continue;

      final tenantId = id('t');
      batch.insert('tenants', {
        'id': tenantId,
        'room_id': roomId,
        'full_name': r.tenant,
        'phone': r.phone,
        'move_in_date':
            DateTime(now.year - 1, ((occupiedIndex % 12) + 1), 1)
                .toIso8601String(),
        'move_out_date': null,
        'citizenship_no': '',
        'emergency_contact': '',
        'is_active': 1,
      });

      // Electricity reading for the current month.
      final prev = 100.0 + occupiedIndex * 40;
      final units = 45.0 + (occupiedIndex % 5) * 12;
      final elecAmount = units * h.rate;
      batch.insert('electricity_readings', {
        'id': id('e'),
        'room_id': roomId,
        'billing_month': month,
        'previous_unit': prev,
        'current_unit': prev + units,
        'units_consumed': units,
        'rate_used': h.rate,
        'amount': elecAmount,
        'meter_photo_path': null,
        'recorded_at': now.toIso8601String(),
      });

      // Utilities: internet (flat) + water.
      const internet = 500.0;
      const water = 300.0;
      batch.insert('utility_charges', {
        'id': id('u'),
        'room_id': roomId,
        'type': 'internet',
        'billing_month': month,
        'amount': internet,
        'note': '',
        'recorded_at': now.toIso8601String(),
      });
      batch.insert('utility_charges', {
        'id': id('u'),
        'room_id': roomId,
        'type': 'water',
        'billing_month': month,
        'amount': water,
        'note': '',
        'recorded_at': now.toIso8601String(),
      });

      final utilityDue = internet + water;
      final totalDue = r.rent + elecAmount + utilityDue;

      // Distribute statuses: most paid, a couple partial, a couple due.
      final mod = occupiedIndex % 4;
      final double amountPaid;
      final String status;
      final String? paidDate;
      if (mod == 3) {
        amountPaid = 0;
        status = 'due';
        paidDate = null;
      } else if (mod == 2) {
        amountPaid = (totalDue * 0.5).roundToDouble();
        status = 'partial';
        paidDate = null;
      } else {
        amountPaid = totalDue;
        status = 'paid';
        paidDate = DateTime(now.year, now.month, 3).toIso8601String();
      }

      batch.insert('payments', {
        'id': id('p'),
        'room_id': roomId,
        'tenant_id': tenantId,
        'billing_month': month,
        'rent_due': r.rent,
        'electricity_due': elecAmount,
        'utility_due': utilityDue,
        'total_due': totalDue,
        'amount_paid': amountPaid,
        'status': status,
        'paid_date': paidDate,
        'due_date': dueDate,
      });

      occupiedIndex++;
    }
  }

  batch.insert('settings', {'key': 'currency_code', 'value': 'NPR'});
  batch.insert('settings', {'key': 'landlord_name', 'value': 'Sagar Thapa'});
  batch.insert('settings', {'key': 'reminder_day', 'value': '5'});

  await batch.commit(noResult: true);
}

class _HouseSpec {
  _HouseSpec(this.name, this.address, this.rate, this.rooms);
  final String name;
  final String address;
  final double rate;
  final List<_RoomSpec> rooms;
}

class _RoomSpec {
  _RoomSpec(this.number, this.rent, this.tenant, this.phone);
  final String number;
  final double rent;
  final String? tenant;
  final String? phone;
}
