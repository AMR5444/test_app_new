import 'package:flutter_bloc/flutter_bloc.dart';
import '../Api/Azkar_API.dart';
import '../models/azkar_model.dart';

class AzkarCubit extends Cubit<List<ZekrItem>> {
  final AzkarApi api;
  AzkarCubit(this.api) : super([]);

  bool isLoading = false;
  String? error;
  final Map<String, bool> _loadedCategories = {};

  Future<void> loadAzkar(String category) async {
    if (_loadedCategories[category] == true && state.isNotEmpty)
      return; // Already loaded

    isLoading = true;
    error = null;
    emit(state); // CircularProgress

    try {
      final azkar = await api.fetchAzkar(category); // يتيجي الأذكار من API
      _loadedCategories[category] = true;
      isLoading = false;
      emit(azkar); // تحديث الـ state بالقائمة الجديدة
    } catch (e) {
      isLoading = false;
      error = 'فشل تحميل الأذكار';
      emit(state); // خلي البيانات القديمة تظهر بدل ما تمسحها
    }
  }

  bool isLoadedFor(String category) => _loadedCategories[category] == true;

  void decrease(int index) {
    final updated = List<ZekrItem>.from(state);
    if (updated[index].currentCount > 0) {
      updated[index].currentCount--;
    }
    emit(List.from(state));
  }
}
