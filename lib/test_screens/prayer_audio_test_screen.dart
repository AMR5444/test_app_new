import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app_new/core/Notifications/NotificationsService.dart';
import 'package:test_app_new/core/theme/app_theme.dart';
import 'package:test_app_new/home/data/prayer_audio_voice_catalog.dart';
import 'package:timezone/timezone.dart' as tz;

class PrayerAudioTestScreen extends StatefulWidget {
  const PrayerAudioTestScreen({super.key});

  @override
  State<PrayerAudioTestScreen> createState() => _PrayerAudioTestScreenState();
}

class _PrayerAudioTestScreenState extends State<PrayerAudioTestScreen> {
  static const int _testAdhanId = 99901;
  static const int _testIqamaId = 99902;

  String _adhanVoiceName = '';
  String _iqamaVoiceName = '';
  String _status = '';

  @override
  void initState() {
    super.initState();
    _loadSelectedVoices();
  }

  Future<void> _loadSelectedVoices() async {
    final prefs = await SharedPreferences.getInstance();
    final adhanId = prefs.getString('selectedAdhanVoiceId');
    final iqamaId = prefs.getString('selectedIqamaVoiceId');
    if (!mounted) return;
    setState(() {
      _adhanVoiceName = PrayerAudioVoiceCatalog.resolveAdhanVoice(adhanId).name;
      _iqamaVoiceName = PrayerAudioVoiceCatalog.resolveIqamaVoice(iqamaId).name;
    });
  }

  Future<void> _scheduleTestAdhan() async {
    final prefs = await SharedPreferences.getInstance();
    final adhanVoiceId = prefs.getString('selectedAdhanVoiceId');
    final voice = PrayerAudioVoiceCatalog.resolveAdhanVoice(adhanVoiceId);

    final now = tz.TZDateTime.now(tz.local);
    final scheduled = now.add(const Duration(seconds: 5));

    await NotificationsService.schedulePrayerNotification(
      id: _testAdhanId,
      title: 'اختبار الأذان',
      body: 'سيتم تشغيل صوت الأذان بعد 5 ثوانٍ',
      scheduledDate: scheduled,
      channelId: 'test_adhan_channel',
      channelName: 'Test Adhan',
      assetPath: voice.assetPath,
      addStopAction: true,
    );

    if (!mounted) return;
    setState(() => _status = 'تم جدولة اختبار الأذان (${voice.name})');
  }

  Future<void> _scheduleTestIqama() async {
    final prefs = await SharedPreferences.getInstance();
    final iqamaVoiceId = prefs.getString('selectedIqamaVoiceId');
    final voice = PrayerAudioVoiceCatalog.resolveIqamaVoice(iqamaVoiceId);

    final now = tz.TZDateTime.now(tz.local);
    final scheduled = now.add(const Duration(seconds: 5));

    await NotificationsService.schedulePrayerNotification(
      id: _testIqamaId,
      title: 'اختبار الإقامة',
      body: 'سيتم تشغيل صوت الإقامة بعد 5 ثوانٍ',
      scheduledDate: scheduled,
      channelId: 'test_iqama_channel',
      channelName: 'Test Iqama',
      assetPath: voice.assetPath,
    );

    if (!mounted) return;
    setState(() => _status = 'تم جدولة اختبار الإقامة (${voice.name})');
  }

  Future<void> _stopTestAdhan() async {
    await NotificationsService.cancel(_testAdhanId);
    if (!mounted) return;
    setState(() => _status = 'تم إلغاء إشعار اختبار الأذان');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'اختبار الأذان والإقامة',
          style: GoogleFonts.ibmPlexSansArabic(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _InfoCard(
              isDark: isDark,
              label: 'صوت الأذان المختار',
              value: _adhanVoiceName,
            ),
            const SizedBox(height: 12),
            _InfoCard(
              isDark: isDark,
              label: 'صوت الإقامة المختار',
              value: _iqamaVoiceName,
            ),
            const SizedBox(height: 32),
            _TestButton(
              isDark: isDark,
              icon: Icons.volume_up_outlined,
              label: 'Test Adhan',
              sublabel: 'إشعار بعد 5 ثوانٍ مع زر إيقاف الأذان',
              color: AppColors.primary,
              onPressed: _scheduleTestAdhan,
            ),
            const SizedBox(height: 16),
            _TestButton(
              isDark: isDark,
              icon: Icons.record_voice_over_outlined,
              label: 'Test Iqama',
              sublabel: 'إشعار بعد 5 ثوانٍ بدون زر إيقاف',
              color: AppColors.accent,
              onPressed: _scheduleTestIqama,
            ),
            const SizedBox(height: 16),
            _TestButton(
              isDark: isDark,
              icon: Icons.stop_circle_outlined,
              label: 'Stop Adhan',
              sublabel: 'إلغاء إشعار اختبار الأذان فقط',
              color: Colors.redAccent,
              onPressed: _stopTestAdhan,
            ),
            const SizedBox(height: 24),
            if (_status.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.bgCardDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Text(
                ' جررررب الاذان من هنا يا علي يا سيد يا بدوي ',
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 13,
                  color: Colors.orange[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final bool isDark;
  final String label;
  final String value;

  const _InfoCard({
    required this.isDark,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            value,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            label,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TestButton extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onPressed;

  const _TestButton({
    required this.isDark,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  label,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  sublabel,
                  style: GoogleFonts.ibmPlexSansArabic(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, size: 24),
        ],
      ),
    );
  }
}
