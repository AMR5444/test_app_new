import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app_new/home/data/prayer_audio_service.dart';
import 'package:test_app_new/home/data/prayer_audio_voice_catalog.dart';
import 'package:test_app_new/home/models/prayer_audio_voice.dart';

class SettingsState {
  final bool isDarkMode;
  final double fontSize;
  final bool prayerNotifications;
  final bool adhanEnabled;
  final bool iqamaEnabled;
  final int prayerReminderMinutes;
  final bool azkarNotifications;
  final String reciter;
  final String language;
  final String selectedAdhanVoiceId;
  final String selectedIqamaVoiceId;

  const SettingsState({
    this.isDarkMode = false,
    this.fontSize = 26,
    this.prayerNotifications = true,
    this.adhanEnabled = true,
    this.iqamaEnabled = true,
    this.prayerReminderMinutes = 15,
    this.azkarNotifications = true,
    this.reciter = 'مشاري راشد العفاسي',
    this.language = 'العربية',
    this.selectedAdhanVoiceId = 'default_adhan',
    this.selectedIqamaVoiceId = 'default_iqama',
  });

  SettingsState copyWith({
    bool? isDarkMode,
    double? fontSize,
    bool? prayerNotifications,
    bool? adhanEnabled,
    bool? iqamaEnabled,
    int? prayerReminderMinutes,
    bool? azkarNotifications,
    String? reciter,
    String? language,
    String? selectedAdhanVoiceId,
    String? selectedIqamaVoiceId,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      fontSize: fontSize ?? this.fontSize,
      prayerNotifications: prayerNotifications ?? this.prayerNotifications,
      adhanEnabled: adhanEnabled ?? this.adhanEnabled,
      iqamaEnabled: iqamaEnabled ?? this.iqamaEnabled,
      prayerReminderMinutes:
          prayerReminderMinutes ?? this.prayerReminderMinutes,
      azkarNotifications: azkarNotifications ?? this.azkarNotifications,
      reciter: reciter ?? this.reciter,
      language: language ?? this.language,
      selectedAdhanVoiceId: selectedAdhanVoiceId ?? this.selectedAdhanVoiceId,
      selectedIqamaVoiceId: selectedIqamaVoiceId ?? this.selectedIqamaVoiceId,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  static const _selectedAdhanVoiceKey = 'selectedAdhanVoiceId';
  static const _selectedIqamaVoiceKey = 'selectedIqamaVoiceId';

  SettingsCubit() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final adhanVoice = PrayerAudioVoiceCatalog.resolveAdhanVoice(
      prefs.getString(_selectedAdhanVoiceKey),
    );
    final iqamaVoice = PrayerAudioVoiceCatalog.resolveIqamaVoice(
      prefs.getString(_selectedIqamaVoiceKey),
    );
    emit(
      state.copyWith(
        isDarkMode: prefs.getBool('isDarkMode') ?? false,
        fontSize: prefs.getDouble('fontSize') ?? 26,
        prayerNotifications: prefs.getBool('prayerNotifications') ?? true,
        adhanEnabled: prefs.getBool('adhanEnabled') ?? true,
        iqamaEnabled: prefs.getBool('iqamaEnabled') ?? true,
        prayerReminderMinutes: prefs.getInt('prayerReminderMinutes') ?? 15,
        azkarNotifications: prefs.getBool('azkarNotifications') ?? true,
        reciter: prefs.getString('reciter') ?? 'مشاري راشد العفاسي',
        selectedAdhanVoiceId: adhanVoice.id,
        selectedIqamaVoiceId: iqamaVoice.id,
      ),
    );
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
    await _syncPrayerAudio();
  }

  Future<void> toggleAdhan() async {
    final prefs = await SharedPreferences.getInstance();
    final newVal = !state.adhanEnabled;
    await prefs.setBool('adhanEnabled', newVal);
    emit(state.copyWith(adhanEnabled: newVal));
    await _syncPrayerAudio();
  }

  Future<void> toggleIqama() async {
    final prefs = await SharedPreferences.getInstance();
    final newVal = !state.iqamaEnabled;
    await prefs.setBool('iqamaEnabled', newVal);
    emit(state.copyWith(iqamaEnabled: newVal));
    await _syncPrayerAudio();
  }

  Future<void> setPrayerReminderMinutes(int minutes) async {
    const allowedMinutes = {5, 10, 15, 20, 30};
    if (!allowedMinutes.contains(minutes)) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('prayerReminderMinutes', minutes);
    emit(state.copyWith(prayerReminderMinutes: minutes));
    await _syncPrayerAudio();
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

  Future<void> setAdhanVoice(PrayerAudioVoice voice) async {
    if (voice.type != PrayerAudioVoiceType.adhan ||
        PrayerAudioVoiceCatalog.resolveAdhanVoice(voice.id).id != voice.id) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedAdhanVoiceKey, voice.id);
    emit(state.copyWith(selectedAdhanVoiceId: voice.id));
  }

  Future<void> setIqamaVoice(PrayerAudioVoice voice) async {
    if (voice.type != PrayerAudioVoiceType.iqama ||
        PrayerAudioVoiceCatalog.resolveIqamaVoice(voice.id).id != voice.id) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedIqamaVoiceKey, voice.id);
    emit(state.copyWith(selectedIqamaVoiceId: voice.id));
  }

  Future<void> _syncPrayerAudio() async {
    try {
      await PrayerAudioService.shared.syncWithSettings();
    } catch (_) {}
  }
}
