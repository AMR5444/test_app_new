import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/core/settings/logic/settings_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';
import 'package:test_app_new/core/settings/presentation/widgets/appearance_settings_section.dart';
import 'package:test_app_new/core/settings/presentation/widgets/notifications_settings_section.dart';
import 'package:test_app_new/core/settings/presentation/widgets/reading_settings_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(
    BuildContext context,
  ) => BlocSelector<SettingsCubit, SettingsState, bool>(
    selector: (state) => state.isDarkMode,
    builder: (context, isDark) => Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Text(
                  'الإعدادات',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              ),
              AppearanceSettingsSection(isDark: isDark),
              NotificationsSettingsSection(isDark: isDark),
              ReadingSettingsSection(isDark: isDark),
              // TEMPORARY: Test screen access — DELETE AFTER TESTING
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.bgCardDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.bug_report, color: Colors.orange),
                    title: Text(
                      'اختبار الأذان (مؤقت)',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'شاشة اختبار مؤقتة للأذان والإقامة',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    onTap: () => Navigator.pushNamed(context, '/test-adhan'),
                  ),
                ),
              ),
              // END TEMPORARY
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'نور • الإصدار ١.٠',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ),
  );
}
