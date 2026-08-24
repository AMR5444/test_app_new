import 'package:equatable/equatable.dart';

class IslamicEvent extends Equatable {
  final String id;
  final String title;
  final int hijriDay;
  final int? hijriMonth;

  const IslamicEvent({
    required this.id,
    required this.title,
    required this.hijriDay,
    this.hijriMonth,
  });

  bool matchesHijriDate(int day, int month) {
    return hijriDay == day && (hijriMonth == null || hijriMonth == month);
  }

  @override
  List<Object?> get props => [id, title, hijriDay, hijriMonth];
}
