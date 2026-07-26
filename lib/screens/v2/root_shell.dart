import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/kit/kit.dart';
import 'analytics/analytics_screen.dart';
import 'dashboard_screen.dart';
import 'payments/payments_screen.dart';
import 'settings/settings_screen.dart';

/// The main navigation shell: four tabs behind a floating nav bar.
class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key});

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final destinations = [
      NavDestination(icon: Icons.home_rounded, label: l.navHome),
      NavDestination(icon: Icons.bar_chart_rounded, label: l.navAnalytics),
      NavDestination(icon: Icons.credit_card_rounded, label: l.navPayments),
      NavDestination(icon: Icons.settings_rounded, label: l.navSettings),
    ];
    final portfolio = ref.watch(portfolioProvider);

    return portfolio.when(
      loading: () => const _LoadingScreen(),
      error: (e, _) => _ErrorScreen(message: '$e'),
      data: (_) => Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _index,
          children: const [
            DashboardScreen(),
            AnalyticsScreen(),
            PaymentsScreen(),
            SettingsScreen(),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            // Sit just above the home indicator (design ≈ 18px from the edge).
            (MediaQuery.of(context).padding.bottom * 0.5).clamp(10, 20) + 4,
          ),
          child: FloatingNavBar(
            currentIndex: _index,
            destinations: destinations,
            onSelected: (i) => setState(() => _index = i),
          ),
        ),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                gradient: t.brandGradient,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: t.brand2.withValues(alpha: 0.35),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: const Icon(Icons.home_work_rounded,
                  color: Colors.white, size: 36),
            ),
            const SizedBox(height: 18),
            Text('Kothabhada', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Loading your offline portfolio…',
                style: TextStyle(color: t.text2, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, color: t.due, size: 42),
              const SizedBox(height: 12),
              Text('Something went wrong',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: t.text2, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
