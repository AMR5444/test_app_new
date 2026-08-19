import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/Qibla_section/logic/qibla_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

/// Shows whether the user is currently facing the Qibla, based purely on
/// [QiblaState.isFacingQibla].
class QiblaStatusBadge extends StatelessWidget {
  final bool isDark;

  const QiblaStatusBadge({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<QiblaCubit, QiblaState, bool>(
      selector: (state) => state.isFacingQibla,
      builder: (context, isFacing) {
        final color = isFacing
            ? AppColors.primary
            : (isDark ? AppColors.textMuted : AppColors.textSecondary);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isFacing
                ? AppColors.accentLight.withValues(alpha: isDark ? 0.25 : 1)
                : (isDark ? AppColors.bgCardDark : AppColors.bgCard),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isFacing ? Icons.check_circle : Icons.explore_outlined,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                isFacing ? 'أنت متجه نحو القبلة' : 'استدر نحو القبلة',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
