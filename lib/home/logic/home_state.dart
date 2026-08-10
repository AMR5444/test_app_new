import 'package:equatable/equatable.dart';
import 'package:test_app_new/Quran_Section/models/LastRead_model.dart';
import 'package:test_app_new/Quran_Section/models/surah_model.dart';

class HomeState extends Equatable {
  final LastRead? lastPosition;
  final SurahModel? lastSurah;
  final bool isLoadingSurah;
  final String currentTime;
  final String dateHeader;
  final String hijriDate;

  const HomeState({
    this.lastPosition,
    this.lastSurah,
    this.isLoadingSurah = false,
    this.currentTime = '',
    this.dateHeader = '',
    this.hijriDate = '',
  });

  HomeState copyWith({
    LastRead? lastPosition,
    SurahModel? lastSurah,
    bool? isLoadingSurah,
    String? currentTime,
    String? dateHeader,
    String? hijriDate,
  }) {
    return HomeState(
      lastPosition: lastPosition ?? this.lastPosition,
      lastSurah: lastSurah ?? this.lastSurah,
      isLoadingSurah: isLoadingSurah ?? this.isLoadingSurah,
      currentTime: currentTime ?? this.currentTime,
      dateHeader: dateHeader ?? this.dateHeader,
      hijriDate: hijriDate ?? this.hijriDate,
    );
  }

  @override
  List<Object?> get props => [
    lastPosition,
    lastSurah,
    isLoadingSurah,
    currentTime,
    dateHeader,
    hijriDate,
  ];
}
