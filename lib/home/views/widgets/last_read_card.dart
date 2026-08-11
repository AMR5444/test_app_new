import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/Quran_Section/models/LastRead_model.dart';
import 'package:test_app_new/Quran_Section/models/surah_model.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

class LastReadCard extends StatelessWidget {
  final bool isDark;
  final LastRead? lastPosition;
  final SurahModel? lastSurah;
  final VoidCallback onTap;

  const LastReadCard({
    super.key,
    required this.isDark,
    required this.lastPosition,
    required this.lastSurah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (lastPosition == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.08),
                AppColors.primary.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.arrow_back_ios,
                size: 14,
                color: AppColors.primary,
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'متابعة القراءة',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    lastSurah != null
                        ? '${lastSurah!.name} • صفحة ${lastPosition!.pageIndex + 1}'
                        : 'سورة ${lastPosition!.surahNumber} • صفحة ${lastPosition!.pageIndex + 1}',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    _toArabicNumbers(lastPosition!.surahNumber.toString()),
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _toArabicNumbers(String input) {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return input.split('').map((c) {
      final code = c.codeUnitAt(0);
      return (code >= 48 && code <= 57) ? arabic[code - 48] : c;
    }).join();
  }
}
