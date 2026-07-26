import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import 'models/models.dart';
import 'repository.dart';

/// The database. Overridden in `main()` with an initialized instance so the
/// rest of the tree can read it synchronously.
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider must be overridden in main()');
});

final repositoryProvider = Provider<RentalRepository>(
  (ref) => RentalRepository(ref.watch(databaseProvider)),
);

/// Single source of truth: the full portfolio snapshot. Every mutation goes
/// through here and reloads a fresh snapshot so all derived providers update.
class PortfolioNotifier extends AsyncNotifier<PortfolioSnapshot> {
  RentalRepository get _repo => ref.read(repositoryProvider);

  @override
  Future<PortfolioSnapshot> build() => _repo.loadSnapshot();

  Future<void> _mutate(Future<void> Function() work) async {
    await work();
    state = await AsyncValue.guard(_repo.loadSnapshot);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_repo.loadSnapshot);
  }

  // Houses
  Future<void> saveHouse({
    String? id,
    required String name,
    required String address,
    required double electricityRate,
  }) =>
      _mutate(() => _repo.saveHouse(
            id: id,
            name: name,
            address: address,
            electricityRate: electricityRate,
          ));

  Future<void> deleteHouse(String id) => _mutate(() => _repo.deleteHouse(id));

  // Rooms
  Future<void> saveRoom({
    String? id,
    required String houseId,
    required String roomNumber,
    required double monthlyRent,
  }) =>
      _mutate(() => _repo.saveRoom(
            id: id,
            houseId: houseId,
            roomNumber: roomNumber,
            monthlyRent: monthlyRent,
          ));

  Future<void> deleteRoom(String id) => _mutate(() => _repo.deleteRoom(id));

  // Tenants
  Future<void> addTenant({
    required String roomId,
    required String fullName,
    required String phone,
    required DateTime moveInDate,
    String? idDocumentPhotoPath,
    String citizenshipNo = '',
    String emergencyContact = '',
  }) =>
      _mutate(() => _repo.addTenant(
            roomId: roomId,
            fullName: fullName,
            phone: phone,
            moveInDate: moveInDate,
            idDocumentPhotoPath: idDocumentPhotoPath,
            citizenshipNo: citizenshipNo,
            emergencyContact: emergencyContact,
          ));

  Future<void> updateTenant({
    required String tenantId,
    required String fullName,
    required String phone,
    String citizenshipNo = '',
    String emergencyContact = '',
  }) =>
      _mutate(() => _repo.updateTenant(
            tenantId: tenantId,
            fullName: fullName,
            phone: phone,
            citizenshipNo: citizenshipNo,
            emergencyContact: emergencyContact,
          ));

  Future<void> moveOutTenant(String tenantId) =>
      _mutate(() => _repo.moveOutTenant(tenantId));

  // Electricity & utilities
  Future<void> saveElectricityReading({
    required String roomId,
    required double currentUnit,
    String? meterPhotoPath,
  }) =>
      _mutate(() => _repo.saveElectricityReading(
            roomId: roomId,
            currentUnit: currentUnit,
            meterPhotoPath: meterPhotoPath,
          ));

  Future<void> addUtilityCharge({
    required String roomId,
    required UtilityType type,
    required double amount,
    String note = '',
  }) =>
      _mutate(() => _repo.addUtilityCharge(
            roomId: roomId,
            type: type,
            amount: amount,
            note: note,
          ));

  // Payments
  Future<void> markPaid(String paymentId) =>
      _mutate(() => _repo.markPaid(paymentId));

  Future<void> recordPartial(String paymentId, double amount) =>
      _mutate(() => _repo.recordPartialPayment(paymentId, amount));

  // Documents
  Future<void> addDocument({
    String? tenantId,
    String? houseId,
    required String title,
    required String filePath,
    required DocumentType type,
  }) =>
      _mutate(() => _repo.addDocument(
            tenantId: tenantId,
            houseId: houseId,
            title: title,
            filePath: filePath,
            type: type,
          ));

  Future<void> deleteDocument(String id) =>
      _mutate(() => _repo.deleteDocument(id));

  // Backup / restore
  Future<String> exportBackup() => _repo.exportToFile();
  Future<void> importBackup(String path) =>
      _mutate(() => _repo.importFromFile(path));
}

final portfolioProvider =
    AsyncNotifierProvider<PortfolioNotifier, PortfolioSnapshot>(
  PortfolioNotifier.new,
);

/// Convenience: the loaded snapshot or null while loading/errored.
final snapshotProvider = Provider<PortfolioSnapshot?>(
  (ref) => ref.watch(portfolioProvider).valueOrNull,
);

// ── Derived, synchronous selectors (default gracefully while loading) ──

class DashboardStats {
  const DashboardStats({
    required this.houseCount,
    required this.roomCount,
    required this.occupiedCount,
    required this.collected,
    required this.expected,
    required this.due,
  });

  final int houseCount;
  final int roomCount;
  final int occupiedCount;
  final double collected;
  final double expected;
  final double due;

  double get collectionRate => expected <= 0 ? 0 : (collected / expected);

  static const empty = DashboardStats(
    houseCount: 0,
    roomCount: 0,
    occupiedCount: 0,
    collected: 0,
    expected: 0,
    due: 0,
  );
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final snap = ref.watch(snapshotProvider);
  if (snap == null) return DashboardStats.empty;
  final month = billingMonthOf(DateTime.now());
  final monthPayments = snap.paymentsForMonth(month);
  double collected = 0, expected = 0, due = 0;
  for (final p in monthPayments) {
    collected += p.amountPaid;
    expected += p.totalDue;
    due += p.remaining;
  }
  return DashboardStats(
    houseCount: snap.houses.length,
    roomCount: snap.rooms.length,
    occupiedCount: snap.rooms.where((r) => r.isOccupied).length,
    collected: collected,
    expected: expected,
    due: due,
  );
});

