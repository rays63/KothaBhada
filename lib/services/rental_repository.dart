import 'package:flutter/material.dart';

import '../database/app_database.dart';
import '../models/payment_status.dart';
import '../models/portfolio_snapshot.dart';
import '../models/property_models.dart';
import 'seed_data.dart';

abstract class RentalRepository {
  Future<PortfolioSnapshot> loadSnapshot();

  Future<ThemeMode?> loadThemeMode();

  Future<void> saveThemeMode(ThemeMode mode);

  Future<void> saveProperty(PropertyDraft draft);
  Future<void> deleteProperty(String propertyId);

  Future<void> saveRoom(RoomDraft draft);

  Future<void> addUtilityRecord(UtilityRecordDraft draft);

  Future<void> addDocument(DocumentDraft draft);
  Future<void> updateDocument(String documentId, DocumentDraft draft);
  Future<void> deleteDocument(String documentId);

  Future<void> markReceivablePaid(String receivableId);

  Future<void> recordPartialPayment(String receivableId, double amount);

  Future<void> saveElectricityReading(ElectricityReadingDraft draft);

  Future<List<ElectricityReading>> loadElectricityReadingsForRoom(
    String roomId,
  );

  Future<String> backupData();
  Future<String> exportData();
  Future<void> restoreData(String backupPath);
}

class SqliteRentalRepository implements RentalRepository {
  SqliteRentalRepository(this._database);

  final AppDatabase _database;

  @override
  Future<PortfolioSnapshot> loadSnapshot() => _database.loadSnapshot();

  @override
  Future<ThemeMode?> loadThemeMode() => _database.loadThemeMode();

  @override
  Future<void> saveThemeMode(ThemeMode mode) => _database.saveThemeMode(mode);

  @override
  Future<void> saveProperty(PropertyDraft draft) =>
      _database.saveProperty(draft);

  @override
  Future<void> deleteProperty(String propertyId) =>
      _database.deleteProperty(propertyId);

  @override
  Future<void> saveRoom(RoomDraft draft) => _database.saveRoom(draft);

  @override
  Future<void> addUtilityRecord(UtilityRecordDraft draft) =>
      _database.addUtilityRecord(draft);

  @override
  Future<void> addDocument(DocumentDraft draft) => _database.addDocument(draft);

  @override
  Future<void> updateDocument(String documentId, DocumentDraft draft) =>
      _database.updateDocument(documentId, draft);

  @override
  Future<void> deleteDocument(String documentId) =>
      _database.deleteDocument(documentId);

  @override
  Future<void> markReceivablePaid(String receivableId) =>
      _database.markReceivablePaid(receivableId);

  @override
  Future<void> recordPartialPayment(String receivableId, double amount) =>
      _database.recordPartialPayment(receivableId, amount);

  @override
  Future<void> saveElectricityReading(ElectricityReadingDraft draft) =>
      _database.saveElectricityReading(draft);

  @override
  Future<List<ElectricityReading>> loadElectricityReadingsForRoom(
    String roomId,
  ) => _database.loadElectricityReadingsForRoom(roomId);

  @override
  Future<String> backupData() => _database.createBackupFile();

  @override
  Future<String> exportData() => _database.exportDataFile();

  @override
  Future<void> restoreData(String backupPath) =>
      _database.restoreDataFile(backupPath);
}

class InMemoryRentalRepository implements RentalRepository {
  InMemoryRentalRepository({PortfolioSnapshot? snapshot, ThemeMode? themeMode})
    : _snapshot = snapshot ?? SeedData.snapshot,
      _themeMode = themeMode ?? ThemeMode.light;

  PortfolioSnapshot _snapshot;
  ThemeMode _themeMode;
  final List<ElectricityReading> _electricityReadings = [];

  @override
  Future<PortfolioSnapshot> loadSnapshot() async => _snapshot;

