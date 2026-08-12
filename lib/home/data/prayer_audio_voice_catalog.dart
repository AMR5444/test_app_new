import 'package:test_app_new/home/models/prayer_audio_voice.dart';

class PrayerAudioVoiceCatalog {
  static const adhanVoices = [
    PrayerAudioVoice(
      id: 'default_adhan',
      name: 'الصوت الافتراضي',
      type: PrayerAudioVoiceType.adhan,
    ),
  ];

  static const iqamaVoices = [
    PrayerAudioVoice(
      id: 'default_iqama',
      name: 'الصوت الافتراضي',
      type: PrayerAudioVoiceType.iqama,
    ),
  ];

  static PrayerAudioVoice get defaultAdhanVoice => adhanVoices.first;
  static PrayerAudioVoice get defaultIqamaVoice => iqamaVoices.first;

  static PrayerAudioVoice resolveAdhanVoice(String? id) {
    return adhanVoices.firstWhere(
      (voice) => voice.id == id,
      orElse: () => defaultAdhanVoice,
    );
  }

  static PrayerAudioVoice resolveIqamaVoice(String? id) {
    return iqamaVoices.firstWhere(
      (voice) => voice.id == id,
      orElse: () => defaultIqamaVoice,
    );
  }
}
