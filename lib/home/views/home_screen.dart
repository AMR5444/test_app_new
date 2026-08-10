import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app_new/core/settings/settings_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';
import 'package:test_app_new/home/logic/home_cubit.dart';
import 'package:test_app_new/home/logic/home_state.dart';
import 'package:test_app_new/home/views/widgets/last_read_card.dart';
import 'widgets/daily_ayah_card.dart';
import 'widgets/daily_stats_section.dart';
import 'widgets/home_header.dart';
import 'widgets/prayer_times_card.dart';
import 'widgets/quick_access_grid.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
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
                    PrayerTimesCard(isDark: isDark),
                    DailyAyahCard(isDark: isDark),
                    QuickAccessGrid(isDark: isDark, onNavigate: onNavigate),
                    BlocBuilder<HomeCubit, HomeState>(
                      builder: (context, state) {
                        return LastReadCard(
                          isDark: isDark,
                          lastPosition: state.lastPosition,
                          lastSurah: state.lastSurah,
                          onTap: () => onNavigate(1),
                        );
                      },
                    ),
                    DailyStatsSection(isDark: isDark),
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
