import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app_new/Quran_Section/data/LastPositionService.dart';
import 'package:test_app_new/Quran_Section/data/daily_reading_service.dart';
import 'package:test_app_new/Quran_Section/data/quran_api_service.dart';
import 'package:test_app_new/azkr_section/data/daily_azkar_progress_service.dart';
import 'package:test_app_new/home/data/home_date_time_service.dart';
import 'package:test_app_new/home/data/prayer_times_service.dart';
import 'package:test_app_new/home/logic/home_state.dart';
import 'package:test_app_new/home/models/prayer_times_data.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeDateTimeService _dateTimeService;
  final PrayerTimesService _prayerTimesService;
  final DailyAzkarProgressService _dailyAzkarProgressService;

  HomeCubit({
    HomeDateTimeService? dateTimeService,
    PrayerTimesService? prayerTimesService,
    DailyAzkarProgressService? dailyAzkarProgressService,
  }) : _dateTimeService = dateTimeService ?? HomeDateTimeService(),
       _prayerTimesService = prayerTimesService ?? PrayerTimesService(),
       _dailyAzkarProgressService =
           dailyAzkarProgressService ?? DailyAzkarProgressService(),
       super(const HomeState()) {
    Future.microtask(_init);
  }

  Timer? _timer;
  StreamSubscription<void>? _azkarStatsSubscription;
  DateTime? _lastReadingStatsRefresh;

  Future<void> _init() async {
    await _dateTimeService.initialize();
    _updateHomeData();
    _loadLastPosition();
    _loadPrayerTimes();
    _azkarStatsSubscription = _dailyAzkarProgressService.changes.listen(
      (_) => _loadTodayAzkarStats(),
    );
    _loadTodayAzkarStats();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateHomeData(),
    );
  }

  void _updateHomeData() {
    final now = DateTime.now();
    final dateTime = _dateTimeService.format(now);
    emit(
      state.copyWith(
        currentTime: dateTime.currentTime,
        dateHeader: dateTime.dateHeader,
        hijriDate: dateTime.hijriDate,
      ),
    );
    _refreshTodayReadingMinutes(now);
    final prayerData = _prayerTimesService.current();
    if (prayerData == null) {
      if (state.prayerTimes.isNotEmpty && !state.isPrayerTimesLoading) {
        _loadPrayerTimes();
      }
      return;
    }
    _emitPrayerTimes(prayerData);
  }

  void _refreshTodayReadingMinutes(DateTime now) {
    final currentMinute = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    if (_lastReadingStatsRefresh == currentMinute) return;

    _lastReadingStatsRefresh = currentMinute;
    _loadTodayReadingMinutes();
  }

  Future<void> _loadTodayReadingMinutes() async {
    final minutes = await DailyReadingService.shared.getTodayReadingMinutes();
    if (!isClosed) {
      emit(state.copyWith(todayReadingMinutes: minutes));
    }
  }

  Future<void> _loadTodayAzkarStats() async {
    final stats = await _dailyAzkarProgressService.getTodayStats();
    if (!isClosed) {
      emit(
        state.copyWith(
          todayAzkarCompleted: stats.todayAzkarCompleted,
          todayAzkarTotal: stats.todayAzkarTotal,
        ),
      );
    }
  }

  Future<void> _loadPrayerTimes() async {
    emit(state.copyWith(isPrayerTimesLoading: true));
    try {
      _emitPrayerTimes(await _prayerTimesService.load(), isLoading: false);
    } on PrayerTimesException catch (error) {
      emit(
        state.copyWith(
          isPrayerTimesLoading: false,
          prayerTimesError: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isPrayerTimesLoading: false,
          prayerTimesError: 'تعذر تحميل مواقيت الصلاة',
        ),
      );
    }
  }

  void _emitPrayerTimes(PrayerTimesData data, {bool? isLoading}) => emit(
    state.copyWith(
      prayerTimes: data.times,
      nextPrayer: data.nextPrayer,
      nextPrayerTime: data.nextPrayerTime,
      prayerCountdown: data.countdown,
      prayerLocation: data.location,
      isPrayerTimesLoading: isLoading,
      clearPrayerTimesError: true,
    ),
  );

  Future<void> _loadLastPosition() async {
    final lastPos = await LastPositionService.getLastPosition();
    if (lastPos == null) return;
    emit(state.copyWith(lastPosition: lastPos));
    await _loadSurahInfo(lastPos.surahNumber);
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

  @override
  Future<void> close() {
    _timer?.cancel();
    _azkarStatsSubscription?.cancel();
    return super.close();
  }
}
