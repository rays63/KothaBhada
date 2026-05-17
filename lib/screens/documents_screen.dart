import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/property_models.dart';
import '../providers/app_controller.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key, this.propertyId});

  final String? propertyId;

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Lease');
  final _pathController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  RentalProperty? _property;
  Room? _room;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
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

    final documents = widget.propertyId == null
        ? snapshot.documents
        : snapshot.documents
              .where((document) => document.propertyId == widget.propertyId)
              .toList();

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
              'Store rental agreements, IDs, receipts, and supporting files with local-only persistence.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Form(
                key: _formKey,
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
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Document title',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pathController,
                      decoration: const InputDecoration(
                        labelText: 'Local file path',
                        hintText: '/storage/.../lease.pdf',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(labelText: 'Note'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _saving ? null : _saveDocument,
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      label: Text(_saving ? 'Saving...' : 'Save document'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            ...documents.map((document) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${document.propertyName} • ${document.roomLabel}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppTheme.muted),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        document.category.toUpperCase(),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: AppTheme.primary,
                              letterSpacing: 1.1,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        document.filePath,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppTheme.ink),
                      ),
                      if (document.note.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          document.note,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDocument() async {
    if (!_formKey.currentState!.validate()) return;
    if (_property == null || _room == null) return;
    setState(() => _saving = true);
    try {
      await context.read<AppController>().addDocument(
        DocumentDraft(
          propertyId: _property!.id,
          propertyName: _property!.name,
          roomId: _room!.id,
          roomLabel: _room!.label,
          title: _titleController.text.trim(),
          category: _categoryController.text.trim(),
          filePath: _pathController.text.trim(),
          note: _noteController.text.trim(),
        ),
      );
      if (!mounted) return;
      _titleController.clear();
      _pathController.clear();
      _noteController.clear();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
