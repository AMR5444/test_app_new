import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:test_app_new/Quran_Section/madani_mushaf/models/mushaf_page_layout_model.dart';

class MushafLayoutService {
  final Dio _dio = Dio();

  static const _baseUrl =
      'https://raw.githubusercontent.com/zonetecde/mushaf-layout/refs/heads/main/mushaf';

  static const _boxName = 'mushafLayoutBox';

  // نسخة الكاش - رفعها بيمسح أي بيانات مخزّنة قبل الإصلاح ده تلقائيًا
  static const int _cacheSchemaVersion = 3;
  static const String _versionKey = '__schema_version__';

  Future<Box> _openValidatedBox() async {
    final box = Hive.isBoxOpen(_boxName)
        ? Hive.box(_boxName)
        : await Hive.openBox(_boxName);
    final storedVersion = box.get(_versionKey);
    if (storedVersion != _cacheSchemaVersion) {
      await box.clear();
      await box.put(_versionKey, _cacheSchemaVersion);
    }
    return box;
  }

  // بيتأكد إن كل سطر من نوع "text" فعلاً فيه كلمات، مش بس إن الصفحة
  // مش فاضية بالكامل - ده اللي كان بيسيب آيات البقرة/آل عمران/النساء
  // فاضية حتى مع وجود عنوان السورة والبسملة.
  bool _isCompleteModel(MushafPageLayoutModel model) {
    if (model.lines.isEmpty) return false;
    for (final line in model.lines) {
      if (line.type == 'text' && line.words.isEmpty) return false;
    }
    return true;
  }

  Future<MushafPageLayoutModel> fetchPage(int pageNumber) async {
    assert(pageNumber >= 1 && pageNumber <= 604, 'رقم الصفحة لازم بين 1 و604');

    final box = await _openValidatedBox();

    if (box.containsKey(pageNumber)) {
      final cachedData = box.get(pageNumber);

      if (cachedData is Map) {
        try {
          final json = Map<String, dynamic>.from(cachedData);
          final cachedModel = MushafPageLayoutModel.fromJson(json);

          if (_isCompleteModel(cachedModel)) {
            return cachedModel;
          }
        } catch (_) {
          // تجاهل الكاش التالف وكمل تحميل من الإنترنت تحت
        }
      }
      // كاش غير صالح/ناقص: احذفه بدل ما يفضل يرجّع صفحة ناقصة للأبد
      await box.delete(pageNumber);
    }

    // =========================
    // تحميل من الإنترنت
    // =========================

    final fileName = pageNumber.toString().padLeft(3, '0');

    final response = await _dio.get('$_baseUrl/page-$fileName.json');

    final rawData = response.data;

    late final Map<String, dynamic> json;

    // Dio رجع String
    if (rawData is String) {
      final decoded = jsonDecode(rawData);

      if (decoded is Map) {
        json = Map<String, dynamic>.from(decoded);
      } else {
        throw FormatException('الـ JSON المستلم للصفحة $pageNumber ليس Map.');
      }
    }
    // Dio رجع Map
    else if (rawData is Map) {
      json = Map<String, dynamic>.from(rawData);
    }
    // نوع غير متوقع
    else {
      throw FormatException(
        'نوع البيانات غير متوقع للصفحة $pageNumber: '
        '${rawData.runtimeType}',
      );
    }

    final model = MushafPageLayoutModel.fromJson(json);

    await box.put(pageNumber, model.toJson());

    return model;
  }
}
