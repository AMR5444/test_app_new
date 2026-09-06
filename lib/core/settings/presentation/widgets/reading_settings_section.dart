import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/core/settings/logic/settings_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';
import 'package:test_app_new/core/settings/presentation/widgets/settings_components.dart';

class ReadingSettingsSection extends StatelessWidget {
  final bool isDark;

  const ReadingSettingsSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    return BlocSelector<SettingsCubit, SettingsState, (String, String)>(
      selector: (state) => (state.reciter, state.language),
      builder: (context, reading) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SettingsSectionHeader(title: 'القراءة'),
          SettingsCard(
            isDark: isDark,
            children: [
              SettingsNavigationTile(
                isDark: isDark,
                icon: Icons.menu_book_outlined,
                title: 'القارئ',
                subtitle: reading.$1,
                onTap: () => _showReciterPicker(context, cubit, isDark, reading.$1),
              ),
              SettingsDivider(isDark: isDark),
              SettingsNavigationTile(
                isDark: isDark,
                icon: Icons.translate,
                title: 'اللغة',
                subtitle: reading.$2,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReciterPicker(
    BuildContext context,
    SettingsCubit cubit,
    bool isDark,
    String selectedReciter,
  ) {
    const reciters = [
      'مشاري راشد العفاسي',
      'عبد الرحمن السديس',
      'سعد الغامدي',
      'ماهر المعيقلي',
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.bgCardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'اختر القارئ',
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...reciters.map(
              (reciter) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  reciter,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.ibmPlexSansArabic(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
                trailing: selectedReciter == reciter
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  cubit.setReciter(reciter);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
