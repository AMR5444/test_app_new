import 'package:equatable/equatable.dart';
import 'package:test_app_new/Calendar_section/data/models/islamic_event.dart';

class UpcomingEvent extends Equatable {
  final IslamicEvent event;
  final DateTime gregorianDate;
  final int daysAhead;

  const UpcomingEvent({
    required this.event,
    required this.gregorianDate,
    required this.daysAhead,
  });

  @override
  List<Object?> get props => [event, gregorianDate, daysAhead];
}
