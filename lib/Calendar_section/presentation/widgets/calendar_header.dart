import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/Calendar_section/data/models/calendar_day.dart';
import 'package:test_app_new/Calendar_section/data/services/hijri_calendar_service.dart';
import 'package:test_app_new/Calendar_section/logic/calendar_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({super.key, required this.isDark});

  final bool isDark;

  static const _hijriService = HijriCalendarService();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      CalendarCubit,
      CalendarState,
      ({CalendarDay? selectedDay, int focusedYear, int focusedMonth})
    >(
      selector: (state) => (
        selectedDay: state.selectedDay,
        focusedYear: state.focusedYear,
        focusedMonth: state.focusedMonth,
      ),
      builder: (context, selected) {
        final selectedDay = selected.selectedDay;
        final textColor = isDark ? AppColors.textLight : AppColors.textPrimary;
        final mutedColor = isDark
            ? AppColors.textMuted
            : AppColors.textSecondary;

        final hijriLabel = selectedDay != null
            ? '${_hijriService.hijriMonthName(selectedDay.hijriMonth)} \u00b7 ${_hijriService.toArabicDigits(selectedDay.hijriYear)}'
            : '';
        final gregorianLabel = selected.focusedMonth != 0
            ? '${_hijriService.gregorianMonthName(selected.focusedMonth)} ${selected.focusedYear}'
            : '';
        final weekdayLabel = selectedDay != null
            ? _hijriService.weekDayName(selectedDay.gregorianDate.weekday % 7)
            : '';

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.read<CalendarCubit>().goToToday(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            weekdayLabel,
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          Icon(
                            Icons.chevron_left_rounded,
                            size: 18,
                            color: mutedColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () =>
                            context.read<CalendarCubit>().goToNextMonth(),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: mutedColor,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            hijriLabel,
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                            ),
                          ),
                          Text(
                            gregorianLabel,
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 11,
                              color: mutedColor,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () =>
                            context.read<CalendarCubit>().goToPreviousMonth(),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.chevron_left_rounded,
                            size: 16,
                            color: mutedColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _ArchBadge(
                isDark: isDark,
                label: selectedDay != null
                    ? _hijriService.toArabicDigits(selectedDay.hijriDay)
                    : '',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ArchBadge extends StatelessWidget {
  const _ArchBadge({required this.isDark, required this.label});

  final bool isDark;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 108,
      child: CustomPaint(
        painter: _ArchPainter(
          fill: isDark ? AppColors.bgCardDark2 : AppColors.bgCard,
          stroke: AppColors.accent,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              label,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textLight : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArchPainter extends CustomPainter {
  _ArchPainter({required this.fill, required this.stroke});

  final Color fill;
  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final domeRadius = size.width / 2;
    final straightTop = size.height - size.width;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, straightTop + domeRadius)
      ..arcToPoint(
        Offset(size.width, straightTop + domeRadius),
        radius: Radius.circular(domeRadius),
        clockwise: true,
      )
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.25), 6, false);
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    canvas.drawCircle(
      Offset(size.width / 2, straightTop + domeRadius / 2),
      2.4,
      Paint()..color = stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _ArchPainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.stroke != stroke;
}
