import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters/currency_formatter.dart';
import '../core/theme/app_theme.dart';
import '../models/payment_status.dart';
import '../models/portfolio_snapshot.dart';
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
                  'TOTAL OUTSTANDING',
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
                      CurrencyFormatter.nepali(snapshot.totalOutstanding),
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
                        '^ ${snapshot.pendingReceivables.length}',
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
                        value: snapshot.pendingReceivables.isEmpty
                            ? 0
                            : snapshot.pendingReceivables.length /
                                  (snapshot.pendingReceivables.length +
                                      snapshot.completedReceivables.length),
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.transparent,
                        color: AppTheme.due,
                      ),
                      const Center(
                        child: Icon(
                          Icons.priority_high_rounded,
                          color: AppTheme.due,
                          size: 34,
                        ),
                      ),
                    ],
                  ),
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
                    : 'Mark Paid',
                onPrimaryAction: () => item.status == PaymentStatus.paid
                    ? _showReceipt(context)
                    : _markPaid(context, item.id),
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
    await context.read<AppController>().markReceivablePaid(id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Payment marked as paid')));
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
