import 'package:flutter/material.dart';

import '../database/app_database.dart';
import '../models/portfolio_snapshot.dart';
import 'seed_data.dart';

abstract class RentalRepository {
  Future<PortfolioSnapshot> loadSnapshot();

  Future<ThemeMode?> loadThemeMode();

  Future<void> saveThemeMode(ThemeMode mode);
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
}

class InMemoryRentalRepository implements RentalRepository {
  InMemoryRentalRepository({PortfolioSnapshot? snapshot, ThemeMode? themeMode})
    : _snapshot = snapshot ?? SeedData.snapshot,
      _themeMode = themeMode ?? ThemeMode.light;

  final PortfolioSnapshot _snapshot;
  ThemeMode _themeMode;

  @override
  Future<PortfolioSnapshot> loadSnapshot() async => _snapshot;

  @override
  Future<ThemeMode?> loadThemeMode() async => _themeMode;

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    _themeMode = mode;
  }
}
