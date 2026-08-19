import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/Qibla_section/logic/qibla_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

class QiblaLocationHeader extends StatelessWidget {
  final bool isDark;

  const QiblaLocationHeader({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      QiblaCubit,
      QiblaState,
      ({String? name, double? lat, double? lon})
    >(
      selector: (state) =>
          (name: state.locationName, lat: state.latitude, lon: state.longitude),
      builder: (context, selected) {
        if (selected.lat == null || selected.lon == null) {
          return const SizedBox.shrink();
        }

        final displayValue =
            selected.name ??
            '${selected.lat!.toStringAsFixed(2)}°, ${selected.lon!.toStringAsFixed(2)}°';

        return Column(
          children: [
            Text(
              'موقعك الحالي',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: isDark ? AppColors.textMuted : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              displayValue,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ],
        );
      },
    );
  }
}
