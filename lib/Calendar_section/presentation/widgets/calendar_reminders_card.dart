import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/Calendar_section/data/models/reminders.dart';
import 'package:test_app_new/Calendar_section/logic/calendar_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

class CalendarRemindersCard extends StatelessWidget {
  const CalendarRemindersCard({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.bgCardDark : AppColors.bgCard;
    final titleColor = isDark ? AppColors.textLight : AppColors.textPrimary;
    final mutedColor = isDark ? AppColors.textMuted : AppColors.textSecondary;

    return BlocSelector<CalendarCubit, CalendarState, List<Reminder>>(
      selector: (state) => state.remindersForSelectedDay,
      builder: (context, reminders) {
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
                      'تذكير',
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
                      Icons.notifications_rounded,
                      color: AppColors.textLight,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                reminders.isEmpty
                    ? 'لا توجد تذكيرات لهذا اليوم'
                    : '${reminders.length} تذكير اليوم',
                textAlign: TextAlign.right,
                style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: mutedColor),
              ),
              if (reminders.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                for (final reminder in reminders)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => context
                              .read<CalendarCubit>()
                              .deleteReminder(reminder.id),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: mutedColor,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            reminder.title,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          reminder.formattedTime,
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 11,
                            color: mutedColor,
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
                  onTap: () => _openAddReminderSheet(context),
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

  Future<void> _openAddReminderSheet(BuildContext context) {
    final cubit = context.read<CalendarCubit>();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.bgCardDark : AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return _AddReminderSheet(
          isDark: isDark,
          onSave: (title, time) {
            cubit.addReminder(
              title: title,
              hour: time.hour,
              minute: time.minute,
            );
          },
        );
      },
    );
  }
}

class _AddReminderSheet extends StatefulWidget {
  const _AddReminderSheet({required this.isDark, required this.onSave});

  final bool isDark;
  final void Function(String title, TimeOfDay time) onSave;

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  late final TextEditingController _titleController;
  TimeOfDay _pickedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final titleColor = isDark ? AppColors.textLight : AppColors.textPrimary;
    final mutedColor = isDark ? AppColors.textMuted : AppColors.textSecondary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'إضافة تذكير',
              textAlign: TextAlign.right,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _titleController,
              textAlign: TextAlign.right,
              style: GoogleFonts.ibmPlexSansArabic(color: titleColor),
              decoration: InputDecoration(
                hintText: 'عنوان التذكير',
                hintStyle: GoogleFonts.ibmPlexSansArabic(color: mutedColor),
                filled: true,
                fillColor: isDark ? AppColors.bgCardDark2 : AppColors.bgLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                final result = await showTimePicker(
                  context: context,
                  initialTime: _pickedTime,
                );
                if (result != null && mounted) {
                  setState(() => _pickedTime = result);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.bgCardDark2 : AppColors.bgLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 18,
                      color: mutedColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _pickedTime.format(context),
                      style: GoogleFonts.ibmPlexSansArabic(color: titleColor),
                    ),
                    const Spacer(),
                    Text('الوقت', style: GoogleFonts.ibmPlexSansArabic(color: mutedColor)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  widget.onSave(_titleController.text, _pickedTime);
                  Navigator.of(context).pop();
                },
                child: const Text('حفظ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
