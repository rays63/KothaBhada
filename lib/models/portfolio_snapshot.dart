import 'property_models.dart';

class PortfolioSnapshot {
  const PortfolioSnapshot({
    required this.properties,
    required this.tenants,
    required this.revenue,
    required this.utilityUsage,
    required this.utilityRecords,
    required this.documents,
    required this.activities,
    required this.pendingReceivables,
    required this.completedReceivables,
    required this.preferences,
  });

  final List<RentalProperty> properties;
  final List<TenantProfile> tenants;
  final List<MonthlyRevenuePoint> revenue;
  final List<UtilityUsage> utilityUsage;
  final List<UtilityRecord> utilityRecords;
  final List<DocumentRecord> documents;
  final List<ActivityEntry> activities;
  final List<PaymentReceivable> pendingReceivables;
  final List<PaymentReceivable> completedReceivables;
  final AppPreferences preferences;

  int get totalRooms =>
      properties.fold(0, (sum, property) => sum + property.totalRooms);

  int get occupiedRooms =>
      properties.fold(0, (sum, property) => sum + property.occupiedRooms);

  int get vacantRooms => totalRooms - occupiedRooms;

  double get occupancyRate => totalRooms == 0 ? 0 : occupiedRooms / totalRooms;

  double get totalOutstanding =>
      pendingReceivables.fold<double>(0, (sum, item) => sum + item.amount);

  double get currentRevenue {
    if (revenue.isEmpty) return 0;
    final currentIndex = revenue.length >= 4 ? 3 : revenue.length - 1;
    return revenue[currentIndex].amount;
  }

  double get averageRent {
    final rooms = properties.expand((property) => property.rooms).toList();
    if (rooms.isEmpty) return 0;
    final total = rooms.fold<double>(0, (sum, room) => sum + room.monthlyRent);
    return total / rooms.length;
  }

  double get netProfit => currentRevenue * 0.656;

  int get paidRooms => properties
      .expand((property) => property.rooms)
      .where((room) => room.status.name == 'paid')
      .length;

  int get dueRooms => properties
      .expand((property) => property.rooms)
      .where((room) => room.status.name != 'paid')
      .length;
}
