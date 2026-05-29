import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary green palette (from UI design)
  static const Color primary = Color(0xFF1A5C38);
  static const Color primaryDark = Color(0xFF0F3D25);
  static const Color primaryLight = Color(0xFF2E7D52);
  static const Color accent = Color(0xFF4CAF7D);
  static const Color accentLight = Color(0xFFD4EAD8);

  // Background
  static const Color bgLight = Color(0xFFF7F5F0);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgDark = Color(0xFF0D1F16);
  static const Color bgCardDark = Color(0xFF1A2E20);
  static const Color bgCardDark2 = Color(0xFF243A2B);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Prayer times card gradient
  static const Color prayerGradientStart = Color(0xFF1A5C38);
  static const Color prayerGradientEnd = Color(0xFF2E7D52);

  // Bottom nav
  static const Color navBg = Color(0xFFFFFFFF);
  static const Color navBgDark = Color(0xFF121E17);
  static const Color navSelected = Color(0xFF1A5C38);
  static const Color navUnselected = Color(0xFF9CA3AF);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.bgLight,
      textTheme: GoogleFonts.cairoTextTheme(),
      fontFamily: GoogleFonts.cairo().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.navBg,
        selectedItemColor: AppColors.navSelected,
        unselectedItemColor: AppColors.navUnselected,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.bgDark,
      textTheme: GoogleFonts.cairoTextTheme(
        ThemeData.dark().textTheme,
      ),
      fontFamily: GoogleFonts.cairo().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          color: AppColors.textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.textLight),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.navBgDark,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.navUnselected,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
