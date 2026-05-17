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

  Future<void> markReceivablePaid(String receivableId) async {
    await _runSaving(() async {
      await _repository.markReceivablePaid(receivableId);
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
