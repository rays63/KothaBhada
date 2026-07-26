import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n_ext.dart';
import '../../../data/models/models.dart';
import '../../../data/providers.dart';
import '../../../widgets/kit/kit.dart';
import '../widgets/screen_header.dart';

/// Add Document upload (design screen 30).
class AddDocumentScreen extends ConsumerStatefulWidget {
  const AddDocumentScreen({super.key, this.tenantId, this.houseId});

  final String? tenantId;
  final String? houseId;

  @override
  ConsumerState<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends ConsumerState<AddDocumentScreen> {
  final _name = TextEditingController();
  DocumentType _type = DocumentType.agreement;
  String? _pickedPath;
  String? _pickedName;
  String? _tagTenantId;
  String? _tagHouseId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tagTenantId = widget.tenantId;
    _tagHouseId = widget.houseId;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickCamera() async {
    final img = await ImagePicker().pickImage(source: ImageSource.camera);
    if (img != null) _setPicked(img.path);
  }

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    final path = res?.files.single.path;
    if (path != null) _setPicked(path);
  }

  void _setPicked(String path) {
    setState(() {
      _pickedPath = path;
      _pickedName = path.split('/').last;
      if (_name.text.trim().isEmpty) {
        _name.text = _pickedName!.split('.').first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(title: context.l10n.docsAdd),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
                children: [
                  // Upload drop zone
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: t.text2.withValues(alpha: 0.45),
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: t.brand2.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            _pickedPath == null
                                ? Icons.upload_rounded
                                : Icons.check_circle_rounded,
                            color: t.brand2,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _pickedName ?? context.l10n.docsUploadFile,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(context.l10n.docsFileTypes,
                            style: TextStyle(fontSize: 12, color: t.text2)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.outline(
                          label: context.l10n.docsCamera,
                          icon: Icons.photo_camera_outlined,
                          onPressed: _pickCamera,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppButton.outline(
                          label: context.l10n.docsFiles,
                          icon: Icons.folder_open_outlined,
                          onPressed: _pickFile,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: context.l10n.docsNameLabel,
                    hint: context.l10n.docsNameHint,
                    controller: _name,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  FieldLabel(context.l10n.docsCategory),
                  SegmentedControl<DocumentType>(
                    value: _type,
                    segments: {
                      DocumentType.agreement: context.l10n.docsCatAgreement,
                      DocumentType.idProof: context.l10n.docsCatId,
                      DocumentType.other: context.l10n.docsCatOther,
                    },
                    onChanged: (v) => setState(() => _type = v),
                  ),
                  const SizedBox(height: 14),
                  FieldLabel(context.l10n.docsTagTo),
                  _TagPicker(
                    tenantId: _tagTenantId,
                    houseId: _tagHouseId,
                    onChanged: (tenantId, houseId) => setState(() {
                      _tagTenantId = tenantId;
                      _tagHouseId = houseId;
                    }),
                  ),
                  const SizedBox(height: 22),
                  AppButton.primary(
                    label: context.l10n.docsSave,
                    block: true,
                    loading: _saving,
                    onPressed:
                        (_pickedPath != null && _name.text.trim().isNotEmpty)
                            ? _save
                            : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final stored =
          await ref.read(repositoryProvider).storeDocumentFile(_pickedPath!);
      await ref.read(portfolioProvider.notifier).addDocument(
            tenantId: _tagTenantId,
            houseId: _tagHouseId,
            title: _name.text.trim(),
            filePath: stored,
            type: _type,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      showAppToast(context, context.l10n.docsSaved);
    } catch (e) {
      if (mounted) showAppToast(context, '$e', success: false);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _TagPicker extends ConsumerWidget {
  const _TagPicker({
    required this.tenantId,
    required this.houseId,
    required this.onChanged,
  });
  final String? tenantId;
  final String? houseId;
  final void Function(String? tenantId, String? houseId) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = context.l10n;
    final snap = ref.watch(snapshotProvider);
    String label = l.docsSelectOwner;
    if (snap != null) {
      if (tenantId != null) {
        label = snap.tenantById(tenantId!)?.fullName ?? label;
      } else if (houseId != null) {
        label = snap.houseOf(houseId!)?.name ?? label;
      }
    }

    return GestureDetector(
      onTap: () async {
        if (snap == null) return;
        await showAppSheet<void>(
          context,
          builder: (ctx) => ListView(
            shrinkWrap: true,
            children: [
              Text(l.docsTagTo, style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 8),
              ListTile(
                title: Text(l.commonNone),
                onTap: () {
                  onChanged(null, null);
                  Navigator.of(ctx).pop();
                },
              ),
              if (snap.tenants.where((e) => e.isActive).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
                  child: Text(l.docsTenants,
                      style: TextStyle(fontSize: 12, color: t.text2)),
                ),
              for (final tenant in snap.tenants.where((e) => e.isActive))
                ListTile(
                  leading: InitialsAvatar(label: tenant.fullName, size: 36),
                  title: Text(tenant.fullName),
                  onTap: () {
                    onChanged(tenant.id, null);
                    Navigator.of(ctx).pop();
                  },
                ),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
                child: Text(l.docsHouses,
                    style: TextStyle(fontSize: 12, color: t.text2)),
              ),
              for (final house in snap.houses)
                ListTile(
                  leading: Icon(Icons.home_rounded, color: t.sky),
                  title: Text(house.name),
                  onTap: () {
                    onChanged(null, house.id);
                    Navigator.of(ctx).pop();
                  },
                ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: t.isDark ? t.surface : t.surface2,
          borderRadius: BorderRadius.circular(AppTokens.rInput),
          border: Border.all(color: t.line),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      color: (tenantId == null && houseId == null)
                          ? t.text2
                          : t.text)),
            ),
            Icon(Icons.expand_more_rounded, color: t.brand2, size: 20),
          ],
        ),
      ),
    );
  }
}
