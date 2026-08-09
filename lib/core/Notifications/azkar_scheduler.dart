import 'package:test_app_new/core/Notifications/NotificationsService.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'RemindersScheduler.dart';

Future<void> scheduleDailyAzkar() async {
  await NotificationsService.init();

  tzdata.initializeTimeZones();
  final tz.Location local = tz.local;
  final reminders = [
    {
      'id': 1,
      'title': '🌅 أذكار الصباح',
      'body': 'حان وقت أذكار الصباح، لا تنسى قراءتها',
      'payload': 'أذكار الصباح',
      'hour': 7,
      'minute': 0,
    },
    {
      'id': 2,
      'title': '🌙 أذكار المساء',
      'body': 'حان وقت أذكار المساء، لا تنسى قراءتها',
      'payload': 'أذكار المساء',
      'hour': 19,
      'minute': 0,
    },
    {
      'id': 5,
      'title': '😴 أذكار النوم',
      'body': 'حان وقت أذكار النوم، لا تنسى قراءتها',
      'payload': 'أذكار النوم',
      'hour': 23,
      'minute': 0,
    },
    {
      'id': 6,
      'title': ' أذكار الاستيقاظ',
      'body': 'حان وقت أذكار الاستيقاظ، لا تنسى قراءتها',
      'payload': 'أذكار الاستيقاظ',
      'hour': 6,
      'minute': 30,
    },
  ];

  RemindersScheduler.scheduleReminders(reminders);
}
