import 'package:test_app_new/Notifications/NotificationsService.dart';
import 'package:timezone/timezone.dart' as tz;

class RemindersScheduler {
  /// جدولة قائمة الإشعارات اليومية
  static Future<void> scheduleReminders(
    List<Map<String, dynamic>> reminders,
  ) async {
    final tz.Location local = tz.local;
    final now = tz.TZDateTime.now(local);

    for (var reminder in reminders) {
      var scheduledTime = tz.TZDateTime(
        local,
        now.year,
        now.month,
        now.day,
        reminder['hour'] as int,
        reminder['minute'] as int,
      );

      // لو الوقت فات النهارده، جدوله لبكرة
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      // جدولة الإشعار
      await NotificationsService.scheduleNotification(
        id: reminder['id'] as int,
        title: reminder['title'] as String,
        body: reminder['body'] as String,
        scheduledDate: scheduledTime,
        payload: reminder['payload'] as String,
      ).then((_) {
        print('✅ تم جدولة ${reminder['title']} على $scheduledTime');
      });
    }
  }
}
