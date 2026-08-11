import 'package:shared_preferences/shared_preferences.dart';

class DailyReadingService {
  DailyReadingService._();

  static final DailyReadingService shared = DailyReadingService._();

  static const _storageKeyPrefix = 'daily_quran_reading_seconds_';
  DateTime? _sessionStartedAt;

  void startReading() {
    _sessionStartedAt ??= DateTime.now();
  }

  Future<void> stopReading() async {
    final sessionStartedAt = _sessionStartedAt;
    if (sessionStartedAt == null) return;

    _sessionStartedAt = null;
    await _saveDuration(sessionStartedAt, DateTime.now());
  }

  Future<int> getTodayReadingMinutes() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    var totalSeconds = prefs.getInt(_storageKey(now)) ?? 0;

    final sessionStartedAt = _sessionStartedAt;
    if (sessionStartedAt != null) {
      totalSeconds += _durationForDate(sessionStartedAt, now, now);
    }
    return totalSeconds ~/ Duration.secondsPerMinute;
  }

  Future<void> _saveDuration(DateTime start, DateTime end) async {
    final prefs = await SharedPreferences.getInstance();
    var cursor = start;

    while (cursor.isBefore(end)) {
      final nextDay = DateTime(cursor.year, cursor.month, cursor.day + 1);
      final segmentEnd = end.isBefore(nextDay) ? end : nextDay;
      final key = _storageKey(cursor);
      final savedSeconds = prefs.getInt(key) ?? 0;
      final durationSeconds = segmentEnd.difference(cursor).inSeconds;
      await prefs.setInt(key, savedSeconds + durationSeconds);
      cursor = segmentEnd;
    }
  }

  int _durationForDate(DateTime start, DateTime end, DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final segmentStart = start.isAfter(dayStart) ? start : dayStart;
    final segmentEnd = end.isBefore(dayEnd) ? end : dayEnd;
    return segmentEnd.isAfter(segmentStart)
        ? segmentEnd.difference(segmentStart).inSeconds
        : 0;
  }

  String _storageKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$_storageKeyPrefix$year-$month-$day';
  }
}
