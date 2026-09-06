import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/Calendar_section/logic/calendar_cubit.dart';
import 'package:test_app_new/Calendar_section/presentation/widgets/calendar_events_card.dart';
import 'package:test_app_new/Calendar_section/presentation/widgets/calendar_header.dart';
import 'package:test_app_new/Calendar_section/presentation/widgets/calendar_month_grid.dart';
import 'package:test_app_new/Calendar_section/presentation/widgets/calendar_reminders_card.dart';
import 'package:test_app_new/core/settings/logic/settings_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CalendarCubit(),
      child: const _CalendarScreenContent(),
    );
  }
}

class _CalendarScreenContent extends StatelessWidget {
  const _CalendarScreenContent();

  @override
  Widget build(BuildContext context) {
    final isDark = context.select<SettingsCubit, bool>(
      (cubit) => cubit.state.isDarkMode,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        body: SafeArea(
          child: BlocBuilder<CalendarCubit, CalendarState>(
            buildWhen: (previous, current) => previous.status != current.status,
            builder: (context, state) {
              switch (state.status) {
                case CalendarStatus.initial:
                case CalendarStatus.loading:
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                case CalendarStatus.error:
                  return _CalendarErrorView(
                    isDark: isDark,
                    message: state.errorMessage ?? 'حدث خطأ غير متوقع',
                  );
                case CalendarStatus.success:
                  return _CalendarContent(isDark: isDark);
              }
            },
          ),
        ),
      ),
    );
  }
}

class _CalendarContent extends StatelessWidget {
  const _CalendarContent({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'التقويم',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.bgCardDark : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    CalendarHeader(isDark: isDark),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 10 : 16,
                        vertical: 14,
                      ),
                      child: CalendarMonthGrid(isDark: isDark),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    CalendarEventsCard(isDark: isDark),
                    const SizedBox(height: 12),
                    CalendarRemindersCard(isDark: isDark),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CalendarErrorView extends StatelessWidget {
  const _CalendarErrorView({required this.isDark, required this.message});

  final bool isDark;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: isDark ? AppColors.textMuted : AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 14,
                color: isDark ? AppColors.textMuted : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<CalendarCubit>().retry(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textLight,
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
