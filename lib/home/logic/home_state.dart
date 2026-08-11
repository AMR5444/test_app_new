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
  final Map prayerTimes;
  final String nextPrayer;
  final String nextPrayerTime;
  final String prayerCountdown;
  final String prayerLocation;
  final bool isPrayerTimesLoading;
  final String? prayerTimesError;
  final int todayReadingMinutes;
  final int todayAzkarCompleted;
  final int todayAzkarTotal;
  final String dailyAyahText;
  final String dailyAyahSource;

  const HomeState({
    this.lastPosition,
    this.lastSurah,
    this.isLoadingSurah = false,
    this.currentTime = '',
    this.dateHeader = '',
    this.hijriDate = '',
    this.prayerTimes = const {},
    this.nextPrayer = '',
    this.nextPrayerTime = '',
    this.prayerCountdown = '',
    this.prayerLocation = '',
    this.isPrayerTimesLoading = false,
    this.prayerTimesError,
    this.todayReadingMinutes = 0,
    this.todayAzkarCompleted = 0,
    this.todayAzkarTotal = 0,
    this.dailyAyahText = '',
    this.dailyAyahSource = '',
  });

  HomeState copyWith({
    LastRead? lastPosition,
    SurahModel? lastSurah,
    bool? isLoadingSurah,
    String? currentTime,
    String? dateHeader,
    String? hijriDate,
    Map? prayerTimes,
    String? nextPrayer,
    String? nextPrayerTime,
    String? prayerCountdown,
    String? prayerLocation,
    bool? isPrayerTimesLoading,
    String? prayerTimesError,
    bool clearPrayerTimesError = false,
    int? todayReadingMinutes,
    int? todayAzkarCompleted,
    int? todayAzkarTotal,
    String? dailyAyahText,
    String? dailyAyahSource,
  }) {
    return HomeState(
      lastPosition: lastPosition ?? this.lastPosition,
      lastSurah: lastSurah ?? this.lastSurah,
      isLoadingSurah: isLoadingSurah ?? this.isLoadingSurah,
      currentTime: currentTime ?? this.currentTime,
      dateHeader: dateHeader ?? this.dateHeader,
      hijriDate: hijriDate ?? this.hijriDate,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      nextPrayer: nextPrayer ?? this.nextPrayer,
      nextPrayerTime: nextPrayerTime ?? this.nextPrayerTime,
      prayerCountdown: prayerCountdown ?? this.prayerCountdown,
      prayerLocation: prayerLocation ?? this.prayerLocation,
      isPrayerTimesLoading: isPrayerTimesLoading ?? this.isPrayerTimesLoading,
      prayerTimesError: clearPrayerTimesError
          ? null
          : prayerTimesError ?? this.prayerTimesError,
      todayReadingMinutes: todayReadingMinutes ?? this.todayReadingMinutes,
      todayAzkarCompleted: todayAzkarCompleted ?? this.todayAzkarCompleted,
      todayAzkarTotal: todayAzkarTotal ?? this.todayAzkarTotal,
      dailyAyahText: dailyAyahText ?? this.dailyAyahText,
      dailyAyahSource: dailyAyahSource ?? this.dailyAyahSource,
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
    prayerTimes,
    nextPrayer,
    nextPrayerTime,
    prayerCountdown,
    prayerLocation,
    isPrayerTimesLoading,
    prayerTimesError,
    todayReadingMinutes,
    todayAzkarCompleted,
    todayAzkarTotal,
    dailyAyahText,
    dailyAyahSource,
  ];
}
