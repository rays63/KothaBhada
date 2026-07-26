import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n_ext.dart';
import '../../../data/security_service.dart';
import '../../../widgets/kit/kit.dart';
import '../widgets/screen_header.dart';

/// Create + confirm a new PIN (Settings → Security → Change PIN).
class ChangePinScreen extends ConsumerStatefulWidget {
  const ChangePinScreen({super.key});

  @override
  ConsumerState<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends ConsumerState<ChangePinScreen> {
  bool _confirming = false;
  String _first = '';
  String _entry = '';
  bool _error = false;
  static const _len = 4;

  void _onKey(String d) {
    if (_entry.length >= _len) return;
    setState(() {
      _entry += d;
      _error = false;
    });
    if (_entry.length == _len) _next();
  }

  void _onBackspace() {
    if (_entry.isEmpty) return;
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  Future<void> _next() async {
    if (!_confirming) {
      _first = _entry;
      await Future<void>.delayed(const Duration(milliseconds: 120));
      setState(() {
        _entry = '';
        _confirming = true;
      });
    } else {
      if (_entry == _first) {
        await ref.read(securityServiceProvider).setPin(_first);
        if (!mounted) return;
        Navigator.of(context).pop();
        showAppToast(context, context.l10n.secPinUpdated);
      } else {
        setState(() {
          _error = true;
          _entry = '';
          _first = '';
          _confirming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: l.secChangePin),
            const SizedBox(height: 20),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: t.brand2.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(Icons.lock_outline_rounded, size: 28, color: t.brand2),
            ),
            const SizedBox(height: 16),
            Text(_confirming ? l.secConfirmNewPin : l.secEnterNewPin,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              _error ? l.onbPinMismatch : l.secChoosePinSub,
              style: TextStyle(fontSize: 13, color: _error ? t.due : t.text2),
            ),
            const SizedBox(height: 26),
            PinDots(length: _len, filled: _entry.length, error: _error),
            const Spacer(),
            PinPad(onKey: _onKey, onBackspace: _onBackspace),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
