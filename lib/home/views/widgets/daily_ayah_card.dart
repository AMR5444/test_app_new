import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

class DailyAyahCard extends StatelessWidget {
  final bool isDark;
  final String? ayahText;
  final String? ayahSource;

  const DailyAyahCard({
    super.key,
    required this.isDark,
    this.ayahText,
    this.ayahSource,
  });

  static const Map<String, String> _fallbackAyah = {
    'text': 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
    'source': 'سورة البقرة • ١٥٢',
  };

  void _shareAyah(BuildContext context) {
    final text = ayahText ?? _fallbackAyah['text']!;
    final source = ayahSource ?? _fallbackAyah['source']!;
    SharePlus.instance.share(ShareParams(text: '$text\n— $source'));
  }

  @override
  Widget build(BuildContext context) {
    final text = ayahText ?? _fallbackAyah['text']!;
    final source = ayahSource ?? _fallbackAyah['source']!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _shareAyah(context),
                child: Row(
                  children: [
                    const Icon(
                      Icons.share_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'مشاركة',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'آية اليوم',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
            child: Column(
              children: [
                Text(
                  text,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiri(
                    fontSize: 22,
                    height: 1.9,
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '— $source —',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
