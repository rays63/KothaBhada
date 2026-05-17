import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _nepali = NumberFormat.currency(
    locale: 'en_IN',
    symbol: 'रू ',
    decimalDigits: 0,
  );

  static String nepali(num value) => _nepali.format(value);
}
