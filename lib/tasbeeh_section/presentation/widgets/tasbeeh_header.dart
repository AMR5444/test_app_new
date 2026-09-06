import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/core/theme/app_theme.dart';
import 'package:test_app_new/tasbeeh_section/logic/tasbeeh_cubit.dart';

/// Shows the currently selected Zekr and its description, and lets the user
/// switch to another Zekr from the catalogue via a bottom sheet.
class TasbeehHeader extends StatelessWidget {
  final bool isDark;

  const TasbeehHeader({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasbeehCubit, TasbeehState>(
      builder: (context, state) {
        final zekr = state.selectedZekr;
        return GestureDetector(
          onTap: () => _showZekrPicker(context, state),
          child: Column(
            children: [
              Text(
                zekr.zekr,
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                zekr.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Icon(
                Icons.unfold_more_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showZekrPicker(BuildContext context, TasbeehState state) {
    final cubit = context.read<TasbeehCubit>();
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.bgCardDark : AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              for (var i = 0; i < state.azkarList.length; i++)
                ListTile(
                  title: Text(
                    state.azkarList[i].zekr,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontWeight: i == state.selectedIndex
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isDark
                          ? AppColors.textLight
                          : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    state.azkarList[i].description,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: i == state.selectedIndex
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    cubit.changeZekr(i);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
