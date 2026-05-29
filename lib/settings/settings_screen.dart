import 'package:flutter/material.dart';
import 'package:test_app_new/core/theme/app_theme.dart';
import 'package:test_app_new/settings/app_settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppSettingsController _settings = AppSettingsController.instance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _settings,
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bg = isDark ? const Color(0xFF001813) : const Color(0xFFF2F2F1);
        final cardBg = isDark
            ? const Color(0xFF02211A)
            : const Color(0xFFF9F9F8);
        final border = isDark
            ? const Color(0xFF12352C)
            : const Color(0xFFDCDDD9);
        final titleColor = isDark
            ? const Color(0xFFEFF8F3)
            : const Color(0xFF0C1714);
        final subtitleColor = isDark
            ? const Color(0xFF8DA79E)
            : const Color(0xFF717673);
        final sectionColor = isDark
            ? const Color(0xFF748A83)
            : const Color(0xFF7F807D);
        final iconBg = isDark
            ? const Color(0xFF0E3229)
            : const Color(0xFFE5EEEA);
        final iconColor = isDark
            ? const Color(0xFF8CE1BF)
            : const Color(0xFF0D5F43);

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Center(
                  child: Text(
                    'الإعدادات',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                _SectionTitle(text: 'المظهر', color: sectionColor),
                const SizedBox(height: 8),
                _GroupCard(
                  background: cardBg,
                  borderColor: border,
                  children: [
                    _SwitchRow(
                      title: 'الوضع الداكن',
                      subtitle: 'لقراءة مريحة في الإضاءة المنخفضة',
                      icon: Icons.dark_mode_outlined,
                      value: _settings.themeMode == ThemeMode.dark,
                      onChanged: _settings.setDarkMode,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      iconBg: iconBg,
                      iconColor: iconColor,
                    ),
                    Divider(height: 1, color: border),
                    _FontSizeRow(
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      iconBg: iconBg,
                      iconColor: iconColor,
                      value: _settings.quranFontSize,
                      onChanged: _settings.setQuranFontSize,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _SectionTitle(text: 'الإشعارات', color: sectionColor),
                const SizedBox(height: 8),
                _GroupCard(
                  background: cardBg,
                  borderColor: border,
                  children: [
                    _SwitchRow(
                      title: 'مواقيت الصلاة',
                      subtitle: 'تذكير قبل الأذان',
                      icon: Icons.notifications_none_rounded,
                      value: _settings.prayerReminderEnabled,
                      onChanged: _settings.setPrayerReminderEnabled,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      iconBg: iconBg,
                      iconColor: iconColor,
                    ),
                    Divider(height: 1, color: border),
                    _SwitchRow(
                      title: 'تذكير الأذكار',
                      subtitle: 'الصباح والمساء',
                      icon: Icons.notifications_none_rounded,
                      value: _settings.azkarReminderEnabled,
                      onChanged: _settings.setAzkarReminderEnabled,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      iconBg: iconBg,
                      iconColor: iconColor,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _SectionTitle(text: 'القراءة', color: sectionColor),
                const SizedBox(height: 8),
                _GroupCard(
                  background: cardBg,
                  borderColor: border,
                  children: [
                    _PickerRow(
                      title: 'القارئ',
                      subtitle: _settings.reciter,
                      icon: Icons.menu_book_outlined,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      iconBg: iconBg,
                      iconColor: iconColor,
                      onTap: () => _pickReciter(context),
                    ),
                    Divider(height: 1, color: border),
                    _PickerRow(
                      title: 'اللغة',
                      subtitle: _settings.language,
                      icon: Icons.translate_rounded,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      iconBg: iconBg,
                      iconColor: iconColor,
                      onTap: () => _pickLanguage(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'نور • الإصدار ١.٠',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickReciter(BuildContext context) async {
    const reciters = [
      'مشاري راشد العفاسي',
      'عبد الباسط عبد الصمد',
      'ماهر المعيقلي',
      'سعد الغامدي',
    ];
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.bgDark
          : AppColors.bgCard,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: reciters
            .map(
              (r) => ListTile(
                title: Text(r, textAlign: TextAlign.right),
                onTap: () => Navigator.pop(context, r),
              ),
            )
            .toList(),
      ),
    );
    if (selected != null) {
      await _settings.setReciter(selected);
    }
  }

  Future<void> _pickLanguage(BuildContext context) async {
    const languages = ['العربية', 'English'];
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.bgDark
          : AppColors.bgCard,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: languages
            .map(
              (l) => ListTile(
                title: Text(l, textAlign: TextAlign.right),
                onTap: () => Navigator.pop(context, l),
              ),
            )
            .toList(),
      ),
    );
    if (selected != null) {
      await _settings.setLanguage(selected);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final Color color;

  const _SectionTitle({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final Color background;
  final Color borderColor;
  final List<Widget> children;

  const _GroupCard({
    required this.background,
    required this.borderColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color titleColor;
  final Color subtitleColor;
  final Color iconBg;
  final Color iconColor;

  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.titleColor,
    required this.subtitleColor,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.bgCard,
            activeTrackColor: const Color(0xFF005433),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          _CircleIcon(icon: icon, iconBg: iconBg, iconColor: iconColor),
        ],
      ),
    );
  }
}

class _FontSizeRow extends StatelessWidget {
  final Color titleColor;
  final Color subtitleColor;
  final Color iconBg;
  final Color iconColor;
  final double value;
  final ValueChanged<double> onChanged;

  const _FontSizeRow({
    required this.titleColor,
    required this.subtitleColor,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF04603F),
                thumbColor: const Color(0xFF0C8B62),
                inactiveTrackColor: const Color(0xFFB2BAB6),
                trackHeight: 4,
              ),
              child: Slider(
                min: 18,
                max: 40,
                divisions: 11,
                value: value,
                onChanged: onChanged,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'حجم الخط',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              Text(
                '${value.round()}px',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          _CircleIcon(
            icon: Icons.text_fields_rounded,
            iconBg: iconBg,
            iconColor: iconColor,
          ),
        ],
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color titleColor;
  final Color subtitleColor;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _PickerRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.titleColor,
    required this.subtitleColor,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.chevron_left_rounded, color: subtitleColor, size: 30),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            _CircleIcon(icon: icon, iconBg: iconBg, iconColor: iconColor),
          ],
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _CircleIcon({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: 24),
    );
  }
}
