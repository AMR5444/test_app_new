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

  /// Action id for the "stop adhan" notification action button.
  ///
  /// Shared between Android's [AndroidNotificationAction] and iOS/macOS's
  /// [DarwinNotificationAction] so both platforms are handled by the same
  /// response-handling code below.
  static const String stopAdhanActionId = 'stop_adhan';

  /// iOS/macOS notification category that carries the stop-adhan action.
  /// Must be registered up front via [DarwinInitializationSettings] and
  /// then referenced per-notification via `categoryIdentifier`.
  static const String _adhanCategoryId = 'adhan_category';

  static Future<void> init() async {
    initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: <DarwinNotificationCategory>[
        DarwinNotificationCategory(
          _adhanCategoryId,
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain(
              stopAdhanActionId,
              'إيقاف الأذان',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.destructive,
              },
            ),
          ],
        ),
      ],
    );

    final settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await notificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
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

  /// Foreground/main-isolate notification response handler.
  static void _onNotificationResponse(NotificationResponse response) {
    if (_handleStopAdhanAction(response)) return;

    final payload = response.payload;
    if (payload != null) {
      handleNotificationClick(payload);
    }
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) {
    _handleStopAdhanAction(response);
  }

  static bool _handleStopAdhanAction(NotificationResponse response) {
    if (response.actionId != stopAdhanActionId) return false;
    final id = response.id;
    if (id != null) {
      notificationsPlugin.cancel(id: id);
    }
    return true;
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
    bool addStopAction = false,
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
          actions: addStopAction
              ? const <AndroidNotificationAction>[
                  AndroidNotificationAction(
                    stopAdhanActionId,
                    'إيقاف الأذان',
                    cancelNotification: true,
                    showsUserInterface: false,
                  ),
                ]
              : null,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: playSound || hasCustomSound,
          categoryIdentifier: addStopAction ? _adhanCategoryId : null,
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
