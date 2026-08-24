import 'package:equatable/equatable.dart';
import 'package:test_app_new/Calendar_section/data/models/islamic_event.dart';

class CalendarDay extends Equatable {
  final DateTime gregorianDate;
  final int hijriDay;
  final int hijriMonth;
  final int hijriYear;
  final bool isInFocusedMonth;
  final bool isToday;
  final List<IslamicEvent> events;

  const CalendarDay({
    required this.gregorianDate,
    required this.hijriDay,
    required this.hijriMonth,
    required this.hijriYear,
    required this.isInFocusedMonth,
    required this.isToday,
    this.events = const [],
  });

  bool get hasEvents => events.isNotEmpty;

  bool matchesHijriDate(DateTime other) {
    return gregorianDate.year == other.year &&
        gregorianDate.month == other.month &&
        gregorianDate.day == other.day;
  }

  @override
  List<Object?> get props => [
    gregorianDate,
    hijriDay,
    hijriMonth,
    hijriYear,
    isInFocusedMonth,
    isToday,
    events,
  ];
}
