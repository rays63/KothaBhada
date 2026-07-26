import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/format.dart';
import '../../../core/l10n_ext.dart';
import '../../../data/models/models.dart';
import '../../../data/providers.dart';
import '../../../data/repository.dart';
import '../../../widgets/kit/kit.dart';

enum _Filter { all, due, partial, paid }

enum _Range { twoWeeks, oneMonth, threeMonths, sixMonths, oneYear, custom }

extension _RangeLabel on _Range {
  String get label => switch (this) {
        _Range.twoWeeks => '2W',
        _Range.oneMonth => '1M',
        _Range.threeMonths => '3M',
        _Range.sixMonths => '6M',
        _Range.oneYear => '1Y',
        _Range.custom => 'Custom',
      };
}

/// Payments tab (design screens 23–26): filter chips, payment rows with
/// status-coloured left border, mark-paid sheet and success screen.
class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  _Filter _filter = _Filter.all;
  _Range _range = _Range.oneMonth;
  DateTimeRange? _customRange;

  /// Inclusive [start, end] window for the selected period, counting back
  /// from now (or the custom range).
  DateTimeRange _window() {
    final now = DateTime.now();
    if (_range == _Range.custom && _customRange != null) return _customRange!;
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final start = switch (_range) {
      _Range.twoWeeks => end.subtract(const Duration(days: 14)),
      _Range.oneMonth => DateTime(now.year, now.month - 1, now.day),
      _Range.threeMonths => DateTime(now.year, now.month - 3, now.day),
      _Range.sixMonths => DateTime(now.year, now.month - 6, now.day),
      _Range.oneYear => DateTime(now.year - 1, now.month, now.day),
      _Range.custom => DateTime(now.year, now.month - 1, now.day),
    };
    return DateTimeRange(start: start, end: end);
  }

  /// Opens the filter sheet (period) and applies the result.
  Future<void> _openFilter() async {
    final result = await showAppSheet<_FilterResult>(
      context,
      builder: (_) => _FilterSheet(range: _range, customRange: _customRange),
    );
    if (result != null) {
      setState(() {
        _range = result.range;
        _customRange = result.customRange;
      });
    }
  }

  /// Short label for the filter button, e.g. "1M" or "Jul 1 – Jul 23".
  String get _filterSummary =>
      _range == _Range.custom && _customRange != null
          ? '${DateFormat('MMM d').format(_customRange!.start)} – ${DateFormat('MMM d').format(_customRange!.end)}'
          : _range.label;

  @override
  Widget build(BuildContext context) {
    final snap = ref.watch(snapshotProvider);
    final window = _window();
    // Payments whose due date falls in the selected period.
    final inWindow = (snap?.payments ?? const <Payment>[]).where((p) {
      final d = p.dueDate;
      return !d.isBefore(window.start) && !d.isAfter(window.end);
    }).toList();

    final filtered = inWindow.where((p) {
      return switch (_filter) {
        _Filter.all => true,
        _Filter.due => p.status == PaymentStatus.due,
        _Filter.partial => p.status == PaymentStatus.partial,
        _Filter.paid => p.status == PaymentStatus.paid,
      };
    }).toList()
      ..sort((a, b) {
        final s = a.status.index.compareTo(b.status.index);
        return s != 0 ? s : b.dueDate.compareTo(a.dueDate);
      });

    final l = context.l10n;
    String filterLabel(_Filter f) => switch (f) {
          _Filter.all => l.payFilterAll,
          _Filter.due => l.payFilterDue,
          _Filter.partial => l.payFilterPartial,
          _Filter.paid => l.payFilterPaid,
        };
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l.paymentsTitle,
                    style: Theme.of(context).textTheme.headlineMedium),
                _FilterButton(label: _filterSummary, onTap: _openFilter),
              ],
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              children: [
                for (final f in _Filter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: filterLabel(f),
                      selected: _filter == f,
                      onTap: () => setState(() => _filter = f),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: (snap == null || filtered.isEmpty)
                ? EmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: l.payNothingHere,
                    message: _filter == _Filter.all
                        ? l.payNoneAll
                        : l.payNoneStatus(filterLabel(_filter)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 120),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) =>
                        _PaymentRow(payment: filtered[i], snap: snap),
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Header pill: a filter icon + the active period/year summary; opens the
/// combined filter sheet.
class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: t.brand2.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune_rounded, size: 16, color: t.brand2),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: t.brand2)),
            ],
          ),
        ),
      ),
    );
  }
}

