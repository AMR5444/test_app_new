import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app_new/Quran_Section/data/LastPositionService.dart';
import 'package:test_app_new/Quran_Section/data/quran_api_service.dart';
import 'package:test_app_new/home/logic/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState()) {
    _loadLastPosition();
  }

  Future<void> _loadLastPosition() async {
    final lastPos = await LastPositionService.getLastPosition();
    if (lastPos != null) {
      emit(state.copyWith(lastPosition: lastPos));
      await _loadSurahInfo(lastPos.surahNumber);
    }
  }

  Future<void> _loadSurahInfo(int surahNumber) async {
    emit(state.copyWith(isLoadingSurah: true));
    try {
      final surahs = await QuranApiService().fetchSurahs();
      final surah = surahs.firstWhere(
        (s) => s.number == surahNumber,
        orElse: () => surahs.first,
      );
      emit(state.copyWith(lastSurah: surah, isLoadingSurah: false));
    } catch (_) {
      emit(state.copyWith(isLoadingSurah: false));
    }
  }
}
