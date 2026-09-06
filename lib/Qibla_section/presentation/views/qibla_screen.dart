import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/Qibla_section/logic/qibla_cubit.dart';
import 'package:test_app_new/Qibla_section/presentation/widgets/qibla_compass.dart';
import 'package:test_app_new/Qibla_section/presentation/widgets/qibla_error_view.dart';
import 'package:test_app_new/Qibla_section/presentation/widgets/qibla_info_card.dart';
import 'package:test_app_new/Qibla_section/presentation/widgets/qibla_location_label.dart';
import 'package:test_app_new/Qibla_section/presentation/widgets/qibla_status.dart';
import 'package:test_app_new/core/settings/logic/settings_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

class QiblaScreen extends StatefulWidget {
  final bool isVisible;

  const QiblaScreen({super.key, this.isVisible = true});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  QiblaCubit? _cubit;

  @override
  void initState() {
    super.initState();
    if (widget.isVisible) _activate();
  }

  @override
  void didUpdateWidget(covariant QiblaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible == oldWidget.isVisible) return;

    if (widget.isVisible) {
      _activate();
    } else {
      _cubit?.pause();
    }
  }

  void _activate() {
    final cubit = _cubit;
    if (cubit == null) {
      _cubit = QiblaCubit();
    } else {
      cubit.resume();
    }
  }

  @override
  void dispose() {
    _cubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = _cubit;

    // Never visited yet: no cubit, no location/sensor requests at all.
    if (cubit == null) return const SizedBox.shrink();

    return BlocProvider.value(value: cubit, child: const _QiblaScreenContent());
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
        child: BlocConsumer<QiblaCubit, QiblaState>(
          buildWhen: (previous, current) => previous.status != current.status,
          listenWhen: (previous, current) =>
              current.isFacingQibla && !previous.isFacingQibla,
          listener: (context, state) => HapticFeedback.mediumImpact(),
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
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 13,
                  color: isDark ? AppColors.textMuted : AppColors.textSecondary,
                ),
              ),
              SizedBox(height: isCompact ? 12 : 20),
              QiblaLocationLabel(isDark: isDark),
              const SizedBox(height: 10),
              QiblaInfoCard(isDark: isDark),
            ],
          ),
        );
      },
    );
  }
}