typedef _FilterResult = ({_Range range, DateTimeRange? customRange});

/// Filter sheet: pick the period (2W/1M/3M/6M/1Y/Custom).
class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.range, required this.customRange});

  final _Range range;
  final DateTimeRange? customRange;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late _Range _range = widget.range;
  late DateTimeRange? _customRange = widget.customRange;

  Future<void> _pickCustom() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _customRange,
    );
    if (picked != null) {
      setState(() {
        _customRange = picked;
        _range = _Range.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    String rangeLabel(_Range r) => switch (r) {
          _Range.twoWeeks => l.payPeriod2W,
          _Range.oneMonth => l.payPeriod1M,
          _Range.threeMonths => l.payPeriod3M,
          _Range.sixMonths => l.payPeriod6M,
          _Range.oneYear => l.payPeriod1Y,
          _Range.custom => l.payPeriodCustom,
        };
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.payFilterTitle,
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        FieldLabel(l.payPeriod),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final r in _Range.values)
              _FilterChip(
                label: r == _Range.custom && _customRange != null
                    ? '${DateFormat('MMM d').format(_customRange!.start)} – ${DateFormat('MMM d').format(_customRange!.end)}'
                    : rangeLabel(r),
                icon: r == _Range.custom ? Icons.calendar_month_rounded : null,
                selected: _range == r,
                onTap: () {
                  if (r == _Range.custom) {
                    _pickCustom();
                  } else {
                    setState(() => _range = r);
                  }
                },
              ),
          ],
        ),
        const SizedBox(height: 22),
        AppButton.primary(
          label: l.commonApply,
          block: true,
          onPressed: () => Navigator.of(context).pop<_FilterResult>(
            (range: _range, customRange: _customRange),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label,
      required this.selected,
      required this.onTap,
      this.icon});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final fg = selected ? t.brand2 : t.text2;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected
              ? t.brand2.withValues(alpha: 0.15)
              : t.text2.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentRow extends ConsumerWidget {
  const _PaymentRow({required this.payment, required this.snap});
  final Payment payment;
  final PortfolioSnapshot snap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = context.l10n;
    final tenant =
        snap.tenantById(payment.tenantId) ?? snap.activeTenantOf(payment.roomId);
    final room = snap.roomOf(payment.roomId);
    final house = snap.houseOfRoom(payment.roomId);
    final name = tenant?.fullName ?? 'Tenant';
    final (Color border, StatusKind kind, String statusLabel) =
        switch (payment.status) {
      PaymentStatus.due => (
          t.due,
          StatusKind.due,
          payment.isOverdue ? l.statusOverdue : l.statusDue
        ),
      PaymentStatus.partial => (t.partial, StatusKind.partial, l.statusPartial),
      PaymentStatus.paid => (Colors.transparent, StatusKind.paid, l.statusPaid),
    };

    final subtitle = switch (payment.status) {
      PaymentStatus.paid => l.payAmountPaid(money(payment.amountPaid)),
      PaymentStatus.partial =>
        l.payOfTotal(money(payment.amountPaid), money(payment.totalDue)),
      PaymentStatus.due => l.payAmountDue(money(payment.remaining)),
    };

    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(AppTokens.rCard),
        boxShadow: t.shadowSm,
        border: Border(left: BorderSide(color: border, width: 4)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTokens.rCard),
          onTap: payment.status == PaymentStatus.paid
              ? null
              : () => _openMarkPaid(context, ref, payment, name,
                  room?.roomNumber ?? ''),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                InitialsAvatar(label: name, size: 38, radius: 12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$name · ${room?.roomNumber ?? ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.home_rounded, size: 12, color: t.text2),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(house?.name ?? l.payUnassigned,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: t.text2)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: TextStyle(fontSize: 12, color: t.text2)),
                    ],
                  ),
                ),
                StatusChip(label: statusLabel, kind: kind),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _openMarkPaid(BuildContext context, WidgetRef ref, Payment payment,
    String name, String roomNumber) async {
  await showAppSheet<void>(
    context,
    builder: (_) => _MarkPaidSheet(
      payment: payment,
      name: name,
      roomNumber: roomNumber,
    ),
  );
}

