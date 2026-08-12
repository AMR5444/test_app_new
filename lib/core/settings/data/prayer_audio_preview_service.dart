import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:test_app_new/home/models/prayer_audio_voice.dart';

class PrayerAudioPreviewService {
  PrayerAudioPreviewService._();

  static final PrayerAudioPreviewService instance =
      PrayerAudioPreviewService._();

  final AudioPlayer _player = AudioPlayer();

  final ValueNotifier<String?> playingVoiceId = ValueNotifier<String?>(null);

  Future<void> togglePreview(PrayerAudioVoice voice) async {
    if (playingVoiceId.value == voice.id) {
      await stop();
      return;
    }

    await stop();

    try {
      final ByteData data = await rootBundle.load(voice.assetPath);

      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      _setPlaying(voice.id);

      await _player.play(BytesSource(bytes));
    } catch (_) {
      _setPlaying(null);
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _setPlaying(null);
  }

  void _setPlaying(String? voiceId) {
    playingVoiceId.value = voiceId;
  }

  Future<void> dispose() async {
    await _player.dispose();
    playingVoiceId.dispose();
  }
}
