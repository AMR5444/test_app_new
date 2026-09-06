import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

class SettingsSectionHeader extends StatelessWidget {
  final String title;

  const SettingsSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 20, 8),
    child: Text(
      title,
      style: GoogleFonts.ibmPlexSansArabic(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    ),
  );
}

class SettingsCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const SettingsCard({super.key, required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
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
    child: Column(children: children),
  );
}

class SettingsDivider extends StatelessWidget {
  final bool isDark;

  const SettingsDivider({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    indent: 68,
    endIndent: 16,
    color: isDark ? AppColors.bgCardDark2 : Colors.grey.shade100,
  );
}

class SettingsToggleTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsToggleTile({
    super.key,
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              title,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(width: 12),
        SettingsIcon(icon: icon),
      ],
    ),
  );
}

class SettingsNavigationTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingsNavigationTile({
    super.key,
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.arrow_back_ios, size: 14, color: AppColors.textMuted),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(width: 12),
          SettingsIcon(icon: icon),
        ],
      ),
    ),
  );
}

class SettingsIcon extends StatelessWidget {
  final IconData icon;

  const SettingsIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: AppColors.accentLight,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: AppColors.primary, size: 20),
  );
}
