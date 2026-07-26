import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n_ext.dart';
import '../../../data/security_service.dart';
import '../../../widgets/kit/kit.dart';

/// Returning-user lock screen (design screen 06): PIN entry with an optional
/// biometric shortcut. Calls [onUnlocked] on success.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key, required this.onUnlocked});

  final VoidCallback onUnlocked;

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _entry = '';
  bool _error = false;
  bool _biometricAvailable = false;
  static const _pinLength = 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeBiometric());
  }

  Future<void> _maybeBiometric() async {
    final security = ref.read(securityServiceProvider);
    final enabled = await security.biometricEnabled();
    final can = await security.canUseBiometrics();
    if (!mounted) return;
    setState(() => _biometricAvailable = enabled && can);
    if (enabled && can) {
      final ok = await security.authenticate();
      if (ok && mounted) widget.onUnlocked();
    }
  }

  void _onKey(String d) {
    if (_entry.length >= _pinLength) return;
    setState(() {
      _entry += d;
      _error = false;
    });
    if (_entry.length == _pinLength) _verify();
  }

  void _onBackspace() {
    if (_entry.isEmpty) return;
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  Future<void> _verify() async {
    final ok = await ref.read(securityServiceProvider).verifyPin(_entry);
    if (!mounted) return;
    if (ok) {
      widget.onUnlocked();
    } else {
      setState(() {
        _error = true;
        _entry = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 44, 22, 28),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: t.brandGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: t.brand2.withValues(alpha: 0.34),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.home_work_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(height: 14),
              Text(context.l10n.lockWelcomeBack,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 5),
              Text(
                _error ? context.l10n.lockIncorrectPin : context.l10n.lockEnterPin,
                style:
                    TextStyle(fontSize: 13, color: _error ? t.due : t.text2),
              ),
              const SizedBox(height: 24),
              PinDots(length: _pinLength, filled: _entry.length, error: _error),
              const Spacer(),
              PinPad(
                onKey: _onKey,
                onBackspace: _onBackspace,
                trailing: _biometricAvailable
                    ? IconButton(
                        onPressed: _maybeBiometric,
                        icon: Icon(Icons.fingerprint_rounded,
                            color: t.brand2, size: 30),
                      )
                    : null,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
