import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/Qibla_section/logic/qibla_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

class QiblaLocationLabel extends StatelessWidget {
  final bool isDark;

  const QiblaLocationLabel({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<QiblaCubit, QiblaState, String?>(
      selector: (state) => state.locationName,
      builder: (context, locationName) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16,
              color: isDark ? AppColors.textMuted : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'موقعك الحالي',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textMuted
                          : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    locationName ?? '...',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textLight
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
