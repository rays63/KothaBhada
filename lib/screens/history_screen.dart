import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters/currency_formatter.dart';
import '../core/theme/app_theme.dart';
import '../models/property_models.dart';
import '../providers/app_controller.dart';
import '../utils/date_formatter.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, this.propertyId});

  final String? propertyId;

  @override
  Widget build(BuildContext context) {
    final snapshot = context.watch<AppController>().snapshot;
    if (snapshot == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final cycles =
        (propertyId == null
                ? snapshot.billingCycles
                : snapshot.billingCycles
                      .where((cycle) => cycle.propertyId == propertyId)
                      .toList())
            .toList()
          ..sort((a, b) => b.generatedAt.compareTo(a.generatedAt));

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text(
              'Recent History',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Tenant payments and billing snapshots with clear status visibility.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
            ),
            const SizedBox(height: 18),
            if (cycles.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  'No payment history yet. Activity appears here once billing cycles start.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
                ),
              )
            else
              ...cycles.take(20).map((cycle) {
                final pending = (cycle.totalDue - cycle.totalPaid).clamp(
                  0.0,
                  double.infinity,
                );
                final statusColor = cycle.status == BillingCycleStatus.paid
                    ? const Color(0xFF0F6A32)
                    : cycle.status == BillingCycleStatus.partial
                    ? const Color(0xFF915F00)
                    : AppTheme.due;
                final statusBackground = cycle.status == BillingCycleStatus.paid
                    ? const Color(0xFFDFF8E5)
                    : cycle.status == BillingCycleStatus.partial
                    ? const Color(0xFFFFE7BF)
                    : const Color(0xFFFFDDE0);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceLow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.history_rounded,
                                color: AppTheme.primary,
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 60,
                              margin: const EdgeInsets.only(top: 6),
                              color: AppTheme.surfaceHigh,
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${cycle.tenantName} • Room ${cycle.roomLabel}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusBackground,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      cycle.status.name.toUpperCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: statusColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Paid ${CurrencyFormatter.nepali(cycle.totalPaid)} • Electricity ${CurrencyFormatter.nepali(cycle.electricityDue)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pending ${CurrencyFormatter.nepali(pending.toDouble())}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color:
                                          cycle.status ==
                                              BillingCycleStatus.paid
                                          ? AppTheme.primary
                                          : AppTheme.due,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                DateFormatter.date(cycle.generatedAt),
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(color: AppTheme.muted),
                              ),
                            ],
                          ),
                        ),
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
}
