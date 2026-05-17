import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../providers/app_controller.dart';
import '../widgets/app_bottom_nav.dart';
import 'analytics_screen.dart';
import 'dashboard_screen.dart';
import 'payments_screen.dart';
import 'settings_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, _) {
        if (controller.isLoading || controller.snapshot == null) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF6F7FB), Color(0xFFE8F4F3)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryContainer],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.15),
                            blurRadius: 28,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.home_work_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Kothabhada',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Loading your offline portfolio...',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final snapshot = controller.snapshot!;
        final screens = [
          DashboardScreen(snapshot: snapshot),
          AnalyticsScreen(snapshot: snapshot),
          PaymentsScreen(snapshot: snapshot),
          SettingsScreen(snapshot: snapshot),
        ];

        return Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: KeyedSubtree(key: ValueKey(_index), child: screens[_index]),
          ),
          bottomNavigationBar: AppBottomNav(
            currentIndex: _index,
            onSelected: (value) => setState(() => _index = value),
          ),
        );
      },
    );
  }
}
