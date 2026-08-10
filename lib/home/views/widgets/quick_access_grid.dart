import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

class QuickAccessGrid extends StatelessWidget {
  final bool isDark;
  final void Function(int) onNavigate;

  const QuickAccessGrid({
    super.key,
    required this.isDark,
    required this.onNavigate,
  });

  static const List<Map<String, dynamic>> _items = [
    {'icon': Icons.explore_outlined, 'label': 'القبلة', 'tab': 3},
    {'icon': Icons.auto_awesome_outlined, 'label': 'الأذكار', 'tab': 2},
    {'icon': Icons.menu_book_outlined, 'label': 'المصحف', 'tab': 1},
    {'icon': Icons.history, 'label': 'أخر قراءة', 'tab': 1},
    {'icon': Icons.favorite_outline, 'label': 'المفضلة', 'tab': 1},
    {'icon': Icons.touch_app_outlined, 'label': 'التسبيح', 'tab': 2},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemBuilder: (context, index) {
          final item = _items[index];
          return GestureDetector(
            onTap: () => onNavigate(item['tab'] as int),
            child: Container(
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['label'] as String,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textLight
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
