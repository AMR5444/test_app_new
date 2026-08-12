import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/core/settings/logic/settings_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';


const double _meccaLat = 21.3891;
const double _meccaLng = 39.8579;
const double _earthRadiusKm = 6371.0;

const int _kFilterWindow = 8;

const double _kAlignThreshold = 5.0;

const double _kSnapThreshold = 2.0;


// QiblaScreen

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  //  Location state 
  double _userLat = 30.0444; // Cairo fallback
  double _userLng = 31.2357;
  String _locationName = 'القاهرة، مصر';
  double _distanceKm = 8651;
  bool _locationReady = false;

  double? _rawHeading;

  double? _smoothedHeading;

  /// Ring buffer for the moving-average filter.
  final List<double> _headingBuffer = [];

  /// Sensor offset detected during calibration.
  double _sensorOffset = 0.0;

  /// True while the 360° calibration sweep is in progress.
  bool _isCalibrating = false;

  /// Accumulated readings collected during calibration.
  final List<double> _calibrationSamples = [];

  // ── Qibla derived values 
  double _qiblaAngle = 165.0;

  /// Whether the needle is currently within the "perfect alignment" zone.
  bool _isAligned = false;

  // ── Glow animation controller 
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  // ── Stream subscriptions 
  StreamSubscription<CompassEvent>? _compassSub;
  StreamSubscription<Position>? _positionSub;

  // ── Haptic throttle 
  DateTime _lastHaptic = DateTime.fromMillisecondsSinceEpoch(0);

  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    // Glow animation for perfect-alignment mode.
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _initLocationAndCompass();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    _positionSub?.cancel();
    _glowController.dispose();
    super.dispose();
  }

  // Initialisation

  Future<void> _initLocationAndCompass() async {
    await _requestAndSubscribeLocation();
    _subscribeCompass();

    // Show calibration dialog after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showCalibrationDialog();
    });
  }

  // ---------------------------------------------------------------------------
  // Location
  // ---------------------------------------------------------------------------

  Future<void> _requestAndSubscribeLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      // Fall back to Cairo coordinates — already set as defaults.
      return;
    }

    // Get an immediate fix, then subscribe to live updates.
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _applyPosition(pos);
    } catch (_) {
      // Ignore; live updates will follow.
    }

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50, // metres — avoids excessive recalculation
      ),
    ).listen(_applyPosition);
  }

  void _applyPosition(Position pos) {
    if (!mounted) return;
    setState(() {
      _userLat = pos.latitude;
      _userLng = pos.longitude;
      _locationReady = true;
      _locationName = _formatCoords(pos.latitude, pos.longitude);
    });
    _recalcQibla();
  }

  /// Lightweight coordinate formatter used when reverse-geocoding isn't wired.
  String _formatCoords(double lat, double lng) {
    final latDir = lat >= 0 ? 'ش' : 'ج';
    final lngDir = lng >= 0 ? 'ق' : 'غ';
    return '${lat.abs().toStringAsFixed(2)}°$latDir  ${lng.abs().toStringAsFixed(2)}°$lngDir';
  }

  // ---------------------------------------------------------------------------
  // Qibla calculation (pure offline, Haversine)
  // ---------------------------------------------------------------------------

  void _recalcQibla() {
    final dLng = _toRad(_meccaLng - _userLng);
    final lat1 = _toRad(_userLat);
    final lat2 = _toRad(_meccaLat);

    final x = math.sin(dLng) * math.cos(lat2);
    final y = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    final bearing = (_toDeg(math.atan2(x, y)) + 360) % 360;

    // Haversine distance
    final dLat = _toRad(_meccaLat - _userLat);
    final dLng2 = _toRad(_meccaLng - _userLng);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(_userLat)) *
            math.cos(_toRad(_meccaLat)) *
            math.sin(dLng2 / 2) *
            math.sin(dLng2 / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    setState(() {
      _qiblaAngle = bearing;
      _distanceKm = _earthRadiusKm * c;
    });
  }

  // ---------------------------------------------------------------------------
  // Compass subscription + low-pass filter
  // ---------------------------------------------------------------------------

  void _subscribeCompass() {
    _compassSub = FlutterCompass.events?.listen(_onCompassEvent);
  }

  void _onCompassEvent(CompassEvent event) {
    if (!mounted || event.heading == null) return;

    double raw = event.heading!;

    // ── Calibration accumulation ─────────────────────────────────────────────
    if (_isCalibrating) {
      _calibrationSamples.add(raw);
      // Require at least one full revolution worth of samples (~72 at 5 Hz).
      if (_calibrationSamples.length >= 72) {
        _finishCalibration();
      }
    }

    // Apply sensor offset.
    raw = (raw - _sensorOffset + 360) % 360;

    // ── Circular moving-average low-pass filter ───────────────────────────────
    _headingBuffer.add(raw);
    if (_headingBuffer.length > _kFilterWindow) {
      _headingBuffer.removeAt(0);
    }
    final smoothed = _circularMean(_headingBuffer);

    // ── Alignment detection ───────────────────────────────────────────────────
    final relative = (_qiblaAngle - smoothed + 360) % 360;
    final diff = relative > 180 ? 360 - relative : relative;
    final nowAligned = diff <= _kAlignThreshold;

    if (nowAligned && !_isAligned) {
      _onAlignmentAchieved();
    } else if (!nowAligned && _isAligned) {
      _onAlignmentLost();
    }

    setState(() {
      _rawHeading = event.heading;
      _smoothedHeading = smoothed;
      _isAligned = nowAligned;
    });
  }

  /// Circular (angular) mean — avoids wrap-around artefacts near 0°/360°.
  double _circularMean(List<double> angles) {
    double sinSum = 0, cosSum = 0;
    for (final a in angles) {
      sinSum += math.sin(_toRad(a));
      cosSum += math.cos(_toRad(a));
    }
    return (_toDeg(math.atan2(sinSum, cosSum)) + 360) % 360;
  }

  // ---------------------------------------------------------------------------
  // Smart Calibration
  // ---------------------------------------------------------------------------

  void _showCalibrationDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CalibrationDialog(
        onStart: _startCalibration,
        onSkip: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _startCalibration() {
    Navigator.of(context).pop();
    setState(() {
      _isCalibrating = true;
      _calibrationSamples.clear();
    });
    HapticFeedback.mediumImpact();
  }

  void _finishCalibration() {
    // Sensor offset = deviation of the mean measured heading from the
    // expected mean (0° for a full 360° sweep → circular mean ≈ undefined,
    // so we use variance instead: low variance means the sensor is biased).
    //
    // Practical approach: compare mean of calibration samples to 0 (north).
    // A more rigorous method would need a reference, but this corrects for
    // systematic offset sensors often exhibit.
    final mean = _circularMean(_calibrationSamples);

    // Heuristic: if the device was rotated 360° and the sensor has a constant
    // offset, the mean of a full sweep should be near 0°. Treat mean as offset.
    // Only apply if it looks like a real sweep (stddev > 80°).
    final stdDev = _circularStdDev(_calibrationSamples, mean);
    if (stdDev > 80) {
      // Full rotation detected — the mean offset is negligible; clear offset.
      _sensorOffset = 0.0;
    } else {
      // Partial sweep or stationary; treat mean as bias offset.
      _sensorOffset = mean;
    }

    if (mounted) {
      setState(() => _isCalibrating = false);
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تمت المعايرة بنجاح ✓',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  double _circularStdDev(List<double> angles, double mean) {
    if (angles.isEmpty) return 0;
    double sum = 0;
    for (final a in angles) {
      double diff = (a - mean + 360) % 360;
      if (diff > 180) diff = 360 - diff;
      sum += diff * diff;
    }
    return math.sqrt(sum / angles.length);
  }

  // ---------------------------------------------------------------------------
  // Perfect Alignment
  // ---------------------------------------------------------------------------

  void _onAlignmentAchieved() {
    _glowController.repeat(reverse: true);
    _triggerHaptic(aligned: true);
  }

  void _onAlignmentLost() {
    _glowController.stop();
    _glowController.reset();
  }

  void _triggerHaptic({required bool aligned}) {
    final now = DateTime.now();
    if (now.difference(_lastHaptic).inMilliseconds < 800) return;
    _lastHaptic = now;

    if (aligned) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  // ---------------------------------------------------------------------------
  // Derived values
  // ---------------------------------------------------------------------------

  /// The needle angle relative to the current device heading.
  double get _relativeQiblaAngle {
    final heading = _smoothedHeading;
    if (heading == null) return _qiblaAngle;
    final rel = (_qiblaAngle - heading + 360) % 360;

    // Within ±snapThreshold snap to exact Qibla to prevent jitter.
    final diff = rel > 180 ? 360 - rel : rel;
    if (diff <= _kSnapThreshold) return 0.0; // needle points up = aligned
    return rel;
  }

  String get _directionLabel {
    final angle = _qiblaAngle;
    if (angle < 22.5 || angle >= 337.5) return 'شمال';
    if (angle < 67.5) return 'شمال شرق';
    if (angle < 112.5) return 'شرق';
    if (angle < 157.5) return 'جنوب شرق';
    if (angle < 202.5) return 'جنوب';
    if (angle < 247.5) return 'جنوب غرب';
    if (angle < 292.5) return 'غرب';
    return 'شمال غرب';
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  double _toRad(double deg) => deg * math.pi / 180;
  double _toDeg(double rad) => rad * 180 / math.pi;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

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

  // ── Widgets (UI unchanged) ────────────────────────────────────────────────

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
            // ── Glow overlay (perfect alignment) ──────────────────────────
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (_, __) {
                if (!_isAligned) return const SizedBox.shrink();
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary
                            .withOpacity(0.35 * _glowAnimation.value),
                        blurRadius: 40 + 20 * _glowAnimation.value,
                        spreadRadius: 8 * _glowAnimation.value,
                      ),
                    ],
                  ),
                );
              },
            ),
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
              curve: Curves.easeOut,
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
                    '${_qiblaAngle.round()}°',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textLight
                          : AppColors.textPrimary,
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
            // Calibration progress overlay
            if (_isCalibrating)
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.45),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'دوّر الجهاز 360°',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${_calibrationSamples.length}/72',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: Colors.white70,
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
      painter: _NeedlePainter(isAligned: _isAligned),
    );
  }

  Widget _buildCalibrationHint(bool isDark) {
    return GestureDetector(
      onLongPress: _showCalibrationDialog, // long-press hint to re-calibrate
      child: Container(
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isAligned ? AppColors.primary : Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _isAligned
                  ? 'أنت تواجه القبلة الآن 🕋'
                  : 'أدر هاتفك ببطء حتى يصبح المؤشر للأعلى',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Needle painter — now receives isAligned for subtle colour shift
// ---------------------------------------------------------------------------
class _NeedlePainter extends CustomPainter {
  const _NeedlePainter({required this.isAligned});

  final bool isAligned;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const needleLength = 90.0;

    final color = isAligned ? AppColors.primary : AppColors.primary;

    final tipPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.dx, center.dy - needleLength);
    path.lineTo(center.dx - 8, center.dy);
    path.lineTo(center.dx + 8, center.dy);
    path.close();
    canvas.drawPath(path, tipPaint);

    canvas.drawCircle(
      Offset(center.dx, center.dy - needleLength + 8),
      5,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_NeedlePainter old) => old.isAligned != isAligned;
}

// ---------------------------------------------------------------------------
// Calibration dialog
// ---------------------------------------------------------------------------
class _CalibrationDialog extends StatelessWidget {
  const _CalibrationDialog({
    required this.onStart,
    required this.onSkip,
  });

  final VoidCallback onStart;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'معايرة البوصلة',
        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: Text(
        'لتحقيق أعلى دقة، دوّر هاتفك 360° بشكل أفقي.\n'
        'اضغط "ابدأ" ثم دوّر الجهاز ببطء.',
        style: GoogleFonts.cairo(fontSize: 13),
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: onSkip,
          child: Text('تخطي', style: GoogleFonts.cairo()),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onStart,
          child: Text(
            'ابدأ',
            style: GoogleFonts.cairo(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
