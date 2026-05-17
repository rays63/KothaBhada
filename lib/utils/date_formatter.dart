import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _date = DateFormat('yyyy-MM-dd');
  static final DateFormat _dateTime = DateFormat('yyyy-MM-dd HH:mm');

  static String date(DateTime value) => _date.format(value.toLocal());

  static String dateTime(DateTime value) => _dateTime.format(value.toLocal());
}
