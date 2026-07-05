import 'package:intl/intl.dart';

/// Centralized date/time formatting so every screen renders dates the same
/// way instead of re-implementing month-name arrays and ad-hoc string
/// building — a pattern that was duplicated, slightly differently, in
/// almost every screen across this codebase.
class AppDateFormatters {
  AppDateFormatters._();

  static final DateFormat _mediumDate = DateFormat('MMM d, yyyy');
  static final DateFormat _monthDay = DateFormat('MMM d');
  static final DateFormat _weekdayDate = DateFormat('EEEE, MMM d');
  static final DateFormat _time24 = DateFormat('HH:mm');

  /// e.g. "Jul 3, 2026"
  static String mediumDate(DateTime date) => _mediumDate.format(date);

  /// e.g. "Friday, Jul 3"
  static String weekdayAndDate(DateTime date) => _weekdayDate.format(date);

  /// e.g. "14:05" — 24h, zero-padded
  static String time24(DateTime date) => _time24.format(date);

  /// "Today", "1d ago", "6d ago", "2mo ago", "1y ago"
  static String relative(DateTime date, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final diff = reference.difference(date);
    if (diff.inDays <= 0) return 'Today';
    if (diff.inDays == 1) return '1d ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).round()}mo ago';
    return '${(diff.inDays / 365).round()}y ago';
  }

  /// Chat-style timestamp: "14:05" today, "Yesterday 14:05", else "Jul 3, 14:05".
  ///
  /// Fixes the original `DateFormat('MMM d, Hm')` bug: passing a raw pattern
  /// string with a skeleton token ('Hm') to the positional DateFormat
  /// constructor doesn't insert a separator, so it rendered times like
  /// "145" instead of "14:05".
  static String chatTimestamp(DateTime time, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    if (isSameDay(reference, time)) return _time24.format(time);
    if (isSameDay(reference.subtract(const Duration(days: 1)), time)) {
      return 'Yesterday ${_time24.format(time)}';
    }
    return '${_monthDay.format(time)}, ${_time24.format(time)}';
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Strips the time-of-day component. Use this before using a DateTime as
  /// a Map key that needs to match table_calendar's day objects, which are
  /// always normalized to midnight.
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}