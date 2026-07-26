import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n_ext.dart';
import '../../../data/providers.dart';
import '../../../data/security_service.dart';
import '../../../widgets/kit/kit.dart';
import '../documents/documents_screen.dart';
import 'about_screen.dart';
import 'backup_screen.dart';
import 'language_screen.dart';
import 'security_screen.dart';

/// Settings tab (design screen 33).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = context.l10n;
    final snap = ref.watch(snapshotProvider);
    final stats = ref.watch(dashboardStatsProvider);
    final prefs = ref.watch(prefsProvider);
    final name = snap?.landlordName ?? 'Landlord';
    final langLabel = prefs.locale.languageCode == 'ne' ? 'नेपाली' : 'English';

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 120),
        children: [
          Text(l.settingsTitle,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          // Profile
          ListRowCard(
            leading: InitialsAvatar(label: name, gradient: t.brandGradient),
            title: name,
            subtitle: l.settingsHousesRooms(stats.houseCount, stats.roomCount),
            trailing: Icon(Icons.chevron_right_rounded, color: t.text2),
            onTap: () => _editName(context, ref, name),
          ),
          const SizedBox(height: 16),
          _SettingsGroup(children: [
            _SettingsRow(
              icon: Icons.language_rounded,
              color: t.sky,
              label: l.settingsLanguage,
              trailingText: langLabel,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const LanguageScreen())),
            ),
            _SettingsRow(
              icon: Icons.shield_outlined,
              color: t.violet,
              label: l.settingsSecurity,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const SecurityScreen())),
            ),
          ]),
          const SizedBox(height: 14),
          _SettingsGroup(children: [
            _SettingsRow(
              icon: Icons.dark_mode_outlined,
              color: t.brand2,
              label: l.settingsDarkMode,
              trailing: AppToggle(
                value: prefs.themeMode == ThemeMode.dark,
                onChanged: (v) =>
                    ref.read(prefsProvider.notifier).setDarkMode(v),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          _SettingsGroup(children: [
            _SettingsRow(
              icon: Icons.folder_copy_outlined,
              color: t.coral,
              label: l.settingsDocuments,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const DocumentsScreen())),
            ),
            _SettingsRow(
              icon: Icons.backup_outlined,
              color: t.brand2,
              label: l.settingsBackup,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const BackupScreen())),
            ),
            _SettingsRow(
              icon: Icons.info_outline_rounded,
              color: t.amber,
              label: l.settingsAbout,
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutScreen())),
            ),
          ]),
          const SizedBox(height: 18),
          AppButton.outline(
            label: l.settingsLockApp,
            icon: Icons.lock_outline_rounded,
            block: true,
            onPressed: () =>
                ref.read(appLockedProvider.notifier).state = true,
          ),
        ],
      ),
    );
  }

  Future<void> _editName(
      BuildContext context, WidgetRef ref, String current) async {
    final controller = TextEditingController(text: current);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 36),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(ctx.l10n.settingsYourName,
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 14),
              AppTextField(
                  controller: controller, hint: ctx.l10n.onbNameHint),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: AppButton.ghost(
                      label: ctx.l10n.commonCancel,
                      block: true,
                      onPressed: () => Navigator.of(ctx).pop(false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton.primary(
                      label: ctx.l10n.commonSave,
                      block: true,
                      onPressed: () => Navigator.of(ctx).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (saved == true && controller.text.trim().isNotEmpty) {
      await ref
          .read(repositoryProvider)
          .setSetting('landlord_name', controller.text.trim());
      ref.invalidate(portfolioProvider);
    }
    controller.dispose();
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(AppTokens.rCard),
        boxShadow: t.shadowSm,
        border: t.isDark ? Border.all(color: t.line) : null,
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(height: 1, thickness: 1, color: t.line, indent: 60),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.color,
    required this.label,
    this.trailingText,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String? trailingText;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.rCard),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 17, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              if (trailingText != null) ...[
                Text(trailingText!,
                    style: TextStyle(fontSize: 13, color: t.text2)),
                const SizedBox(width: 6),
              ],
              trailing ??
                  (onTap != null
                      ? Icon(Icons.chevron_right_rounded, color: t.text2, size: 20)
                      : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}
