import 'payment_status.dart';

class RentalProperty {
  const RentalProperty({
    required this.id,
    required this.name,
    required this.address,
    required this.totalRooms,
    required this.occupiedRooms,
    required this.monthlyTarget,
    required this.totalDue,
    required this.rooms,
  });

  final String id;
  final String name;
  final String address;
  final int totalRooms;
  final int occupiedRooms;
  final double monthlyTarget;
  final double totalDue;
  final List<Room> rooms;

  RentalProperty copyWith({
    String? name,
    String? address,
    int? totalRooms,
    int? occupiedRooms,
    double? monthlyTarget,
    double? totalDue,
    List<Room>? rooms,
  }) {
    return RentalProperty(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      totalRooms: totalRooms ?? this.totalRooms,
      occupiedRooms: occupiedRooms ?? this.occupiedRooms,
      monthlyTarget: monthlyTarget ?? this.monthlyTarget,
      totalDue: totalDue ?? this.totalDue,
      rooms: rooms ?? this.rooms,
    );
  }
}

class Room {
  const Room({
    required this.id,
    required this.propertyId,
    required this.label,
    required this.tenantName,
    required this.dueDay,
    required this.monthlyRent,
    this.electricityRate = 12,
    this.waterCost = 50,
    this.internetCost = 500,
    required this.status,
    required this.note,
  });

  final String id;
  final String propertyId;
  final String label;
  final String tenantName;
  final int dueDay;
  final double monthlyRent;
  final double electricityRate;
  final double waterCost;
  final double internetCost;
  final PaymentStatus status;
  final String note;
}

class TenantProfile {
  const TenantProfile({
    required this.id,
    required this.roomId,
    required this.propertyId,
    required this.name,
    required this.phone,
    this.citizenshipNo = '',
    required this.moveInDate,
    required this.emergencyContact,
  });

  final String id;
  final String roomId;
  final String propertyId;
  final String name;
  final String phone;
  final String citizenshipNo;
  final DateTime moveInDate;
  final String emergencyContact;
}

class PaymentReceivable {
  const PaymentReceivable({
    required this.id,
    required this.propertyId,
    required this.propertyName,
    required this.roomId,
    required this.roomLabel,
    required this.amount,
    required this.overdueLabel,
    required this.tags,
    required this.status,
  });

  final String id;
  final String propertyId;
  final String propertyName;
  final String roomId;
  final String roomLabel;
  final double amount;
  final String overdueLabel;
  final List<String> tags;
  final PaymentStatus status;
}

enum BillingCycleStatus { pending, partial, paid, overdue }

class BillingCycle {
  const BillingCycle({
    required this.id,
    required this.propertyId,
    required this.propertyName,
    required this.roomId,
    required this.roomLabel,
    required this.tenantId,
    required this.tenantName,
    required this.cycleYear,
    required this.cycleMonth,
    required this.rentDue,
    required this.electricityDue,
    required this.internetDue,
    required this.utilityDue,
    required this.totalDue,
    required this.totalPaid,
    required this.status,
    required this.dueDate,
    required this.generatedAt,
    required this.closedAt,
  });

  final String id;
  final String propertyId;
  final String propertyName;
  final String roomId;
  final String roomLabel;
  final String tenantId;
  final String tenantName;
  final int cycleYear;
  final int cycleMonth;
  final double rentDue;
  final double electricityDue;
  final double internetDue;
  final double utilityDue;
  final double totalDue;
  final double totalPaid;
  final BillingCycleStatus status;
  final DateTime dueDate;
  final DateTime generatedAt;
  final DateTime? closedAt;
}

class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.billingCycleId,
    required this.tenantId,
    required this.amount,
    required this.method,
    required this.note,
    required this.isPartial,
    required this.paidAt,
  });

  final String id;
  final String billingCycleId;
  final String tenantId;
  final double amount;
  final String method;
  final String note;
  final bool isPartial;
  final DateTime paidAt;
}

class MonthlyRevenuePoint {
  const MonthlyRevenuePoint({required this.month, required this.amount});

  final String month;
  final double amount;
}

class UtilityUsage {
  const UtilityUsage({
    required this.propertyName,
    required this.electricity,
    required this.water,
  });

  final String propertyName;
  final double electricity;
  final double water;
}

enum UtilityType { electricity, internet, water, maintenance, other }

class UtilityRecord {
  const UtilityRecord({
    required this.id,
    required this.propertyId,
    required this.propertyName,
    required this.roomId,
    required this.roomLabel,
    required this.tenantName,
    required this.type,
    required this.meterReading,
    required this.amount,
    required this.note,
    required this.imagePath,
    required this.recordedAt,
  });

