// lib/Quran_Section/data/last_position_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app_new/Quran_Section/models/LastRead_model.dart';

class LastPositionService {
  static const String _key = 'last_read';

  /// حفظ آخر موقع
  static Future<void> saveLastPosition(LastRead lastRead) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(lastRead.toJson()));
  }

  /// استرجاع آخر موقع
  static Future<LastRead?> getLastPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString != null) {
      return LastRead.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  /// حذف آخر موقع
  static Future<void> clearLastPosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
