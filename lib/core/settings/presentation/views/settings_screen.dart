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
  Widget build(BuildContext context) => BlocSelector<SettingsCubit, SettingsState, bool>(
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
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              ),
              AppearanceSettingsSection(isDark: isDark),
              NotificationsSettingsSection(isDark: isDark),
              ReadingSettingsSection(isDark: isDark),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'نور • الإصدار ١.٠',
                  style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textMuted),
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
