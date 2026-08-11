import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyAyahData {
  final String text;
  final String source;
  final String dateKey;

  const DailyAyahData({
    required this.text,
    required this.source,
    required this.dateKey,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'source': source,
    'dateKey': dateKey,
  };

  factory DailyAyahData.fromJson(Map<String, dynamic> json) => DailyAyahData(
    text: json['text'] as String,
    source: json['source'] as String,
    dateKey: json['dateKey'] as String,
  );
}

class DailyAyahService {
  static const String _cacheKey = 'daily_ayah_cache';
  static const int _totalAyahs = 6236;
  final Dio _dio = Dio();

  int _getAyahNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    return ((dayOfYear + date.year * 366) % _totalAyahs) + 1;
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _toArabicNumbers(String input) {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return input.split('').map((c) {
      final code = c.codeUnitAt(0);
      return (code >= 48 && code <= 57) ? arabic[code - 48] : c;
    }).join();
  }

  Future<DailyAyahData> getDailyAyah() async {
    final now = DateTime.now();
    final todayKey = _dateKey(now);

    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);

    if (cached != null) {
      try {
        final decoded = DailyAyahData.fromJson(jsonDecode(cached));
        if (decoded.dateKey == todayKey) return decoded;
      } catch (_) {
        // cache corrupt, fetch fresh
      }
    }

    final ayahNum = _getAyahNumber(now);
    try {
      final fetched = await _fetchFromApi(ayahNum, todayKey);
      await prefs.setString(_cacheKey, jsonEncode(fetched.toJson()));
      return fetched;
    } catch (_) {
      const fallback = DailyAyahData(
        text: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
        source: 'سورة البقرة • ١٥٢',
        dateKey: '',
      );
      final todayFallback = DailyAyahData(
        text: fallback.text,
        source: fallback.source,
        dateKey: todayKey,
      );
      await prefs.setString(_cacheKey, jsonEncode(todayFallback.toJson()));
      return todayFallback;
    }
  }

  Future<DailyAyahData> _fetchFromApi(int ayahNumber, String dateKey) async {
    final response = await _dio.get(
      'https://api.alquran.cloud/v1/ayah/$ayahNumber/quran-uthmani',
    );
    final data = response.data['data'];
    final surahName = data['surah']['name'] as String;
    final ayahNum = data['numberInSurah'] as int;
    return DailyAyahData(
      text: data['text'] as String,
      source: '$surahName • ${_toArabicNumbers(ayahNum.toString())}',
      dateKey: dateKey,
    );
  }
}
