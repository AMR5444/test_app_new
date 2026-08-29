import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app_new/Calendar_section/data/models/calendar_day.dart';
import 'package:test_app_new/Calendar_section/data/models/reminders.dart';
import 'package:test_app_new/Calendar_section/data/models/upcoming_event.dart';
import 'package:test_app_new/Calendar_section/data/services/hijri_calendar_service.dart';
import 'package:test_app_new/Calendar_section/data/services/islamic_events_service.dart';
import 'package:test_app_new/Calendar_section/logic/calendar_state.dart';

export 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit({
    HijriCalendarService? hijriCalendarService,
    IslamicEventsService? islamicEventsService,
  }) : _hijriCalendarService =
           hijriCalendarService ?? const HijriCalendarService(),
       _islamicEventsService =
           islamicEventsService ?? const IslamicEventsService(),
       super(const CalendarState()) {
    Future.microtask(_init);
  }

  final HijriCalendarService _hijriCalendarService;
  final IslamicEventsService _islamicEventsService;

  static const int _nextEventLookaheadDays = 90;

  Future<void> _init() async {
    final today = _normalizedToday();
    _buildMonth(year: today.year, month: today.month, selectedDate: today);
  }

  void selectDay(CalendarDay day) {
    if (isClosed) return;
    emit(state.copyWith(selectedDay: day));
  }

  void goToNextMonth() {
    final next = DateTime(state.focusedYear, state.focusedMonth + 1, 1);
    _buildMonth(year: next.year, month: next.month);
  }

  void goToPreviousMonth() {
    final previous = DateTime(state.focusedYear, state.focusedMonth - 1, 1);
    _buildMonth(year: previous.year, month: previous.month);
  }

  void goToToday() {
    final today = _normalizedToday();
    _buildMonth(year: today.year, month: today.month, selectedDate: today);
  }

  Future<void> retry() => _init();

  void addReminder({
    required String title,
    required int hour,
    required int minute,
  }) {
    if (isClosed) return;
    final day = state.selectedDay?.gregorianDate;
    if (day == null || title.trim().isEmpty) return;

    final reminder = Reminder(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      date: DateTime(day.year, day.month, day.day),
      hour: hour,
      minute: minute,
    );

    emit(state.copyWith(reminders: [...state.reminders, reminder]));
  }

  void deleteReminder(String id) {
    if (isClosed) return;
    emit(
      state.copyWith(
        reminders: state.reminders
            .where((reminder) => reminder.id != id)
            .toList(),
      ),
    );
  }

  void _buildMonth({
    required int year,
    required int month,
    DateTime? selectedDate,
  }) {
    if (isClosed) return;
    emit(state.copyWith(status: CalendarStatus.loading));

    try {
      final weeks = _buildWeeks(year, month);

      final target = selectedDate ?? state.selectedDay?.gregorianDate;
      final allDays = weeks.expand((week) => week);
      final selectedDay =
          (target != null ? _findDay(weeks, target) : null) ??
          _findDay(weeks, _normalizedToday()) ??
          allDays.firstWhere(
            (day) => day.isInFocusedMonth,
            orElse: () => weeks.first.first,
          );

      final nextEvent = _findNextEvent(from: _normalizedToday());

      emit(
        state.copyWith(
          status: CalendarStatus.success,
          focusedYear: year,
          focusedMonth: month,
          weeks: weeks,
          selectedDay: selectedDay,
          nextEvent: nextEvent,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: CalendarStatus.error,
          errorMessage: 'تعذر تحميل التقويم',
        ),
      );
    }
  }

  List<List<CalendarDay>> _buildWeeks(int year, int month) {
    final firstOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final today = _normalizedToday();
    final leadingDays = firstOfMonth.weekday % 7;
    final totalCells = ((leadingDays + daysInMonth + 6) ~/ 7) * 7;
    final gridStart = firstOfMonth.subtract(Duration(days: leadingDays));

    final allDays = List<CalendarDay>.generate(totalCells, (index) {
      final date = DateTime(
        gridStart.year,
        gridStart.month,
        gridStart.day + index,
      );
      final hijri = _hijriCalendarService.toHijri(date);

      return CalendarDay(
        gregorianDate: date,
        hijriDay: hijri.day,
        hijriMonth: hijri.month,
        hijriYear: hijri.year,
        isInFocusedMonth: date.year == year && date.month == month,
        isToday: _isSameDay(date, today),
        events: _islamicEventsService.eventsFor(hijri.day, hijri.month),
      );
    });

    return List<List<CalendarDay>>.generate(
      allDays.length ~/ 7,
      (week) => allDays.sublist(week * 7, week * 7 + 7),
    );
  }

  CalendarDay? _findDay(List<List<CalendarDay>> weeks, DateTime date) {
    for (final week in weeks) {
      for (final day in week) {
        if (day.matchesHijriDate(date)) return day;
      }
    }
    return null;
  }

  UpcomingEvent? _findNextEvent({required DateTime from}) {
    for (var offset = 0; offset <= _nextEventLookaheadDays; offset++) {
      final date = from.add(Duration(days: offset));
      final hijri = _hijriCalendarService.toHijri(date);
      final events = _islamicEventsService.eventsFor(hijri.day, hijri.month);
      if (events.isNotEmpty) {
        return UpcomingEvent(
          event: events.first,
          gregorianDate: date,
          daysAhead: offset,
        );
      }
    }
    return null;
  }

  DateTime _normalizedToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
