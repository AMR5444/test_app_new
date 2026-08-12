import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app_new/core/settings/data/settings_storage.dart';
import 'package:test_app_new/core/settings/logic/settings_state.dart';
import 'package:test_app_new/home/data/prayer_audio_service.dart';
import 'package:test_app_new/home/data/prayer_audio_voice_catalog.dart';
import 'package:test_app_new/home/models/prayer_audio_voice.dart';

export 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({SettingsStorage? storage})
    : _storage = storage ?? SettingsStorage(),
      super(const SettingsState()) {
    _loadSettings();
  }

  final SettingsStorage _storage;

  Future<void> _loadSettings() async {
    final storedState = await _storage.load();
    if (isClosed) return;

    emit(
      storedState.copyWith(
        selectedAdhanVoiceId: PrayerAudioVoiceCatalog
            .resolveAdhanVoice(storedState.selectedAdhanVoiceId)
            .id,
        selectedIqamaVoiceId: PrayerAudioVoiceCatalog
            .resolveIqamaVoice(storedState.selectedIqamaVoiceId)
            .id,
      ),
    );
  }

  Future<void> toggleDarkMode() async {
    final value = !state.isDarkMode;
    await _storage.setDarkMode(value);
    emit(state.copyWith(isDarkMode: value));
  }

  Future<void> togglePrayerNotifications() async {
    final value = !state.prayerNotifications;
    await _storage.setPrayerNotifications(value);
    emit(state.copyWith(prayerNotifications: value));
    await _syncPrayerAudio();
  }

  Future<void> toggleAdhan() async {
    final value = !state.adhanEnabled;
    await _storage.setAdhanEnabled(value);
    emit(state.copyWith(adhanEnabled: value));
    await _syncPrayerAudio();
  }

  Future<void> toggleIqama() async {
    final value = !state.iqamaEnabled;
    await _storage.setIqamaEnabled(value);
    emit(state.copyWith(iqamaEnabled: value));
    await _syncPrayerAudio();
  }

  Future<void> setPrayerReminderMinutes(int minutes) async {
    const allowedMinutes = {5, 10, 15, 20, 30};
    if (!allowedMinutes.contains(minutes)) return;

    await _storage.setPrayerReminderMinutes(minutes);
    emit(state.copyWith(prayerReminderMinutes: minutes));
    await _syncPrayerAudio();
  }

  Future<void> toggleAzkarNotifications() async {
    final value = !state.azkarNotifications;
    await _storage.setAzkarNotifications(value);
    emit(state.copyWith(azkarNotifications: value));
  }

  Future<void> setReciter(String reciter) async {
    await _storage.setReciter(reciter);
    emit(state.copyWith(reciter: reciter));
  }

  Future<void> setAdhanVoice(PrayerAudioVoice voice) async {
    if (voice.type != PrayerAudioVoiceType.adhan ||
        PrayerAudioVoiceCatalog.resolveAdhanVoice(voice.id).id != voice.id) {
      return;
    }

    await _storage.setAdhanVoiceId(voice.id);
    emit(state.copyWith(selectedAdhanVoiceId: voice.id));
  }

  Future<void> setIqamaVoice(PrayerAudioVoice voice) async {
    if (voice.type != PrayerAudioVoiceType.iqama ||
        PrayerAudioVoiceCatalog.resolveIqamaVoice(voice.id).id != voice.id) {
      return;
    }

    await _storage.setIqamaVoiceId(voice.id);
    emit(state.copyWith(selectedIqamaVoiceId: voice.id));
  }

  Future<void> _syncPrayerAudio() async {
    try {
      await PrayerAudioService.shared.syncWithSettings();
    } catch (_) {
      // Settings persistence must remain available if notification sync fails.
    }
  }
}
