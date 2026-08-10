import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

class PrayerTimesCard extends StatelessWidget {
  final bool isDark;

  const PrayerTimesCard({super.key, required this.isDark});

  static const Map<String, String> _prayerTimes = {
    'الفجر': '٤:٤٣',
    'الشروق': '٦:٠٥',
    'الظهر': '١٢:٣٤',
    'العصر': '٣:٥٨',
    'المغرب': '٦:٤٢',
    'العشاء': '',
  };

  static const String _nextPrayer = 'الظهر';
  static const String _nextPrayerTime = '١٢:٣٤ م';

  @override
  Widget build(BuildContext context) {
    final prayers = ['الفجر', 'الشروق', 'الظهر', 'العصر', 'المغرب'];

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
                      'القاهرة',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'متبقي ٢:١٥:١٧',
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
                      'الصلاة القادمة • $_nextPrayer',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      _nextPrayerTime,
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
                final isNext = name == _nextPrayer;
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
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
                                fontSize: 11,
                                color: isNext
                                    ? AppColors.primary
                                    : Colors.white70,
                                fontWeight: isNext
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            Text(
                              _prayerTimes[name] ?? '',
                              style: GoogleFonts.cairo(
                                fontSize: 10,
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
