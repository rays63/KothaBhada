import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/payment_status.dart';
import '../models/property_models.dart';
import '../providers/app_controller.dart';

class RoomFormScreen extends StatefulWidget {
  const RoomFormScreen({super.key, required this.property, this.room});

  final RentalProperty property;
  final Room? room;

  @override
  State<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen> {
  late final TextEditingController _labelController;
  late final TextEditingController _tenantController;
  late final TextEditingController _dueDayController;
  late final TextEditingController _rentController;
  late final TextEditingController _noteController;

  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  late PaymentStatus _status;

  @override
  void initState() {
    super.initState();
    final room = widget.room;
    _labelController = TextEditingController(text: room?.label ?? '');
    _tenantController = TextEditingController(text: room?.tenantName ?? '');
    _dueDayController = TextEditingController(
      text: room?.dueDay.toString() ?? '5',
    );
    _rentController = TextEditingController(
      text: room?.monthlyRent.toStringAsFixed(0) ?? '',
    );
    _noteController = TextEditingController(text: room?.note ?? '');
    _status = room?.status ?? PaymentStatus.due;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _tenantController.dispose();
    _dueDayController.dispose();
    _rentController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.room == null ? 'Add Room' : 'Edit Room',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Text(
                widget.property.name,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppTheme.primary),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage room and tenant details for operational tracking.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Room number/label',
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _tenantController,
                decoration: const InputDecoration(labelText: 'Tenant name'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _dueDayController,
                decoration: const InputDecoration(
                  labelText: 'Due day of month',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final day = int.tryParse(value?.trim() ?? '');
                  if (day == null || day < 1 || day > 31) return 'Use day 1-31';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _rentController,
                decoration: const InputDecoration(labelText: 'Monthly rent'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');
                  if (amount == null || amount <= 0) {
                    return 'Enter valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<PaymentStatus>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Payment status'),
                items: const [
                  DropdownMenuItem(
                    value: PaymentStatus.paid,
                    child: Text('Paid'),
                  ),
                  DropdownMenuItem(
                    value: PaymentStatus.partial,
                    child: Text('Partial'),
                  ),
                  DropdownMenuItem(
                    value: PaymentStatus.due,
                    child: Text('Due'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _status = value);
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note'),
                maxLines: 2,
              ),
              const SizedBox(height: 26),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(_saving ? 'Saving...' : 'Save room'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await context.read<AppController>().saveRoom(
        RoomDraft(
          id: widget.room?.id,
          propertyId: widget.property.id,
          label: _labelController.text.trim(),
          tenantName: _tenantController.text.trim(),
          dueDay: int.parse(_dueDayController.text.trim()),
          monthlyRent: double.parse(_rentController.text.trim()),
          status: _status,
          note: _noteController.text.trim(),
        ),
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
