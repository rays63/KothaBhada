import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/l10n_ext.dart';
import '../../../data/providers.dart';
import '../../../widgets/kit/kit.dart';
import '../widgets/screen_header.dart';

/// Backup & Restore (design screens 36 + 37). Exports the whole database to a
/// single JSON file the user controls, and imports it back with a warning.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = context.l10n;
    final snap = ref.watch(snapshotProvider);
    final lastBackup = snap?.settings['last_backup_at'];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(title: l.backupTitle),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: t.brandGradient,
                      borderRadius: BorderRadius.circular(AppTokens.rCard),
                      boxShadow: [
                        BoxShadow(
                          color: t.brand2.withValues(alpha: 0.3),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_rounded,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(l.backupLast,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.9))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          lastBackup == null
                              ? l.backupNone
                              : DateFormat('d MMM yyyy, h:mm a')
                                  .format(DateTime.parse(lastBackup)),
                          style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text('kothabhada-backup.json',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.9))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton.primary(
                    label: l.backupExport,
                    icon: Icons.file_download_outlined,
                    block: true,
                    loading: _busy,
                    onPressed: _export,
                  ),
                  const SizedBox(height: 10),
                  AppButton.outline(
                    label: l.backupImport,
                    icon: Icons.file_upload_outlined,
                    block: true,
                    onPressed: _busy ? null : _import,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l.backupHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, height: 1.5, color: t.text2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final path = await ref.read(portfolioProvider.notifier).exportBackup();
      await ref
          .read(repositoryProvider)
          .setSetting('last_backup_at', DateTime.now().toIso8601String());
      ref.invalidate(portfolioProvider);
      await Share.shareXFiles([XFile(path)], text: 'Kothabhada backup');
      if (mounted) showAppToast(context, context.l10n.backupExported);
    } catch (e) {
      if (mounted) showAppToast(context, '$e', success: false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = result?.files.single.path;
    if (path == null || !mounted) return;

    final ok = await _showOverwriteWarning(context);
    if (!ok || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(portfolioProvider.notifier).importBackup(path);
      if (mounted) showAppToast(context, context.l10n.backupRestored);
    } catch (e) {
      if (mounted) {
        showAppToast(context, context.l10n.backupImportFailed('$e'),
            success: false);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _showOverwriteWarning(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final t = ctx.tokens;
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 30),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: t.partialBg,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(Icons.warning_amber_rounded,
                      color: t.partial, size: 28),
                ),
                const SizedBox(height: 14),
                Text(ctx.l10n.backupOverwriteTitle,
                    style: Theme.of(ctx).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  ctx.l10n.backupOverwriteBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, height: 1.6, color: t.text2),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: AppButton.outline(
                        label: ctx.l10n.commonCancel,
                        block: true,
                        onPressed: () => Navigator.of(ctx).pop(false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _OverwriteButton(
                          onPressed: () => Navigator.of(ctx).pop(true)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }
}

/// The amber "Overwrite" button from the warning dialog.
class _OverwriteButton extends StatelessWidget {
  const _OverwriteButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [t.partial, const Color(0xFFFBBF24)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTokens.rButton),
          boxShadow: [
            BoxShadow(
              color: t.partial.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTokens.rButton),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: Text(context.l10n.backupOverwrite,
                  style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}
