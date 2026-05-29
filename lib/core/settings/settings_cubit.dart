import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool isDarkMode;
  final double fontSize;
  final bool prayerNotifications;
  final bool azkarNotifications;
  final String reciter;
  final String language;

  const SettingsState({
    this.isDarkMode = false,
    this.fontSize = 26,
    this.prayerNotifications = true,
    this.azkarNotifications = true,
    this.reciter = 'مشاري راشد العفاسي',
    this.language = 'العربية',
  });

  SettingsState copyWith({
    bool? isDarkMode,
    double? fontSize,
    bool? prayerNotifications,
    bool? azkarNotifications,
    String? reciter,
    String? language,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      fontSize: fontSize ?? this.fontSize,
      prayerNotifications: prayerNotifications ?? this.prayerNotifications,
      azkarNotifications: azkarNotifications ?? this.azkarNotifications,
      reciter: reciter ?? this.reciter,
      language: language ?? this.language,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    emit(state.copyWith(
      isDarkMode: prefs.getBool('isDarkMode') ?? false,
      fontSize: prefs.getDouble('fontSize') ?? 26,
      prayerNotifications: prefs.getBool('prayerNotifications') ?? true,
      azkarNotifications: prefs.getBool('azkarNotifications') ?? true,
      reciter: prefs.getString('reciter') ?? 'مشاري راشد العفاسي',
    ));
  }

  Future<void> toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    final newVal = !state.isDarkMode;
    await prefs.setBool('isDarkMode', newVal);
    emit(state.copyWith(isDarkMode: newVal));
  }

  Future<void> setFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
    emit(state.copyWith(fontSize: size));
  }

  Future<void> togglePrayerNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final newVal = !state.prayerNotifications;
    await prefs.setBool('prayerNotifications', newVal);
    emit(state.copyWith(prayerNotifications: newVal));
  }

  Future<void> toggleAzkarNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final newVal = !state.azkarNotifications;
    await prefs.setBool('azkarNotifications', newVal);
    emit(state.copyWith(azkarNotifications: newVal));
  }

  Future<void> setReciter(String reciter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reciter', reciter);
    emit(state.copyWith(reciter: reciter));
  }
}
