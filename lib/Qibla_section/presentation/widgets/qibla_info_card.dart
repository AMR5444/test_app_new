import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/Qibla_section/logic/qibla_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

class QiblaInfoCard extends StatelessWidget {
  final bool isDark;

  const QiblaInfoCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QiblaCubit, QiblaState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgCardDark : AppColors.bgCard,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _InfoItem(
                isDark: isDark,
                label: 'اتجاه القبلة',
                value: _formatDegrees(state.qiblaBearing),
              ),
              _Divider(isDark: isDark),
              _InfoItem(
                isDark: isDark,
                label: 'اتجاه الجهاز',
                value: _formatDegrees(state.heading),
              ),
              _Divider(isDark: isDark),
              _InfoItem(
                isDark: isDark,
                label: 'المسافة لمكة',
                value: _formatDistance(state.distanceKm),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDegrees(double? value) {
    if (value == null) return '--°';
    return '${value.round()}°';
  }

  String _formatDistance(double? km) {
    if (km == null) return '--';
    if (km >= 1000) {
      return '${(km / 1000).toStringAsFixed(1)} ألف كم';
    }
    return '${km.round()} كم';
  }
}

class _InfoItem extends StatelessWidget {
  final bool isDark;
  final String label;
  final String value;

  const _InfoItem({
    required this.isDark,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: isDark ? AppColors.textMuted : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;

  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: isDark ? AppColors.bgCardDark2 : AppColors.accentLight,
    );
  }
}
