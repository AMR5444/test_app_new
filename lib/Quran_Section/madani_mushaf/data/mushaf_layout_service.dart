import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:test_app_new/Quran_Section/madani_mushaf/models/mushaf_page_layout_model.dart';

class MushafLayoutService {
  final Dio _dio = Dio();

  static const _baseUrl =
      'https://raw.githubusercontent.com/zonetecde/mushaf-layout/refs/heads/main/mushaf';

  static const _boxName = 'mushafLayoutBox';

  Future<MushafPageLayoutModel> fetchPage(int pageNumber) async {
    assert(pageNumber >= 1 && pageNumber <= 604, 'رقم الصفحة لازم بين 1 و604');

    final box = Hive.isBoxOpen(_boxName)
        ? Hive.box(_boxName)
        : await Hive.openBox(_boxName);

    if (box.containsKey(pageNumber)) {
      final cachedData = box.get(pageNumber);

      if (cachedData is Map) {
        final json = Map<String, dynamic>.from(cachedData);

        return MushafPageLayoutModel.fromJson(json);
      }
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
