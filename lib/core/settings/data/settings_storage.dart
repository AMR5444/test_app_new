import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app_new/core/settings/logic/settings_state.dart';

class SettingsStorage {
  static const _isDarkModeKey = 'isDarkMode';
  static const _prayerNotificationsKey = 'prayerNotifications';
  static const _adhanEnabledKey = 'adhanEnabled';
  static const _iqamaEnabledKey = 'iqamaEnabled';
  static const _prayerReminderMinutesKey = 'prayerReminderMinutes';
  static const _azkarNotificationsKey = 'azkarNotifications';
  static const _reciterKey = 'reciter';
  static const _selectedAdhanVoiceKey = 'selectedAdhanVoiceId';
  static const _selectedIqamaVoiceKey = 'selectedIqamaVoiceId';

  SettingsStorage({Future<SharedPreferences>? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance();

  final Future<SharedPreferences> _preferences;

  Future<SettingsState> load() async {
    final prefs = await _preferences;
    return SettingsState(
      isDarkMode: prefs.getBool(_isDarkModeKey) ?? false,
      prayerNotifications: prefs.getBool(_prayerNotificationsKey) ?? true,
      adhanEnabled: prefs.getBool(_adhanEnabledKey) ?? true,
      iqamaEnabled: prefs.getBool(_iqamaEnabledKey) ?? true,
      prayerReminderMinutes: prefs.getInt(_prayerReminderMinutesKey) ?? 15,
      azkarNotifications: prefs.getBool(_azkarNotificationsKey) ?? true,
      reciter: prefs.getString(_reciterKey) ?? 'مشاري راشد العفاسي',
      selectedAdhanVoiceId: prefs.getString(_selectedAdhanVoiceKey) ?? 'default_adhan',
      selectedIqamaVoiceId: prefs.getString(_selectedIqamaVoiceKey) ?? 'default_iqama',
    );
  }

  Future<void> setDarkMode(bool value) => _setBool(_isDarkModeKey, value);
  Future<void> setPrayerNotifications(bool value) => _setBool(_prayerNotificationsKey, value);
  Future<void> setAdhanEnabled(bool value) => _setBool(_adhanEnabledKey, value);
  Future<void> setIqamaEnabled(bool value) => _setBool(_iqamaEnabledKey, value);
  Future<void> setPrayerReminderMinutes(int value) => _setInt(_prayerReminderMinutesKey, value);
  Future<void> setAzkarNotifications(bool value) => _setBool(_azkarNotificationsKey, value);
  Future<void> setReciter(String value) => _setString(_reciterKey, value);
  Future<void> setAdhanVoiceId(String value) => _setString(_selectedAdhanVoiceKey, value);
  Future<void> setIqamaVoiceId(String value) => _setString(_selectedIqamaVoiceKey, value);

  Future<void> _setBool(String key, bool value) async => (await _preferences).setBool(key, value);
  Future<void> _setDouble(String key, double value) async => (await _preferences).setDouble(key, value);
  Future<void> _setInt(String key, int value) async => (await _preferences).setInt(key, value);
  Future<void> _setString(String key, String value) async => (await _preferences).setString(key, value);
}
