import 'package:test_app_new/azkr_section/data/Azkar_API.dart';
import 'package:test_app_new/azkr_section/logic/azkar_state.dart';
import 'package:test_app_new/azkr_section/models/azkar_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AzkarCubit extends Cubit<AzkarState> {
  final AzkarApi api;
  final Map<String, bool> _loadedCategories = {};

  AzkarCubit(this.api) : super(AzkarInitial());

  Future<void> loadAzkar(String category) async {
    if (_loadedCategories[category] == true && state is AzkarLoaded) {
      return;
    }

    emit(AzkarLoading());
    try {
      final azkar = await api.fetchAzkar(category);
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
        updated[index].currentCount--;
      }
      emit(AzkarLoaded(updated, currentState.category));
    }
  }
}
