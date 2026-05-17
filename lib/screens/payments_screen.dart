import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters/currency_formatter.dart';
import '../core/theme/app_theme.dart';
import '../models/payment_status.dart';
import '../models/portfolio_snapshot.dart';
import '../models/property_models.dart';
import '../providers/app_controller.dart';
import '../widgets/receivable_card.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key, required this.snapshot});

  final PortfolioSnapshot snapshot;

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  bool _showPending = true;

  @override
  Widget build(BuildContext context) {
    final snapshot = context.watch<AppController>().snapshot ?? widget.snapshot;
    final receivables = _showPending
        ? snapshot.pendingReceivables
        : snapshot.completedReceivables;
    final expected = snapshot.monthlyExpectedRevenue;
    final collected = snapshot.collectedRevenue;
    final pending = snapshot.pendingRevenue;
    final collectionRatio = expected <= 0
        ? 0.0
        : (collected / expected).clamp(0.0, 1.0).toDouble();
    final collectionPercent = (collectionRatio * 100).round();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        children: [
          Row(
            children: [
              const Icon(Icons.menu_rounded, color: AppTheme.primary),
              const SizedBox(width: 14),
              Text(
                'Kothabhada',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppTheme.primary),
              ),
              const Spacer(),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceHigh,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.person, color: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Payments', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Manage your rental revenue streams',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLow,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _PaymentsTab(
                    selected: _showPending,
                    label: 'Pending',
                    onTap: () => setState(() => _showPending = true),
                  ),
                ),
                Expanded(
                  child: _PaymentsTab(
                    selected: !_showPending,
                    label: 'Completed',
                    onTap: () => setState(() => _showPending = false),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [Color(0xFFDDECF0), Color(0xFFD6E4EC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'MONTHLY COLLECTION',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.primary,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      CurrencyFormatter.nepali(collected),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA7F0B9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$collectionPercent%',
                        style: const TextStyle(
                          color: Color(0xFF115A2C),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: collectionRatio,
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.transparent,
                        color: AppTheme.secondary,
                      ),
                      Center(
                        child: Text(
                          '$collectionPercent%',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Pending ${CurrencyFormatter.nepali(pending)} of ${CurrencyFormatter.nepali(expected)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: Text(
                  _showPending
                      ? 'Pending Receivables'
                      : 'Completed Receivables',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              TextButton(
                onPressed: _showPending
                    ? () => _remindAll(
                        context,
                        snapshot.pendingReceivables.length,
                      )
                    : null,
                child: Text(
                  _showPending ? 'Mark all as reminded' : 'Receipts',
                  style: TextStyle(
                    color: _showPending ? AppTheme.primary : AppTheme.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...receivables.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ReceivableCard(
                receivable: item,
                primaryActionLabel: item.status == PaymentStatus.paid
                    ? 'Receipt'
                    : 'Record Payment',
                onPrimaryAction: () => item.status == PaymentStatus.paid
                    ? _showReceipt(context)
                    : _openPaymentActionSheet(context, item),
              ),
            ),
          ),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFE7ECFF),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 5,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Automated Ledger Tip',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: AppTheme.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  'Set up automatic reminders for tenants who have not paid by the 5th of each month. Current settings have 12 tenants notified via SMS.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.ink,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markPaid(BuildContext context, String id) async {
    final appController = context.read<AppController>();
    await appController.markReceivablePaid(id);
    if (!mounted) return;
    ScaffoldMessenger.of(
      this.context,
    ).showSnackBar(const SnackBar(content: Text('Payment marked as paid')));
  }

  Future<void> _openPaymentActionSheet(
    BuildContext context,
    PaymentReceivable item,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.propertyName} • Room ${item.roomLabel}',
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Pending ${CurrencyFormatter.nepali(item.amount)}',
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.muted),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.task_alt_rounded,
                    color: AppTheme.primary,
                  ),
                  title: const Text('Mark full as paid'),
                  subtitle: const Text('Close this month bill for this room'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _markPaid(context, item.id);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.payments_outlined,
                    color: AppTheme.partial,
                  ),
                  title: const Text('Record partial payment'),
                  subtitle: const Text('Keep remaining amount pending'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _recordPartialPayment(context, item);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _recordPartialPayment(
    BuildContext context,
    PaymentReceivable item,
  ) async {
    final appController = context.read<AppController>();
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Partial Payment'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Amount',
                helperText: 'Pending ${CurrencyFormatter.nepali(item.amount)}',
              ),
              validator: (value) {
                final parsed = double.tryParse(value?.trim() ?? '');
                if (parsed == null || parsed <= 0) return 'Enter valid amount';
                if (parsed >= item.amount) {
                  return 'Use full payment option for complete amount';
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
      await appController.recordPartialPayment(item.id, amount);
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

  void _remindAll(BuildContext context, int total) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminder queued for $total tenants')),
    );
  }

  void _showReceipt(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receipt available in local documents')),
    );
  }
}

class _PaymentsTab extends StatelessWidget {
  const _PaymentsTab({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppTheme.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
