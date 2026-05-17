import 'package:flutter/material.dart';

import '../core/formatters/currency_formatter.dart';
import '../core/theme/app_theme.dart';
import '../models/portfolio_snapshot.dart';
import '../models/property_models.dart';
import '../widgets/glass_header_card.dart';
import '../widgets/metric_tile.dart';
import '../widgets/property_summary_card.dart';
import '../widgets/section_heading.dart';
import 'property_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.snapshot});

  final PortfolioSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthLabel = 'May 2026';

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceHigh,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.home_work_rounded,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kothabhada',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: AppTheme.primary,
                            ),
                          ),
                          Text(
                            'Portfolio Health',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.notifications_none_rounded,
                      color: AppTheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'Your rentals, beautifully organized.',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  'Offline-first control for houses, rooms, utility tracking, and rent follow-up.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.muted,
                  ),
                ),
                const SizedBox(height: 22),
                GlassHeaderCard(
                  eyebrow: monthLabel,
                  title: CurrencyFormatter.nepali(snapshot.currentRevenue),
                  subtitle:
                      'Monthly inflow across ${snapshot.properties.length} properties',
                  badge: '${(snapshot.occupancyRate * 100).round()}% occupied',
                  icon: Icons.insights_rounded,
                  accent: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: MetricTile(
                        label: 'Outstanding',
                        value: CurrencyFormatter.nepali(
                          snapshot.totalOutstanding,
                        ),
                        tone: AppTheme.due,
                        icon: Icons.priority_high_rounded,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: MetricTile(
                        label: 'Occupied Rooms',
                        value:
                            '${snapshot.occupiedRooms}/${snapshot.totalRooms}',
                        tone: AppTheme.primary,
                        icon: Icons.meeting_room_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: MetricTile(
                        label: 'Due Today',
                        value: '${snapshot.dueRooms} rooms',
                        tone: AppTheme.partial,
                        icon: Icons.schedule_rounded,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: MetricTile(
                        label: 'Documents',
                        value: '18 archived',
                        tone: AppTheme.primary,
                        icon: Icons.description_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const SectionHeading(
                  title: 'Properties',
                  actionLabel: 'View portfolio',
                ),
                const SizedBox(height: 16),
                ...snapshot.properties.map((property) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PropertySummaryCard(
                      property: property,
                      onTap: () => _openProperty(context, property),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                const SectionHeading(
                  title: 'Utilities and workflow',
                  actionLabel: 'Optimized for offline use',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.bolt_rounded,
                        title: 'Electricity',
                        subtitle: 'Meter readings and tenant usage snapshots',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.wifi_rounded,
                        title: 'Internet',
                        subtitle: 'Track bundles, shared plans, and due cycles',
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _openProperty(BuildContext context, RentalProperty property) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PropertyDetailScreen(property: property),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF141B2B).withValues(alpha: 0.05),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surfaceLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}
