import 'package:flutter/material.dart';

import '../core/formatters/currency_formatter.dart';
import '../core/theme/app_theme.dart';
import '../models/payment_status.dart';
import '../models/property_models.dart';
import 'status_badge.dart';

class ReceivableCard extends StatelessWidget {
  const ReceivableCard({
    super.key,
    required this.receivable,
    this.onPrimaryAction,
    this.primaryActionLabel,
  });

  final PaymentReceivable receivable;
  final VoidCallback? onPrimaryAction;
  final String? primaryActionLabel;

  @override
  Widget build(BuildContext context) {
    final isPaid = receivable.status == PaymentStatus.paid;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.surfaceHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      receivable.roomLabel,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Text('•', style: TextStyle(color: AppTheme.muted)),
                    Text(
                      receivable.propertyName,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
                    ),
                  ],
                ),
              ),
              if (isPaid)
                const StatusBadge(
                  label: 'Paid',
                  background: Color(0xFF7EF38B),
                  foreground: Color(0xFF106530),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: receivable.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tag,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.ink),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CurrencyFormatter.nepali(receivable.amount),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: isPaid ? AppTheme.primary : AppTheme.due,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      receivable.overdueLabel.toUpperCase(),
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(letterSpacing: 1.3),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: onPrimaryAction,
                icon: Icon(
                  isPaid
                      ? Icons.receipt_long_rounded
                      : Icons.notifications_none_rounded,
                ),
                label: Text(
                  primaryActionLabel ?? (isPaid ? 'Receipt' : 'Remind'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
