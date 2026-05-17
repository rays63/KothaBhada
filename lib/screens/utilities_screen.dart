import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters/currency_formatter.dart';
import '../core/theme/app_theme.dart';
import '../models/property_models.dart';
import '../providers/app_controller.dart';
import '../services/meter_image_service.dart';
import '../widgets/status_badge.dart';

class UtilitiesScreen extends StatefulWidget {
  const UtilitiesScreen({super.key, this.propertyId});

  final String? propertyId;

  @override
  State<UtilitiesScreen> createState() => _UtilitiesScreenState();
}

class _UtilitiesScreenState extends State<UtilitiesScreen> {
  UtilityType _selectedType = UtilityType.electricity;
  String? _capturedImagePath;
  bool _saving = false;

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
    final records = widget.propertyId == null
        ? snapshot.utilityRecords
        : snapshot.utilityRecords
              .where((record) => record.propertyId == widget.propertyId)
              .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Utilities')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text(
              'Utility Logs',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Capture electricity, internet, and maintenance records with optional meter image evidence.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
            ),
            const SizedBox(height: 18),
            _UtilityComposer(
              properties: properties,
              selectedType: _selectedType,
              capturedImagePath: _capturedImagePath,
              onTypeChanged: (value) => setState(() => _selectedType = value),
              onCapture: _captureImage,
              onSubmit: _saving
                  ? null
                  : (draft) async {
                      setState(() => _saving = true);
                      await context.read<AppController>().addUtilityRecord(
                        draft,
                      );
                      if (!mounted) return;
                      setState(() {
                        _saving = false;
                        _capturedImagePath = null;
                      });
                    },
            ),
            const SizedBox(height: 22),
            ...records.map((record) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${record.propertyName} • ${record.roomLabel}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          StatusBadge(
                            label: record.type.name.toUpperCase(),
                            background: AppTheme.surfaceLow,
                            foreground: AppTheme.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        record.tenantName,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppTheme.muted),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.nepali(record.amount),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primary,
                        ),
                      ),
                      if (record.meterReading != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Meter reading: ${record.meterReading!.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        record.note,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (record.imagePath != null &&
                          record.imagePath!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Image: ${record.imagePath}',
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

  Future<void> _captureImage() async {
    final file = await MeterImageService().captureMeterReading();
    if (!mounted) return;
    setState(() => _capturedImagePath = file?.path);
  }
}

class _UtilityComposer extends StatefulWidget {
  const _UtilityComposer({
    required this.properties,
    required this.selectedType,
    required this.capturedImagePath,
    required this.onTypeChanged,
    required this.onCapture,
    required this.onSubmit,
  });

  final List<RentalProperty> properties;
  final UtilityType selectedType;
  final String? capturedImagePath;
  final ValueChanged<UtilityType> onTypeChanged;
  final VoidCallback onCapture;
  final Future<void> Function(UtilityRecordDraft draft)? onSubmit;

  @override
  State<_UtilityComposer> createState() => _UtilityComposerState();
}

class _UtilityComposerState extends State<_UtilityComposer> {
  final _amountController = TextEditingController();
  final _readingController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  RentalProperty? _property;
  Room? _room;

  @override
  void initState() {
    super.initState();
    if (widget.properties.isNotEmpty) {
      _property = widget.properties.first;
      if (_property!.rooms.isNotEmpty) _room = _property!.rooms.first;
    }
  }

  @override
  void didUpdateWidget(covariant _UtilityComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_property == null && widget.properties.isNotEmpty) {
      _property = widget.properties.first;
      if (_property!.rooms.isNotEmpty) _room = _property!.rooms.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _readingController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              items: widget.properties.map((property) {
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
            DropdownButtonFormField<UtilityType>(
              initialValue: widget.selectedType,
              decoration: const InputDecoration(labelText: 'Utility type'),
              items: UtilityType.values.map((type) {
                return DropdownMenuItem(value: type, child: Text(type.name));
              }).toList(),
              onChanged: (value) {
                if (value != null) widget.onTypeChanged(value);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
              validator: (value) {
                final amount = double.tryParse(value ?? '');
                if (amount == null || amount <= 0) return 'Enter valid amount';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _readingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Meter reading (optional)',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            if (widget.capturedImagePath != null)
              Text(
                'Captured: ${widget.capturedImagePath}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.primary),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onCapture,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Capture meter image'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: widget.onSubmit == null ? null : _submit,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Log utility'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_property == null || _room == null || widget.onSubmit == null) return;
    await widget.onSubmit!(
      UtilityRecordDraft(
        propertyId: _property!.id,
        propertyName: _property!.name,
        roomId: _room!.id,
        roomLabel: _room!.label,
        tenantName: _room!.tenantName,
        type: widget.selectedType,
        meterReading: _readingController.text.trim().isEmpty
            ? null
            : double.tryParse(_readingController.text.trim()),
        amount: double.parse(_amountController.text.trim()),
        note: _noteController.text.trim(),
        imagePath: widget.capturedImagePath,
        recordedAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    _amountController.clear();
    _readingController.clear();
    _noteController.clear();
  }
}
