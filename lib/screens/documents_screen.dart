import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/property_models.dart';
import '../providers/app_controller.dart';
import '../services/document_storage_service.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key, this.propertyId});

  final String? propertyId;

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _storageService = DocumentStorageService();
  final _pathController = TextEditingController();
  final _noteController = TextEditingController();

  RentalProperty? _property;
  Room? _room;
  bool _busy = false;

  @override
  void dispose() {
    _pathController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = context.watch<AppController>().snapshot;
    if (snapshot == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final properties = widget.propertyId == null
        ? snapshot.properties
        : snapshot.properties
              .where((item) => item.id == widget.propertyId)
              .toList();

    if (_property == null && properties.isNotEmpty) {
      _property = properties.first;
      if (_property!.rooms.isNotEmpty) _room = _property!.rooms.first;
    }

    final roomDocuments = (_room == null)
        ? const <DocumentRecord>[]
        : snapshot.documents.where((item) => item.roomId == _room!.id).toList();
    final leaseDocument = _findCategory(
      roomDocuments,
      _Category.leaseAgreement,
    );
    final idDocument = _findCategory(roomDocuments, _Category.citizenshipId);
    final otherDocument = _findCategory(
      roomDocuments,
      _Category.otherDocuments,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Documents')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text(
              'Document Vault',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload, view, replace, and delete tenant files with local offline persistence.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  DropdownButtonFormField<RentalProperty>(
                    initialValue: _property,
                    decoration: const InputDecoration(labelText: 'House'),
                    items: properties.map((property) {
                      return DropdownMenuItem(
                        value: property,
                        child: Text(property.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _property = value;
                        _room = value?.rooms.isNotEmpty == true
                            ? value!.rooms.first
                            : null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Room>(
                    initialValue: _room,
                    decoration: const InputDecoration(labelText: 'Room'),
                    items: (_property?.rooms ?? []).map((room) {
                      return DropdownMenuItem(
                        value: room,
                        child: Text('${room.label} • ${room.tenantName}'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _room = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _DocumentCategoryCard(
              title: 'Lease Agreement',
              subtitle: 'Rental contract and lease terms',
              document: leaseDocument,
              busy: _busy,
              onUpload: _room == null
                  ? null
                  : () =>
                        _chooseUpload(_Category.leaseAgreement, leaseDocument),
              onImportPath: _room == null
                  ? null
                  : () => _importFromPath(
                      _Category.leaseAgreement,
                      leaseDocument,
                    ),
              onView: leaseDocument == null
                  ? null
                  : () => _viewDocument(leaseDocument),
              onReplace: leaseDocument == null
                  ? null
                  : () =>
                        _chooseUpload(_Category.leaseAgreement, leaseDocument),
              onDelete: leaseDocument == null
                  ? null
                  : () => _deleteDocument(leaseDocument),
            ),
            const SizedBox(height: 12),
            _DocumentCategoryCard(
              title: 'Citizenship / ID',
              subtitle: 'Identity document copy',
              document: idDocument,
              busy: _busy,
              onUpload: _room == null
                  ? null
                  : () => _chooseUpload(_Category.citizenshipId, idDocument),
              onImportPath: _room == null
                  ? null
                  : () => _importFromPath(_Category.citizenshipId, idDocument),
              onView: idDocument == null
                  ? null
                  : () => _viewDocument(idDocument),
              onReplace: idDocument == null
                  ? null
                  : () => _chooseUpload(_Category.citizenshipId, idDocument),
              onDelete: idDocument == null
                  ? null
                  : () => _deleteDocument(idDocument),
            ),
            const SizedBox(height: 12),
            _DocumentCategoryCard(
              title: 'Other Documents',
              subtitle: 'Receipts, forms, and supporting files',
              document: otherDocument,
              busy: _busy,
              onUpload: _room == null
                  ? null
                  : () =>
                        _chooseUpload(_Category.otherDocuments, otherDocument),
              onImportPath: _room == null
                  ? null
                  : () => _importFromPath(
                      _Category.otherDocuments,
                      otherDocument,
                    ),
              onView: otherDocument == null
                  ? null
                  : () => _viewDocument(otherDocument),
              onReplace: otherDocument == null
                  ? null
                  : () =>
                        _chooseUpload(_Category.otherDocuments, otherDocument),
              onDelete: otherDocument == null
                  ? null
                  : () => _deleteDocument(otherDocument),
            ),
          ],
        ),
      ),
    );
  }

  DocumentRecord? _findCategory(
    List<DocumentRecord> documents,
    _Category category,
  ) {
    final normalized = category.storageValue;
    final exact = documents
        .where((item) => item.category == normalized)
        .toList();
    if (exact.isNotEmpty) return exact.first;
    return null;
  }

  Future<void> _chooseUpload(
    _Category category,
    DocumentRecord? existing,
  ) async {
    if (_room == null || _property == null) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Pick from gallery'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _uploadFromPicker(
                      ImageSource.gallery,
                      category,
                      existing,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Capture from camera'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _uploadFromPicker(
                      ImageSource.camera,
                      category,
                      existing,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _uploadFromPicker(
    ImageSource source,
    _Category category,
    DocumentRecord? existing,
  ) async {
    if (_room == null || _property == null) return;
    setState(() => _busy = true);
    try {
      final storedPath = await _storageService.pickAndStoreImage(
        source: source,
        roomId: _room!.id,
        category: category.storageValue,
      );
      if (storedPath == null) return;
      await _upsertDocument(category, storedPath, existing);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Document saved')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Bad state: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importFromPath(
    _Category category,
    DocumentRecord? existing,
  ) async {
    if (_room == null || _property == null) return;
    _pathController.clear();
    _noteController.clear();
    final sourcePath = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final formKey = GlobalKey<FormState>();
        return AlertDialog(
          title: const Text('Import from local path'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _pathController,
                  decoration: const InputDecoration(
                    labelText: 'File path',
                    hintText: '/storage/.../document.jpg',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a file path';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                  ),
                ),
              ],
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
                Navigator.of(dialogContext).pop(_pathController.text.trim());
              },
              child: const Text('Import'),
            ),
          ],
        );
      },
    );
    if (sourcePath == null || sourcePath.isEmpty) return;

    setState(() => _busy = true);
    try {
      final storedPath = await _storageService.importFileToStorage(
        sourcePath,
        roomId: _room!.id,
        category: category.storageValue,
      );
      await _upsertDocument(
        category,
        storedPath,
        existing,
        noteOverride: _noteController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Document imported')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Bad state: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _upsertDocument(
    _Category category,
    String filePath,
    DocumentRecord? existing, {
    String? noteOverride,
  }) async {
    if (_room == null || _property == null) return;
    final appController = context.read<AppController>();
    final draft = DocumentDraft(
      propertyId: _property!.id,
      propertyName: _property!.name,
      roomId: _room!.id,
      roomLabel: _room!.label,
      title: '${category.title} - ${_room!.tenantName}',
      category: category.storageValue,
      filePath: filePath,
      note: noteOverride ?? existing?.note ?? '',
    );
    if (existing == null) {
      await appController.addDocument(draft);
      return;
    }
    final previousPath = existing.filePath;
    await appController.updateDocument(existing.id, draft);
    if (previousPath != filePath) {
      await _storageService.deleteIfManaged(previousPath);
    }
  }

  Future<void> _deleteDocument(DocumentRecord document) async {
    final appController = context.read<AppController>();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete document?'),
          content: Text(
            'This will remove ${document.title} from local storage.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (shouldDelete != true) return;
    setState(() => _busy = true);
    try {
      await _storageService.deleteIfManaged(document.filePath);
      await appController.deleteDocument(document.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Document deleted')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _viewDocument(DocumentRecord document) {
    final isImage = _isImagePath(document.filePath);
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxHeight: 620),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        document.title,
                        style: Theme.of(dialogContext).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: isImage
                      ? InteractiveViewer(
                          child: Image.file(
                            File(document.filePath),
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Center(
                              child: Text('Unable to open image file.'),
                            ),
                          ),
                        )
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.insert_drive_file_outlined,
                                  size: 44,
                                  color: AppTheme.primary,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Preview not available for this file type.',
                                  style: Theme.of(
                                    dialogContext,
                                  ).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  document.filePath,
                                  style: Theme.of(
                                    dialogContext,
                                  ).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isImagePath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }
}

enum _Category {
  leaseAgreement('lease_agreement', 'Lease Agreement'),
  citizenshipId('citizenship_id', 'Citizenship / ID'),
  otherDocuments('other_documents', 'Other Documents');

  const _Category(this.storageValue, this.title);

  final String storageValue;
  final String title;
}

class _DocumentCategoryCard extends StatelessWidget {
  const _DocumentCategoryCard({
    required this.title,
    required this.subtitle,
    required this.document,
    required this.busy,
    required this.onUpload,
    required this.onImportPath,
    required this.onView,
    required this.onReplace,
    required this.onDelete,
  });

  final String title;
  final String subtitle;
  final DocumentRecord? document;
  final bool busy;
  final VoidCallback? onUpload;
  final VoidCallback? onImportPath;
  final VoidCallback? onView;
  final VoidCallback? onReplace;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final hasDocument = document != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppTheme.muted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: hasDocument
                      ? const Color(0xFFDFF8E5)
                      : const Color(0xFFFFE7BF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  hasDocument ? 'Uploaded' : 'Missing',
                  style: TextStyle(
                    color: hasDocument
                        ? const Color(0xFF0F6A32)
                        : const Color(0xFF915F00),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (hasDocument) ...[
            const SizedBox(height: 10),
            Text(
              document!.filePath,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: busy ? null : onUpload,
                icon: const Icon(Icons.upload_rounded),
                label: Text(hasDocument ? 'Replace' : 'Upload'),
              ),
              OutlinedButton.icon(
                onPressed: busy ? null : onImportPath,
                icon: const Icon(Icons.file_open_outlined),
                label: const Text('Import Path'),
              ),
              OutlinedButton.icon(
                onPressed: busy ? null : onView,
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('View'),
              ),
              OutlinedButton.icon(
                onPressed: busy ? null : onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
