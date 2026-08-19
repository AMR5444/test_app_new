import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/Qibla_section/logic/qibla_cubit.dart';
import 'package:test_app_new/Qibla_section/presentation/widgets/qibla_compass.dart';
import 'package:test_app_new/Qibla_section/presentation/widgets/qibla_error_view.dart';
import 'package:test_app_new/Qibla_section/presentation/widgets/qibla_info_card.dart';
import 'package:test_app_new/Qibla_section/presentation/widgets/qibla_status.dart';
import 'package:test_app_new/core/settings/logic/settings_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QiblaCubit(),
      child: const _QiblaScreenContent(),
    );
  }
}

class _QiblaScreenContent extends StatelessWidget {
  const _QiblaScreenContent();

  @override
  Widget build(BuildContext context) {
    final isDark = context.select<SettingsCubit, bool>(
      (cubit) => cubit.state.isDarkMode,
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(title: const Text('اتجاه القبلة')),
      body: SafeArea(
        child: BlocBuilder<QiblaCubit, QiblaState>(
          buildWhen: (previous, current) => previous.status != current.status,
          builder: (context, state) {
            switch (state.status) {
              case QiblaStatus.initial:
              case QiblaStatus.loading:
                return Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              case QiblaStatus.error:
                return QiblaErrorView(
                  isDark: isDark,
                  message: state.errorMessage ?? 'حدث خطأ غير متوقع',
                );
              case QiblaStatus.success:
                return _QiblaContent(isDark: isDark);
            }
          },
        ),
      ),
    );
  }
}

class _QiblaContent extends StatelessWidget {
  final bool isDark;

  const _QiblaContent({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 600;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              QiblaStatusBadge(isDark: isDark),
              SizedBox(height: isCompact ? 12 : 24),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: QiblaCompass(isDark: isDark),
                  ),
                ),
              ),
              SizedBox(height: isCompact ? 12 : 24),
              Text(
                'أدر جهازك حتى تشير الإبرة إلى الكعبة',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: isDark ? AppColors.textMuted : AppColors.textSecondary,
                ),
              ),
              SizedBox(height: isCompact ? 12 : 20),
              QiblaInfoCard(isDark: isDark),
            ],
          ),
        );
      },
    );
  }
}
