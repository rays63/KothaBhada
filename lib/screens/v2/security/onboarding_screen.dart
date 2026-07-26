import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n_ext.dart';
import '../../../data/providers.dart';
import '../../../data/security_service.dart';
import '../../../widgets/kit/kit.dart';

/// First-run onboarding: intro slides → create PIN → confirm PIN → optional
/// biometric (design screens 02–05). Calls [onComplete] once a PIN is set.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

enum _Step { intro, name, createPin, confirmPin, biometric }

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  _Step _step = _Step.intro;
  final _pageController = PageController();
  int _introPage = 0;

  final _name = TextEditingController();
  String _firstPin = '';
  String _entry = '';
  bool _error = false;

  static const _pinLength = 4;

  @override
  void dispose() {
    _pageController.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _saveNameAndContinue() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    await ref.read(repositoryProvider).setSetting('landlord_name', name);
    // Reload the portfolio so the dashboard greets the user by name.
    ref.invalidate(portfolioProvider);
    if (mounted) setState(() => _step = _Step.createPin);
  }

  void _onKey(String d) {
    if (_entry.length >= _pinLength) return;
    setState(() {
      _entry += d;
      _error = false;
    });
    if (_entry.length == _pinLength) _onPinComplete();
  }

  void _onBackspace() {
    if (_entry.isEmpty) return;
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  Future<void> _onPinComplete() async {
    if (_step == _Step.createPin) {
      _firstPin = _entry;
      // brief pause so the last dot fills before switching
      await Future<void>.delayed(const Duration(milliseconds: 120));
      setState(() {
        _entry = '';
        _step = _Step.confirmPin;
      });
    } else if (_step == _Step.confirmPin) {
      if (_entry == _firstPin) {
        final security = ref.read(securityServiceProvider);
        await security.setPin(_firstPin);
        final canBiometric = await security.canUseBiometrics();
        if (!mounted) return;
        if (canBiometric) {
          setState(() => _step = _Step.biometric);
        } else {
          widget.onComplete();
        }
      } else {
        setState(() {
          _error = true;
          _entry = '';
          _firstPin = '';
          _step = _Step.createPin;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: switch (_step) {
          _Step.intro => _intro(),
          _Step.name => _nameStep(),
          _Step.createPin => _PinStep(
              icon: Icons.lock_outline_rounded,
              title: context.l10n.onbCreatePin,
              subtitle: context.l10n.onbCreatePinSub,
              length: _pinLength,
              filled: _entry.length,
              error: _error,
              onKey: _onKey,
              onBackspace: _onBackspace,
            ),
          _Step.confirmPin => _PinStep(
              icon: Icons.check_rounded,
              title: context.l10n.onbConfirmPin,
              subtitle: context.l10n.onbConfirmPinSub,
              length: _pinLength,
              filled: _entry.length,
              error: _error,
              onKey: _onKey,
              onBackspace: _onBackspace,
            ),
          _Step.biometric => _biometric(),
        },
      ),
    );
  }

  Widget _intro() {
    final t = context.tokens;
    final l = context.l10n;
    final slides = [
      _IntroSlide(
        icon: Icons.public_rounded,
        title: l.onbIntro1Title,
        body: l.onbIntro1Body,
      ),
      _IntroSlide(
        icon: Icons.receipt_long_rounded,
        title: l.onbIntro2Title,
        body: l.onbIntro2Body,
      ),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => setState(() => _step = _Step.name),
              child: Text(l.commonSkip,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: t.text2)),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _introPage = i),
              children: slides,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(slides.length, (i) {
              final active = i == _introPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? t.brand2 : t.text2.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          AppButton.primary(
            label: _introPage == slides.length - 1
                ? l.onbGetStarted
                : l.commonNext,
            block: true,
            onPressed: () {
              if (_introPage == slides.length - 1) {
                setState(() => _step = _Step.name);
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _nameStep() {
    final t = context.tokens;
    final canContinue = _name.text.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  t.brand2.withValues(alpha: 0.18),
                  t.sky.withValues(alpha: 0.16),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(Icons.waving_hand_rounded, size: 60, color: t.brand2),
          ),
          const SizedBox(height: 24),
          Text(context.l10n.onbNameTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text(
            context.l10n.onbNameBody,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.6, color: t.text2),
          ),
          const SizedBox(height: 24),
          AppTextField(
            hint: context.l10n.onbNameHint,
            controller: _name,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.person_outline_rounded,
            onChanged: (_) => setState(() {}),
          ),
          const Spacer(),
          AppButton.primary(
            label: context.l10n.commonContinue,
            block: true,
            onPressed: canContinue ? _saveNameAndContinue : null,
          ),
        ],
      ),
    );
  }

  Widget _biometric() {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  t.violet.withValues(alpha: 0.18),
                  t.brand2.withValues(alpha: 0.16),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(Icons.fingerprint_rounded, size: 64, color: t.violet),
          ),
          const SizedBox(height: 18),
          Text(context.l10n.onbFasterUnlock,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text(
            context.l10n.onbBiometricBody,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.6, color: t.text2),
          ),
          const SizedBox(height: 22),
          AppButton.primary(
            label: context.l10n.onbEnableBiometrics,
            icon: Icons.fingerprint_rounded,
            block: true,
            onPressed: () async {
              final security = ref.read(securityServiceProvider);
              final ok = await security.authenticate(
                  reason: 'Enable biometric unlock');
              if (ok) await security.setBiometricEnabled(true);
              widget.onComplete();
            },
          ),
          const SizedBox(height: 10),
          AppButton.ghost(
            label: context.l10n.onbMaybeLater,
            block: true,
            onPressed: widget.onComplete,
          ),
        ],
      ),
    );
  }
}

class _IntroSlide extends StatelessWidget {
  const _IntroSlide(
      {required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                t.brand2.withValues(alpha: 0.18),
                t.sky.withValues(alpha: 0.16),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(44),
          ),
          child: Icon(icon, size: 80, color: t.brand2),
        ),
        const SizedBox(height: 24),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.6, color: t.text2),
          ),
        ),
      ],
    );
  }
}

class _PinStep extends StatelessWidget {
  const _PinStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.length,
    required this.filled,
    required this.error,
    required this.onKey,
    required this.onBackspace,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int length;
  final int filled;
  final bool error;
  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 36, 22, 28),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: t.brand2.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, size: 28, color: t.brand2),
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            error ? context.l10n.onbPinMismatch : subtitle,
            style: TextStyle(fontSize: 13, color: error ? t.due : t.text2),
          ),
          const SizedBox(height: 26),
          PinDots(length: length, filled: filled, error: error),
          const SizedBox(height: 34),
          PinPad(onKey: onKey, onBackspace: onBackspace),
        ],
      ),
    );
  }
}
