import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/format.dart';
import '../../../core/l10n_ext.dart';
import '../../../data/models/models.dart';
import '../../../data/providers.dart';
import '../../../widgets/kit/kit.dart';
import '../widgets/screen_header.dart';

/// Document viewer / preview (design screen 32).
class DocumentViewerScreen extends ConsumerWidget {
  const DocumentViewerScreen({super.key, required this.document});
  final Document document;

  bool get _isImage {
    final p = document.filePath.toLowerCase();
    return p.endsWith('.jpg') ||
        p.endsWith('.jpeg') ||
        p.endsWith('.png') ||
        p.endsWith('.webp') ||
        p.endsWith('.heic');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = context.l10n;
    final exists = File(document.filePath).existsSync();
    final typeLabel = switch (document.type) {
      DocumentType.agreement => l.docsTypeAgreement,
      DocumentType.idProof => l.docsTypeId,
      DocumentType.other => l.docsTypeFile,
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(
              title: '',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HeaderIconButton(
                    icon: Icons.ios_share_rounded,
                    onTap: exists
                        ? () => Share.shareXFiles([XFile(document.filePath)])
                        : null,
                  ),
                  const SizedBox(width: 8),
                  HeaderIconButton(
                    icon: Icons.delete_outline_rounded,
                    color: t.due,
                    onTap: () => _delete(context, ref),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
                children: [
                  AspectRatio(
                    aspectRatio: _isImage ? 0.8 : 1 / 1.3,
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: t.shadow,
                      ),
                      child: (_isImage && exists)
                          ? Image.file(File(document.filePath), fit: BoxFit.contain)
                          : Center(
                              child: Icon(Icons.description_outlined,
                                  size: 64, color: t.text2.withValues(alpha: 0.5)),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(document.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(l.docsAddedOn(dayLabel(document.createdAt)),
                                style: TextStyle(fontSize: 12, color: t.text2)),
                          ],
                        ),
                      ),
                      StatusChip(label: typeLabel, kind: StatusKind.brand),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmDialog(
      context,
      title: context.l10n.docsDeleteTitle,
      message: context.l10n.docsDeleteBody(document.title),
      confirmLabel: context.l10n.commonDelete,
      danger: true,
    );
    if (ok) {
      await ref.read(portfolioProvider.notifier).deleteDocument(document.id);
      if (context.mounted) {
        Navigator.of(context).pop();
        showAppToast(context, context.l10n.docsDeleted);
      }
    }
  }
}
