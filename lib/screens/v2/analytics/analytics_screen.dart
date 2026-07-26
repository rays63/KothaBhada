import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/format.dart';
import '../../../core/l10n_ext.dart';
import '../../../data/models/models.dart';
import '../../../data/providers.dart';
import '../../../widgets/kit/kit.dart';

/// Analytics tab (design screen 27): income trend, status split, per-house
/// collection. A months window selector stands in for the date-range picker.
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _months = 6;
  DateTimeRange? _customRange;

  /// Number of months to plot, and the anchor end month.
  ({int count, DateTime end}) get _span {
    if (_customRange != null) {
      final r = _customRange!;
      final months = (r.end.year - r.start.year) * 12 +
          (r.end.month - r.start.month) +
          1;
      return (count: months.clamp(1, 24), end: r.end);
    }
    return (count: _months, end: DateTime.now());
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year, now.month + 1, 0),
      initialDateRange: _customRange ??
          DateTimeRange(
              start: DateTime(now.year, now.month - 5), end: now),
    );
    if (picked != null) setState(() => _customRange = picked);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = context.l10n;
    final stats = ref.watch(dashboardStatsProvider);
    final split = ref.watch(statusSplitProvider);
    final houses = ref.watch(perHouseCollectionProvider);

    final now = DateTime.now();
    final snap = ref.watch(snapshotProvider);
    final span = _span;
    final series = [
      for (var i = span.count - 1; i >= 0; i--)
        () {
          final m = DateTime(span.end.year, span.end.month - i);
          final amount = snap
                  ?.paymentsForMonth(billingMonthOf(m))
                  .fold<double>(0, (s, p) => s + p.amountPaid) ??
              0;
          return (month: m, amount: amount);
        }(),
    ];
    final trend = _trendPercent(series.map((e) => e.amount).toList());

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 120),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow('${now.year}'),
                    const SizedBox(height: 2),
                    Text(l.analyticsTitle,
                        style: Theme.of(context).textTheme.headlineMedium),
                  ],
                ),
              ),
              _CalendarButton(
                active: _customRange != null,
                onTap: _pickRange,
              ),
            ],
          ),
          if (_customRange != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.event_rounded, size: 14, color: t.brand2),
                const SizedBox(width: 6),
                Text(
                  '${DateFormat('MMM yyyy').format(_customRange!.start)} – ${DateFormat('MMM yyyy').format(_customRange!.end)}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: t.brand2),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _customRange = null),
                  child: Text(l.analyticsClear,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: t.text2)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          // Income + collection rate
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: t.brandGradient,
                    borderRadius: BorderRadius.circular(AppTokens.rStat),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.analyticsIncomeMonth(DateFormat('MMMM').format(now)),
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.9))),
                      const SizedBox(height: 2),
                      Text(money(stats.collected),
                          style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(AppTokens.rStat),
                    boxShadow: t.shadowSm,
                    border: t.isDark ? Border.all(color: t.line) : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.analyticsCollectionRate,
                          style: TextStyle(fontSize: 11, color: t.text2)),
                      const SizedBox(height: 2),
                      Text('${(stats.collectionRate * 100).round()}%',
                          style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: t.brand2)),
                      const SizedBox(height: 6),
                      BrandProgressBar(value: stats.collectionRate, height: 5),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Monthly income line chart
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l.analyticsMonthlyIncome,
                        style: Theme.of(context).textTheme.titleSmall),
                    if (trend != null)
                      StatusChip(
                        label: '${trend >= 0 ? '+' : ''}${trend.round()}%',
                        kind: trend >= 0 ? StatusKind.brand : StatusKind.due,
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(height: 130, child: _IncomeChart(series: series)),
                const SizedBox(height: 10),
                _MonthsSelector(
                  value: _customRange == null ? _months : 0,
                  onChanged: (v) => setState(() {
                    _months = v;
                    _customRange = null;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Status split donut
          AppCard(
            child: Row(
              children: [
                SizedBox(width: 96, height: 96, child: _StatusDonut(split: split)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegendRow(
                          color: t.paid,
                          label: l.analyticsPaidPct,
                          pct: split.fraction(split.paid)),
                      const SizedBox(height: 8),
                      _LegendRow(
                          color: t.partial,
                          label: l.analyticsPartialPct,
                          pct: split.fraction(split.partial)),
                      const SizedBox(height: 8),
                      _LegendRow(
                          color: t.due,
                          label: l.analyticsDuePct,
                          pct: split.fraction(split.due)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(l.analyticsPerHouse,
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          for (final h in houses) ...[
            _HouseBar(collection: h),
            const SizedBox(height: 12),
          ],
          if (houses.isEmpty)
            Text(l.analyticsAddHousesHint,
                style: TextStyle(color: t.text2, fontSize: 13)),
        ],
      ),
    );
  }

  double? _trendPercent(List<double> values) {
    if (values.length < 2) return null;
    final prev = values[values.length - 2];
    final last = values.last;
    if (prev <= 0) return last > 0 ? 100 : null;
    return (last - prev) / prev * 100;
  }
}

class _CalendarButton extends StatelessWidget {
  const _CalendarButton({required this.active, required this.onTap});
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.rIconPill),
        onTap: onTap,
        child: Ink(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: active ? t.brand2.withValues(alpha: 0.15) : t.surface,
            borderRadius: BorderRadius.circular(AppTokens.rIconPill),
            boxShadow: active ? null : t.shadowSm,
            border: (t.isDark && !active) ? Border.all(color: t.line) : null,
          ),
          child: Icon(Icons.calendar_month_rounded,
              size: 19, color: active ? t.brand2 : t.text),
        ),
      ),
    );
  }
}

