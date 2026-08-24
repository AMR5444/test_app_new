import 'package:equatable/equatable.dart';
import 'package:test_app_new/Calendar_section/data/models/calendar_day.dart';
import 'package:test_app_new/Calendar_section/data/models/upcoming_event.dart';

enum CalendarStatus { initial, loading, success, error }

class CalendarState extends Equatable {
  final CalendarStatus status;
  final int focusedYear;
  final int focusedMonth;
  final List<List<CalendarDay>> weeks;
  final CalendarDay? selectedDay;
  final UpcomingEvent? nextEvent;
  final String? errorMessage;

  const CalendarState({
    this.status = CalendarStatus.initial,
    this.focusedYear = 0,
    this.focusedMonth = 0,
    this.weeks = const [],
    this.selectedDay,
    this.nextEvent,
    this.errorMessage,
  });

  CalendarState copyWith({
    CalendarStatus? status,
    int? focusedYear,
    int? focusedMonth,
    List<List<CalendarDay>>? weeks,
    CalendarDay? selectedDay,
    UpcomingEvent? nextEvent,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CalendarState(
      status: status ?? this.status,
      focusedYear: focusedYear ?? this.focusedYear,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      weeks: weeks ?? this.weeks,
      selectedDay: selectedDay ?? this.selectedDay,
      nextEvent: nextEvent ?? this.nextEvent,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    focusedYear,
    focusedMonth,
    weeks,
    selectedDay,
    nextEvent,
    errorMessage,
  ];
}
