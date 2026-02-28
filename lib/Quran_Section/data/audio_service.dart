import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playAyah(int ayahNumber) async {
    await _player.stop();

    final url =
        "https://cdn.islamic.network/quran/audio/128/ar.alafasy/$ayahNumber.mp3";

    await _player.play(UrlSource(url));
  }

  static Future<void> stop() async {
    await _player.stop();
  }
}
