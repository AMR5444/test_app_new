import 'package:dio/dio.dart';
import 'package:hive_flutter/adapters.dart';

class TafsirService {
  final Dio _dio = Dio();

  Future<String> getTafsir(int ayahNumber) async {
    final box = Hive.box('tafsirBox');

    /// لو موجود في الكاش
    if (box.containsKey(ayahNumber)) {
      return box.get(ayahNumber);
    }

    /// لو مش موجود → هات من API
    final response = await _dio.get(
      'https://api.alquran.cloud/v1/ayah/$ayahNumber/ar.muyassar',
    );

    final tafsir =
        response.data['data']['text'] as String? ?? 'التفسير غير متوفر';
    await box.put(ayahNumber, tafsir);

    return tafsir;
  }
}
