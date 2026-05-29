import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app_new/core/Notifications/NotificationsService.dart';
import 'package:test_app_new/core/Notifications/azkar_scheduler.dart';
import 'package:timezone/timezone.dart' as tz;

class AppSettingsController extends ChangeNotifier {
  AppSettingsController._();

  static final AppSettingsController instance = AppSettingsController._();

  static const String _themeModeKey = 'settings.themeMode';
  static const String _quranFontSizeKey = 'settings.quranFontSize';
  static const String _prayerReminderKey = 'settings.prayerReminder';
  static const String _azkarReminderKey = 'settings.azkarReminder';
  static const String _reciterKey = 'settings.reciter';
  static const String _languageKey = 'settings.language';

  ThemeMode _themeMode = ThemeMode.light;
  double _quranFontSize = 26;
  bool _prayerReminderEnabled = true;
  bool _azkarReminderEnabled = true;
  String _reciter = 'مشاري راشد العفاسي';
  String _language = 'العربية';

  ThemeMode get themeMode => _themeMode;
  double get quranFontSize => _quranFontSize;
  bool get prayerReminderEnabled => _prayerReminderEnabled;
  bool get azkarReminderEnabled => _azkarReminderEnabled;
  String get reciter => _reciter;
  String get language => _language;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = _themeModeFromString(prefs.getString(_themeModeKey));
    _quranFontSize = prefs.getDouble(_quranFontSizeKey) ?? 26;
    _prayerReminderEnabled = prefs.getBool(_prayerReminderKey) ?? true;
    _azkarReminderEnabled = prefs.getBool(_azkarReminderKey) ?? true;
    _reciter = prefs.getString(_reciterKey) ?? 'مشاري راشد العفاسي';
    _language = prefs.getString(_languageKey) ?? 'العربية';
  }

  Future<void> setDarkMode(bool enabled) async {
    _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _themeMode.name);
    notifyListeners();
  }

  Future<void> setQuranFontSize(double size) async {
    _quranFontSize = size.clamp(18, 40);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_quranFontSizeKey, _quranFontSize);
    notifyListeners();
  }

  Future<void> setPrayerReminderEnabled(bool enabled) async {
    _prayerReminderEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prayerReminderKey, enabled);

    if (enabled) {
      await _schedulePrayerReminders();
    } else {
      await _cancelPrayerReminders();
    }
    notifyListeners();
  }

  Future<void> setAzkarReminderEnabled(bool enabled) async {
    _azkarReminderEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_azkarReminderKey, enabled);

    if (enabled) {
      await scheduleDailyAzkar();
    } else {
      await _cancelAzkarReminders();
    }
    notifyListeners();
  }

  Future<void> setReciter(String reciter) async {
    _reciter = reciter;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reciterKey, reciter);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
    notifyListeners();
  }

  Future<void> _schedulePrayerReminders() async {
    await NotificationsService.init();
    final location = tz.local;
    final now = tz.TZDateTime.now(location);

    final prayerTimes = <({int id, String label, int hour, int minute})>[
      (id: 101, label: 'الفجر', hour: 5, minute: 0),
      (id: 102, label: 'الظهر', hour: 12, minute: 30),
      (id: 103, label: 'العصر', hour: 15, minute: 45),
      (id: 104, label: 'المغرب', hour: 18, minute: 30),
      (id: 105, label: 'العشاء', hour: 20, minute: 0),
    ];

    for (final p in prayerTimes) {
      final date = tz.TZDateTime(
        location,
        now.year,
        now.month,
        now.day,
        p.hour,
        p.minute,
      );
      await NotificationsService.scheduleNotification(
        id: p.id,
        title: 'موعد صلاة ${p.label}',
        body: 'حان الآن وقت صلاة ${p.label}',
        scheduledDate: date,
        payload: 'prayer_${p.label}',
      );
    }
  }

  Future<void> _cancelPrayerReminders() async {
    for (int id = 101; id <= 105; id++) {
      await NotificationsService.notificationsPlugin.cancel(id: id);
    }
  }

  Future<void> _cancelAzkarReminders() async {
    const ids = [1, 2, 5, 6];
    for (final id in ids) {
      await NotificationsService.notificationsPlugin.cancel(id: id);
    }
  }

  ThemeMode _themeModeFromString(String? value) {
    if (value == ThemeMode.dark.name) return ThemeMode.dark;
    if (value == ThemeMode.light.name) return ThemeMode.light;
    return ThemeMode.light;
  }
}
