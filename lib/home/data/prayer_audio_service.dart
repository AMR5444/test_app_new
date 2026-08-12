import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app_new/core/Notifications/NotificationsService.dart';
import 'package:test_app_new/home/data/prayer_audio_voice_catalog.dart';
import 'package:test_app_new/home/models/prayer_schedule.dart';
import 'package:timezone/timezone.dart' as tz;

class PrayerAudioService {
  PrayerAudioService._();

  static final PrayerAudioService shared = PrayerAudioService._();

  static const int _scheduleDays = 3;
  static const int _adhanIdOffset = 10000;
  static const int _iqamaIdOffset = 20000;
  static const int _reminderIdOffset = 30000;

  List<PrayerSchedule> _cachedSchedules = const [];

  Future<void> schedule(List<PrayerSchedule> schedules) async {
    _cachedSchedules = schedules.take(_scheduleDays).toList(growable: false);
    await _scheduleCached();
  }

  Future<void> syncWithSettings() async {
    await _scheduleCached();
  }

  Future<void> _scheduleCached() async {
    await _cancelAll();
    if (_cachedSchedules.isEmpty) return;

    final preferences = await SharedPreferences.getInstance();
    final adhanEnabled = preferences.getBool('adhanEnabled') ?? true;
    final iqamaEnabled = preferences.getBool('iqamaEnabled') ?? true;
    final reminderEnabled = preferences.getBool('prayerNotifications') ?? true;
    final reminderMinutes = preferences.getInt('prayerReminderMinutes') ?? 15;
    final adhanVoice = PrayerAudioVoiceCatalog.resolveAdhanVoice(
      preferences.getString('selectedAdhanVoiceId'),
    );
    final iqamaVoice = PrayerAudioVoiceCatalog.resolveIqamaVoice(
      preferences.getString('selectedIqamaVoiceId'),
    );
    final now = tz.TZDateTime.now(
      _cachedSchedules.first.times.values.first.location,
    );

    for (var dayIndex = 0; dayIndex < _cachedSchedules.length; dayIndex++) {
      final schedule = _cachedSchedules[dayIndex];
      for (final entry in schedule.times.entries) {
        final prayer = entry.key;
        final prayerTime = entry.value;
        final eventId = dayIndex * PrayerName.values.length + prayer.index;

        if (adhanEnabled && prayerTime.isAfter(now)) {
          await NotificationsService.schedulePrayerNotification(
            id: _adhanIdOffset + eventId,
            title: 'حان وقت صلاة ${prayer.label}',
            body: 'حان الآن موعد الأذان.',
            scheduledDate: prayerTime,
            channelId: 'prayer_adhan_${adhanVoice.id}',
            channelName: 'Adhan',
            assetPath: adhanVoice.assetPath,
            addStopAction: true,
          );
        }

        final iqamaDelay = prayer == PrayerName.maghrib ? 5 : 15;
        final iqamaTime = prayerTime.add(Duration(minutes: iqamaDelay));
        if (iqamaEnabled && iqamaTime.isAfter(now)) {
          await NotificationsService.schedulePrayerNotification(
            id: _iqamaIdOffset + eventId,
            title: 'حان وقت الإقامة لصلاة ${prayer.label}',
            body: 'حان الآن موعد الإقامة.',
            scheduledDate: iqamaTime,
            channelId: 'prayer_iqama_${iqamaVoice.id}',
            channelName: 'Iqama',
            assetPath: iqamaVoice.assetPath,
          );
        }

        if (reminderEnabled) {
          final reminderTime = prayerTime.subtract(
            Duration(minutes: reminderMinutes),
          );
          if (reminderTime.isAfter(tz.TZDateTime.now(reminderTime.location))) {
            await NotificationsService.schedulePrayerNotification(
              id: _reminderIdOffset + eventId,
              title: 'تذكير بصلاة ${prayer.label}',
              body: 'يتبقى $reminderMinutes دقيقة على الأذان.',
              scheduledDate: reminderTime,
              channelId: 'prayer_reminder_channel',
              channelName: 'Prayer reminders',
              playSound: true,
            );
          }
        }
      }
    }
  }

  Future<void> _cancelAll() async {
    for (var dayIndex = 0; dayIndex < _scheduleDays; dayIndex++) {
      for (final prayer in PrayerName.values) {
        final eventId = dayIndex * PrayerName.values.length + prayer.index;
        await NotificationsService.cancel(_adhanIdOffset + eventId);
        await NotificationsService.cancel(_iqamaIdOffset + eventId);
        await NotificationsService.cancel(_reminderIdOffset + eventId);
      }
    }
  }
}