class _MarkPaidSheet extends ConsumerStatefulWidget {
  const _MarkPaidSheet(
      {required this.payment, required this.name, required this.roomNumber});
  final Payment payment;
  final String name;
  final String roomNumber;

  @override
  ConsumerState<_MarkPaidSheet> createState() => _MarkPaidSheetState();
}

class _MarkPaidSheetState extends ConsumerState<_MarkPaidSheet> {
  bool _full = true;
  late final TextEditingController _amount;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(
        text: widget.payment.remaining.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = context.l10n;
    final remaining = widget.payment.remaining;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.payMarkAsPaid, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          l.payMarkAsPaidSub(
              widget.name, widget.roomNumber, money(remaining)),
          style: TextStyle(fontSize: 13, color: t.text2),
        ),
        const SizedBox(height: 16),
        SegmentedControl<bool>(
          value: _full,
          segments: {true: l.payFullPayment, false: l.payPartial},
          onChanged: (v) => setState(() {
            _full = v;
            _amount.text = v ? remaining.toStringAsFixed(0) : '';
          }),
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: l.payAmountReceived,
          controller: _amount,
          enabled: !_full,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: AppButton.outline(
                label: l.commonCancel,
                block: true,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppButton.primary(
                label: l.commonConfirm,
                icon: Icons.check_rounded,
                block: true,
                onPressed: _confirm,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirm() async {
    final remaining = widget.payment.remaining;
    final amount = _full
        ? remaining
        : (double.tryParse(_amount.text.trim()) ?? 0);
    if (amount <= 0) {
      showAppToast(context, context.l10n.payEnterAmount, success: false);
      return;
    }
    try {
      final notifier = ref.read(portfolioProvider.notifier);
      if (_full || amount >= remaining) {
        await notifier.markPaid(widget.payment.id);
      } else {
        await notifier.recordPartial(widget.payment.id, amount);
      }
      if (!mounted) return;
      Navigator.of(context).pop(); // close sheet
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(
          amount: amount,
          name: widget.name,
          roomNumber: widget.roomNumber,
          full: _full || amount >= remaining,
        ),
      ));
    } catch (e) {
      if (mounted) showAppToast(context, '$e', success: false);
    }
  }
}

/// Full-screen success confirmation (design screen 25).
class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    required this.name,
    required this.roomNumber,
    required this.full,
  });

  final double amount;
  final String name;
  final String roomNumber;
  final bool full;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: t.brandGradient),
        child: Stack(
          children: [
            const Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: GlowBlob(color: Color(0xFF5EEAD4), size: 240, opacity: 0.35),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 78,
                          height: 78,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check_rounded,
                              color: t.brand2, size: 42),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(context.l10n.payRecordedTitle,
                        style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.payRecordedBody(
                          money(amount), name, roomNumber),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.white.withValues(alpha: 0.9)),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '${dayLabel(DateTime.now())} · ${full ? context.l10n.payTagFull : context.l10n.payTagPartial}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 160,
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTokens.rButton),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(AppTokens.rButton),
                          onTap: () => Navigator.of(context).pop(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Center(
                              child: Text(context.l10n.commonDone,
                                  style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: t.brand1)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
