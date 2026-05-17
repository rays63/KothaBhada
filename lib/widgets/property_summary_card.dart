import 'package:flutter/material.dart';

import '../core/formatters/currency_formatter.dart';
import '../core/theme/app_theme.dart';
import '../models/property_models.dart';
import 'status_badge.dart';

class PropertySummaryCard extends StatelessWidget {
  const PropertySummaryCard({
    super.key,
    required this.property,
    required this.onTap,
  });

  final RentalProperty property;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final occupancyRate = property.totalRooms == 0
        ? 0.0
        : property.occupiedRooms / property.totalRooms;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF141B2B).withValues(alpha: 0.05),
              blurRadius: 22,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        property.address,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: '${(occupancyRate * 100).round()}% occupied',
                  background: AppTheme.surfaceLow,
                  foreground: AppTheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _PropertyMetric(
                    label: 'Monthly Target',
                    value: CurrencyFormatter.nepali(property.monthlyTarget),
                  ),
                ),
                Expanded(
                  child: _PropertyMetric(
                    label: 'Outstanding',
                    value: CurrencyFormatter.nepali(property.totalDue),
                    valueColor: AppTheme.due,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: occupancyRate,
                minHeight: 12,
                backgroundColor: AppTheme.surfaceLow,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyMetric extends StatelessWidget {
  const _PropertyMetric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: valueColor ?? AppTheme.ink),
        ),
      ],
    );
  }
}
