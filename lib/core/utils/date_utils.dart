/// Date helpers used by streak and activity tracking.
abstract final class DateUtilsX {
  /// `yyyy-MM-dd` key for a day (local time).
  static String dayKey(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  static String todayKey() => dayKey(DateTime.now());

  static String yesterdayKey() =>
      dayKey(DateTime.now().subtract(const Duration(days: 1)));

  /// The last 7 days, oldest first, ending today.
  static List<DateTime> lastSevenDays() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
  }

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static String shortWeekday(DateTime date) => _weekdays[date.weekday - 1];

  /// "Good morning" / "Good afternoon" / "Good evening".
  static String greeting([DateTime? now]) {
    final hour = (now ?? DateTime.now()).hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
