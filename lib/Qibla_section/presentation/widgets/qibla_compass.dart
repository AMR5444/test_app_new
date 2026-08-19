import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app_new/Qibla_section/logic/qibla_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

class QiblaCompass extends StatelessWidget {
  final bool isDark;

  const QiblaCompass({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      QiblaCubit,
      QiblaState,
      ({double relativeAngle, bool isFacing})
    >(
      selector: (state) => (
        relativeAngle: state.relativeAngle ?? 0.0,
        isFacing: state.isFacingQibla,
      ),
      builder: (context, selected) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.maxWidth < constraints.maxHeight
                ? constraints.maxWidth
                : constraints.maxHeight;

            return SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _Dial(
                    isDark: isDark,
                    isFacing: selected.isFacing,
                    size: size,
                  ),
                  _AnimatedNeedle(
                    relativeAngleDegrees: selected.relativeAngle,
                    isDark: isDark,
                    isFacing: selected.isFacing,
                    size: size,
                  ),
                  _CenterDot(isFacing: selected.isFacing),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _AnimatedNeedle extends StatefulWidget {
  final double relativeAngleDegrees;
  final bool isDark;
  final bool isFacing;
  final double size;

  const _AnimatedNeedle({
    required this.relativeAngleDegrees,
    required this.isDark,
    required this.isFacing,
    required this.size,
  });

  @override
  State<_AnimatedNeedle> createState() => _AnimatedNeedleState();
}

class _AnimatedNeedleState extends State<_AnimatedNeedle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _turnsAnimation;

  double _committedTurns = 0;
  static const Duration _animationDuration = Duration(milliseconds: 220);

  static const double _jitterToleranceDegrees = 0.6;

  @override
  void initState() {
    super.initState();
    _committedTurns = widget.relativeAngleDegrees / 360;
    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
    _turnsAnimation = AlwaysStoppedAnimation(_committedTurns);
  }

  @override
  void didUpdateWidget(covariant _AnimatedNeedle oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.relativeAngleDegrees == widget.relativeAngleDegrees) {
      return;
    }

    final currentDisplayedTurns = _turnsAnimation.value;

    final targetTurns = _nextUnwrappedTurns(
      currentTurns: currentDisplayedTurns,
      targetAngleDegrees: widget.relativeAngleDegrees,
    );

    final deltaDegrees = (targetTurns - currentDisplayedTurns) * 360;
    if (deltaDegrees.abs() < _jitterToleranceDegrees) {
      _committedTurns = targetTurns;
      return;
    }

    _turnsAnimation = Tween<double>(
      begin: currentDisplayedTurns,
      end: targetTurns,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _committedTurns = targetTurns;
    _controller
      ..reset()
      ..forward();
  }

  double _nextUnwrappedTurns({
    required double currentTurns,
    required double targetAngleDegrees,
  }) {
    final targetTurns = targetAngleDegrees / 360;

    // Shortest circular delta between the two turns values, in (-0.5, 0.5].
    var delta = (targetTurns - currentTurns) % 1.0;
    if (delta > 0.5) delta -= 1.0;
    if (delta < -0.5) delta += 1.0;

    return currentTurns + delta;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final needleColor = widget.isFacing
        ? AppColors.primary
        : (widget.isDark ? AppColors.textLight : AppColors.textPrimary);
    final needleLength = widget.size * 0.36;

    return AnimatedBuilder(
      animation: _turnsAnimation,
      builder: (context, _) {
        final angleRad = _turnsAnimation.value * 2 * math.pi;
        return Transform.rotate(
          angle: angleRad,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _NeedlePainter(color: needleColor),
                ),

                Transform.translate(
                  offset: Offset(0, -needleLength - 8),
                  child: Transform.rotate(
                    angle: -angleRad,
                    child: _KaabaBadge(isFacing: widget.isFacing),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Small badge that marks the Kaaba's position at the needle's tip.
class _KaabaBadge extends StatelessWidget {
  final bool isFacing;

  const _KaabaBadge({required this.isFacing});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isFacing ? AppColors.primary : Colors.black).withValues(
              alpha: isFacing ? 0.45 : 0.12,
            ),
            blurRadius: isFacing ? 18 : 8,
            spreadRadius: isFacing ? 2 : 0,
          ),
        ],
      ),
      child: const Text('🕋', style: TextStyle(fontSize: 18)),
    );
  }
}

class _Dial extends StatelessWidget {
  final bool isDark;
  final bool isFacing;
  final double size;

  const _Dial({
    required this.isDark,
    required this.isFacing,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final ringColor = isFacing
        ? AppColors.primary
        : (isDark ? AppColors.bgCardDark2 : AppColors.accentLight);
    final labelColor = isDark ? AppColors.textMuted : AppColors.textSecondary;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (isFacing) _GlowPulse(size: size, color: AppColors.primary),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppColors.bgCardDark : AppColors.bgCard,
            border: Border.all(color: ringColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CustomPaint(
            size: Size(size, size),
            painter: _TicksPainter(
              color: isDark ? AppColors.textMuted : AppColors.textSecondary,
            ),
          ),
        ),
        ..._cardinalLabels(size, labelColor),
      ],
    );
  }

  List<Widget> _cardinalLabels(double size, Color color) {
    const labels = {'N': 0.0, 'E': 90.0, 'S': 180.0, 'W': 270.0};
    final r = size / 2 - 22;
    return labels.entries.map((entry) {
      final rad = entry.value * math.pi / 180;
      final dx = r * math.sin(rad);
      final dy = -r * math.cos(rad);
      return Transform.translate(
        offset: Offset(dx, dy),
        child: Text(
          entry.key,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: entry.key == 'N' ? AppColors.primary : color,
          ),
        ),
      );
    }).toList();
  }
}

class _GlowPulse extends StatefulWidget {
  final double size;
  final Color color;

  const _GlowPulse({required this.size, required this.color});

  @override
  State<_GlowPulse> createState() => _GlowPulseState();
}

class _GlowPulseState extends State<_GlowPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.22 + 0.14 * t),
                blurRadius: 26 + 20 * t,
                spreadRadius: 4 + 6 * t,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Draws minute/major tick marks around the dial's inner edge.
class _TicksPainter extends CustomPainter {
  final Color color;

  const _TicksPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..color = color.withValues(alpha: 0.5);

    for (var i = 0; i < 36; i++) {
      final angle = (i * 10) * math.pi / 180;
      final isMajor = i % 9 == 0;
      final outer = radius - 8;
      final inner = isMajor ? radius - 20 : radius - 14;

      final direction = Offset(math.sin(angle), -math.cos(angle));
      final p1 = center + direction * outer;
      final p2 = center + direction * inner;

      paint.strokeWidth = isMajor ? 2.5 : 1.2;
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TicksPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _NeedlePainter extends CustomPainter {
  final Color color;

  const _NeedlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final length = size.width * 0.36;
    final tailLength = size.width * 0.14;
    final halfWidth = size.width * 0.045;

    final tip = center - Offset(0, length);
    final tail = center + Offset(0, tailLength);

    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(center.dx - halfWidth, center.dy)
      ..lineTo(tail.dx, tail.dy)
      ..lineTo(center.dx + halfWidth, center.dy)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _NeedlePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _CenterDot extends StatelessWidget {
  final bool isFacing;

  const _CenterDot({required this.isFacing});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFacing ? AppColors.primary : AppColors.textMuted,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}
