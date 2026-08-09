import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:test_app_new/Quran_Section/models/ayah_model.dart';
import 'package:test_app_new/Quran_Section/models/surah_model.dart';

class QuranApiService {
  final Dio _dio = Dio();

  // عدد آيات كل سورة (ثابت ومعروف) - بيُستخدم للتأكد إن الكاش مكتمل
  // وملوش أي آية ناقصة (بيحصل خصوصًا في السور الطويلة زي البقرة/آل عمران/
  // النساء لو الاتصال اتقطع في نص التحميل الأول).
  static const Map<int, int> _ayahCountBySurah = {
    1: 7,
    2: 286,
    3: 200,
    4: 176,
    5: 120,
    6: 165,
    7: 206,
    8: 75,
    9: 129,
    10: 109,
    11: 123,
    12: 111,
    13: 43,
    14: 52,
    15: 99,
    16: 128,
    17: 111,
    18: 110,
    19: 98,
    20: 135,
    21: 112,
    22: 78,
    23: 118,
    24: 64,
    25: 77,
    26: 227,
    27: 93,
    28: 88,
    29: 69,
    30: 60,
    31: 34,
    32: 30,
    33: 73,
    34: 54,
    35: 45,
    36: 83,
    37: 182,
    38: 88,
    39: 75,
    40: 85,
    41: 54,
    42: 53,
    43: 89,
    44: 59,
    45: 37,
    46: 35,
    47: 38,
    48: 29,
    49: 18,
    50: 45,
    51: 60,
    52: 49,
    53: 62,
    54: 55,
    55: 78,
    56: 96,
    57: 29,
    58: 22,
    59: 24,
    60: 13,
    61: 14,
    62: 11,
    63: 11,
    64: 18,
    65: 12,
    66: 12,
    67: 30,
    68: 52,
    69: 52,
    70: 44,
    71: 28,
    72: 28,
    73: 20,
    74: 56,
    75: 40,
    76: 31,
    77: 50,
    78: 40,
    79: 46,
    80: 42,
    81: 29,
    82: 19,
    83: 36,
    84: 25,
    85: 22,
    86: 17,
    87: 19,
    88: 26,
    89: 30,
    90: 20,
    91: 15,
    92: 21,
    93: 11,
    94: 8,
    95: 8,
    96: 19,
    97: 5,
    98: 8,
    99: 8,
    100: 11,
    101: 11,
    102: 8,
    103: 3,
    104: 9,
    105: 5,
    106: 4,
    107: 7,
    108: 3,
    109: 6,
    110: 3,
    111: 5,
    112: 4,
    113: 5,
    114: 6,
  };

  // نسخة الكاش الحالية - أي رفع للرقم ده بيجبر التطبيق يمسح الكاش القديم
  // (اللي ممكن يكون اتخزن ناقص/تالف من نسخة سابقة) تلقائيًا بدون ما
  // نحتاج نطلب من المستخدم يعمل uninstall يدويًا.
  static const int _cacheSchemaVersion = 2;
  static const String _versionKey = '__schema_version__';

  Future<Box> _openValidatedSurahBox() async {
    final box = Hive.isBoxOpen('surahBox')
        ? Hive.box('surahBox')
        : await Hive.openBox('surahBox');

    final storedVersion = box.get(_versionKey);
    if (storedVersion != _cacheSchemaVersion) {
      await box.clear();
      await box.put(_versionKey, _cacheSchemaVersion);
    }
    return box;
  }

  /////list surah////
  Future<List<SurahModel>> fetchSurahs() async {
    final response = await _dio.get('https://api.alquran.cloud/v1/meta');

    final surahs = response.data['data']['surahs']['references'] as List;

    return surahs.map((json) => SurahModel.fromjson(json)).toList();
  }

  ////Save surah////
  Future<List<AyahModel>> fetchSurah(int surahNumber) async {
    final box = await _openValidatedSurahBox();

    if (box.containsKey(surahNumber)) {
      final rawCached = box.get(surahNumber);
      // حماية من بيانات Hive قديمة/تالفة أو ناقصة (زي ما بيحصل لو الاتصال
      // اتقطع أثناء تحميل سورة طويلة زي البقرة/آل عمران/النساء) بدل ما
      // تفضل السورة ناقصة الآيات للأبد.
      if (rawCached is List && rawCached.isNotEmpty) {
        try {
          final cachedAyahs = rawCached
              .map((e) => AyahModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          final expectedCount = _ayahCountBySurah[surahNumber];
          final isComplete =
              expectedCount == null || cachedAyahs.length >= expectedCount;
          if (cachedAyahs.isNotEmpty && isComplete) {
            return cachedAyahs;
          }
        } catch (_) {
          // الكاش تالف (schema قديم) → تجاهله وأعد التحميل من الإنترنت
        }
      }
      // كاش فاضي/ناقص/تالف: احذفه وكمل تحميل من API بدل ما ترجع بيانات ناقصة
      await box.delete(surahNumber);
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
    final box = await _openValidatedSurahBox();

    final surah = box.get(surahNumber);

    if (surah == null || surah is! List) return [];
    final ayahs = surah
        .map((e) => AyahModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((ayah) => ayah.page == pageNumber)
        .toList();

    return ayahs;
  }
}
