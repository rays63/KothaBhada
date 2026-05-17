import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters/currency_formatter.dart';
import '../core/theme/app_theme.dart';
import '../models/property_models.dart';
import '../providers/app_controller.dart';
import '../utils/date_formatter.dart';
import 'documents_screen.dart';
import 'electricity_history_screen.dart';
import 'room_form_screen.dart';

class OccupantDetailsScreen extends StatefulWidget {
  const OccupantDetailsScreen({
    super.key,
    required this.propertyId,
    required this.roomId,
  });

  final String propertyId;
  final String roomId;

  @override
  State<OccupantDetailsScreen> createState() => _OccupantDetailsScreenState();
}

class _OccupantDetailsScreenState extends State<OccupantDetailsScreen> {
  final _readingFormKey = GlobalKey<FormState>();
  final _currentReadingController = TextEditingController();
  final _rateController = TextEditingController(text: '12');
  final _noteController = TextEditingController();

  bool _loadingReadings = true;
  bool _savingReading = false;
  bool _didApplyRoomDefaults = false;
  List<ElectricityReading> _readings = const [];

  @override
  void initState() {
    super.initState();
    _currentReadingController.addListener(_onReadingChanged);
    _rateController.addListener(_onReadingChanged);
    _loadReadings();
  }

  @override
  void dispose() {
    _currentReadingController.dispose();
    _rateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _previousReading =>
      _readings.isEmpty ? 0 : _readings.first.currentReading;

  double get _currentReading =>
      double.tryParse(_currentReadingController.text.trim()) ?? 0;

  double get _rate => double.tryParse(_rateController.text.trim()) ?? 0;

  double get _unitsConsumed {
    final value = _currentReading - _previousReading;
    return value < 0 ? 0 : value;
  }

  double get _totalCost => _unitsConsumed * _rate;

  @override
  Widget build(BuildContext context) {
    final snapshot = context.watch<AppController>().snapshot;
    if (snapshot == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final property = snapshot.properties.firstWhere(
      (item) => item.id == widget.propertyId,
      orElse: () => snapshot.properties.first,
    );
    final room = property.rooms.firstWhere(
      (item) => item.id == widget.roomId,
      orElse: () => property.rooms.first,
    );
    if (!_didApplyRoomDefaults) {
      _rateController.text = room.electricityRate.toStringAsFixed(0);
      _didApplyRoomDefaults = true;
    }
    final tenantMatches = snapshot.tenants.where(
      (item) => item.roomId == room.id,
    );
    final tenant = tenantMatches.isEmpty ? null : tenantMatches.first;
    final cycleMatches = snapshot.currentMonthCycles.where(
      (cycle) => cycle.roomId == room.id,
    );
    final currentCycle = cycleMatches.isEmpty ? null : cycleMatches.first;
    final pendingAmount = currentCycle == null
        ? 0.0
        : (currentCycle.totalDue - currentCycle.totalPaid).clamp(
            0.0,
            double.infinity,
          );

    return Scaffold(
      appBar: AppBar(title: Text('Room ${room.label}')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text(
              room.tenantName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              property.name,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tenant Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Room no: ${room.label}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Contact: ${tenant?.phone.isNotEmpty == true ? tenant!.phone : 'Not set'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Citizenship: ${tenant?.citizenshipNo.isNotEmpty == true ? tenant!.citizenshipNo : 'Not set'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tenant == null
                        ? 'Move-in date not set'
                        : 'Move-in: ${DateFormatter.date(tenant.moveInDate)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _openDocuments(context, property.id),
                        icon: const Icon(Icons.folder_copy_outlined),
                        label: const Text('View Documents'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            _openCustomizeRoom(context, property, room),
                        icon: const Icon(Icons.tune_rounded),
                        label: const Text('Customize Room'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _summaryCard(
              context: context,
              title: 'Monthly Rent',
              amount: currentCycle?.rentDue ?? room.monthlyRent,
              subtitle: currentCycle == null
                  ? 'No cycle generated yet'
                  : 'Status: ${currentCycle.status.name.toUpperCase()}',
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Form(
                key: _readingFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Electricity',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    _readonlyRow(
                      context,
                      label: 'Previous reading',
                      value: _previousReading.toStringAsFixed(1),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _currentReadingController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Current reading',
                      ),
                      validator: (value) {
                        final parsed = double.tryParse(value?.trim() ?? '');
                        if (parsed == null) return 'Enter a valid reading';
                        if (parsed < 0) return 'Reading cannot be negative';
                        if (parsed < _previousReading) {
                          return 'Cannot be lower than previous reading';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _rateController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Electricity rate per unit',
                      ),
                      validator: (value) {
                        final parsed = double.tryParse(value?.trim() ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid positive rate';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note (optional)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _readonlyRow(
                      context,
                      label: 'Units consumed',
                      value: _unitsConsumed.toStringAsFixed(1),
                    ),
                    const SizedBox(height: 8),
                    _readonlyRow(
                      context,
                      label: 'Total electricity cost',
                      value: CurrencyFormatter.nepali(_totalCost),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _savingReading
                          ? null
                          : () => _saveReading(context, property, room),
                      icon: const Icon(Icons.save_alt_rounded),
                      label: Text(
                        _savingReading ? 'Saving...' : 'Save Reading',
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_loadingReadings)
                      const LinearProgressIndicator()
                    else ...[
                      Text(
                        'Last 2 readings',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (_readings.isEmpty)
                        Text(
                          'No readings yet',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.muted),
                        )
                      else
                        ..._readings.take(2).map((reading) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '${DateFormatter.date(reading.recordedAt)} • ${reading.currentReading.toStringAsFixed(1)} • ${CurrencyFormatter.nepali(reading.totalCost)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          );
                        }),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _openHistory(context, room),
                        icon: const Icon(Icons.history_rounded),
                        label: const Text('View all history'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _summaryCard(
              context: context,
              title: 'Internet',
              amount: currentCycle?.internetDue ?? 0,
              subtitle: 'Monthly internet charge',
            ),
            const SizedBox(height: 14),
            _summaryCard(
              context: context,
              title: 'Utilities',
              amount: currentCycle?.utilityDue ?? 0,
              subtitle: 'Water and other utility costs',
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Summary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Total: ${CurrencyFormatter.nepali(currentCycle?.totalDue ?? 0)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Paid: ${CurrencyFormatter.nepali(currentCycle?.totalPaid ?? 0)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pending: ${CurrencyFormatter.nepali(pendingAmount.toDouble())}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: pendingAmount > 0
                          ? AppTheme.due
                          : AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: currentCycle == null || pendingAmount <= 0
                              ? null
                              : () => _markPaid(context, currentCycle.id),
                          child: const Text('Mark as Paid'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: currentCycle == null || pendingAmount <= 0
                              ? null
                              : () => _recordPartial(
                                  context,
                                  currentCycle.id,
                                  pendingAmount.toDouble(),
                                ),
                          child: const Text('Partial Payment'),
                        ),
                      ),
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

  Widget _summaryCard({
    required BuildContext context,
    required String title,
    required double amount,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.nepali(amount),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppTheme.primary),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _readonlyRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppTheme.primary),
        ),
      ],
    );
  }

  Future<void> _loadReadings() async {
    setState(() {
      _loadingReadings = true;
    });
    try {
      final readings = await context
          .read<AppController>()
          .loadElectricityReadingsForRoom(widget.roomId);
      if (!mounted) return;
      setState(() {
        _readings = readings;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingReadings = false;
        });
      }
    }
  }

  Future<void> _saveReading(
    BuildContext context,
    RentalProperty property,
    Room room,
  ) async {
    final appController = context.read<AppController>();
    if (!_readingFormKey.currentState!.validate()) return;
    setState(() {
      _savingReading = true;
    });
    try {
      await appController.saveElectricityReading(
        ElectricityReadingDraft(
          propertyId: property.id,
          propertyName: property.name,
          roomId: room.id,
          roomLabel: room.label,
          tenantName: room.tenantName,
          currentReading: _currentReading,
          rate: _rate,
          imagePath: null,
          note: _noteController.text.trim(),
          recordedAt: DateTime.now(),
        ),
      );
      if (!mounted) return;
      _currentReadingController.clear();
      _noteController.clear();
      await _loadReadings();
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(content: Text('Reading saved successfully')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Bad state: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingReading = false;
        });
      }
    }
  }

  Future<void> _markPaid(BuildContext context, String cycleId) async {
    final appController = context.read<AppController>();
    await appController.markReceivablePaid(cycleId);
    if (!mounted) return;
    ScaffoldMessenger.of(
      this.context,
    ).showSnackBar(const SnackBar(content: Text('Payment marked as paid')));
  }

  Future<void> _recordPartial(
    BuildContext context,
    String cycleId,
    double pendingAmount,
  ) async {
    final appController = context.read<AppController>();
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Record Partial Payment'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Amount',
                helperText:
                    'Pending ${CurrencyFormatter.nepali(pendingAmount)}',
              ),
              validator: (value) {
                final parsed = double.tryParse(value?.trim() ?? '');
                if (parsed == null || parsed <= 0) return 'Enter valid amount';
                if (parsed >= pendingAmount) {
                  return 'Use "Mark as Paid" for full amount';
                }
                return null;
              },
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
                Navigator.of(
                  dialogContext,
                ).pop(double.parse(controller.text.trim()));
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (amount == null) return;
    try {
      await appController.recordPartialPayment(cycleId, amount);
      if (!mounted) return;
      ScaffoldMessenger.of(
        this.context,
      ).showSnackBar(const SnackBar(content: Text('Partial payment recorded')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Bad state: ', '')),
        ),
      );
    }
  }

  void _openDocuments(BuildContext context, String propertyId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DocumentsScreen(propertyId: propertyId),
      ),
    );
  }

  void _openCustomizeRoom(
    BuildContext context,
    RentalProperty property,
    Room room,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoomFormScreen(property: property, room: room),
      ),
    );
  }

  void _openHistory(BuildContext context, Room room) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ElectricityHistoryScreen(roomId: room.id, roomLabel: room.label),
      ),
    );
  }

  void _onReadingChanged() {
    if (!mounted) return;
    setState(() {});
  }
}
