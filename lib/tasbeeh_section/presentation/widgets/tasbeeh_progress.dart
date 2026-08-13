import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/core/theme/app_theme.dart';
import 'package:test_app_new/tasbeeh_section/logic/tasbeeh_cubit.dart';

/// Displays a progress bar plus the "count / target" text for the active
class TasbeehProgress extends StatelessWidget {
  final bool isDark;

  const TasbeehProgress({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasbeehCubit, TasbeehState>(
      builder: (context, state) {
        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: state.progress,
                backgroundColor: isDark
                    ? AppColors.bgCardDark2
                    : AppColors.accentLight,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${state.count} / ${state.target}',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }
}