/// Payments for the current billing month.
final currentMonthPaymentsProvider = Provider<List<Payment>>((ref) {
  final snap = ref.watch(snapshotProvider);
  if (snap == null) return const [];
  return snap.paymentsForMonth(billingMonthOf(DateTime.now()));
});

/// Per-room electricity history (lazy).
final electricityForRoomProvider =
    FutureProvider.family<List<ElectricityReading>, String>((ref, roomId) {
  ref.watch(portfolioProvider); // refresh when data changes
  return ref.watch(repositoryProvider).electricityForRoom(roomId);
});

final utilitiesForRoomProvider =
    FutureProvider.family<List<UtilityCharge>, String>((ref, roomId) {
  ref.watch(portfolioProvider);
  return ref.watch(repositoryProvider).utilitiesForRoom(roomId);
});

final documentsProvider = FutureProvider<List<Document>>((ref) {
  ref.watch(portfolioProvider);
  return ref.watch(repositoryProvider).documents();
});

/// Monthly collected income for the last 6 billing months (oldest → newest).
final monthlyIncomeProvider =
    Provider<List<({DateTime month, double amount})>>((ref) {
  final snap = ref.watch(snapshotProvider);
  final now = DateTime.now();
  final months = [for (var i = 5; i >= 0; i--) DateTime(now.year, now.month - i)];
  if (snap == null) {
    return [for (final m in months) (month: m, amount: 0.0)];
  }
  return [
    for (final m in months)
      (
        month: m,
        amount: snap
            .paymentsForMonth(billingMonthOf(m))
            .fold<double>(0, (s, p) => s + p.amountPaid),
      ),
  ];
});

class StatusSplit {
  const StatusSplit({required this.paid, required this.partial, required this.due});
  final double paid;
  final double partial;
  final double due;
  double get total => paid + partial + due;
  double fraction(double part) => total <= 0 ? 0 : part / total;
}

/// Paid / partial / due amount split for the current billing month.
final statusSplitProvider = Provider<StatusSplit>((ref) {
  final payments = ref.watch(currentMonthPaymentsProvider);
  double paid = 0, partial = 0, due = 0;
  for (final p in payments) {
    switch (p.status) {
      case PaymentStatus.paid:
        paid += p.totalDue;
      case PaymentStatus.partial:
        partial += p.amountPaid;
        due += p.remaining;
      case PaymentStatus.due:
        due += p.remaining;
    }
  }
  return StatusSplit(paid: paid, partial: partial, due: due);
});

class HouseCollection {
  const HouseCollection({
    required this.house,
    required this.collected,
    required this.expected,
  });
  final House house;
  final double collected;
  final double expected;
  double get rate => expected <= 0 ? 0 : (collected / expected).clamp(0, 1);
}

/// Per-house collection rate for the current billing month.
final perHouseCollectionProvider = Provider<List<HouseCollection>>((ref) {
  final snap = ref.watch(snapshotProvider);
  if (snap == null) return const [];
  final month = billingMonthOf(DateTime.now());
  final byRoomHouse = {for (final r in snap.rooms) r.id: r.houseId};
  final collected = <String, double>{};
  final expected = <String, double>{};
  for (final p in snap.paymentsForMonth(month)) {
    final houseId = byRoomHouse[p.roomId];
    if (houseId == null) continue;
    collected[houseId] = (collected[houseId] ?? 0) + p.amountPaid;
    expected[houseId] = (expected[houseId] ?? 0) + p.totalDue;
  }
  return [
    for (final h in snap.houses)
      HouseCollection(
        house: h,
        collected: collected[h.id] ?? 0,
        expected: expected[h.id] ?? 0,
      ),
  ];
});

// ── App preferences (theme + locale), persisted in the settings table ──

class AppPrefs {
  const AppPrefs({required this.themeMode, required this.locale});
  final ThemeMode themeMode;
  final Locale locale;

  AppPrefs copyWith({ThemeMode? themeMode, Locale? locale}) => AppPrefs(
        themeMode: themeMode ?? this.themeMode,
        locale: locale ?? this.locale,
      );

  static const initial =
      AppPrefs(themeMode: ThemeMode.light, locale: Locale('en'));
}

class PrefsNotifier extends Notifier<AppPrefs> {
  @override
  AppPrefs build() {
    _load();
    return AppPrefs.initial;
  }

  Future<void> _load() async {
    final repo = ref.read(repositoryProvider);
    final theme = await repo.getSetting('theme_mode');
    final locale = await repo.getSetting('locale');
    state = AppPrefs(
      themeMode: theme == 'dark' ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(locale ?? 'en'),
    );
  }

  Future<void> setDarkMode(bool dark) async {
    state = state.copyWith(themeMode: dark ? ThemeMode.dark : ThemeMode.light);
    await ref.read(repositoryProvider).setSetting(
          'theme_mode',
          dark ? 'dark' : 'light',
        );
  }

  Future<void> setLocale(Locale locale) async {
    state = state.copyWith(locale: locale);
    await ref.read(repositoryProvider).setSetting('locale', locale.languageCode);
  }
}

final prefsProvider =
    NotifierProvider<PrefsNotifier, AppPrefs>(PrefsNotifier.new);