  final String id;
  final String propertyId;
  final String propertyName;
  final String roomId;
  final String roomLabel;
  final String tenantName;
  final UtilityType type;
  final double? meterReading;
  final double amount;
  final String note;
  final String? imagePath;
  final DateTime recordedAt;
}

class ElectricityReading {
  const ElectricityReading({
    required this.id,
    required this.propertyId,
    required this.propertyName,
    required this.roomId,
    required this.roomLabel,
    required this.tenantName,
    required this.previousReading,
    required this.currentReading,
    required this.unitsConsumed,
    required this.rate,
    required this.totalCost,
    required this.recordedAt,
    required this.imagePath,
    required this.note,
  });

  final String id;
  final String propertyId;
  final String propertyName;
  final String roomId;
  final String roomLabel;
  final String tenantName;
  final double previousReading;
  final double currentReading;
  final double unitsConsumed;
  final double rate;
  final double totalCost;
  final DateTime recordedAt;
  final String? imagePath;
  final String note;
}

class DocumentRecord {
  const DocumentRecord({
    required this.id,
    required this.propertyId,
    required this.propertyName,
    required this.roomId,
    required this.roomLabel,
    required this.title,
    required this.category,
    required this.filePath,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final String propertyId;
  final String propertyName;
  final String roomId;
  final String roomLabel;
  final String title;
  final String category;
  final String filePath;
  final String note;
  final DateTime createdAt;
}

class ActivityEntry {
  const ActivityEntry({
    required this.id,
    required this.propertyId,
    required this.title,
    required this.detail,
    required this.createdAt,
  });

  final String id;
  final String propertyId;
  final String title;
  final String detail;
  final DateTime createdAt;
}

class PropertyDraft {
  const PropertyDraft({
    this.id,
    required this.name,
    required this.address,
    required this.monthlyTarget,
  });

  final String? id;
  final String name;
  final String address;
  final double monthlyTarget;
}

class RoomDraft {
  RoomDraft({
    this.id,
    required this.propertyId,
    required this.label,
    required this.tenantName,
    this.tenantPhone = '',
    this.citizenshipNo = '',
    DateTime? moveInDate,
    required this.dueDay,
    required this.monthlyRent,
    this.electricityRate = 12,
    this.waterCost = 50,
    this.internetCost = 500,
    required this.status,
    required this.note,
  }) : moveInDate = moveInDate ?? DateTime.now();

  final String? id;
  final String propertyId;
  final String label;
  final String tenantName;
  final String tenantPhone;
  final String citizenshipNo;
  final DateTime moveInDate;
  final int dueDay;
  final double monthlyRent;
  final double electricityRate;
  final double waterCost;
  final double internetCost;
  final PaymentStatus status;
  final String note;
}

class UtilityRecordDraft {
  const UtilityRecordDraft({
    required this.propertyId,
    required this.propertyName,
    required this.roomId,
    required this.roomLabel,
    required this.tenantName,
    required this.type,
    required this.meterReading,
    required this.amount,
    required this.note,
    required this.imagePath,
    required this.recordedAt,
  });

  final String propertyId;
  final String propertyName;
  final String roomId;
  final String roomLabel;
  final String tenantName;
  final UtilityType type;
  final double? meterReading;
  final double amount;
  final String note;
  final String? imagePath;
  final DateTime recordedAt;
}

class ElectricityReadingDraft {
  const ElectricityReadingDraft({
    required this.propertyId,
    required this.propertyName,
    required this.roomId,
    required this.roomLabel,
    required this.tenantName,
    required this.currentReading,
    required this.rate,
    required this.imagePath,
    required this.note,
    required this.recordedAt,
  });

  final String propertyId;
  final String propertyName;
  final String roomId;
  final String roomLabel;
  final String tenantName;
  final double currentReading;
  final double rate;
  final String? imagePath;
  final String note;
  final DateTime recordedAt;
}

class DocumentDraft {
  const DocumentDraft({
    required this.propertyId,
    required this.propertyName,
    required this.roomId,
    required this.roomLabel,
    required this.title,
    required this.category,
    required this.filePath,
    required this.note,
  });

  final String propertyId;
  final String propertyName;
  final String roomId;
  final String roomLabel;
  final String title;
  final String category;
  final String filePath;
  final String note;
}

class AppPreferences {
  const AppPreferences({
    required this.currencyCode,
    required this.reminderDay,
    required this.landlordName,
  });

  final String currencyCode;
  final int reminderDay;
  final String landlordName;

  AppPreferences copyWith({
    String? currencyCode,
    int? reminderDay,
    String? landlordName,
  }) {
    return AppPreferences(
      currencyCode: currencyCode ?? this.currencyCode,
      reminderDay: reminderDay ?? this.reminderDay,
      landlordName: landlordName ?? this.landlordName,
    );
  }
}
