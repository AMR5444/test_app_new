enum PrayerAudioVoiceType { adhan, iqama }

class PrayerAudioVoice {
  final String id;
  final String name;
  final String assetPath;
  final PrayerAudioVoiceType type;

  const PrayerAudioVoice({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.type,
  });
}
