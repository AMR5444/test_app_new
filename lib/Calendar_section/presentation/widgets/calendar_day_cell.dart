import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/Calendar_section/data/models/calendar_day.dart';
import 'package:test_app_new/Calendar_section/data/services/hijri_calendar_service.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.day,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final CalendarDay day;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  static const _hijriService = HijriCalendarService();

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final Color subFg;
    final Color? border;

    if (isSelected) {
      bg = AppColors.primary;
      fg = AppColors.textLight;
      subFg = AppColors.textLight.withValues(alpha: 0.75);
      border = null;
    } else if (day.isToday) {
      bg = AppColors.accent;
      fg = AppColors.textLight;
      subFg = AppColors.textLight.withValues(alpha: 0.8);
      border = null;
    } else {
      bg = isDark ? AppColors.bgCardDark2 : AppColors.bgCard;
      fg = isDark ? AppColors.textLight : AppColors.textPrimary;
      subFg = isDark ? AppColors.textMuted : AppColors.textSecondary;
      border = isDark ? AppColors.bgCardDark2 : AppColors.accentLight;
    }

    return Opacity(
      opacity: day.isInFocusedMonth ? 1 : 0.38,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
              border: border != null ? Border.all(color: border) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _hijriService.toArabicDigits(day.hijriDay),
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: fg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _hijriService.toArabicDigits(day.gregorianDate.day),
                  style: GoogleFonts.cairo(fontSize: 10, color: subFg),
                ),
                if (day.hasEvents && !isSelected && !day.isToday) ...[
                  const SizedBox(height: 3),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
