import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n_ext.dart';
import '../../../data/security_service.dart';
import '../../../widgets/kit/kit.dart';
import '../widgets/screen_header.dart';
import 'change_pin_screen.dart';

/// Security settings (design screen 35): PIN lock (required), biometric toggle,
/// change PIN.
class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = ref.read(securityServiceProvider);
    final enabled = await s.biometricEnabled();
    final available = await s.canUseBiometrics();
    if (!mounted) return;
    setState(() {
      _biometricEnabled = enabled;
      _biometricAvailable = available;
      _loading = false;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    final s = ref.read(securityServiceProvider);
    if (value) {
      final ok = await s.authenticate(reason: 'Enable biometric unlock');
      if (!ok) return;
    }
    await s.setBiometricEnabled(value);
    if (mounted) setState(() => _biometricEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(title: l.secTitle),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: t.surface,
                      borderRadius: BorderRadius.circular(AppTokens.rCard),
                      boxShadow: t.shadowSm,
                      border: t.isDark ? Border.all(color: t.line) : null,
                    ),
                    child: Column(
                      children: [
                        _row(
                          context,
                          title: l.secAppLock,
                          subtitle: l.secRequiredEveryOpen,
                          trailing: const AppToggle(value: true, onChanged: _noop),
                        ),
                        Divider(height: 1, color: t.line),
                        _row(
                          context,
                          title: l.secBiometric,
                          subtitle: _biometricAvailable
                              ? l.secFingerprintFace
                              : l.secNotAvailable,
                          trailing: _loading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : AppToggle(
                                  value: _biometricEnabled,
                                  onChanged: _biometricAvailable
                                      ? _toggleBiometric
                                      : (_) {},
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppButton.outline(
                    label: l.secChangePin,
                    icon: Icons.lock_outline_rounded,
                    block: true,
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ChangePinScreen())),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    color: t.isDark ? t.surface : t.surface2,
                    child: Row(
                      children: [
                        Icon(Icons.shield_outlined, size: 18, color: t.brand2),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l.secPinDeviceOnly,
                            style: TextStyle(
                                fontSize: 12, height: 1.5, color: t.text2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _noop(bool _) {}

  Widget _row(BuildContext context,
      {required String title,
      required String subtitle,
      required Widget trailing}) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: t.text2)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
