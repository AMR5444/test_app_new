import 'package:equatable/equatable.dart';

class Reminder extends Equatable {
  final String id;
  final String title;
  final DateTime date;
  final int hour;
  final int minute;

  const Reminder({
    required this.id,
    required this.title,
    required this.date,
    required this.hour,
    required this.minute,
  });

  bool matchesDate(DateTime other) {
    return date.year == other.year &&
        date.month == other.month &&
        date.day == other.day;
  }

  String get formattedTime {
    final isPm = hour >= 12;
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    final mm = minute.toString().padLeft(2, '0');
    return '$h12:$mm ${isPm ? 'م' : 'ص'}';
  }

  @override
  List<Object?> get props => [id, title, date, hour, minute];
}
