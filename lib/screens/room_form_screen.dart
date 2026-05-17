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
  late final TextEditingController _phoneController;
  late final TextEditingController _citizenshipController;
  late final TextEditingController _dueDayController;
  late final TextEditingController _rentController;
  late final TextEditingController _electricityRateController;
  late final TextEditingController _waterController;
  late final TextEditingController _internetController;
  late final TextEditingController _noteController;

  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  late PaymentStatus _status;
  DateTime _moveInDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final room = widget.room;
    final tenant = _tenantForRoom(room?.id);
    _labelController = TextEditingController(text: room?.label ?? '');
    _tenantController = TextEditingController(text: room?.tenantName ?? '');
    _phoneController = TextEditingController(text: tenant?.phone ?? '');
    _citizenshipController = TextEditingController(
      text: tenant?.citizenshipNo ?? '',
    );
    _dueDayController = TextEditingController(
      text: room?.dueDay.toString() ?? '5',
    );
    _rentController = TextEditingController(
      text: room?.monthlyRent.toStringAsFixed(0) ?? '',
    );
    _electricityRateController = TextEditingController(
      text: room?.electricityRate.toStringAsFixed(0) ?? '12',
    );
    _waterController = TextEditingController(
      text: room?.waterCost.toStringAsFixed(0) ?? '50',
    );
    _internetController = TextEditingController(
      text: room?.internetCost.toStringAsFixed(0) ?? '500',
    );
    _noteController = TextEditingController(text: room?.note ?? '');
    _status = room?.status ?? PaymentStatus.due;
    _moveInDate = tenant?.moveInDate ?? DateTime.now();
  }

  TenantProfile? _tenantForRoom(String? roomId) {
    if (roomId == null) return null;
    final snapshot = context.read<AppController>().snapshot;
    if (snapshot == null) return null;
    final tenants = snapshot.tenants
        .where((item) => item.roomId == roomId)
        .toList();
    return tenants.isEmpty ? null : tenants.first;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _tenantController.dispose();
    _phoneController.dispose();
    _citizenshipController.dispose();
    _dueDayController.dispose();
    _rentController.dispose();
    _electricityRateController.dispose();
    _waterController.dispose();
    _internetController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _hasTenant => _tenantController.text.trim().isNotEmpty;

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
                'Configure room details and optional occupant profile.',
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
                validator: (value) {
                  final label = value?.trim() ?? '';
                  if (label.isEmpty) return 'Required';
                  final snapshot = context.read<AppController>().snapshot;
                  if (snapshot == null) return null;
                  final property = snapshot.properties.firstWhere(
                    (item) => item.id == widget.property.id,
                    orElse: () => widget.property,
                  );
                  final exists = property.rooms.any(
                    (room) =>
                        room.id != widget.room?.id &&
                        room.label.trim().toLowerCase() == label.toLowerCase(),
                  );
                  if (exists) return 'Room label already exists in this house';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _tenantController,
                decoration: const InputDecoration(
                  labelText: 'Tenant name (leave empty for vacant room)',
                ),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  final tenantName = value?.trim() ?? '';
                  if (tenantName.isEmpty) return null;
                  final snapshot = context.read<AppController>().snapshot;
                  if (snapshot == null) return null;
                  final duplicate = snapshot.tenants.any(
                    (tenant) =>
                        tenant.roomId != widget.room?.id &&
                        tenant.name.trim().toLowerCase() ==
                            tenantName.toLowerCase(),
                  );
                  if (duplicate) return 'Tenant with this name already exists';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (!_hasTenant) return null;
                  if ((value?.trim() ?? '').isEmpty) return 'Phone is required';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _citizenshipController,
                decoration: const InputDecoration(
                  labelText: 'Citizenship number',
                ),
                validator: (value) {
                  if (!_hasTenant) return null;
                  if ((value?.trim() ?? '').isEmpty) {
                    return 'Citizenship number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Move-in date'),
                subtitle: Text(
                  '${_moveInDate.year}-${_moveInDate.month.toString().padLeft(2, '0')}-${_moveInDate.day.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.calendar_month_rounded),
                onTap: _hasTenant ? _pickMoveInDate : null,
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
                decoration: const InputDecoration(labelText: 'Room rent'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');
                  if (amount == null || amount <= 0) {
                    return 'Enter valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _electricityRateController,
                decoration: const InputDecoration(
                  labelText: 'Electricity unit cost',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');
                  if (amount == null || amount <= 0) {
                    return 'Enter valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _waterController,
                decoration: const InputDecoration(labelText: 'Water cost'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');
                  if (amount == null || amount < 0) return 'Enter valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _internetController,
                decoration: const InputDecoration(labelText: 'Internet cost'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');
                  if (amount == null || amount < 0) return 'Enter valid amount';
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

  Future<void> _pickMoveInDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _moveInDate,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    setState(() => _moveInDate = picked);
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
          tenantPhone: _phoneController.text.trim(),
          citizenshipNo: _citizenshipController.text.trim(),
          moveInDate: _moveInDate,
          dueDay: int.parse(_dueDayController.text.trim()),
          monthlyRent: double.parse(_rentController.text.trim()),
          electricityRate: double.parse(_electricityRateController.text.trim()),
          waterCost: double.parse(_waterController.text.trim()),
          internetCost: double.parse(_internetController.text.trim()),
          status: _status,
          note: _noteController.text.trim(),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
