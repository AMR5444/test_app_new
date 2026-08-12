import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app_new/core/settings/logic/settings_cubit.dart';
import 'package:test_app_new/core/settings/presentation/widgets/settings_components.dart';

class AppearanceSettingsSection extends StatelessWidget {
  final bool isDark;

  const AppearanceSettingsSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    return BlocSelector<SettingsCubit, SettingsState, bool>(
      selector: (state) => state.isDarkMode,
      builder: (context, appearance) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SettingsSectionHeader(title: 'المظهر'),
          SettingsCard(
            isDark: isDark,
            children: [
              SettingsToggleTile(
                isDark: isDark,
                icon: Icons.light_mode_outlined,
                title: 'الوضع الداكن',
                subtitle: 'لقراءة مريحة في الإضاءة المنخفضة',
                value: appearance,
                onChanged: (_) => cubit.toggleDarkMode(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
