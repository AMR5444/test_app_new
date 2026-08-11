import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DailyAzkarProgressService {
  static const _storageKeyPrefix = 'daily_azkar_progress_';
  static final StreamController<void> _changesController =
      StreamController<void>.broadcast();

  Stream<void> get changes => _changesController.stream;

  Future<void> registerLoadedCategory(String category, int total) async {
    final progress = await _loadProgress();
    progress.categories[category] = total;
    await _saveProgress(progress);
  }

  Future<void> markZekrCompleted(String category, int index) async {
    final progress = await _loadProgress();
    final total = progress.categories[category];
    if (total == null || index < 0 || index >= total) return;

    progress.completedZekrIds.add('$category:$index');
    await _saveProgress(progress);
  }

  Future<DailyAzkarStats> getTodayStats() async {
    final progress = await _loadProgress();
    return DailyAzkarStats(
      todayAzkarCompleted: progress.completedZekrIds
          .where((id) => _isRegisteredZekrId(id, progress.categories))
          .length,
      todayAzkarTotal: progress.categories.values.fold(
        0,
        (sum, total) => sum + total,
      ),
    );
  }

  Future<_DailyAzkarProgress> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_storageKey(DateTime.now()));
    if (json == null) return _DailyAzkarProgress.empty();

    final data = jsonDecode(json) as Map<String, dynamic>;
    return _DailyAzkarProgress.fromJson(data);
  }

  Future<void> _saveProgress(_DailyAzkarProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey(DateTime.now()),
      jsonEncode(progress.toJson()),
    );
    _changesController.add(null);
  }

  bool _isRegisteredZekrId(String id, Map<String, int> categories) {
    final separatorIndex = id.lastIndexOf(':');
    if (separatorIndex <= 0 || separatorIndex == id.length - 1) return false;

    final category = id.substring(0, separatorIndex);
    final index = int.tryParse(id.substring(separatorIndex + 1));
    final total = categories[category];
    return index != null && total != null && index >= 0 && index < total;
  }

  String _storageKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$_storageKeyPrefix$year-$month-$day';
  }
}

class DailyAzkarStats {
  final int todayAzkarCompleted;
  final int todayAzkarTotal;

  const DailyAzkarStats({
    required this.todayAzkarCompleted,
    required this.todayAzkarTotal,
  });
}

class _DailyAzkarProgress {
  final Map<String, int> categories;
  final Set<String> completedZekrIds;

  _DailyAzkarProgress({
    required this.categories,
    required this.completedZekrIds,
  });

  factory _DailyAzkarProgress.empty() {
    return _DailyAzkarProgress(categories: {}, completedZekrIds: {});
  }

  factory _DailyAzkarProgress.fromJson(Map<String, dynamic> json) {
    final categoriesJson = json['categories'] as Map<String, dynamic>? ?? {};
    final completedJson = json['completedZekrIds'] as List<dynamic>? ?? [];
    return _DailyAzkarProgress(
      categories: categoriesJson.map(
        (category, total) => MapEntry(category, total as int),
      ),
      completedZekrIds: completedJson.cast<String>().toSet(),
    );
  }

  Map<String, dynamic> toJson() => {
    'categories': categories,
    'completedZekrIds': completedZekrIds.toList(),
  };
}
