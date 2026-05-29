import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/core/settings/settings_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _heading;
  double? _qiblaAngle;
  String _locationName = 'القاهرة، مصر';
  double _distanceKm = 8651;
  bool _hasPermission = false;

  // Cairo coordinates (default)
  static const double _userLat = 30.0444;
  static const double _userLng = 31.2357;
  // Mecca coordinates
  static const double _meccaLat = 21.3891;
  static const double _meccaLng = 39.8579;

  @override
  void initState() {
    super.initState();
    _calculateQiblaAngle();
    _requestLocationPermission();
    FlutterCompass.events?.listen((event) {
      if (mounted) {
        setState(() {
          _heading = event.heading;
        });
      }
    });
  }

  void _calculateQiblaAngle() {
    final dLng = _toRad(_meccaLng - _userLng);
    final lat1 = _toRad(_userLat);
    final lat2 = _toRad(_meccaLat);
    final x = math.sin(dLng) * math.cos(lat2);
    final y = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    final angle = math.atan2(x, y);
    setState(() {
      _qiblaAngle = (_toDeg(angle) + 360) % 360;
    });

    // Calculate distance
    final R = 6371.0;
    final dLat = _toRad(_meccaLat - _userLat);
    final dLng2 = _toRad(_meccaLng - _userLng);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(_userLat)) *
            math.cos(_toRad(_meccaLat)) *
            math.sin(dLng2 / 2) *
            math.sin(dLng2 / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    setState(() {
      _distanceKm = R * c;
    });
  }

  Future<void> _requestLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    if (mounted) {
      setState(() => _hasPermission = true);
    }
  }

  double _toRad(double deg) => deg * math.pi / 180;
  double _toDeg(double rad) => rad * 180 / math.pi;

  double get _relativeQiblaAngle {
    if (_heading == null || _qiblaAngle == null) return _qiblaAngle ?? 165;
    return (_qiblaAngle! - _heading! + 360) % 360;
  }

  String get _directionLabel {
    final angle = _qiblaAngle ?? 165;
    if (angle < 22.5 || angle >= 337.5) return 'شمال';
    if (angle < 67.5) return 'شمال شرق';
    if (angle < 112.5) return 'شرق';
    if (angle < 157.5) return 'جنوب شرق';
    if (angle < 202.5) return 'جنوب';
    if (angle < 247.5) return 'جنوب غرب';
    if (angle < 292.5) return 'غرب';
    return 'شمال غرب';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final isDark = settings.isDarkMode;
        return Scaffold(
          backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(isDark),
                const SizedBox(height: 8),
                _buildLocationInfo(isDark),
                const SizedBox(height: 32),
                Expanded(child: _buildCompass(isDark)),
                _buildCalibrationHint(isDark),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Text(
        'اتجاه القبلة',
        style: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildLocationInfo(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${_distanceKm.round()} كم',
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.circle, size: 4, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          _locationName,
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
      ],
    );
  }

  Widget _buildCompass(bool isDark) {
    return Center(
      child: SizedBox(
        width: 280,
        height: 280,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? AppColors.bgCardDark2
                      : Colors.grey.shade200,
                  width: 2,
                ),
              ),
            ),
            // Inner ring
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? AppColors.bgCardDark2
                      : Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            // Cardinal directions
            ..._buildCardinals(isDark),
            // Animated needle
            AnimatedRotation(
              turns: _relativeQiblaAngle / 360,
              duration: const Duration(milliseconds: 300),
              child: _buildNeedle(),
            ),
            // Center circle with angle
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.bgCardDark : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(_qiblaAngle ?? 165).round()}°',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    _directionLabel,
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCardinals(bool isDark) {
    final cardinals = {'ش': 270, 'ق': 0, 'ج': 90, 'غ': 180};
    return cardinals.entries.map((e) {
      final angle = e.value * math.pi / 180;
      const r = 120.0;
      final x = r * math.sin(angle);
      final y = -r * math.cos(angle);
      return Transform.translate(
        offset: Offset(x, y),
        child: Text(
          e.key,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textSecondary : Colors.grey.shade500,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildNeedle() {
    return CustomPaint(
      size: const Size(280, 280),
      painter: _NeedlePainter(),
    );
  }

  Widget _buildCalibrationHint(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'أدر هاتفك ببطء حتى يصبح المؤشر للأعلى',
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const needleLength = 90.0;

    // Needle tip (upward)
    final tipPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.dx, center.dy - needleLength);
    path.lineTo(center.dx - 8, center.dy);
    path.lineTo(center.dx + 8, center.dy);
    path.close();
    canvas.drawPath(path, tipPaint);

    // Needle ball
    canvas.drawCircle(
      Offset(center.dx, center.dy - needleLength + 8),
      5,
      Paint()..color = AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(_NeedlePainter oldDelegate) => false;
}
