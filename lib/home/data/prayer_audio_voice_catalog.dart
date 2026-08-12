import 'package:test_app_new/home/models/prayer_audio_voice.dart';

class PrayerAudioVoiceCatalog {
  static const adhanVoices = [
    PrayerAudioVoice(
      id: 'adhan_mishary',
      name: 'مشاري راشد العفاسي',
      assetPath: 'lib/assets/audio/adhan_mishary.mp3',
      type: PrayerAudioVoiceType.adhan,
    ),
    PrayerAudioVoice(
      id: 'adhan_mansour_al_zahrani',
      name: 'منصور الزهراني',
      assetPath: 'lib/assets/audio/adhan_mansour_al_zahrani.mp3',
      type: PrayerAudioVoiceType.adhan,
    ),
    PrayerAudioVoice(
      id: 'adhan_ahmad_al_nafees',
      name: 'أحمد النفيس',
      assetPath: 'lib/assets/audio/adhan_ahmad_al_nafees.mp3',
      type: PrayerAudioVoiceType.adhan,
    ),
    PrayerAudioVoice(
      id: 'adhan_mustafa_ozcan',
      name: 'حافظ مصطفى أوزجان',
      assetPath: 'lib/assets/audio/adhan_mustafa_ozcan.mp3',
      type: PrayerAudioVoiceType.adhan,
    ),
  ];

  static const iqamaVoices = [
    PrayerAudioVoice(
      id: 'iqama_al_hosary',
      name: 'الحصري',
      assetPath: 'lib/assets/audio/iqama_al_hosary.mp3',
      type: PrayerAudioVoiceType.iqama,
    ),
    PrayerAudioVoice(
      id: 'iqama_ali_al_mulla',
      name: 'علي الملا',
      assetPath: 'lib/assets/audio/iqama_ali_al_mulla.mp3',
      type: PrayerAudioVoiceType.iqama,
    ),
  ];

  static PrayerAudioVoice get defaultAdhanVoice => adhanVoices.first;
  static PrayerAudioVoice get defaultIqamaVoice => iqamaVoices.first;

  static PrayerAudioVoice resolveAdhanVoice(String? id) => adhanVoices
      .firstWhere((voice) => voice.id == id, orElse: () => defaultAdhanVoice);

  static PrayerAudioVoice resolveIqamaVoice(String? id) => iqamaVoices
      .firstWhere((voice) => voice.id == id, orElse: () => defaultIqamaVoice);
}
