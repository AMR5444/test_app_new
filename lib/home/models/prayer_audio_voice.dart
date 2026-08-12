enum PrayerAudioVoiceType { adhan, iqama }

class PrayerAudioVoice {
  final String id;
  final String name;
  final PrayerAudioVoiceType type;

  const PrayerAudioVoice({
    required this.id,
    required this.name,
    required this.type,
  });
}
