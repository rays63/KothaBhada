import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n_ext.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../data/repository.dart';
import '../../widgets/kit/kit.dart';
import 'houses/house_detail_screen.dart';
import 'houses/house_form_screen.dart';

/// Dashboard / Home (design screens 07 + 08).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final snap = ref.watch(snapshotProvider);
    final stats = ref.watch(dashboardStatsProvider);
    final landlord = snap?.landlordName ?? 'Landlord';

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Eyebrow(context.l10n.dashGreeting),
                      const SizedBox(height: 2),
                      Text(landlord,
                          style: Theme.of(context).textTheme.headlineMedium),
                    ],
                  ),
                ),
                InitialsAvatar(
                  label: landlord,
                  size: 44,
                  radius: 14,
                  gradient: t.brandGradient,
                ),
              ],
            ),
          ),
          Expanded(
            child: (snap == null || snap.houses.isEmpty)
                ? _EmptyDashboard(onAdd: () => _addHouse(context))
                : _DashboardBody(snap: snap, stats: stats),
          ),
        ],
      ),
    );
  }

  static void _addHouse(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const HouseFormScreen()),
      );
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.snap, required this.stats});

  final PortfolioSnapshot snap;
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = context.l10n;
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(22, 6, 22, 150),
          children: [
            // Hero — collected this month
            GradientPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.dashCollectedThisMonth,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    money(stats.collected),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(l.dashOfExpected(money(stats.expected)),
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12)),
                  const SizedBox(height: 12),
                  BrandProgressBar(value: stats.collectionRate, onBrand: true),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Stat row
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.home_rounded,
                    value: '${stats.houseCount}',
                    label: l.dashHouses,
                    accent: t.sky,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    icon: Icons.grid_view_rounded,
                    value: '${stats.roomCount}',
                    label: l.dashRooms,
                    accent: t.violet,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    icon: Icons.error_outline_rounded,
                    value: moneyCompact(stats.due).replaceAll('Rs ', ''),
                    label: l.dashDue,
                    accent: t.due,
                    valueColor: t.due,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SectionHeader(
              title: l.dashYourHouses,
              actionLabel: l.dashSeeAll,
              onAction: () {},
            ),
            const SizedBox(height: 10),
            for (final house in snap.houses) ...[
              _HouseRow(house: house, snap: snap),
              const SizedBox(height: 10),
            ],
          ],
        ),
        Positioned(
          right: 18,
          bottom: 110,
          child: AppButton.primary(
            label: l.dashAddHouse,
            icon: Icons.add_rounded,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HouseFormScreen()),
            ),
          ),
        ),
      ],
    );
  }
}

class _HouseRow extends StatelessWidget {
  const _HouseRow({required this.house, required this.snap});

  final House house;
  final PortfolioSnapshot snap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final rooms = snap.roomsOf(house.id);
    final occupied = rooms.where((r) => r.isOccupied).length;
    final total = rooms.length;

    final StatusKind kind;
    if (total == 0 || occupied == 0) {
      kind = StatusKind.neutral;
    } else if (occupied == total) {
      kind = StatusKind.paid;
    } else {
      kind = StatusKind.brand;
    }

    return ListRowCard(
      leading: InitialsAvatar(
        label: house.name,
        gradient: InitialsAvatar.gradientFor(house.name, t),
      ),
      title: house.name,
      subtitle: '${house.address} · ${context.l10n.roomsCount(total)}',
      trailing: StatusChip(label: '$occupied/$total', kind: kind),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => HouseDetailScreen(houseId: house.id)),
      ),
    );
  }
}

class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return EmptyState(
      icon: Icons.home_work_rounded,
      title: l.dashNoHousesTitle,
      message: l.dashNoHousesBody,
      actionLabel: l.dashAddHouse,
      actionIcon: Icons.add_rounded,
      onAction: onAdd,
    );
  }
}
