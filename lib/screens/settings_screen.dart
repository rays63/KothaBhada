import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/portfolio_snapshot.dart';
import '../providers/app_controller.dart';
import '../widgets/settings_group.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.snapshot});

  final PortfolioSnapshot snapshot;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _restorePathController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _restorePathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final snapshot = controller.snapshot ?? widget.snapshot;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Tune app preferences and manage fully offline data safety.',
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
            title: 'Preferences',
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
            title: 'Data Management',
            children: [
              _ActionRow(
                title: 'Backup data',
                subtitle: 'Create a full local JSON backup',
                icon: Icons.backup_rounded,
                onTap: _busy ? null : _backupData,
              ),
              _ActionRow(
                title: 'Restore backup',
                subtitle: 'Restore all local records from a JSON file path',
                icon: Icons.restore_page_rounded,
                onTap: _busy ? null : _restoreBackup,
              ),
              _ActionRow(
                title: 'Export data',
                subtitle: 'Generate an export JSON for sharing/archive',
                icon: Icons.upload_file_rounded,
                onTap: _busy ? null : _exportData,
              ),
            ],
          ),
          const SizedBox(height: 18),
          SettingsGroup(
            title: 'About',
            children: const [
              _SettingsRow(
                title: 'App',
                value: 'Kothabhada v1.0.0 • Offline-first rental operations',
                icon: Icons.info_outline_rounded,
              ),
              _SettingsRow(
                title: 'Scope',
                value:
                    'Houses, rooms, tenants, billing, utilities, analytics, documents',
                icon: Icons.dashboard_customize_outlined,
              ),
            ],
          ),
          if (_busy) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }

  Future<void> _backupData() async {
    final appController = context.read<AppController>();
    await _runBusy(() async {
      final path = await appController.backupData();
      if (!mounted) return;
      _showPathResult('Backup created', path);
    });
  }

  Future<void> _exportData() async {
    final appController = context.read<AppController>();
    await _runBusy(() async {
      final path = await appController.exportData();
      if (!mounted) return;
      _showPathResult('Export created', path);
    });
  }

  Future<void> _restoreBackup() async {
    final appController = context.read<AppController>();
    _restorePathController.clear();
    final path = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final formKey = GlobalKey<FormState>();
        return AlertDialog(
          title: const Text('Restore backup'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: _restorePathController,
              decoration: const InputDecoration(
                labelText: 'Backup file path',
                hintText: '/.../kothabhada_backup_....json',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter backup path';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(
                  dialogContext,
                ).pop(_restorePathController.text.trim());
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
    if (path == null || path.isEmpty) return;
    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm restore'),
          content: const Text(
            'Restoring will replace all current local data with the selected backup.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Restore'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    if (!mounted) return;
    await _runBusy(() async {
      await appController.restoreData(path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup restored successfully')),
      );
    });
  }

  Future<void> _runBusy(Future<void> Function() work) async {
    setState(() => _busy = true);
    try {
      await work();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Bad state: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _showPathResult(String label, String path) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(label),
          content: SelectableText(path),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
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

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
          ],
        ),
      ),
    );
  }
}