class _IncomeChart extends StatelessWidget {
  const _IncomeChart({required this.series});
  final List<({DateTime month, double amount})> series;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final spots = [
      for (var i = 0; i < series.length; i++)
        FlSpot(i.toDouble(), series[i].amount),
    ];
    final maxY = series.fold<double>(1, (m, e) => e.amount > m ? e.amount : m);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (series.length - 1).toDouble(),
        minY: 0,
        maxY: maxY * 1.2,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, _) {
                final i = value.round();
                if (i < 0 || i >= series.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(DateFormat('MMM').format(series[i].month),
                      style: TextStyle(fontSize: 10, color: t.text2)),
                );
              },
            ),
          ),
        ),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.32,
            color: t.brand2,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, _) => spot.x == spots.last.x,
              getDotPainter: (s, _, _, _) => FlDotCirclePainter(
                  radius: 4, color: t.brand2, strokeWidth: 0),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  t.brand2.withValues(alpha: 0.25),
                  t.brand2.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDonut extends StatelessWidget {
  const _StatusDonut({required this.split});
  final StatusSplit split;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    if (split.total <= 0) {
      return Center(
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: t.line, width: 8),
          ),
        ),
      );
    }
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 26,
        sections: [
          if (split.paid > 0)
            PieChartSectionData(
                value: split.paid, color: t.paid, radius: 14, showTitle: false),
          if (split.partial > 0)
            PieChartSectionData(
                value: split.partial,
                color: t.partial,
                radius: 14,
                showTitle: false),
          if (split.due > 0)
            PieChartSectionData(
                value: split.due, color: t.due, radius: 14, showTitle: false),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow(
      {required this.color, required this.label, required this.pct});
  final Color color;
  final String label;
  final double pct;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 8),
        Text('$label · ${(pct * 100).round()}%',
            style: TextStyle(fontSize: 12, color: t.text)),
      ],
    );
  }
}

class _MonthsSelector extends StatelessWidget {
  const _MonthsSelector({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedControl<int>(
      value: value,
      segments: const {3: '3M', 6: '6M', 12: '1Y'},
      onChanged: onChanged,
    );
  }
}

class _HouseBar extends StatelessWidget {
  const _HouseBar({required this.collection});
  final HouseCollection collection;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final gradient = InitialsAvatar.gradientFor(collection.house.name, t);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(collection.house.name,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text('${(collection.rate * 100).round()}%',
                style: TextStyle(fontSize: 12, color: t.text2)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              Container(height: 7, color: t.text2.withValues(alpha: 0.14)),
              FractionallySizedBox(
                widthFactor: collection.rate.clamp(0.0, 1.0),
                child: Container(
                  height: 7,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
