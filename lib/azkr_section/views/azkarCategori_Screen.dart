import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/azkr_section/views/Generic%20Azkar%20Screen.dart';
import 'package:test_app_new/core/settings/settings_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

class AzkarCategoriesScreen extends StatelessWidget {
  const AzkarCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final isDark = settings.isDarkMode;

        final categories = [
          {
            'title': 'أذكار الصباح',
            'subtitle': 'تُقال بعد صلاة الفجر حتى طلوع الشمس',
            'icon': Icons.wb_sunny_outlined,
            'count': 5,
            'key': 'أذكار الصباح',
          },
          {
            'title': 'أذكار المساء',
            'subtitle': 'تُقال بعد صلاة العصر حتى المغرب',
            'icon': Icons.wb_twilight,
            'count': 4,
            'key': 'أذكار المساء',
          },
          {
            'title': 'أذكار النوم',
            'subtitle': 'تُقال عند الإيواء إلى الفراش',
            'icon': Icons.bedtime_outlined,
            'count': 5,
            'key': 'أذكار النوم',
          },
          {
            'title': 'أذكار الاستيقاظ',
            'subtitle': 'تُقال عند الاستيقاظ من النوم',
            'icon': Icons.light_mode_outlined,
            'count': 1,
            'key': 'أذكار الاستيقاظ',
          },
          {
            'title': 'أذكار بعد الصلاة',
            'subtitle': 'تُقال بعد السلام من الصلاة المفروضة',
            'icon': Icons.back_hand_outlined,
            'count': 5,
            'key': 'أذكار بعد السلام من الصلاة المفروضة',
          },
        ];

        return Scaffold(
          backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'الأذكار',
                        style: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textLight : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'حصن المسلم اليومي',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return _buildCategoryTile(
                        context: context,
                        isDark: isDark,
                        title: cat['title'] as String,
                        subtitle: cat['subtitle'] as String,
                        icon: cat['icon'] as IconData,
                        count: cat['count'] as int,
                        categoryKey: cat['key'] as String,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryTile({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required int count,
    required String categoryKey,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AzkarScreen(title: title, category: categoryKey),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgCardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.arrow_back_ios,
              size: 14,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}
