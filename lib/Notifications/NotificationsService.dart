import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:test_app_new/Api/Azkar_API.dart';
import 'package:test_app_new/models/azkar_model.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await notificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) {
          handleNotificationClick(payload);
        }
      },
    );
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();
  }

  static void handleNotificationClick(String category) {
    navigatorKey.currentState?.pushNamed(
      '/azkar',
      arguments: category, // أذكار الصباح أو المساء
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required TZDateTime scheduledDate,
    String? payload,
  }) async {
    await notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel_id',
          'Daily Reminders',
          channelDescription: 'Reminder to complete daily habits',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    print('✅ تم جدولة إشعار: $title في ${scheduledDate.toString()}');
  }

  static Future<void> scheduleAzkarNotifications({
    required String category,
    required tz.Location location,
    required int hour,
    required int minute,
  }) async {
    final api = AzkarApi();
    final List<ZekrItem> azkarList = await api.fetchAzkar(category);

    for (int i = 0; i < azkarList.length; i++) {
      final zekr = azkarList[i];

      final scheduledDate = tz.TZDateTime(
        location,
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        hour,
        minute,
      );

      await scheduleNotification(
        id: i,
        title: category,
        body: zekr.content.isNotEmpty ? zekr.content : zekr.text,
        scheduledDate: scheduledDate,
        // payload: category,
      );
    }
  }
}
