import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/core/settings/settings_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';
import 'package:test_app_new/home/data/prayer_audio_voice_catalog.dart';
import 'package:test_app_new/home/models/prayer_audio_voice.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final isDark = settings.isDarkMode;
        final cubit = context.read<SettingsCubit>();

        return Scaffold(
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

                  // Section: المظهر
                  _buildSectionHeader('المظهر', isDark),
                  _buildCard(
                    isDark: isDark,
                    children: [
                      _buildToggleTile(
                        isDark: isDark,
                        icon: Icons.light_mode_outlined,
                        title: 'الوضع الداكن',
                        subtitle: 'لقراءة مريحة في الإضاءة المنخفضة',
                        value: settings.isDarkMode,
                        onChanged: (_) => cubit.toggleDarkMode(),
                      ),
                      _buildDivider(isDark),
                      _buildFontSizeTile(isDark, settings.fontSize, cubit),
                    ],
                  ),

                  // Section: الإشعارات
                  _buildSectionHeader('الإشعارات', isDark),
                  _buildCard(
                    isDark: isDark,
                    children: [
                      _buildToggleTile(
                        isDark: isDark,
                        icon: Icons.notifications_outlined,
                        title: 'تذكير الصلاة',
                        subtitle:
                            'قبل الأذان بـ ${settings.prayerReminderMinutes} دقيقة',
                        value: settings.prayerNotifications,
                        onChanged: (_) => cubit.togglePrayerNotifications(),
                      ),
                      _buildDivider(isDark),
                      _buildReminderMinutesTile(isDark, settings, cubit),
                      _buildDivider(isDark),
                      _buildToggleTile(
                        isDark: isDark,
                        icon: Icons.volume_up_outlined,
                        title: 'الأذان',
                        subtitle: 'تشغيل الأذان عند دخول وقت الصلاة',
                        value: settings.adhanEnabled,
                        onChanged: (_) => cubit.toggleAdhan(),
                      ),
                      _buildDivider(isDark),
                      _buildToggleTile(
                        isDark: isDark,
                        icon: Icons.record_voice_over_outlined,
                        title: 'الإقامة',
                        subtitle: 'بعد ١٥ دقيقة، والمغرب بعد ٥ دقائق',
                        value: settings.iqamaEnabled,
                        onChanged: (_) => cubit.toggleIqama(),
                      ),
                      _buildDivider(isDark),
                      _buildNavigationTile(
                        isDark: isDark,
                        icon: Icons.volume_up_outlined,
                        title: 'صوت الأذان',
                        subtitle: PrayerAudioVoiceCatalog
                            .resolveAdhanVoice(settings.selectedAdhanVoiceId)
                            .name,
                        onTap: () => _showVoicePicker(
                          context,
                          cubit,
                          isDark,
                          PrayerAudioVoiceType.adhan,
                        ),
                      ),
                      _buildDivider(isDark),
                      _buildNavigationTile(
                        isDark: isDark,
                        icon: Icons.record_voice_over_outlined,
                        title: 'صوت الإقامة',
                        subtitle: PrayerAudioVoiceCatalog
                            .resolveIqamaVoice(settings.selectedIqamaVoiceId)
                            .name,
                        onTap: () => _showVoicePicker(
                          context,
                          cubit,
                          isDark,
                          PrayerAudioVoiceType.iqama,
                        ),
                      ),
                      _buildDivider(isDark),
                      _buildToggleTile(
                        isDark: isDark,
                        icon: Icons.notifications_outlined,
                        title: 'تذكير الأذكار',
                        subtitle: 'الصباح والمساء',
                        value: settings.azkarNotifications,
                        onChanged: (_) => cubit.toggleAzkarNotifications(),
                      ),
                    ],
                  ),

                  // Section: القراءة
                  _buildSectionHeader('القراءة', isDark),
                  _buildCard(
                    isDark: isDark,
                    children: [
                      _buildNavigationTile(
                        isDark: isDark,
                        icon: Icons.menu_book_outlined,
                        title: 'القارئ',
                        subtitle: settings.reciter,
                        onTap: () => _showReciterPicker(context, cubit, isDark),
                      ),
                      _buildDivider(isDark),
                      _buildNavigationTile(
                        isDark: isDark,
                        icon: Icons.translate,
                        title: 'اللغة',
                        subtitle: settings.language,
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'نور • الإصدار ١.٠',
                      style: GoogleFonts.cairo(
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
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 8),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildCard({required bool isDark, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Column(children: children),
    );
  }

  Widget _buildToggleTile({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeTile(bool isDark, double fontSize, SettingsCubit cubit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Slider(
              value: fontSize,
              min: 16,
              max: 36,
              divisions: 10,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.accentLight,
              onChanged: cubit.setFontSize,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'حجم الخط',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
              Text(
                '${fontSize.round()}px',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.text_fields, color: AppColors.primary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderMinutesTile(
    bool isDark,
    SettingsState settings,
    SettingsCubit cubit,
  ) {
    const options = [5, 10, 15, 20, 30];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          DropdownButton<int>(
            value: settings.prayerReminderMinutes,
            underline: const SizedBox.shrink(),
            items: options
                .map(
                  (minutes) => DropdownMenuItem(
                    value: minutes,
                    child: Text('$minutes دقيقة'),
                  ),
                )
                .toList(),
            onChanged: (minutes) {
              if (minutes != null) cubit.setPrayerReminderMinutes(minutes);
            },
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'وقت التذكير',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
              Text(
                'قبل موعد الأذان',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.schedule, color: AppColors.primary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.arrow_back_ios, size: 14, color: AppColors.textMuted),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 68,
      endIndent: 16,
      color: isDark ? AppColors.bgCardDark2 : Colors.grey.shade100,
    );
  }

  void _showReciterPicker(
      BuildContext context, SettingsCubit cubit, bool isDark) {
    final reciters = [
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
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...reciters.map(
              (r) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  r,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.cairo(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
                trailing: cubit.state.reciter == r
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  cubit.setReciter(r);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVoicePicker(
    BuildContext context,
    SettingsCubit cubit,
    bool isDark,
    PrayerAudioVoiceType type,
  ) {
    final voices = type == PrayerAudioVoiceType.adhan
        ? PrayerAudioVoiceCatalog.adhanVoices
        : PrayerAudioVoiceCatalog.iqamaVoices;
    final selectedId = type == PrayerAudioVoiceType.adhan
        ? cubit.state.selectedAdhanVoiceId
        : cubit.state.selectedIqamaVoiceId;
    final title = type == PrayerAudioVoiceType.adhan
        ? 'اختر صوت الأذان'
        : 'اختر صوت الإقامة';

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
              title,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...voices.map(
              (voice) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  voice.name,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.cairo(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
                trailing: selectedId == voice.id
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  if (type == PrayerAudioVoiceType.adhan) {
                    cubit.setAdhanVoice(voice);
                  } else {
                    cubit.setIqamaVoice(voice);
                  }
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
