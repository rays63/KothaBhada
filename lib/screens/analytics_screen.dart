import 'package:flutter/material.dart';

import '../core/formatters/currency_formatter.dart';
import '../core/theme/app_theme.dart';
import '../models/portfolio_snapshot.dart';
import '../widgets/section_heading.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key, required this.snapshot});

  final PortfolioSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final maxRevenue = snapshot.revenue
        .map((point) => point.amount)
        .reduce((value, element) => value > element ? value : element);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Kothabhada',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppTheme.primary),
              ),
              const Spacer(),
              const Icon(
                Icons.notifications_none_rounded,
                color: AppTheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 26),
          Text('Analytics', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Insights and financial performance for your properties.',
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Center(
                      child: Text(
                        'Property',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Rooms',
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 1,
            mainAxisSpacing: 14,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.9,
            children: [
              _MetricCard(
                label: 'TOTAL REVENUE',
                value: CurrencyFormatter.nepali(snapshot.currentRevenue),
                delta: '+12.5%',
                icon: Icons.payments_outlined,
              ),
              _MetricCard(
                label: 'AVG. RENT / ROOM',
                value: CurrencyFormatter.nepali(snapshot.averageRent),
                delta: '+2.1%',
                icon: Icons.meeting_room_outlined,
              ),
              _MetricCard(
                label: 'NET PROFIT',
                value: CurrencyFormatter.nepali(snapshot.netProfit),
                delta: '+8.4%',
                icon: Icons.account_balance_wallet_outlined,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLow,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Revenue Trend',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    Text(
                      'Last 6 Months',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                      color: AppTheme.muted,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 200,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: snapshot.revenue.map((point) {
                      final active = point.month == 'APR';
                      final height = (point.amount / maxRevenue) * 130 + 28;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (active)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.ink,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    CurrencyFormatter.nepali(point.amount),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                height: height,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: active
                                        ? [
                                            AppTheme.primary,
                                            AppTheme.primaryContainer,
                                          ]
                                        : [
                                            AppTheme.primaryContainer
                                                .withValues(alpha: 0.28),
                                            AppTheme.primary.withValues(
                                              alpha: 0.10,
                                            ),
                                          ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                point.month,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: active
                                          ? AppTheme.primary
                                          : AppTheme.muted,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFDDE4FB),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Occupancy Rate',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                Center(
                  child: SizedBox(
                    width: 170,
                    height: 170,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: snapshot.occupancyRate,
                          strokeWidth: 14,
                          strokeCap: StrokeCap.round,
                          backgroundColor: Colors.white,
                          color: AppTheme.secondary,
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(snapshot.occupancyRate * 100).round()}%',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'OCCUPIED',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendDot(
                      color: AppTheme.secondary,
                      label: 'Occupied (${snapshot.occupiedRooms})',
                    ),
                    const SizedBox(width: 18),
                    _LegendDot(
                      color: Colors.white,
                      label: 'Vacant (${snapshot.vacantRooms})',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionHeading(title: 'Utility Consumption'),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: snapshot.utilityUsage.map((usage) {
                final total = usage.electricity + usage.water;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              usage.propertyName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Text(
                            '${CurrencyFormatter.nepali(total)} total',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Row(
                          children: [
                            Expanded(
                              flex: usage.electricity.round(),
                              child: Container(
                                height: 10,
                                color: AppTheme.primary,
                              ),
                            ),
                            Expanded(
                              flex: usage.water.round(),
                              child: Container(
                                height: 10,
                                color: AppTheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.delta,
    required this.icon,
  });

  final String label;
  final String value;
  final String delta;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const Spacer(),
              Icon(icon, color: AppTheme.primary, size: 20),
            ],
          ),
          const SizedBox(height: 18),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                delta,
                style: const TextStyle(
                  color: Color(0xFF18974A),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'from last month',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: color == Colors.white
                ? Border.all(color: AppTheme.surfaceHigh)
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
