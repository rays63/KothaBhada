import 'package:intl/intl.dart';

final NumberFormat _grouped = NumberFormat('#,##0', 'en_US');
final NumberFormat _grouped1 = NumberFormat('#,##0.#', 'en_US');

/// "Rs 68,400" — the app's currency display (NPR).
String money(num value, {String symbol = 'Rs'}) =>
    '$symbol ${_grouped.format(value.round())}';

/// Compact currency for tight chips, e.g. 12,000 → "12k", 1,250,000 → "1.3M".
String moneyCompact(num value, {String symbol = 'Rs'}) {
  final v = value.abs();
  if (v >= 1000000) return '$symbol ${_grouped1.format(value / 1000000)}M';
  if (v >= 1000) return '$symbol ${_grouped1.format(value / 1000)}k';
  return '$symbol ${_grouped.format(value.round())}';
}

/// Number without currency, grouped: 1234.5 → "1,234.5".
String number(num value) => _grouped1.format(value);

/// "Jul 2026" from a "YYYY-MM" billing month.
String billingMonthLabel(String billingMonth) {
  final parts = billingMonth.split('-');
  if (parts.length != 2) return billingMonth;
  final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
  return DateFormat('MMM yyyy').format(date);
}

/// "21 Jul 2026"
String dayLabel(DateTime date) => DateFormat('d MMM yyyy').format(date);
