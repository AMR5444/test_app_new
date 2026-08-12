import 'package:timezone/timezone.dart' as tz;

enum PrayerName { fajr, dhuhr, asr, maghrib, isha }

extension PrayerNameLabel on PrayerName {
  String get label => switch (this) {
    PrayerName.fajr => 'الفجر',
    PrayerName.dhuhr => 'الظهر',
    PrayerName.asr => 'العصر',
    PrayerName.maghrib => 'المغرب',
    PrayerName.isha => 'العشاء',
  };
}

class PrayerSchedule {
  final DateTime date;
  final Map<PrayerName, tz.TZDateTime> times;

  const PrayerSchedule({required this.date, required this.times});
}
