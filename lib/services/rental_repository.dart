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

  Future<void> saveRoom(RoomDraft draft);

  Future<void> addUtilityRecord(UtilityRecordDraft draft);

  Future<void> addDocument(DocumentDraft draft);

  Future<void> markReceivablePaid(String receivableId);
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
  Future<void> saveRoom(RoomDraft draft) => _database.saveRoom(draft);

  @override
  Future<void> addUtilityRecord(UtilityRecordDraft draft) =>
      _database.addUtilityRecord(draft);

  @override
  Future<void> addDocument(DocumentDraft draft) => _database.addDocument(draft);

  @override
  Future<void> markReceivablePaid(String receivableId) =>
      _database.markReceivablePaid(receivableId);
}

class InMemoryRentalRepository implements RentalRepository {
  InMemoryRentalRepository({PortfolioSnapshot? snapshot, ThemeMode? themeMode})
    : _snapshot = snapshot ?? SeedData.snapshot,
      _themeMode = themeMode ?? ThemeMode.light;

  PortfolioSnapshot _snapshot;
  ThemeMode _themeMode;

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
      utilityUsage: _snapshot.utilityUsage,
      utilityRecords: _snapshot.utilityRecords,
      documents: _snapshot.documents,
      activities: _snapshot.activities,
      pendingReceivables: pending,
      completedReceivables: completed,
      preferences: _snapshot.preferences,
    );
  }
}
