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
}

class Room {
  const Room({
    required this.id,
    required this.propertyId,
    required this.label,
    required this.tenantName,
    required this.dueDay,
    required this.monthlyRent,
    required this.status,
    required this.note,
  });

  final String id;
  final String propertyId;
  final String label;
  final String tenantName;
  final int dueDay;
  final double monthlyRent;
  final PaymentStatus status;
  final String note;
}

class PaymentReceivable {
  const PaymentReceivable({
    required this.id,
    required this.propertyName,
    required this.roomLabel,
    required this.amount,
    required this.overdueLabel,
    required this.tags,
    required this.status,
  });

  final String id;
  final String propertyName;
  final String roomLabel;
  final double amount;
  final String overdueLabel;
  final List<String> tags;
  final PaymentStatus status;
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
