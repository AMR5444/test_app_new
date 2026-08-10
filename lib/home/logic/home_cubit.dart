import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:test_app_new/Quran_Section/data/LastPositionService.dart';
import 'package:test_app_new/Quran_Section/data/quran_api_service.dart';
import 'package:test_app_new/home/logic/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  Timer? _timer;
  late final DateFormat _timeFormat;
  late final DateFormat _gregorianFormat;

  static const List<String> _hijriMonths = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الثاني',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  HomeCubit() : super(const HomeState()) {
    Future.microtask(_init);
  }

  Future<void> _init() async {
    await initializeDateFormatting('ar');
    _timeFormat = DateFormat('h:mm:ss a', 'ar');
    _gregorianFormat = DateFormat('EEEE d MMMM', 'ar');

    _updateTime();
    _loadLastPosition();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    emit(
      state.copyWith(
        currentTime: _timeFormat.format(now),
        dateHeader: _toArabicNumbers(_gregorianFormat.format(now)),
        hijriDate: _formatHijri(now),
      ),
    );
  }

  String _formatHijri(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    final day = _toArabicNumbers(hijri.hDay.toString());
    final month = _hijriMonths[hijri.hMonth - 1];
    final year = _toArabicNumbers(hijri.hYear.toString());
    return '$day $month $year هـ';
  }

  String _toArabicNumbers(String input) {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return input.split('').map((c) {
      final code = c.codeUnitAt(0);
      return (code >= 48 && code <= 57) ? arabic[code - 48] : c;
    }).join();
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

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
