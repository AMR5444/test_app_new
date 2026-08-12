import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:test_app_new/home/models/prayer_times_data.dart';
import 'package:test_app_new/home/models/prayer_schedule.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class PrayerTimesService {
  tz.Location? _timezone;
  Coordinates? _coordinates;
  PrayerTimes? _prayerTimes;
  DateTime? _prayerTimesDate;
  String? _locationName;

  Map<String, String>? _cachedTimesMap;
  DateTime? _cachedTimesMapDate;

  Future<PrayerTimesData> load() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const PrayerTimesException('خدمة الموقع غير مفعلة');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const PrayerTimesException('لا يمكن الوصول إلى الموقع');
    }

    final position = await Geolocator.getCurrentPosition();
    tz.initializeTimeZones();
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    _timezone = tz.getLocation(timezoneInfo.identifier);

    final now = tz.TZDateTime.now(_timezone!);
    _prayerTimesDate = DateTime(now.year, now.month, now.day);
    _coordinates = Coordinates(position.latitude, position.longitude);
    _prayerTimes = PrayerTimes(
      date: now,
      coordinates: _coordinates!,
      calculationParameters: CalculationMethodParameters.egyptian(),
    );
    _cachedTimesMap = null;
    _cachedTimesMapDate = null;

    await _resolveLocationName(position);

    return _buildData(now);
  }

  Future<void> _resolveLocationName(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final pm = placemarks.first;
        final city = pm.locality?.trim();
        if (city != null && city.isNotEmpty) {
          _locationName = city;
          return;
        }
        final subAdmin = pm.subAdministrativeArea?.trim();
        if (subAdmin != null && subAdmin.isNotEmpty) {
          _locationName = subAdmin;
          return;
        }
        final admin = pm.administrativeArea?.trim();
        if (admin != null && admin.isNotEmpty) {
          _locationName = admin;
          return;
        }
        final country = pm.country?.trim();
        if (country != null && country.isNotEmpty) {
          _locationName = country;
          return;
        }
      }
    } catch (_) {
      // Fall through to default
    }
    _locationName = null;
  }

  PrayerTimesData? current() {
    final timezone = _timezone;
    if (timezone == null || _prayerTimes == null) return null;

    final now = tz.TZDateTime.now(timezone);
    final date = DateTime(now.year, now.month, now.day);
    if (_prayerTimesDate != date) return null;

    return _buildData(now);
  }

  List<PrayerSchedule> upcomingSchedules({int days = 3}) {
    final timezone = _timezone;
    final coordinates = _coordinates;
    if (timezone == null || coordinates == null || days <= 0) return const [];

    final now = tz.TZDateTime.now(timezone);
    return List.generate(days, (offset) {
      final date = tz.TZDateTime(
        timezone,
        now.year,
        now.month,
        now.day + offset,
      );
      final times = PrayerTimes(
        date: date,
        coordinates: coordinates,
        calculationParameters: CalculationMethodParameters.egyptian(),
      );

      return PrayerSchedule(
        date: date,
        times: {
          PrayerName.fajr: tz.TZDateTime.from(times.fajr, timezone),
          PrayerName.dhuhr: tz.TZDateTime.from(times.dhuhr, timezone),
          PrayerName.asr: tz.TZDateTime.from(times.asr, timezone),
          PrayerName.maghrib: tz.TZDateTime.from(times.maghrib, timezone),
          PrayerName.isha: tz.TZDateTime.from(times.isha, timezone),
        },
      );
    });
  }

  PrayerTimesData _buildData(tz.TZDateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    if (_cachedTimesMap == null || _cachedTimesMapDate != today) {
      _cachedTimesMapDate = today;
      _cachedTimesMap = _buildTimesMap();
    }
    final nextPrayer = _nextPrayer(now);
    return PrayerTimesData(
      times: _cachedTimesMap!,
      nextPrayer: nextPrayer.name,
      nextPrayerTime: _formatTime(nextPrayer.time),
      countdown: _formatCountdown(nextPrayer.time.difference(now)),
      location: _locationName ?? 'موقعك الحالي',
    );
  }

  Map<String, String> _buildTimesMap() {
    final times = _prayerTimes!;
    return {
      'الفجر': _formatTime(times.fajr),
      'الشروق': _formatTime(times.sunrise),
      'الظهر': _formatTime(times.dhuhr),
      'العصر': _formatTime(times.asr),
      'المغرب': _formatTime(times.maghrib),
      'العشاء': _formatTime(times.isha),
    };
  }

  _NextPrayer _nextPrayer(tz.TZDateTime now) {
    final timezone = _timezone!;
    final times = _prayerTimes!;
    final prayers = [
      _NextPrayer('الفجر', tz.TZDateTime.from(times.fajr, timezone)),
      _NextPrayer('الظهر', tz.TZDateTime.from(times.dhuhr, timezone)),
      _NextPrayer('العصر', tz.TZDateTime.from(times.asr, timezone)),
      _NextPrayer('المغرب', tz.TZDateTime.from(times.maghrib, timezone)),
      _NextPrayer('العشاء', tz.TZDateTime.from(times.isha, timezone)),
    ];
    return prayers.firstWhere(
      (prayer) => prayer.time.isAfter(now),
      orElse: () =>
          _NextPrayer('الفجر', tz.TZDateTime.from(times.fajrAfter, timezone)),
    );
  }

  String _formatTime(DateTime time) =>
      DateFormat('h:mm a', 'ar').format(tz.TZDateTime.from(time, _timezone!));

  String _formatCountdown(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

class PrayerTimesException implements Exception {
  final String message;

  const PrayerTimesException(this.message);
}

class _NextPrayer {
  final String name;
  final DateTime time;

  const _NextPrayer(this.name, this.time);
}
