import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format.dart';
import '../../../core/l10n_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/models/models.dart';
import '../../../data/providers.dart';
import '../../../widgets/kit/kit.dart';
import '../widgets/screen_header.dart';
import 'house_form_screen.dart';
import 'room_detail_screen.dart';
import 'room_form_screen.dart';

/// House detail with the rooms grid (design screens 10 + 11 empty).
class HouseDetailScreen extends ConsumerWidget {
  const HouseDetailScreen({super.key, required this.houseId});

  final String houseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(snapshotProvider);
    final house = snap?.houseOf(houseId);
    if (snap == null || house == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final l = context.l10n;
    final rooms = snap.roomsOf(houseId);
    final occupied = rooms.where((r) => r.isOccupied).length;
    final month = billingMonthOf(DateTime.now());
    final payments = {
      for (final p in snap.paymentsForMonth(month)) p.roomId: p,
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(
              title: house.name,
              subtitle: house.address.isEmpty ? null : house.address,
              trailing: _HouseMenu(house: house),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 2, 22, 10),
              child: Row(
                children: [
                  StatusChip(
                    label: l.houseRatePerUnit(
                        number(house.electricityRatePerUnit)),
                    kind: StatusKind.brand,
                    icon: Icons.bolt_rounded,
                  ),
                  const SizedBox(width: 8),
                  if (rooms.isNotEmpty)
                    StatusChip(
                      label: l.houseOccupiedOf(occupied, rooms.length),
                      kind: occupied == rooms.length
                          ? StatusKind.paid
                          : StatusKind.neutral,
                    ),
                ],
              ),
            ),
            Expanded(
              child: rooms.isEmpty
                  ? _EmptyHouse(houseId: houseId)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
                      children: [
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.35,
                          children: [
                            for (final room in rooms)
                              _RoomCard(
                                room: room,
                                tenant: snap.activeTenantOf(room.id),
                                payment: payments[room.id],
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        AppButton.outline(
                          label: l.houseAddRoom,
                          icon: Icons.add_rounded,
                          block: true,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  RoomFormScreen(houseId: houseId),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.room, this.tenant, this.payment});

  final Room room;
  final Tenant? tenant;
  final Payment? payment;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = context.l10n;
    final (String statusLabel, StatusKind statusKind) = _status(l);
    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => RoomDetailScreen(roomId: room.id)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusChip(label: room.roomNumber, kind: StatusKind.neutral),
              StatusChip(label: statusLabel, kind: statusKind),
            ],
          ),
          const Spacer(),
          Text(
            tenant?.fullName ?? l.labelEmpty,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: tenant == null ? t.text2 : t.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(l.roomPerMonthShort(money(room.monthlyRent)),
              style: TextStyle(fontSize: 12, color: t.text2)),
        ],
      ),
    );
  }

  (String, StatusKind) _status(AppLocalizations l) {
    if (!room.isOccupied) return (l.statusVacant, StatusKind.neutral);
    final p = payment;
    if (p == null) return (l.statusOccupied, StatusKind.paid);
    return switch (p.status) {
      PaymentStatus.paid => (l.statusOccupied, StatusKind.paid),
      PaymentStatus.partial => (l.statusPartial, StatusKind.partial),
      PaymentStatus.due => p.isOverdue
          ? (l.statusOverdue, StatusKind.due)
          : (l.statusRentDue, StatusKind.due),
    };
  }
}

class _HouseMenu extends ConsumerWidget {
  const _HouseMenu({required this.house});
  final House house;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: t.text2),
      color: t.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) async {
        if (value == 'edit') {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => HouseFormScreen(house: house)));
        } else if (value == 'delete') {
          final ok = await showConfirmDialog(
            context,
            title: context.l10n.houseDeleteTitle(house.name),
            message: context.l10n.houseDeleteBody,
            confirmLabel: context.l10n.commonDelete,
            danger: true,
          );
          if (ok) {
            await ref.read(portfolioProvider.notifier).deleteHouse(house.id);
            if (context.mounted) Navigator.of(context).pop();
          }
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'edit', child: Text(context.l10n.houseMenuEdit)),
        PopupMenuItem(
            value: 'delete', child: Text(context.l10n.houseMenuDelete)),
      ],
    );
  }
}

class _EmptyHouse extends StatelessWidget {
  const _EmptyHouse({required this.houseId});
  final String houseId;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.meeting_room_rounded,
      title: context.l10n.houseNoRoomsTitle,
      message: context.l10n.houseNoRoomsBody,
      actionLabel: context.l10n.houseAddRoom,
      actionIcon: Icons.add_rounded,
      onAction: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => RoomFormScreen(houseId: houseId)),
      ),
    );
  }
}
