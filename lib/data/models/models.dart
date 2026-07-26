// Domain models for the Kothabhada v2 data layer, following the PRD v2 schema
// (houses / rooms / tenants / electricity_readings / utility_charges /
// payments / documents). All models are immutable and map 1:1 to sqflite rows
// via `fromMap` / `toMap`.

import 'package:flutter/foundation.dart';

enum RoomStatus { vacant, occupied }

enum PaymentStatus { paid, due, partial }

enum UtilityType { internet, water, garbage, other }

enum DocumentType { agreement, idProof, other }

/// Parses an enum by name with a safe fallback.
T _enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  final s = name?.toString();
  for (final v in values) {
    if (v.name == s) return v;
  }
  return fallback;
}

double _toDouble(Object? v) {
  if (v is int) return v.toDouble();
  if (v is double) return v;
  return double.tryParse('$v') ?? 0;
}

int _toInt(Object? v) {
  if (v is int) return v;
  if (v is double) return v.round();
  return int.tryParse('$v') ?? 0;
}

@immutable
class House {
  const House({
    required this.id,
    required this.name,
    required this.address,
    required this.electricityRatePerUnit,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String address;
  final double electricityRatePerUnit;
  final DateTime createdAt;

  factory House.fromMap(Map<String, Object?> m) => House(
        id: m['id']! as String,
        name: m['name']! as String,
        address: (m['address'] ?? '') as String,
        electricityRatePerUnit: _toDouble(m['electricity_rate_per_unit']),
        createdAt: DateTime.parse(m['created_at']! as String),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'address': address,
        'electricity_rate_per_unit': electricityRatePerUnit,
        'created_at': createdAt.toIso8601String(),
      };
}

@immutable
class Room {
  const Room({
    required this.id,
    required this.houseId,
    required this.roomNumber,
    required this.monthlyRent,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String houseId;
  final String roomNumber;
  final double monthlyRent;
  final RoomStatus status;
  final DateTime createdAt;

  bool get isOccupied => status == RoomStatus.occupied;

  factory Room.fromMap(Map<String, Object?> m) => Room(
        id: m['id']! as String,
        houseId: m['house_id']! as String,
        roomNumber: m['room_number']! as String,
        monthlyRent: _toDouble(m['monthly_rent']),
        status: _enumByName(RoomStatus.values, m['status'], RoomStatus.vacant),
        createdAt: DateTime.parse(m['created_at']! as String),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'house_id': houseId,
        'room_number': roomNumber,
        'monthly_rent': monthlyRent,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
      };

  Room copyWith({String? roomNumber, double? monthlyRent, RoomStatus? status}) =>
      Room(
        id: id,
        houseId: houseId,
        roomNumber: roomNumber ?? this.roomNumber,
        monthlyRent: monthlyRent ?? this.monthlyRent,
        status: status ?? this.status,
        createdAt: createdAt,
      );
}

@immutable
class Tenant {
  const Tenant({
    required this.id,
    required this.roomId,
    required this.fullName,
    required this.phone,
    required this.moveInDate,
    this.moveOutDate,
    this.idDocumentPhotoPath,
    this.citizenshipNo = '',
    this.emergencyContact = '',
    required this.isActive,
  });

  final String id;
  final String roomId;
  final String fullName;
  final String phone;
  final DateTime moveInDate;
  final DateTime? moveOutDate;
  final String? idDocumentPhotoPath;
  final String citizenshipNo;
  final String emergencyContact;
  final bool isActive;

  factory Tenant.fromMap(Map<String, Object?> m) => Tenant(
        id: m['id']! as String,
        roomId: m['room_id']! as String,
        fullName: m['full_name']! as String,
        phone: (m['phone'] ?? '') as String,
        moveInDate: DateTime.parse(m['move_in_date']! as String),
        moveOutDate: m['move_out_date'] == null
            ? null
            : DateTime.parse(m['move_out_date']! as String),
        idDocumentPhotoPath: m['id_document_photo_path'] as String?,
        citizenshipNo: (m['citizenship_no'] ?? '') as String,
        emergencyContact: (m['emergency_contact'] ?? '') as String,
        isActive: _toInt(m['is_active']) == 1,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'room_id': roomId,
        'full_name': fullName,
        'phone': phone,
        'move_in_date': moveInDate.toIso8601String(),
        'move_out_date': moveOutDate?.toIso8601String(),
        'id_document_photo_path': idDocumentPhotoPath,
        'citizenship_no': citizenshipNo,
        'emergency_contact': emergencyContact,
        'is_active': isActive ? 1 : 0,
      };
}

@immutable
class ElectricityReading {
  const ElectricityReading({
    required this.id,
    required this.roomId,
    required this.billingMonth,
    required this.previousUnit,
    required this.currentUnit,
    required this.unitsConsumed,
    required this.rateUsed,
    required this.amount,
    this.meterPhotoPath,
    required this.recordedAt,
  });

  final String id;
  final String roomId;

  /// "YYYY-MM"
  final String billingMonth;
  final double previousUnit;
  final double currentUnit;
  final double unitsConsumed;
  final double rateUsed;
  final double amount;
  final String? meterPhotoPath;
  final DateTime recordedAt;

  factory ElectricityReading.fromMap(Map<String, Object?> m) =>
      ElectricityReading(
        id: m['id']! as String,
        roomId: m['room_id']! as String,
        billingMonth: m['billing_month']! as String,
        previousUnit: _toDouble(m['previous_unit']),
        currentUnit: _toDouble(m['current_unit']),
        unitsConsumed: _toDouble(m['units_consumed']),
        rateUsed: _toDouble(m['rate_used']),
        amount: _toDouble(m['amount']),
        meterPhotoPath: m['meter_photo_path'] as String?,
        recordedAt: DateTime.parse(m['recorded_at']! as String),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'room_id': roomId,
        'billing_month': billingMonth,
        'previous_unit': previousUnit,
        'current_unit': currentUnit,
        'units_consumed': unitsConsumed,
        'rate_used': rateUsed,
        'amount': amount,
        'meter_photo_path': meterPhotoPath,
        'recorded_at': recordedAt.toIso8601String(),
      };
}

@immutable
class UtilityCharge {
  const UtilityCharge({
    required this.id,
    required this.roomId,
    required this.type,
    required this.billingMonth,
    required this.amount,
    this.note = '',
    required this.recordedAt,
  });

  final String id;
  final String roomId;
  final UtilityType type;
  final String billingMonth;
  final double amount;
  final String note;
  final DateTime recordedAt;

  factory UtilityCharge.fromMap(Map<String, Object?> m) => UtilityCharge(
        id: m['id']! as String,
        roomId: m['room_id']! as String,
        type: _enumByName(UtilityType.values, m['type'], UtilityType.other),
        billingMonth: m['billing_month']! as String,
        amount: _toDouble(m['amount']),
        note: (m['note'] ?? '') as String,
        recordedAt: DateTime.parse(m['recorded_at']! as String),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'room_id': roomId,
        'type': type.name,
        'billing_month': billingMonth,
        'amount': amount,
        'note': note,
        'recorded_at': recordedAt.toIso8601String(),
      };
}

@immutable
class Payment {
  const Payment({
    required this.id,
    required this.roomId,
    required this.tenantId,
    required this.billingMonth,
    required this.rentDue,
    required this.electricityDue,
    required this.utilityDue,
    required this.totalDue,
    required this.amountPaid,
    required this.status,
    this.paidDate,
    required this.dueDate,
  });

  final String id;
  final String roomId;
  final String tenantId;
  final String billingMonth;
  final double rentDue;
  final double electricityDue;
  final double utilityDue;
  final double totalDue;
  final double amountPaid;
  final PaymentStatus status;
  final DateTime? paidDate;
  final DateTime dueDate;

  double get remaining =>
      (totalDue - amountPaid).clamp(0, double.infinity).toDouble();

  bool get isOverdue =>
      status != PaymentStatus.paid &&
      DateTime.now().isAfter(DateTime(dueDate.year, dueDate.month, dueDate.day));

  factory Payment.fromMap(Map<String, Object?> m) => Payment(
        id: m['id']! as String,
        roomId: m['room_id']! as String,
        tenantId: m['tenant_id']! as String,
        billingMonth: m['billing_month']! as String,
        rentDue: _toDouble(m['rent_due']),
        electricityDue: _toDouble(m['electricity_due']),
        utilityDue: _toDouble(m['utility_due']),
        totalDue: _toDouble(m['total_due']),
        amountPaid: _toDouble(m['amount_paid']),
        status:
            _enumByName(PaymentStatus.values, m['status'], PaymentStatus.due),
        paidDate: m['paid_date'] == null
            ? null
            : DateTime.parse(m['paid_date']! as String),
        dueDate: DateTime.parse(m['due_date']! as String),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'room_id': roomId,
        'tenant_id': tenantId,
        'billing_month': billingMonth,
        'rent_due': rentDue,
        'electricity_due': electricityDue,
        'utility_due': utilityDue,
        'total_due': totalDue,
        'amount_paid': amountPaid,
        'status': status.name,
        'paid_date': paidDate?.toIso8601String(),
        'due_date': dueDate.toIso8601String(),
      };
}

@immutable
class Document {
  const Document({
    required this.id,
    this.tenantId,
    this.houseId,
    required this.title,
    required this.filePath,
    required this.type,
    required this.createdAt,
  });

  final String id;
  final String? tenantId;
  final String? houseId;
  final String title;
  final String filePath;
  final DocumentType type;
  final DateTime createdAt;

  factory Document.fromMap(Map<String, Object?> m) => Document(
        id: m['id']! as String,
        tenantId: m['tenant_id'] as String?,
        houseId: m['house_id'] as String?,
        title: m['title']! as String,
        filePath: m['file_path']! as String,
        type: _enumByName(DocumentType.values, m['type'], DocumentType.other),
        createdAt: DateTime.parse(m['created_at']! as String),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'tenant_id': tenantId,
        'house_id': houseId,
        'title': title,
        'file_path': filePath,
        'type': type.name,
        'created_at': createdAt.toIso8601String(),
      };
}

/// Billing-month helpers ("YYYY-MM").
String billingMonthOf(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';

DateTime firstDayOfBillingMonth(String billingMonth) {
  final parts = billingMonth.split('-');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
}
