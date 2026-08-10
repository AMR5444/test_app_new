import 'package:test_app_new/Quran_Section/models/LastRead_model.dart';
import 'package:test_app_new/Quran_Section/models/surah_model.dart';

class HomeState {
  final LastRead? lastPosition;
  final SurahModel? lastSurah;
  final bool isLoadingSurah;

  const HomeState({
    this.lastPosition,
    this.lastSurah,
    this.isLoadingSurah = false,
  });

  HomeState copyWith({
    LastRead? lastPosition,
    SurahModel? lastSurah,
    bool? isLoadingSurah,
  }) {
    return HomeState(
      lastPosition: lastPosition ?? this.lastPosition,
      lastSurah: lastSurah ?? this.lastSurah,
      isLoadingSurah: isLoadingSurah ?? this.isLoadingSurah,
    );
  }
}
