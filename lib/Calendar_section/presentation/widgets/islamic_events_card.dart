import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/Calendar_section/data/models/calendar_day.dart';
import 'package:test_app_new/Calendar_section/logic/calendar_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

class CalendarEventsCard extends StatelessWidget {
  const CalendarEventsCard({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.bgCardDark : AppColors.bgCard;
    final titleColor = isDark ? AppColors.textLight : AppColors.textPrimary;
    final mutedColor = isDark ? AppColors.textMuted : AppColors.textSecondary;

    return BlocSelector<CalendarCubit, CalendarState, CalendarDay?>(
      selector: (state) => state.selectedDay,
      builder: (context, selectedDay) {
        final events = selectedDay?.events ?? const [];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'المناسبات',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.event_note_rounded,
                      color: AppColors.textLight,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                events.isEmpty
                    ? 'لا توجد مناسبات لهذا اليوم'
                    : '${events.length} مناسبة اليوم',
                textAlign: TextAlign.right,
                style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: mutedColor),
              ),
              if (events.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                for (final event in events)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                            ),
                          ),
                        ),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'إضافة مناسبة — قريبًا',
                          style: GoogleFonts.ibmPlexSansArabic(),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      size: 18,
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
