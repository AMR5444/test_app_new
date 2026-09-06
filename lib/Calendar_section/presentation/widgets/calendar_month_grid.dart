import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/Calendar_section/data/models/calendar_day.dart';
import 'package:test_app_new/Calendar_section/logic/calendar_cubit.dart';
import 'package:test_app_new/Calendar_section/presentation/widgets/calendar_day_cell.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

class CalendarMonthGrid extends StatelessWidget {
  const CalendarMonthGrid({super.key, required this.isDark});

  final bool isDark;

  static const _weekdayInitials = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      CalendarCubit,
      CalendarState,
      ({List<List<CalendarDay>> weeks, DateTime? selectedDate})
    >(
      selector: (state) =>
          (weeks: state.weeks, selectedDate: state.selectedDay?.gregorianDate),
      builder: (context, selected) {
        if (selected.weeks.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            Row(
              children: _weekdayInitials
                  .map(
                    (label) => Expanded(
                      child: Center(
                        child: Text(
                          label,
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textMuted
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 10),
            for (final week in selected.weeks) ...[
              Row(
                children: week
                    .map(
                      (day) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: CalendarDayCell(
                            day: day,
                            isDark: isDark,
                            isSelected:
                                selected.selectedDate != null &&
                                day.gregorianDate.year ==
                                    selected.selectedDate!.year &&
                                day.gregorianDate.month ==
                                    selected.selectedDate!.month &&
                                day.gregorianDate.day ==
                                    selected.selectedDate!.day,
                            onTap: () =>
                                context.read<CalendarCubit>().selectDay(day),
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }
}
