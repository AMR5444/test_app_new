import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app_new/azkr_section/data/Azkar_API.dart';
import 'package:test_app_new/azkr_section/data/daily_azkar_progress_service.dart';
import 'package:test_app_new/azkr_section/logic/azkar_state.dart';
import 'package:test_app_new/azkr_section/models/azkar_model.dart';

class AzkarCubit extends Cubit<AzkarState> {
  final AzkarApi api;
  final DailyAzkarProgressService _dailyProgressService;
  final Map<String, bool> _loadedCategories = {};

  AzkarCubit(this.api, {DailyAzkarProgressService? dailyProgressService})
    : _dailyProgressService =
          dailyProgressService ?? DailyAzkarProgressService(),
      super(AzkarInitial());

  Future<void> loadAzkar(String category) async {
    if (_loadedCategories[category] == true && state is AzkarLoaded) {
      return;
    }

    emit(AzkarLoading());
    try {
      final azkar = await api.fetchAzkar(category);
      await _registerLoadedCategory(category, azkar.length);
      _loadedCategories[category] = true;
      emit(AzkarLoaded(azkar, category));
    } catch (e) {
      emit(AzkarError('فشل تحميل الأذكار'));
    }
  }

  bool isLoadedFor(String category) {
    return _loadedCategories[category] == true;
  }

  void decrease(int index) {
    if (state is AzkarLoaded) {
      final currentState = state as AzkarLoaded;
      final updated = List<ZekrItem>.from(currentState.azkarList);
      if (updated[index].currentCount > 0) {
        final isCompletingZekr = updated[index].currentCount == 1;
        updated[index].currentCount--;
        if (isCompletingZekr) {
          unawaited(_markZekrCompleted(currentState.category, index));
        }
      }
      emit(AzkarLoaded(updated, currentState.category));
    }
  }

  Future<void> _registerLoadedCategory(String category, int total) async {
    try {
      await _dailyProgressService.registerLoadedCategory(category, total);
    } catch (_) {
      // Tracking failures must not affect loading or using azkar.
    }
  }

  Future<void> _markZekrCompleted(String category, int index) async {
    try {
      await _dailyProgressService.markZekrCompleted(category, index);
    } catch (_) {
      // Tracking failures must not affect using azkar.
    }
  }
}
