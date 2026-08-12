import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:test_app_new/azkr_section/data/Azkar_API.dart';
import 'package:test_app_new/azkr_section/models/azkar_model.dart';
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
    print(' تم جدولة إشعار: $title في ${scheduledDate.toString()}');
  }

  static Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required TZDateTime scheduledDate,
    required String channelId,
    required String channelName,
    String? assetPath,
    bool playSound = false,
  }) async {
    final androidSound = _resolveAndroidSound(assetPath);
    final hasCustomSound = androidSound != null;

    await notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: 'Prayer time notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: playSound || hasCustomSound,
          sound: androidSound,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: playSound || hasCustomSound,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static AndroidNotificationSound? _resolveAndroidSound(String? assetPath) {
    final resourceName = _resolveAndroidSoundResourceName(assetPath);
    if (resourceName == null) return null;
    try {
      return RawResourceAndroidNotificationSound(resourceName);
    } catch (_) {
      return null;
    }
  }

  static String? _resolveAndroidSoundResourceName(String? assetPath) {
    if (assetPath == null || assetPath.isEmpty) return null;
    final fileName = assetPath.split('/').last;
    final withoutExtension = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;
    final resourceName = withoutExtension.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9_]'),
      '_',
    );
    return resourceName.isEmpty ? null : resourceName;
  }

  static Future<void> cancel(int id) => notificationsPlugin.cancel(id: id);

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
