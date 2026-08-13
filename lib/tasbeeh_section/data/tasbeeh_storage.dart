import 'package:shared_preferences/shared_preferences.dart';

class TasbeehSavedData {
  final String? selectedZekr;
  final int? count;
  final int? target;

  const TasbeehSavedData({this.selectedZekr, this.count, this.target});
}

class TasbeehStorage {
  static const _selectedZekrKey = 'tasbeeh_selected_zekr';
  static const _countKey = 'tasbeeh_count';
  static const _targetKey = 'tasbeeh_target';

  TasbeehStorage({Future<SharedPreferences>? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance();

  final Future<SharedPreferences> _preferences;

  Future<TasbeehSavedData> load() async {
    final prefs = await _preferences;

    final selectedZekr = prefs.getString(_selectedZekrKey);
    final count = prefs.getInt(_countKey);
    final target = prefs.getInt(_targetKey);

    return TasbeehSavedData(
      selectedZekr: (selectedZekr != null && selectedZekr.isNotEmpty)
          ? selectedZekr
          : null,
      count: (count != null && count >= 0) ? count : null,
      target: (target != null && target > 0) ? target : null,
    );
  }

  Future<void> saveSelectedZekr(String zekr) async =>
      (await _preferences).setString(_selectedZekrKey, zekr);

  Future<void> saveCount(int count) async =>
      (await _preferences).setInt(_countKey, count);

  Future<void> saveTarget(int target) async =>
      (await _preferences).setInt(_targetKey, target);
}
