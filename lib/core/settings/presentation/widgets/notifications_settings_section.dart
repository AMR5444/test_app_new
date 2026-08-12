import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/core/settings/logic/settings_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';
import 'package:test_app_new/home/data/prayer_audio_voice_catalog.dart';
import 'package:test_app_new/home/models/prayer_audio_voice.dart';
import 'package:test_app_new/core/settings/presentation/widgets/settings_components.dart';
import 'package:test_app_new/core/settings/data/prayer_audio_preview_service.dart';

class NotificationsSettingsSection extends StatelessWidget {
  final bool isDark;

  const NotificationsSettingsSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    return BlocSelector<
      SettingsCubit,
      SettingsState,
      ({
        bool prayer,
        bool adhan,
        bool iqama,
        int minutes,
        bool azkar,
        String adhanVoice,
        String iqamaVoice,
      })
    >(
      selector: (state) => (
        prayer: state.prayerNotifications,
        adhan: state.adhanEnabled,
        iqama: state.iqamaEnabled,
        minutes: state.prayerReminderMinutes,
        azkar: state.azkarNotifications,
        adhanVoice: state.selectedAdhanVoiceId,
        iqamaVoice: state.selectedIqamaVoiceId,
      ),
      builder: (context, settings) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SettingsSectionHeader(title: 'الإشعارات'),
          SettingsCard(
            isDark: isDark,
            children: [
              SettingsToggleTile(
                isDark: isDark,
                icon: Icons.notifications_outlined,
                title: 'تذكير الصلاة',
                subtitle: 'قبل الأذان بـ ${settings.minutes} دقيقة',
                value: settings.prayer,
                onChanged: (_) => cubit.togglePrayerNotifications(),
              ),
              SettingsDivider(isDark: isDark),
              _ReminderMinutesTile(
                isDark: isDark,
                minutes: settings.minutes,
                onChanged: cubit.setPrayerReminderMinutes,
              ),
              SettingsDivider(isDark: isDark),
              SettingsToggleTile(
                isDark: isDark,
                icon: Icons.volume_up_outlined,
                title: 'الأذان',
                subtitle: 'تشغيل الأذان عند دخول وقت الصلاة',
                value: settings.adhan,
                onChanged: (_) => cubit.toggleAdhan(),
              ),
              SettingsDivider(isDark: isDark),
              SettingsToggleTile(
                isDark: isDark,
                icon: Icons.record_voice_over_outlined,
                title: 'الإقامة',
                subtitle: 'بعد ١٥ دقيقة، والمغرب بعد ٥ دقائق',
                value: settings.iqama,
                onChanged: (_) => cubit.toggleIqama(),
              ),
              SettingsDivider(isDark: isDark),
              SettingsNavigationTile(
                isDark: isDark,
                icon: Icons.volume_up_outlined,
                title: 'صوت الأذان',
                subtitle: PrayerAudioVoiceCatalog.resolveAdhanVoice(
                  settings.adhanVoice,
                ).name,
                onTap: () => _showVoicePicker(
                  context,
                  cubit,
                  isDark,
                  PrayerAudioVoiceType.adhan,
                  settings.adhanVoice,
                ),
              ),
              SettingsDivider(isDark: isDark),
              SettingsNavigationTile(
                isDark: isDark,
                icon: Icons.record_voice_over_outlined,
                title: 'صوت الإقامة',
                subtitle: PrayerAudioVoiceCatalog.resolveIqamaVoice(
                  settings.iqamaVoice,
                ).name,
                onTap: () => _showVoicePicker(
                  context,
                  cubit,
                  isDark,
                  PrayerAudioVoiceType.iqama,
                  settings.iqamaVoice,
                ),
              ),
              SettingsDivider(isDark: isDark),
              SettingsToggleTile(
                isDark: isDark,
                icon: Icons.notifications_outlined,
                title: 'تذكير الأذكار',
                subtitle: 'الصباح والمساء',
                value: settings.azkar,
                onChanged: (_) => cubit.toggleAzkarNotifications(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showVoicePicker(
    BuildContext context,
    SettingsCubit cubit,
    bool isDark,
    PrayerAudioVoiceType type,
    String selectedId,
  ) {
    final voices = type == PrayerAudioVoiceType.adhan
        ? PrayerAudioVoiceCatalog.adhanVoices
        : PrayerAudioVoiceCatalog.iqamaVoices;
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
            ValueListenableBuilder<String?>(
              valueListenable:
                  PrayerAudioPreviewService.instance.playingVoiceId,
              builder: (context, playingId, _) => Column(
                children: voices
                    .map(
                      (voice) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: IconButton(
                          icon: Icon(
                            playingId == voice.id
                                ? Icons.stop_circle_outlined
                                : Icons.play_circle_outline,
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.textPrimary,
                          ),
                          tooltip: 'معاينة الصوت',
                          onPressed: () => PrayerAudioPreviewService.instance
                              .togglePreview(voice),
                        ),
                        title: Text(
                          voice.name,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.cairo(
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.textPrimary,
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
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() => PrayerAudioPreviewService.instance.stop());
  }
}

class _ReminderMinutesTile extends StatelessWidget {
  final bool isDark;
  final int minutes;
  final ValueChanged<int> onChanged;

  const _ReminderMinutesTile({
    required this.isDark,
    required this.minutes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const options = [5, 10, 15, 20, 30];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          DropdownButton<int>(
            value: minutes,
            underline: const SizedBox.shrink(),
            items: options
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text('$value دقيقة'),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) onChanged(value);
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
          const SettingsIcon(icon: Icons.schedule),
        ],
      ),
    );
  }
}
