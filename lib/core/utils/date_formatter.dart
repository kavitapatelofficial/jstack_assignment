import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _displayFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _dateOnlyFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _timeOnlyFormat = DateFormat('hh:mm a');

  static String formatIso(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return _displayFormat.format(dateTime);
    } catch (_) {
      return isoString;
    }
  }

  static String formatDate(DateTime dateTime) {
    return _displayFormat.format(dateTime.toLocal());
  }

  static String formatDateOnly(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return _dateOnlyFormat.format(dateTime);
    } catch (_) {
      return isoString;
    }
  }

  static String formatTimeOnly(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return _timeOnlyFormat.format(dateTime);
    } catch (_) {
      return isoString;
    }
  }
}
