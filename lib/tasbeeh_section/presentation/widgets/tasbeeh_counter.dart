import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/core/theme/app_theme.dart';
import 'package:test_app_new/tasbeeh_section/logic/tasbeeh_cubit.dart';

/// The large tappable counter circle. Tapping it increments the count
/// through the Cubit; a light haptic pulses on every tap and a stronger one
/// fires the moment the target is reached.
class TasbeehCounter extends StatelessWidget {
  final bool isDark;

  const TasbeehCounter({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasbeehCubit, TasbeehState>(
      builder: (context, state) {
        final reached = state.isTargetReached;
        return GestureDetector(
          onTap: () {
            final cubit = context.read<TasbeehCubit>();
            final wasReached = state.isTargetReached;
            cubit.increment();
            final justReached = !wasReached && cubit.state.isTargetReached;
            justReached
                ? HapticFeedback.mediumImpact()
                : HapticFeedback.lightImpact();
          },
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: reached
                  ? AppColors.primary
                  : (isDark ? AppColors.bgCardDark : AppColors.accentLight),
              border: Border.all(
                color: AppColors.primary,
                width: reached ? 0 : 3,
              ),
            ),
            child: Center(
              child: Text(
                '${state.count}',
                style: GoogleFonts.cairo(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: reached
                      ? AppColors.textLight
                      : (isDark ? AppColors.textLight : AppColors.primary),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
