import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/Quran_Section/views/quran_index_screen.dart';
import 'package:test_app_new/azkr_section/views/azkarCategori_Screen.dart';
import 'package:test_app_new/core/settings/settings_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';
import 'package:test_app_new/home/views/home_screen.dart';
import 'package:test_app_new/views/qibla_screen.dart';
import 'package:test_app_new/views/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final isDark = settings.isDarkMode;

        final List<Widget> screens = [
          HomeScreen(onNavigate: _navigateTo),
          const QuranIndexScreen(),
          const AzkarCategoriesScreen(),
          const QiblaScreen(),
          const SettingsScreen(),
        ];

        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: screens),
          bottomNavigationBar: _buildBottomNav(isDark),
        );
      },
    );
  }

  Widget _buildBottomNav(bool isDark) {
    final items = [
      {
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home,
        'label': 'الرئيسية',
      },
      {
        'icon': Icons.menu_book_outlined,
        'activeIcon': Icons.menu_book,
        'label': 'المصحف',
      },
      {
        'icon': Icons.auto_awesome_outlined,
        'activeIcon': Icons.auto_awesome,
        'label': 'الأذكار',
      },
      {
        'icon': Icons.explore_outlined,
        'activeIcon': Icons.explore,
        'label': 'القبلة',
      },
      {
        'icon': Icons.settings_outlined,
        'activeIcon': Icons.settings,
        'label': 'الإعدادات',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.navBgDark : AppColors.navBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = _currentIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: isSelected
                      ? BoxDecoration(
                          color: isDark
                              ? AppColors.accent.withValues(alpha: 0.15)
                              : AppColors.accentLight,
                          borderRadius: BorderRadius.circular(12),
                        )
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected
                            ? item['activeIcon'] as IconData
                            : item['icon'] as IconData,
                        size: 22,
                        color: isSelected
                            ? (isDark ? AppColors.accent : AppColors.primary)
                            : AppColors.navUnselected,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['label'] as String,
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? (isDark ? AppColors.accent : AppColors.primary)
                              : AppColors.navUnselected,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
