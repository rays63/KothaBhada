import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/payment_status.dart';
import '../models/property_models.dart';
import '../providers/app_controller.dart';

class AddOccupantScreen extends StatefulWidget {
  const AddOccupantScreen({super.key, required this.property});

  final RentalProperty property;

  @override
  State<AddOccupantScreen> createState() => _AddOccupantScreenState();
}

class _AddOccupantScreenState extends State<AddOccupantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _citizenshipController = TextEditingController();
  final _rentController = TextEditingController();
  final _electricityController = TextEditingController(text: '12');
  final _waterController = TextEditingController(text: '50');
  final _internetController = TextEditingController(text: '500');
  bool _saving = false;
  DateTime _moveInDate = DateTime.now();
  Room? _selectedRoom;

  @override
  void initState() {
    super.initState();
    final rooms = _vacantRooms(widget.property);
    if (rooms.isNotEmpty) {
      _selectedRoom = rooms.first;
      _rentController.text = rooms.first.monthlyRent.toStringAsFixed(0);
      _electricityController.text = rooms.first.electricityRate.toStringAsFixed(
        0,
      );
      _waterController.text = rooms.first.waterCost.toStringAsFixed(0);
      _internetController.text = rooms.first.internetCost.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _citizenshipController.dispose();
    _rentController.dispose();
    _electricityController.dispose();
    _waterController.dispose();
    _internetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vacantRooms = _vacantRooms(widget.property);
    if (vacantRooms.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Occupant')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No vacant room available in this house.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.muted),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Occupant')),
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
                'Assign a tenant to an available room with default utility settings.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<Room>(
                initialValue: _selectedRoom,
                decoration: const InputDecoration(labelText: 'Vacant room'),
                items: vacantRooms.map((room) {
                  return DropdownMenuItem(
                    value: room,
                    child: Text('Room ${room.label}'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedRoom = value;
                    _rentController.text = value.monthlyRent.toStringAsFixed(0);
                    _electricityController.text = value.electricityRate
                        .toStringAsFixed(0);
                    _waterController.text = value.waterCost.toStringAsFixed(0);
                    _internetController.text = value.internetCost
                        .toStringAsFixed(0);
                  });
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tenant name'),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Required';
                  final snapshot = context.read<AppController>().snapshot;
                  if (snapshot == null) return null;
                  final duplicate = snapshot.tenants.any(
                    (tenant) =>
                        tenant.name.trim().toLowerCase() == text.toLowerCase(),
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
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _citizenshipController,
                decoration: const InputDecoration(
                  labelText: 'Citizenship number',
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Move-in date'),
                subtitle: Text(
                  '${_moveInDate.year}-${_moveInDate.month.toString().padLeft(2, '0')}-${_moveInDate.day.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.calendar_month_rounded),
                onTap: _pickMoveInDate,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _rentController,
                decoration: const InputDecoration(labelText: 'Room rent'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _validateNonNegative,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _electricityController,
                decoration: const InputDecoration(
                  labelText: 'Electricity unit cost',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _validatePositive,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _waterController,
                decoration: const InputDecoration(labelText: 'Water cost'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _validateNonNegative,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _internetController,
                decoration: const InputDecoration(labelText: 'Internet cost'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _validateNonNegative,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.person_add_alt_rounded),
                label: Text(_saving ? 'Saving...' : 'Add Occupant'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Room> _vacantRooms(RentalProperty property) {
    return property.rooms
        .where((room) => room.tenantName.trim().isEmpty)
        .toList();
  }

  String? _validateNonNegative(String? value) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 0) return 'Enter valid amount';
    return null;
  }

  String? _validatePositive(String? value) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed <= 0) return 'Enter valid amount';
    return null;
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
    if (_selectedRoom == null) return;
    setState(() => _saving = true);
    try {
      await context.read<AppController>().saveRoom(
        RoomDraft(
          id: _selectedRoom!.id,
          propertyId: widget.property.id,
          label: _selectedRoom!.label,
          tenantName: _nameController.text.trim(),
          tenantPhone: _phoneController.text.trim(),
          citizenshipNo: _citizenshipController.text.trim(),
          moveInDate: _moveInDate,
          dueDay: _selectedRoom!.dueDay,
          monthlyRent: double.parse(_rentController.text.trim()),
          electricityRate: double.parse(_electricityController.text.trim()),
          waterCost: double.parse(_waterController.text.trim()),
          internetCost: double.parse(_internetController.text.trim()),
          status: PaymentStatus.due,
          note: 'Occupant assigned',
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
