import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

class PrayerTimesCard extends StatelessWidget {
  final bool isDark;
  final Map<String, String> prayerTimes;
  final String nextPrayer;
  final String nextPrayerTime;
  final String countdown;
  final String location;
  final bool isLoading;
  final String? errorMessage;

  const PrayerTimesCard({
    super.key,
    required this.isDark,
    required this.prayerTimes,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.countdown,
    required this.location,
    required this.isLoading,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    const prayers = ['الفجر', 'الشروق', 'الظهر', 'العصر', 'المغرب', 'العشاء'];
    final status = errorMessage ??
        (isLoading
            ? 'جارٍ تحديد الموقع...'
            : 'متبقي ${countdown.isEmpty ? '--:--:--' : countdown}');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.prayerGradientStart, AppColors.prayerGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.isEmpty ? 'مواقيت الصلاة' : location,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      status,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'الصلاة القادمة • ${nextPrayer.isEmpty ? '--' : nextPrayer}',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      nextPrayerTime.isEmpty ? '--:--' : nextPrayerTime,
                      style: GoogleFonts.cairo(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: prayers.map((name) {
                final isNext = name == nextPrayer;
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        decoration: isNext
                            ? BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              )
                            : null,
                        child: Column(
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                color: isNext
                                    ? AppColors.primary
                                    : Colors.white70,
                                fontWeight: isNext
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            Text(
                              prayerTimes[name] ?? '--:--',
                              style: GoogleFonts.cairo(
                                fontSize: 9,
                                color: isNext
                                    ? AppColors.primary
                                    : Colors.white60,
                                fontWeight: isNext
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
