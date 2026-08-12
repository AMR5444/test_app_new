import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app_new/core/settings/logic/settings_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';
import 'package:test_app_new/home/logic/home_cubit.dart';
import 'package:test_app_new/home/logic/home_state.dart';
import 'package:test_app_new/home/views/widgets/last_read_card.dart';
import 'widgets/daily_ayah_card.dart';
import 'widgets/daily_stats_section.dart';
import 'widgets/home_header.dart';
import 'widgets/prayer_times_card.dart';
import 'widgets/quick_access_grid.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;

  /// Whether the Home tab is currently the visible one (e.g. in an
  /// [IndexedStack]-based navigation, where offscreen tabs stay mounted).
  /// Used to pause the per-second refresh timer when Home isn't shown.
  final bool isVisible;

  const HomeScreen({
    super.key,
    required this.onNavigate,
    this.isVisible = true,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final HomeCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = HomeCubit();
    WidgetsBinding.instance.addObserver(this);
    if (!_shouldRunTimer) {
      _cubit.pauseTimer();
    }
  }

  bool get _shouldRunTimer {
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    final appActive =
        lifecycle == null || lifecycle == AppLifecycleState.resumed;
    return widget.isVisible && appActive;
  }

  void _syncTimer() {
    if (_shouldRunTimer) {
      _cubit.resumeTimer();
    } else {
      _cubit.pauseTimer();
    }
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      _syncTimer();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _syncTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocSelector<SettingsCubit, SettingsState, bool>(
        selector: (state) => state.isDarkMode,
        builder: (context, isDark) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    HomeHeader(isDark: isDark),
                    BlocBuilder<HomeCubit, HomeState>(
                      buildWhen: (previous, current) =>
                          previous.prayerTimes != current.prayerTimes ||
                          previous.nextPrayer != current.nextPrayer ||
                          previous.nextPrayerTime != current.nextPrayerTime ||
                          previous.prayerLocation != current.prayerLocation ||
                          previous.isPrayerTimesLoading !=
                              current.isPrayerTimesLoading ||
                          previous.prayerTimesError != current.prayerTimesError,
                      builder: (context, state) => PrayerTimesCard(
                        isDark: isDark,
                        prayerTimes: state.prayerTimes,
                        nextPrayer: state.nextPrayer,
                        nextPrayerTime: state.nextPrayerTime,
                        location: state.prayerLocation,
                        isLoading: state.isPrayerTimesLoading,
                        errorMessage: state.prayerTimesError,
                      ),
                    ),
                    BlocBuilder<HomeCubit, HomeState>(
                      buildWhen: (previous, current) =>
                          previous.dailyAyahText != current.dailyAyahText ||
                          previous.dailyAyahSource != current.dailyAyahSource,
                      builder: (context, state) => DailyAyahCard(
                        isDark: isDark,
                        ayahText: state.dailyAyahText,
                        ayahSource: state.dailyAyahSource,
                      ),
                    ),
                    QuickAccessGrid(
                      isDark: isDark,
                      onNavigate: widget.onNavigate,
                    ),
                    BlocBuilder<HomeCubit, HomeState>(
                      buildWhen: (previous, current) =>
                          previous.lastPosition != current.lastPosition ||
                          previous.lastSurah != current.lastSurah,
                      builder: (context, state) {
                        return LastReadCard(
                          isDark: isDark,
                          lastPosition: state.lastPosition,
                          lastSurah: state.lastSurah,
                          onTap: () => widget.onNavigate(1),
                        );
                      },
                    ),
                    BlocSelector<
                      HomeCubit,
                      HomeState,
                      ({int readingMinutes, int azkarCompleted, int azkarTotal})
                    >(
                      selector: (state) => (
                        readingMinutes: state.todayReadingMinutes,
                        azkarCompleted: state.todayAzkarCompleted,
                        azkarTotal: state.todayAzkarTotal,
                      ),
                      builder: (context, dailyStats) {
                        return DailyStatsSection(
                          isDark: isDark,
                          readingMinutes: dailyStats.readingMinutes,
                          azkarCompleted: dailyStats.azkarCompleted,
                          azkarTotal: dailyStats.azkarTotal,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
