import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Handles the app lock: a hashed PIN in secure storage + optional biometric
/// unlock via local_auth. The raw PIN is never persisted — only a salted
/// SHA-256 hash (PRD §2 / §5.9).
class SecurityService {
  SecurityService({FlutterSecureStorage? storage, LocalAuthentication? auth})
      : _storage = storage ?? const FlutterSecureStorage(),
        _auth = auth ?? LocalAuthentication();

  final FlutterSecureStorage _storage;
  final LocalAuthentication _auth;

  static const _kHash = 'pin_hash';
  static const _kSalt = 'pin_salt';
  static const _kBiometric = 'biometric_enabled';

  String _hash(String pin, String salt) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();

  String _newSalt() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    return base64Url.encode(bytes);
  }

  Future<bool> hasPin() async => (await _storage.read(key: _kHash)) != null;

  Future<void> setPin(String pin) async {
    final salt = _newSalt();
    await _storage.write(key: _kSalt, value: salt);
    await _storage.write(key: _kHash, value: _hash(pin, salt));
  }

  Future<bool> verifyPin(String pin) async {
    final salt = await _storage.read(key: _kSalt);
    final hash = await _storage.read(key: _kHash);
    if (salt == null || hash == null) return false;
    return _hash(pin, salt) == hash;
  }

  /// Wipes the PIN + biometric preference (used by a reset flow).
  Future<void> clearPin() async {
    await _storage.delete(key: _kHash);
    await _storage.delete(key: _kSalt);
    await _storage.delete(key: _kBiometric);
  }

  Future<bool> biometricEnabled() async =>
      (await _storage.read(key: _kBiometric)) == 'true';

  Future<void> setBiometricEnabled(bool enabled) =>
      _storage.write(key: _kBiometric, value: enabled ? 'true' : 'false');

  /// Whether the device actually has biometrics available to enrol.
  Future<bool> canUseBiometrics() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      if (!supported && !canCheck) return false;
      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty || supported;
    } catch (_) {
      return false;
    }
  }

  /// Prompts the OS biometric sheet. Returns true on success; false on
  /// cancel/failure/unavailability (never throws).
  Future<bool> authenticate(
      {String reason = 'Unlock Kothabhada'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}

final securityServiceProvider =
    Provider<SecurityService>((ref) => SecurityService());

/// Resolves once at startup: does a PIN already exist? Drives the app gate
/// (onboarding vs. lock screen).
final hasPinProvider = FutureProvider<bool>(
  (ref) => ref.watch(securityServiceProvider).hasPin(),
);

/// Set true (e.g. from Settings → "Lock app") to force the lock screen without
/// leaving the app. The lock screen clears it on successful unlock.
final appLockedProvider = StateProvider<bool>((ref) => false);
