import 'package:hijri/hijri_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class HomeDateTimeService {
  late final DateFormat _timeFormat;
  late final DateFormat _gregorianFormat;

  static const List<String> _hijriMonths = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الثاني',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  Future<void> initialize() async {
    await initializeDateFormatting('ar');
    _timeFormat = DateFormat('h:mm:ss a', 'ar');
    _gregorianFormat = DateFormat('EEEE d MMMM', 'ar');
  }

  HomeDateTimeData format(DateTime dateTime) {
    return HomeDateTimeData(
      currentTime: _timeFormat.format(dateTime),
      dateHeader: _toArabicNumbers(_gregorianFormat.format(dateTime)),
      hijriDate: _formatHijri(dateTime),
    );
  }

  String _formatHijri(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    final day = _toArabicNumbers(hijri.hDay.toString());
    final month = _hijriMonths[hijri.hMonth - 1];
    final year = _toArabicNumbers(hijri.hYear.toString());
    return '$day $month $year هـ';
  }

  String _toArabicNumbers(String input) {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return input.split('').map((character) {
      final code = character.codeUnitAt(0);
      return code >= 48 && code <= 57 ? arabic[code - 48] : character;
    }).join();
  }
}

class HomeDateTimeData {
  final String currentTime;
  final String dateHeader;
  final String hijriDate;

  const HomeDateTimeData({
    required this.currentTime,
    required this.dateHeader,
    required this.hijriDate,
  });
}
