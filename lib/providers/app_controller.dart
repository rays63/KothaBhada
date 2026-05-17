import 'package:flutter/material.dart';

import '../models/portfolio_snapshot.dart';
import '../models/property_models.dart';
import '../services/rental_repository.dart';

class AppController extends ChangeNotifier {
  AppController(this._repository);

  final RentalRepository _repository;

  PortfolioSnapshot? _snapshot;
  ThemeMode _themeMode = ThemeMode.light;
  bool _loading = true;
  bool _saving = false;

  PortfolioSnapshot? get snapshot => _snapshot;
  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _loading;
  bool get isSaving => _saving;

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    _themeMode = await _repository.loadThemeMode() ?? ThemeMode.light;
    _snapshot = await _repository.loadSnapshot();
    _loading = false;
    notifyListeners();
  }

  Future<void> setThemeMode(bool dark) async {
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _repository.saveThemeMode(_themeMode);
  }

  Future<void> saveProperty(PropertyDraft draft) async {
    await _runSaving(() async {
      await _repository.saveProperty(draft);
      _snapshot = await _repository.loadSnapshot();
    });
  }

  Future<void> deleteProperty(String propertyId) async {
    await _runSaving(() async {
      await _repository.deleteProperty(propertyId);
      _snapshot = await _repository.loadSnapshot();
    });
  }

  Future<void> saveRoom(RoomDraft draft) async {
    await _runSaving(() async {
      await _repository.saveRoom(draft);
      _snapshot = await _repository.loadSnapshot();
    });
  }

  Future<void> addUtilityRecord(UtilityRecordDraft draft) async {
    await _runSaving(() async {
      await _repository.addUtilityRecord(draft);
      _snapshot = await _repository.loadSnapshot();
    });
  }

  Future<void> addDocument(DocumentDraft draft) async {
    await _runSaving(() async {
      await _repository.addDocument(draft);
      _snapshot = await _repository.loadSnapshot();
    });
  }

  Future<void> updateDocument(String documentId, DocumentDraft draft) async {
    await _runSaving(() async {
      await _repository.updateDocument(documentId, draft);
      _snapshot = await _repository.loadSnapshot();
    });
  }

  Future<void> deleteDocument(String documentId) async {
    await _runSaving(() async {
      await _repository.deleteDocument(documentId);
      _snapshot = await _repository.loadSnapshot();
    });
  }

  Future<void> markReceivablePaid(String receivableId) async {
    await _runSaving(() async {
      await _repository.markReceivablePaid(receivableId);
      _snapshot = await _repository.loadSnapshot();
    });
  }

  Future<void> recordPartialPayment(String receivableId, double amount) async {
    await _runSaving(() async {
      await _repository.recordPartialPayment(receivableId, amount);
      _snapshot = await _repository.loadSnapshot();
    });
  }

  Future<void> saveElectricityReading(ElectricityReadingDraft draft) async {
    await _runSaving(() async {
      await _repository.saveElectricityReading(draft);
      _snapshot = await _repository.loadSnapshot();
    });
  }

  Future<List<ElectricityReading>> loadElectricityReadingsForRoom(
    String roomId,
  ) {
    return _repository.loadElectricityReadingsForRoom(roomId);
  }

  Future<String> backupData() => _repository.backupData();

  Future<String> exportData() => _repository.exportData();

  Future<void> restoreData(String backupPath) async {
    await _runSaving(() async {
      await _repository.restoreData(backupPath);
      _snapshot = await _repository.loadSnapshot();
    });
  }

  Future<void> _runSaving(Future<void> Function() work) async {
    _saving = true;
    notifyListeners();
    await work();
    _saving = false;
    notifyListeners();
  }
}
