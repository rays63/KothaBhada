import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/portfolio_snapshot.dart';
import '../providers/app_controller.dart';
import '../widgets/settings_group.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.snapshot});

  final PortfolioSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Tune the app for fast daily operations while keeping every record available offline.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryContainer],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.preferences.landlordName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Primary landlord account',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFF8E5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Offline ready',
                    style: TextStyle(
                      color: Color(0xFF0F6A32),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SettingsGroup(
            title: 'Operations',
            children: [
              _SettingsRow(
                title: 'Currency',
                value: snapshot.preferences.currencyCode,
                icon: Icons.currency_rupee_rounded,
              ),
              _SettingsRow(
                title: 'Reminder day',
                value: 'Every month on ${snapshot.preferences.reminderDay}',
                icon: Icons.notifications_active_outlined,
              ),
              _SettingsRow(
                title: 'Data engine',
                value: 'SQLite on local device storage',
                icon: Icons.storage_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),
          SettingsGroup(
            title: 'Appearance',
            children: [
              Row(
                children: [
                  const Icon(Icons.dark_mode_outlined, color: AppTheme.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dark mode',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Switch between light editorial and night operations modes.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: controller.themeMode == ThemeMode.dark,
                    activeThumbColor: AppTheme.primary,
                    onChanged: controller.setThemeMode,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          SettingsGroup(
            title: 'Coverage',
            children: const [
              _SettingsRow(
                title: 'Documents',
                value: 'Receipts, agreements, and IDs tracked locally',
                icon: Icons.folder_copy_outlined,
              ),
              _SettingsRow(
                title: 'Utilities',
                value: 'Electricity, internet, water, and maintenance',
                icon: Icons.bolt_rounded,
              ),
              _SettingsRow(
                title: 'Analytics',
                value: 'Monthly trendlines and occupancy summaries',
                icon: Icons.auto_graph_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primary),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
