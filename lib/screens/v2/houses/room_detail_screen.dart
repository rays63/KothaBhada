import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format.dart';
import '../../../core/l10n_ext.dart';
import '../../../data/models/models.dart';
import '../../../data/providers.dart';
import '../../../widgets/kit/kit.dart';
import '../tenants/add_tenant_screen.dart';
import '../tenants/tenant_profile_screen.dart';
import '../widgets/screen_header.dart';
import 'room_form_screen.dart';

/// Room detail: tenant section + Electricity / Utilities / Payments tabs
/// (design screen 13).
class RoomDetailScreen extends ConsumerStatefulWidget {
  const RoomDetailScreen({super.key, required this.roomId});

  final String roomId;

  @override
  ConsumerState<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends ConsumerState<RoomDetailScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final snap = ref.watch(snapshotProvider);
    final room = snap?.roomOf(widget.roomId);
    if (snap == null || room == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final house = snap.houseOf(room.houseId);
    final tenant = snap.activeTenantOf(room.id);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(
              title: context.l10n.roomTitle(room.roomNumber),
              subtitle: context.l10n.roomPerMonth(money(room.monthlyRent)),
              trailing: _RoomMenu(room: room),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 6, 22, 28),
                children: [
                  _TenantSection(room: room, tenant: tenant),
                  const SizedBox(height: 14),
                  SegmentedControl<int>(
                    value: _tab,
                    segments: {
                      0: context.l10n.tabElectricity,
                      1: context.l10n.tabUtilities,
                      2: context.l10n.tabPayments,
                    },
                    onChanged: (v) => setState(() => _tab = v),
                  ),
                  const SizedBox(height: 14),
                  switch (_tab) {
                    0 => _ElectricityTab(
                        room: room,
                        rate: house?.electricityRatePerUnit ?? 0,
                      ),
                    1 => _UtilitiesTab(room: room),
                    _ => _PaymentsTab(roomId: room.id),
                  },
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomMenu extends ConsumerWidget {
  const _RoomMenu({required this.room});
  final Room room;

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
              builder: (_) =>
                  RoomFormScreen(houseId: room.houseId, room: room)));
        } else if (value == 'delete') {
          final ok = await showConfirmDialog(
            context,
            title: context.l10n.roomDeleteTitle(room.roomNumber),
            message: context.l10n.roomDeleteBody,
            confirmLabel: context.l10n.commonDelete,
            danger: true,
          );
          if (ok) {
            await ref.read(portfolioProvider.notifier).deleteRoom(room.id);
            if (context.mounted) Navigator.of(context).pop();
          }
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'edit', child: Text(context.l10n.roomMenuEdit)),
        PopupMenuItem(
            value: 'delete', child: Text(context.l10n.roomMenuDelete)),
      ],
    );
  }
}

class _TenantSection extends ConsumerWidget {
  const _TenantSection({required this.room, this.tenant});
  final Room room;
  final Tenant? tenant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    if (tenant == null) {
      return AppCard(
        child: Row(
          children: [
            IconPill(icon: Icons.person_add_alt_1_rounded, color: t.brand2),
            const SizedBox(width: 12),
            Expanded(
              child: Text(context.l10n.roomNoTenant,
                  style: TextStyle(fontWeight: FontWeight.w600, color: t.text2)),
            ),
            AppButton.primary(
              label: context.l10n.commonAdd,
              icon: Icons.add_rounded,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => AddTenantScreen(roomId: room.id)),
              ),
            ),
          ],
        ),
      );
    }

    return ListRowCard(
      leading: InitialsAvatar(label: tenant!.fullName),
      title: tenant!.fullName,
      subtitle: context.l10n.tenantInSince(
          tenant!.phone.isEmpty ? context.l10n.tenantNoPhone : tenant!.phone,
          dayLabel(tenant!.moveInDate)),
      trailing: Icon(Icons.chevron_right_rounded, color: t.text2),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TenantProfileScreen(tenantId: tenant!.id),
        ),
      ),
    );
  }
}

class _ElectricityTab extends ConsumerStatefulWidget {
  const _ElectricityTab({required this.room, required this.rate});
  final Room room;
  final double rate;

  @override
  ConsumerState<_ElectricityTab> createState() => _ElectricityTabState();
}

