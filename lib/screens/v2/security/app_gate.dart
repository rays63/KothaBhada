import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/notification_service.dart';
import '../../../data/providers.dart';
import '../../../data/security_service.dart';
import '../root_shell.dart';
import 'lock_screen.dart';
import 'onboarding_screen.dart';
import 'splash_screen.dart';

/// Decides what the user sees on launch:
/// - while the PIN check resolves → [SplashScreen]
/// - no PIN yet → [OnboardingScreen] (first run)
/// - PIN exists & not yet unlocked → [LockScreen]
/// - unlocked → [RootShell]
class AppGate extends ConsumerStatefulWidget {
  const AppGate({super.key});

  @override
  ConsumerState<AppGate> createState() => _AppGateState();
}

class _AppGateState extends ConsumerState<AppGate> {
  bool _unlocked = false;

  @override
  Widget build(BuildContext context) {
    // Reschedule rent reminders whenever the portfolio data changes.
    ref.listen(portfolioProvider, (_, next) {
      final snapshot = next.valueOrNull;
      if (snapshot != null) {
        ref.read(notificationServiceProvider).syncRentReminders(snapshot);
      }
    });

    // A lock request (Settings → "Lock app") re-locks without leaving the app.
    final locked = ref.watch(appLockedProvider);
    if (_unlocked && !locked) return const RootShell();

    final hasPin = ref.watch(hasPinProvider);
    return hasPin.when(
      loading: () => const SplashScreen(),
      error: (_, _) => const SplashScreen(),
      data: (exists) {
        if (!exists) {
          return OnboardingScreen(
            onComplete: () => setState(() => _unlocked = true),
          );
        }
        return LockScreen(
          onUnlocked: () {
            ref.read(appLockedProvider.notifier).state = false;
            setState(() => _unlocked = true);
          },
        );
      },
    );
  }
}
