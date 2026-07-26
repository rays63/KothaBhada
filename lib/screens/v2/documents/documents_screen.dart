import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n_ext.dart';
import '../../../data/models/models.dart';
import '../../../data/providers.dart';
import '../../../widgets/kit/kit.dart';
import '../widgets/screen_header.dart';
import 'add_document_screen.dart';
import 'document_tile.dart';

/// Documents grid (design screens 29 + 31 empty).
class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  DocumentType? _filter;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final all = ref.watch(documentsProvider).valueOrNull ?? const [];
    final docs = _filter == null
        ? all
        : all.where((d) => d.type == _filter).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(
              title: l.docsTitle,
              trailing: _AddButton(onTap: _add),
            ),
            if (all.isNotEmpty)
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  children: [
                    _chip(l.docsAll, null),
                    _chip(l.docsAgreements, DocumentType.agreement),
                    _chip(l.docsIds, DocumentType.idProof),
                    _chip(l.docsOther, DocumentType.other),
                  ],
                ),
              ),
            Expanded(
              child: all.isEmpty
                  ? EmptyState(
                      icon: Icons.folder_copy_outlined,
                      title: l.docsNoTitle,
                      message: l.docsNoBody,
                      actionLabel: l.docsAdd,
                      actionIcon: Icons.add_rounded,
                      onAction: _add,
                    )
                  : GridView.count(
                      crossAxisCount: 2,
                      padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.95,
                      children: [
                        for (final d in docs) DocumentTile(document: d),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, DocumentType? type) {
    final t = context.tokens;
    final selected = _filter == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filter = type),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected
                ? t.brand2.withValues(alpha: 0.15)
                : t.text2.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? t.brand2 : t.text2)),
        ),
      ),
    );
  }

  void _add() => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AddDocumentScreen()),
      );
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.rIconPill),
        onTap: onTap,
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: t.brandGradient,
            borderRadius: BorderRadius.circular(AppTokens.rIconPill),
            boxShadow: [
              BoxShadow(
                color: t.brand2.withValues(alpha: 0.34),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
