import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:test_app_new/Quran_Section/models/ayah_model.dart';
import 'package:test_app_new/Quran_Section/models/surah_model.dart';

class QuranApiService {
  final Dio _dio = Dio();

  /////list surah////
  Future<List<SurahModel>> fetchSurahs() async {
    final response = await _dio.get('https://api.alquran.cloud/v1/meta');

    final surahs = response.data['data']['surahs']['references'] as List;

    return surahs.map((json) => SurahModel.fromjson(json)).toList();
  }

  ////Save surah////
  Future<List<AyahModel>> fetchSurah(int surahNumber) async {
    final box = await Hive.openBox('surahBox');

    if (box.containsKey(surahNumber)) {
      final cached = box.get(surahNumber) as List;
      return cached
          .map((e) => AyahModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    final response = await _dio.get(
      'https://api.alquran.cloud/v1/surah/$surahNumber/quran-uthmani',
    );

    final ayahs = (response.data['data']['ayahs'] as List).where((e) {
      final text = (e['text'] as String);
      return text.trim().isNotEmpty;
    }).toList();

    final result = ayahs.map((e) {
      final rawText = (e['text'] as String).trim();

      final isFirstAyah = e['numberInSurah'] == 1;

      // سور لازم ما نشيلش منها حاجة
      final isExcludedSurah = surahNumber == 1 || surahNumber == 9;

      // تحديد البسملة بدقة أعلى
      final isBasmala =
          rawText.startsWith('بِسۡم') ||
          rawText.startsWith('بسم الله') ||
          rawText.contains('ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ');

      final cleanedText = (isFirstAyah && !isExcludedSurah && isBasmala)
          ? '' // نشيلها بالكامل من الداتا
          : rawText;

      return AyahModel(
        number: e['number'],
        numberInSurah: e['numberInSurah'],
        text: cleanedText,
        page: e['page'],
      );
    }).toList();

    await box.put(surahNumber, result.map((e) => e.toJson()).toList());

    return result;
  }

  ///////view Page///
  Future<List<AyahModel>> fetchPageFromSurah(
    int surahNumber,
    int pageNumber,
  ) async {
    final box = Hive.isBoxOpen('surahBox')
        ? Hive.box('surahBox')
        : await Hive.openBox('surahBox');

    final surah = box.get(surahNumber);

    if (surah == null) return [];
    final ayahs = (surah as List)
        .map((e) => AyahModel.fromJson(Map<String, dynamic>.from(e)))
        .where((ayah) => ayah.page == pageNumber)
        .toList();
    print("Surah $surahNumber - Page $pageNumber: ${ayahs.length}");

    return ayahs;
  }
}