class _ElectricityTabState extends ConsumerState<_ElectricityTab> {
  final _current = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _current.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final readings =
        ref.watch(electricityForRoomProvider(widget.room.id)).valueOrNull ??
            const [];
    final previous = readings.isEmpty ? 0.0 : readings.first.currentUnit;
    final current = double.tryParse(_current.text.trim());
    final units = (current == null || current < previous)
        ? 0.0
        : current - previous;
    final amount = units * widget.rate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                  context.l10n.elecNewReading(
                      billingMonthLabel(billingMonthOf(DateTime.now()))),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ReadingBox(
                      label: context.l10n.elecPrevious,
                      value: number(previous),
                      highlight: false,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FieldLabel(context.l10n.elecCurrent),
                        TextField(
                          controller: _current,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*')),
                          ],
                          onChanged: (_) => setState(() {}),
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: t.brand2,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: number(previous),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: t.brand2, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: t.brand2, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: t.brandGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _GradientStat(
                        label: context.l10n.elecUnitsConsumed,
                        value: number(units)),
                    _GradientStat(
                      label: context.l10n.elecAmountAtRate(number(widget.rate)),
                      value: money(amount),
                      alignEnd: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppButton.primary(
                label: context.l10n.elecSaveReading,
                block: true,
                loading: _saving,
                onPressed: (current != null && current >= previous && units > 0)
                    ? _save
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (readings.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(context.l10n.elecRecentReadings,
                style: Theme.of(context).textTheme.titleSmall),
          ),
          const SizedBox(height: 8),
          for (final r in readings.take(6))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListRowCard(
                leading: IconPill(icon: Icons.bolt_rounded, color: t.amber),
                title: billingMonthLabel(r.billingMonth),
                subtitle: context.l10n
                    .elecUnitsAmount(number(r.unitsConsumed), money(r.amount)),
                trailing: Text(number(r.currentUnit),
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        color: t.text2)),
              ),
            ),
        ],
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(portfolioProvider.notifier).saveElectricityReading(
            roomId: widget.room.id,
            currentUnit: double.parse(_current.text.trim()),
          );
      if (!mounted) return;
      _current.clear();
      showAppToast(context, context.l10n.elecReadingSaved);
    } catch (e) {
      if (mounted) showAppToast(context, '$e', success: false);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _ReadingBox extends StatelessWidget {
  const _ReadingBox(
      {required this.label, required this.value, required this.highlight});
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(label),
          Text(value,
              style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _GradientStat extends StatelessWidget {
  const _GradientStat(
      {required this.label, required this.value, this.alignEnd = false});
  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11, color: Colors.white.withValues(alpha: 0.9))),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
      ],
    );
  }
}

class _UtilitiesTab extends ConsumerStatefulWidget {
  const _UtilitiesTab({required this.room});
  final Room room;

  @override
  ConsumerState<_UtilitiesTab> createState() => _UtilitiesTabState();
}

class _UtilitiesTabState extends ConsumerState<_UtilitiesTab> {
  UtilityType _type = UtilityType.internet;
  final _amount = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  IconData _icon(UtilityType t) => switch (t) {
        UtilityType.internet => Icons.wifi_rounded,
        UtilityType.water => Icons.water_drop_rounded,
        UtilityType.garbage => Icons.delete_outline_rounded,
        UtilityType.other => Icons.receipt_long_rounded,
      };

  String _label(BuildContext context, UtilityType type) => switch (type) {
        UtilityType.internet => context.l10n.utilInternet,
        UtilityType.water => context.l10n.utilWater,
        UtilityType.garbage => context.l10n.utilGarbage,
        UtilityType.other => context.l10n.utilOther,
      };

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = context.l10n;
    final charges =
        ref.watch(utilitiesForRoomProvider(widget.room.id)).valueOrNull ??
            const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FieldLabel(l.utilChargeType),
              SegmentedControl<UtilityType>(
                value: _type,
                segments: {
                  UtilityType.internet: l.utilInternet,
                  UtilityType.water: l.utilWater,
                  UtilityType.garbage: l.utilGarbage,
                  UtilityType.other: l.utilOther,
                },
                onChanged: (v) => setState(() => _type = v),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: l.utilAmount,
                hint: '500',
                controller: _amount,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              AppButton.primary(
                label: l.utilAddCharge,
                block: true,
                loading: _saving,
                onPressed: (double.tryParse(_amount.text.trim()) ?? 0) > 0
                    ? _save
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (charges.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(l.utilHistory,
                style: Theme.of(context).textTheme.titleSmall),
          ),
          const SizedBox(height: 8),
          for (final c in charges.take(10))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListRowCard(
                leading: IconPill(icon: _icon(c.type), color: t.sky),
                title: _label(context, c.type),
                subtitle: billingMonthLabel(c.billingMonth),
                trailing: Text(money(c.amount),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref.read(portfolioProvider.notifier).addUtilityCharge(
          roomId: widget.room.id,
          type: _type,
          amount: double.parse(_amount.text.trim()),
        );
    if (!mounted) return;
    _amount.clear();
    setState(() => _saving = false);
    showAppToast(context, context.l10n.utilChargeAdded);
  }
}

class _PaymentsTab extends ConsumerWidget {
  const _PaymentsTab({required this.roomId});
  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = context.l10n;
    final snap = ref.watch(snapshotProvider);
    final payments = (snap?.payments ?? const [])
        .where((p) => p.roomId == roomId)
        .toList();
    if (payments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(l.payNoPaymentsYet,
            textAlign: TextAlign.center,
            style: TextStyle(color: t.text2)),
      );
    }
    return Column(
      children: [
        for (final p in payments)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(billingMonthLabel(p.billingMonth),
                          style:
                              const TextStyle(fontWeight: FontWeight.w700)),
                      StatusChip(
                        label: switch (p.status) {
                          PaymentStatus.paid => l.statusPaid,
                          PaymentStatus.partial => l.statusPartial,
                          PaymentStatus.due =>
                            p.isOverdue ? l.statusOverdue : l.statusDue,
                        },
                        kind: switch (p.status) {
                          PaymentStatus.paid => StatusKind.paid,
                          PaymentStatus.partial => StatusKind.partial,
                          PaymentStatus.due => StatusKind.due,
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.payOfTotal(money(p.amountPaid), money(p.totalDue)),
                    style: TextStyle(fontSize: 12, color: t.text2),
                  ),
                  if (p.status != PaymentStatus.paid) ...[
                    const SizedBox(height: 10),
                    AppButton.primary(
                      label: l.payMarkPaid,
                      block: true,
                      onPressed: () async {
                        await ref
                            .read(portfolioProvider.notifier)
                            .markPaid(p.id);
                        if (context.mounted) {
                          showAppToast(context, l.payPaymentRecorded);
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
