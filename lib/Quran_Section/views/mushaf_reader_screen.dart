import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/Quran_Section/data/quran_api_service.dart';
import 'package:test_app_new/Quran_Section/models/ayah_model.dart';
import 'package:test_app_new/core/theme/app_theme.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class MushafReaderScreen extends StatefulWidget {
  final String surahName;
  final int surahNumber;
  const MushafReaderScreen({
    super.key,
    required this.surahName,
    required this.surahNumber,
  });

  @override
  State<MushafReaderScreen> createState() => _MushafReaderScreenState();
}

class _MushafReaderScreenState extends State<MushafReaderScreen> {
  late Future<List<AyahModel>> ayahsFuture;
  @override
  void initState() {
    super.initState();

    ayahsFuture = QuranApiService().fetchSurah(widget.surahNumber);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgCard;
    final textColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          widget.surahName,
          style: GoogleFonts.ibmPlexSansArabic(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: bg,
      ),
      body: FutureBuilder<List<AyahModel>>(
        future: ayahsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("قم بتحميل السورة "));
          }

          final ayahs = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(26, 12, 26, 18),
            itemCount: ayahs.length,
            itemBuilder: (context, index) {
              final ayah = ayahs[index];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "${ayah.text} ﴿${ayah.numberInSurah}﴾",
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 26,
                    height: 2.0,
                    letterSpacing: 0.1,
                    color: textColor,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
