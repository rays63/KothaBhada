import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/models.dart';
import '../../../data/providers.dart';
import '../../../data/repository.dart';
import '../../../widgets/kit/kit.dart';
import 'document_viewer_screen.dart';

(IconData, Color) docStyle(DocumentType type, AppTokens t) => switch (type) {
      DocumentType.agreement => (Icons.description_outlined, t.coral),
      DocumentType.idProof => (Icons.badge_outlined, t.sky),
      DocumentType.other => (Icons.insert_drive_file_outlined, t.violet),
    };

bool isImagePath(String path) {
  final p = path.toLowerCase();
  return p.endsWith('.jpg') ||
      p.endsWith('.jpeg') ||
      p.endsWith('.png') ||
      p.endsWith('.webp') ||
      p.endsWith('.heic');
}

/// A document card: preview/icon tile + title + owner subtitle.
class DocumentTile extends ConsumerWidget {
  const DocumentTile({super.key, required this.document});
  final Document document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final (icon, color) = docStyle(document.type, t);
    final snap = ref.watch(snapshotProvider);
    final owner = _owner(snap);
    final isImage = isImagePath(document.filePath);

    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DocumentViewerScreen(document: document)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: isImage && File(document.filePath).existsSync()
                ? Image.file(File(document.filePath), fit: BoxFit.cover,
                    width: double.infinity)
                : Center(child: Icon(icon, size: 30, color: color)),
          ),
          const SizedBox(height: 10),
          Text(document.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 2),
          Text(owner,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: t.text2)),
        ],
      ),
    );
  }

  String _owner(PortfolioSnapshot? snap) {
    if (snap == null) return '';
    if (document.tenantId != null) {
      final tenant = snap.tenantById(document.tenantId!);
      final room = tenant == null ? null : snap.roomOf(tenant.roomId);
      if (tenant != null) {
        return room == null
            ? tenant.fullName
            : '${tenant.fullName} · ${room.roomNumber}';
      }
    }
    if (document.houseId != null) {
      return snap.houseOf(document.houseId!)?.name ?? '';
    }
    return '';
  }
}
