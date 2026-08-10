import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/core/theme/app_theme.dart';
import 'stat_card.dart';

class DailyStatsSection extends StatelessWidget {
  final bool isDark;

  const DailyStatsSection({super.key, required this.isDark});

  static const int _azkarDone = 3;
  static const int _azkarTotal = 4;
  static const int _readingMinutes = 15;
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
            style: GoogleFonts.cairo(
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
                  value: '$_readingMinutes د',
                  subtitle: 'هدف $_readingTarget د',
                  progress: _readingMinutes / _readingTarget,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  isDark: isDark,
                  label: 'الأذكار',
                  value: '${(_azkarDone / _azkarTotal * 100).round()}٪',
                  subtitle: '$_azkarDone من $_azkarTotal',
                  progress: _azkarDone / _azkarTotal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