  @override
  Future<ThemeMode?> loadThemeMode() async => _themeMode;

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    _themeMode = mode;
  }

  @override
  Future<void> saveProperty(PropertyDraft draft) async {
    final id = draft.id ?? 'p-${DateTime.now().microsecondsSinceEpoch}';
    final properties = [..._snapshot.properties];
    final index = properties.indexWhere((item) => item.id == id);
    final next = RentalProperty(
      id: id,
      name: draft.name,
      address: draft.address,
      totalRooms: index >= 0 ? properties[index].totalRooms : 0,
      occupiedRooms: index >= 0 ? properties[index].occupiedRooms : 0,
      monthlyTarget: draft.monthlyTarget,
      totalDue: index >= 0 ? properties[index].totalDue : 0,
      rooms: index >= 0 ? properties[index].rooms : const [],
    );
    if (index >= 0) {
      properties[index] = next;
    } else {
      properties.add(next);
    }
    _snapshot = PortfolioSnapshot(
      properties: properties,
      tenants: _snapshot.tenants,
      revenue: _snapshot.revenue,
      billingCycles: _snapshot.billingCycles,
      payments: _snapshot.payments,
      utilityUsage: _snapshot.utilityUsage,
      utilityRecords: _snapshot.utilityRecords,
      documents: _snapshot.documents,
      activities: _snapshot.activities,
      pendingReceivables: _snapshot.pendingReceivables,
      completedReceivables: _snapshot.completedReceivables,
      preferences: _snapshot.preferences,
    );
  }

  @override
  Future<void> deleteProperty(String propertyId) async {
    final properties = _snapshot.properties
        .where((item) => item.id != propertyId)
        .toList();
    final rooms = properties
        .expand((item) => item.rooms)
        .map((room) => room.id)
        .toSet();
    final tenants = _snapshot.tenants
        .where((tenant) => tenant.propertyId != propertyId)
        .toList();
    final utilityRecords = _snapshot.utilityRecords
        .where((record) => record.propertyId != propertyId)
        .toList();
    final documents = _snapshot.documents
        .where((document) => document.propertyId != propertyId)
        .toList();
    final activities = _snapshot.activities
        .where((activity) => activity.propertyId != propertyId)
        .toList();
    final billingCycles = _snapshot.billingCycles
        .where((cycle) => cycle.propertyId != propertyId)
        .toList();
    final cycleIds = billingCycles.map((cycle) => cycle.id).toSet();
    final payments = _snapshot.payments
        .where((payment) => cycleIds.contains(payment.billingCycleId))
        .toList();
    _electricityReadings.removeWhere(
      (reading) => !rooms.contains(reading.roomId),
    );

    _snapshot = PortfolioSnapshot(
      properties: properties,
      tenants: tenants,
      revenue: _snapshot.revenue,
      billingCycles: billingCycles,
      payments: payments,
      utilityUsage: _snapshot.utilityUsage,
      utilityRecords: utilityRecords,
      documents: documents,
      activities: activities,
      pendingReceivables: _snapshot.pendingReceivables
          .where((item) => item.propertyId != propertyId)
          .toList(),
      completedReceivables: _snapshot.completedReceivables
          .where((item) => item.propertyId != propertyId)
          .toList(),
      preferences: _snapshot.preferences,
    );
  }

  @override
  Future<void> saveRoom(RoomDraft draft) async {
    final properties = [..._snapshot.properties];
    final propertyIndex = properties.indexWhere(
      (property) => property.id == draft.propertyId,
    );
    if (propertyIndex < 0) return;
    final property = properties[propertyIndex];
    final rooms = [...property.rooms];
    final id = draft.id ?? 'r-${DateTime.now().microsecondsSinceEpoch}';
    final roomIndex = rooms.indexWhere((room) => room.id == id);
    final nextRoom = Room(
      id: id,
      propertyId: draft.propertyId,
      label: draft.label,
      tenantName: draft.tenantName,
      dueDay: draft.dueDay,
      monthlyRent: draft.monthlyRent,
      electricityRate: draft.electricityRate,
      waterCost: draft.waterCost,
      internetCost: draft.internetCost,
      status: draft.status,
      note: draft.note,
    );
    if (roomIndex >= 0) {
      rooms[roomIndex] = nextRoom;
    } else {
      rooms.add(nextRoom);
    }
    final occupied = rooms
        .where((room) => room.tenantName.trim().isNotEmpty)
        .length;
    properties[propertyIndex] = property.copyWith(
      rooms: rooms,
      totalRooms: rooms.length,
      occupiedRooms: occupied,
    );
    _snapshot = PortfolioSnapshot(
      properties: properties,
      tenants: _snapshot.tenants,
      revenue: _snapshot.revenue,
      billingCycles: _snapshot.billingCycles,
      payments: _snapshot.payments,
      utilityUsage: _snapshot.utilityUsage,
      utilityRecords: _snapshot.utilityRecords,
      documents: _snapshot.documents,
      activities: _snapshot.activities,
      pendingReceivables: _snapshot.pendingReceivables,
      completedReceivables: _snapshot.completedReceivables,
      preferences: _snapshot.preferences,
    );
  }

  @override
  Future<void> addUtilityRecord(UtilityRecordDraft draft) async {
    final records = [..._snapshot.utilityRecords];
    records.insert(
      0,
      UtilityRecord(
        id: 'u-${DateTime.now().microsecondsSinceEpoch}',
        propertyId: draft.propertyId,
        propertyName: draft.propertyName,
        roomId: draft.roomId,
        roomLabel: draft.roomLabel,
        tenantName: draft.tenantName,
        type: draft.type,
        meterReading: draft.meterReading,
        amount: draft.amount,
        note: draft.note,
        imagePath: draft.imagePath,
        recordedAt: draft.recordedAt,
      ),
    );
    _snapshot = PortfolioSnapshot(
      properties: _snapshot.properties,
      tenants: _snapshot.tenants,
      revenue: _snapshot.revenue,
      billingCycles: _snapshot.billingCycles,
      payments: _snapshot.payments,
      utilityUsage: _snapshot.utilityUsage,
      utilityRecords: records,
      documents: _snapshot.documents,
      activities: _snapshot.activities,
      pendingReceivables: _snapshot.pendingReceivables,
      completedReceivables: _snapshot.completedReceivables,
      preferences: _snapshot.preferences,
    );
  }

  @override
  Future<void> addDocument(DocumentDraft draft) async {
    final documents = [..._snapshot.documents];
    documents.insert(
      0,
      DocumentRecord(
        id: 'd-${DateTime.now().microsecondsSinceEpoch}',
        propertyId: draft.propertyId,
        propertyName: draft.propertyName,
        roomId: draft.roomId,
        roomLabel: draft.roomLabel,
        title: draft.title,
        category: draft.category,
        filePath: draft.filePath,
        note: draft.note,
        createdAt: DateTime.now(),
      ),
    );
    _snapshot = PortfolioSnapshot(
      properties: _snapshot.properties,
      tenants: _snapshot.tenants,
      revenue: _snapshot.revenue,
      billingCycles: _snapshot.billingCycles,
      payments: _snapshot.payments,
      utilityUsage: _snapshot.utilityUsage,
      utilityRecords: _snapshot.utilityRecords,
      documents: documents,
      activities: _snapshot.activities,
      pendingReceivables: _snapshot.pendingReceivables,
      completedReceivables: _snapshot.completedReceivables,
      preferences: _snapshot.preferences,
    );
  }

  @override
  Future<void> updateDocument(String documentId, DocumentDraft draft) async {
    final documents = [..._snapshot.documents];
    final index = documents.indexWhere((item) => item.id == documentId);
    if (index < 0) return;
    final existing = documents[index];
    documents[index] = DocumentRecord(
      id: existing.id,
      propertyId: draft.propertyId,
      propertyName: draft.propertyName,
      roomId: draft.roomId,
      roomLabel: draft.roomLabel,
      title: draft.title,
      category: draft.category,
      filePath: draft.filePath,
      note: draft.note,
      createdAt: existing.createdAt,
    );
    _snapshot = PortfolioSnapshot(
      properties: _snapshot.properties,
      tenants: _snapshot.tenants,
      revenue: _snapshot.revenue,
      billingCycles: _snapshot.billingCycles,
      payments: _snapshot.payments,
      utilityUsage: _snapshot.utilityUsage,
      utilityRecords: _snapshot.utilityRecords,
      documents: documents,
      activities: _snapshot.activities,
      pendingReceivables: _snapshot.pendingReceivables,
      completedReceivables: _snapshot.completedReceivables,
      preferences: _snapshot.preferences,
    );
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    final documents = _snapshot.documents
        .where((item) => item.id != documentId)
        .toList();
    _snapshot = PortfolioSnapshot(
      properties: _snapshot.properties,
      tenants: _snapshot.tenants,
      revenue: _snapshot.revenue,
      billingCycles: _snapshot.billingCycles,
      payments: _snapshot.payments,
      utilityUsage: _snapshot.utilityUsage,
      utilityRecords: _snapshot.utilityRecords,
      documents: documents,
      activities: _snapshot.activities,
      pendingReceivables: _snapshot.pendingReceivables,
      completedReceivables: _snapshot.completedReceivables,
      preferences: _snapshot.preferences,
    );
  }

  @override
  Future<void> markReceivablePaid(String receivableId) async {
    final pending = [..._snapshot.pendingReceivables];
    final completed = [..._snapshot.completedReceivables];
    final index = pending.indexWhere((item) => item.id == receivableId);
    if (index < 0) return;
    final item = pending.removeAt(index);
    completed.insert(
      0,
      PaymentReceivable(
        id: item.id,
        propertyId: item.propertyId,
        propertyName: item.propertyName,
        roomId: item.roomId,
        roomLabel: item.roomLabel,
        amount: item.amount,
        overdueLabel: 'Collected today',
        tags: item.tags,
        status: PaymentStatus.paid,
      ),
    );
    _snapshot = PortfolioSnapshot(
      properties: _snapshot.properties,
      tenants: _snapshot.tenants,
      revenue: _snapshot.revenue,
      billingCycles: _snapshot.billingCycles,
      payments: _snapshot.payments,
      utilityUsage: _snapshot.utilityUsage,
      utilityRecords: _snapshot.utilityRecords,
      documents: _snapshot.documents,
      activities: _snapshot.activities,
      pendingReceivables: pending,
      completedReceivables: completed,
      preferences: _snapshot.preferences,
    );
  }

  @override
  Future<void> recordPartialPayment(String receivableId, double amount) async {
    final pending = [..._snapshot.pendingReceivables];
    final completed = [..._snapshot.completedReceivables];
    final index = pending.indexWhere((item) => item.id == receivableId);
    if (index < 0) return;
    final item = pending[index];
    if (amount <= 0 || amount >= item.amount) {
      throw StateError(
        'Partial amount must be greater than 0 and less than due amount.',
      );
    }
    pending[index] = PaymentReceivable(
      id: item.id,
      propertyId: item.propertyId,
      propertyName: item.propertyName,
      roomId: item.roomId,
      roomLabel: item.roomLabel,
      amount: item.amount - amount,
      overdueLabel: 'Partially collected',
      tags: item.tags,
      status: PaymentStatus.partial,
    );
    _snapshot = PortfolioSnapshot(
      properties: _snapshot.properties,
      tenants: _snapshot.tenants,
      revenue: _snapshot.revenue,
      billingCycles: _snapshot.billingCycles,
      payments: _snapshot.payments,
      utilityUsage: _snapshot.utilityUsage,
      utilityRecords: _snapshot.utilityRecords,
      documents: _snapshot.documents,
      activities: _snapshot.activities,
      pendingReceivables: pending,
      completedReceivables: completed,
      preferences: _snapshot.preferences,
    );
  }

  @override
  Future<void> saveElectricityReading(ElectricityReadingDraft draft) async {
    final roomReadings =
        _electricityReadings
            .where((item) => item.roomId == draft.roomId)
            .toList()
          ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    final previous = roomReadings.isEmpty
        ? 0.0
        : roomReadings.first.currentReading;
    if (draft.currentReading < previous) {
      throw StateError('Current reading cannot be less than previous reading.');
    }
    if (draft.rate <= 0) {
      throw StateError('Electricity rate must be greater than zero.');
    }
    final units = draft.currentReading - previous;
    final cost = units * draft.rate;

    _electricityReadings.insert(
      0,
      ElectricityReading(
        id: 'e-${DateTime.now().microsecondsSinceEpoch}',
        propertyId: draft.propertyId,
        propertyName: draft.propertyName,
        roomId: draft.roomId,
        roomLabel: draft.roomLabel,
        tenantName: draft.tenantName,
        previousReading: previous,
        currentReading: draft.currentReading,
        unitsConsumed: units,
        rate: draft.rate,
        totalCost: cost,
        recordedAt: draft.recordedAt,
        imagePath: draft.imagePath,
        note: draft.note,
      ),
    );

    final records = [..._snapshot.utilityRecords];
    records.insert(
      0,
      UtilityRecord(
        id: 'u-${DateTime.now().microsecondsSinceEpoch}',
        propertyId: draft.propertyId,
        propertyName: draft.propertyName,
        roomId: draft.roomId,
        roomLabel: draft.roomLabel,
        tenantName: draft.tenantName,
        type: UtilityType.electricity,
        meterReading: draft.currentReading,
        amount: cost,
        note: draft.note,
        imagePath: draft.imagePath,
        recordedAt: draft.recordedAt,
      ),
    );
    _snapshot = PortfolioSnapshot(
      properties: _snapshot.properties,
      tenants: _snapshot.tenants,
      revenue: _snapshot.revenue,
      billingCycles: _snapshot.billingCycles,
      payments: _snapshot.payments,
      utilityUsage: _snapshot.utilityUsage,
      utilityRecords: records,
      documents: _snapshot.documents,
      activities: _snapshot.activities,
      pendingReceivables: _snapshot.pendingReceivables,
      completedReceivables: _snapshot.completedReceivables,
      preferences: _snapshot.preferences,
    );
  }

  @override
  Future<List<ElectricityReading>> loadElectricityReadingsForRoom(
    String roomId,
  ) async {
    final readings =
        _electricityReadings.where((item) => item.roomId == roomId).toList()
          ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return readings;
  }

  @override
  Future<String> backupData() async {
    return '/in-memory/backup-not-available.json';
  }

  @override
  Future<String> exportData() async {
    return '/in-memory/export-not-available.json';
  }

  @override
  Future<void> restoreData(String backupPath) async {}
}
