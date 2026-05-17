import 'property_models.dart';

class PortfolioSnapshot {
  const PortfolioSnapshot({
    required this.properties,
    required this.tenants,
    required this.revenue,
    required this.billingCycles,
    required this.payments,
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
  final List<BillingCycle> billingCycles;
  final List<PaymentRecord> payments;
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

  int get totalHouses => properties.length;

  int get activeTenants => tenants.length;

  DateTime get now => DateTime.now();

  String get currentMonthLabel {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[now.month]} ${now.year}';
  }

  List<BillingCycle> get currentMonthCycles => billingCycles
      .where(
        (cycle) => cycle.cycleYear == now.year && cycle.cycleMonth == now.month,
      )
      .toList();

  double get monthlyExpectedRevenue =>
      currentMonthCycles.fold<double>(0, (sum, cycle) => sum + cycle.totalDue);

  double get collectedRevenue =>
      currentMonthCycles.fold<double>(0, (sum, cycle) => sum + cycle.totalPaid);

  double get pendingRevenue => monthlyExpectedRevenue - collectedRevenue;

  double get electricityDues => currentMonthCycles
      .where((cycle) => cycle.status != BillingCycleStatus.paid)
      .fold<double>(0, (sum, cycle) => sum + cycle.electricityDue);

  double get utilityTotals =>
      utilityRecords.fold<double>(0, (sum, item) => sum + item.amount);

  double get totalOutstanding => pendingRevenue;

  double get currentRevenue {
    return collectedRevenue;
  }

  double get averageRent {
    final rooms = properties.expand((property) => property.rooms).toList();
    if (rooms.isEmpty) return 0;
    final total = rooms.fold<double>(0, (sum, room) => sum + room.monthlyRent);
    return total / rooms.length;
  }

  double get netProfit => collectedRevenue * 0.656;

  int get paidRooms => properties
      .expand((property) => property.rooms)
      .where((room) => room.status.name == 'paid')
      .length;

  int get dueRooms => currentMonthCycles
      .where((cycle) => cycle.status != BillingCycleStatus.paid)
      .length;
}
