import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app_new/core/settings/logic/settings_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';
import 'package:test_app_new/tasbeeh_section/logic/tasbeeh_cubit.dart';
import 'package:test_app_new/tasbeeh_section/presentation/widgets/tasbeeh_actions.dart';
import 'package:test_app_new/tasbeeh_section/presentation/widgets/tasbeeh_counter.dart';
import 'package:test_app_new/tasbeeh_section/presentation/widgets/tasbeeh_header.dart';
import 'package:test_app_new/tasbeeh_section/presentation/widgets/tasbeeh_progress.dart';

/// Entry point for the Tasbeeh section. Provides the [TasbeehCubit] locally
/// (this feature is not yet wired into app-wide navigation) and connects
/// the presentation widgets to it via Bloc widgets only.
class TasbeehScreen extends StatelessWidget {
  const TasbeehScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TasbeehCubit(),
      child: const _TasbeehScreenContent(),
    );
  }
}

class _TasbeehScreenContent extends StatelessWidget {
  const _TasbeehScreenContent();

  @override
  Widget build(BuildContext context) {
    final isDark = context.select<SettingsCubit, bool>(
      (cubit) => cubit.state.isDarkMode,
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(title: const Text('السبحة')),
      body: SafeArea(
        child: BlocBuilder<TasbeehCubit, TasbeehState>(
          builder: (context, state) {
            if (!state.isReady) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TasbeehHeader(isDark: isDark),
                  const SizedBox(height: 32),
                  TasbeehCounter(isDark: isDark),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TasbeehProgress(isDark: isDark),
                  ),
                  const SizedBox(height: 24),
                  TasbeehActions(isDark: isDark),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
