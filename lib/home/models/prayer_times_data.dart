class PrayerTimesData {
  final Map<String, String> times;
  final String nextPrayer;
  final String nextPrayerTime;
  final String countdown;
  final String location;

  const PrayerTimesData({
    required this.times,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.countdown,
    required this.location,
  });
}
