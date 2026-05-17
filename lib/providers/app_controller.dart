import 'package:flutter/material.dart';

import '../models/portfolio_snapshot.dart';
import '../services/rental_repository.dart';

class AppController extends ChangeNotifier {
  AppController(this._repository);

  final RentalRepository _repository;

  PortfolioSnapshot? _snapshot;
  ThemeMode _themeMode = ThemeMode.light;
  bool _loading = true;

  PortfolioSnapshot? get snapshot => _snapshot;
  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _loading;

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
}
