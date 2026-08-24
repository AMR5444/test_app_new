import 'package:hijri/hijri_calendar.dart';

class HijriTriple {
  final int day;
  final int month;
  final int year;

  const HijriTriple({
    required this.day,
    required this.month,
    required this.year,
  });
}

class HijriCalendarService {
  const HijriCalendarService();

  static const List<String> _hijriMonthNames = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  static const List<String> _gregorianMonthNames = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  static const List<String> _weakDaysNames = [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  HijriTriple toHijri(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);

    return HijriTriple(day: hijri.hDay, month: hijri.hMonth, year: hijri.hYear);
  }

  String hijriMonthName(int hijriMonth) => _hijriMonthNames[hijriMonth - 1];

  String gregorianMonthName(int gregorianMonth) =>
      _gregorianMonthNames[gregorianMonth - 1];

  String weakDayName(int weakDay) => _weakDaysNames[weakDay % 7];

  String toArabicDigits(Object value) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return value.toString().split('').map((character) {
      final code = character.codeUnitAt(0);
      return code >= 48 && code <= 57 ? arabicDigits[code - 48] : character;
    }).join();
  }
}
