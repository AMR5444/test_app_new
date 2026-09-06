import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/core/theme/app_theme.dart';
import 'stat_card.dart';

class DailyStatsSection extends StatelessWidget {
  final bool isDark;
  final int readingMinutes;
  final int azkarCompleted;
  final int azkarTotal;

  const DailyStatsSection({
    super.key,
    required this.isDark,
    required this.readingMinutes,
    required this.azkarCompleted,
    required this.azkarTotal,
  });

  static const int _readingTarget = 20;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'إنجازاتك اليومية',
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  isDark: isDark,
                  label: 'القراءة',
                  value: '$readingMinutes د',
                  subtitle: 'هدف $_readingTarget د',
                  progress: (readingMinutes / _readingTarget)
                      .clamp(0.0, 1.0)
                      .toDouble(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  isDark: isDark,
                  label: 'الأذكار',
                  value: '${(_azkarProgress * 100).round()}٪',
                  subtitle: '$azkarCompleted من $azkarTotal',
                  progress: _azkarProgress,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double get _azkarProgress =>
      azkarTotal <= 0
          ? 0
          : (azkarCompleted / azkarTotal).clamp(0.0, 1.0).toDouble();
}
