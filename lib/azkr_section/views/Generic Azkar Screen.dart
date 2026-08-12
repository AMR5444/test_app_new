import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/azkr_section/data/Azkar_API.dart';
import 'package:test_app_new/azkr_section/logic/azkar_cubit.dart';
import 'package:test_app_new/azkr_section/logic/azkar_state.dart';
import 'package:test_app_new/azkr_section/models/azkar_model.dart';
import 'package:test_app_new/core/settings/logic/settings_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

class AzkarScreen extends StatelessWidget {
  final String title;
  final String category;

  const AzkarScreen({super.key, required this.title, required this.category});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AzkarCubit(AzkarApi())..loadAzkar(category),
      child: _AzkarScreenContent(title: title, category: category),
    );
  }
}

class _AzkarScreenContent extends StatelessWidget {
  final String title;
  final String category;

  const _AzkarScreenContent({required this.title, required this.category});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final isDark = settings.isDarkMode;
        return Scaffold(
          backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, isDark),
                Expanded(
                  child: _AzkarList(isDark: isDark, category: category),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return BlocBuilder<AzkarCubit, AzkarState>(
      builder: (context, state) {
        int done = 0;
        int total = 0;
        if (state is AzkarLoaded) {
          total = state.azkarList.length;
          done = state.azkarList.where((z) => z.currentCount == 0).length;
        }
        final progress = total > 0 ? done / total : 0.0;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: isDark
                          ? AppColors.textLight
                          : AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textLight
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (total > 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progress * 100).round()}%',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '$total / $done',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark
                        ? AppColors.bgCardDark2
                        : AppColors.accentLight,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }
}

class _AzkarList extends StatelessWidget {
  final bool isDark;
  final String category;

  const _AzkarList({required this.isDark, required this.category});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AzkarCubit, AzkarState>(
      builder: (context, state) {
        final cubit = context.read<AzkarCubit>();

        if (state is AzkarInitial || state is AzkarLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is AzkarError) {
          return Center(
            child: Text(
              state.message,
              style: GoogleFonts.cairo(color: AppColors.textSecondary),
            ),
          );
        }

        if (state is AzkarLoaded && state.azkarList.isEmpty) {
          return Center(
            child: Text(
              'لا توجد أذكار حالياً',
              style: GoogleFonts.cairo(color: AppColors.textSecondary),
            ),
          );
        }

        if (state is AzkarLoaded) {
          final azkarList = state.azkarList;
          final allDone = azkarList.every((z) => z.currentCount == 0);

          if (allDone) {
            return _buildCompletedState(isDark);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: azkarList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final zekr = azkarList[index];
              return _buildZekrCard(context, cubit, zekr, index, isDark);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildZekrCard(
    BuildContext context,
    AzkarCubit cubit,
    ZekrItem zekr,
    int index,
    bool isDark,
  ) {
    final isDone = zekr.currentCount == 0;

    return GestureDetector(
      onTap: () => cubit.decrease(index),
      child: Container(
        decoration: BoxDecoration(
          color: isDone
              ? (isDark
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.accentLight)
              : (isDark ? AppColors.bgCardDark : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: isDone
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
              : null,
          boxShadow: isDone
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isDone
                  ? Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${zekr.currentCount}',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  zekr.content.isNotEmpty ? zekr.content : zekr.text,
                  style: GoogleFonts.amiri(
                    fontSize: 18,
                    height: 1.7,
                    color: isDone
                        ? (isDark ? AppColors.accent : AppColors.primary)
                        : (isDark
                              ? AppColors.textLight
                              : AppColors.textPrimary),
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 20),
          Text(
            'بارك الله فيك!',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أتممت أذكارك',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
