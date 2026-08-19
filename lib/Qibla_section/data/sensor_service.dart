import 'dart:async';
import 'dart:math' as math;

import 'package:sensors_plus/sensors_plus.dart';

/// A single, ready-to-consume compass reading.
class HeadingReading {
  final double headingDegrees;
  const HeadingReading(this.headingDegrees);
}

class SensorService {
  SensorService({
    double smoothingFactor = 0.18,
    double spikeThresholdDegrees = 35.0,
    double spikeDampingFactor = 0.25,
    Duration minEmitInterval = const Duration(milliseconds: 33),
  }) : _baseSmoothingFactor = smoothingFactor.clamp(0.01, 1.0),
       _spikeThresholdDegrees = spikeThresholdDegrees,
       _spikeDampingFactor = spikeDampingFactor.clamp(0.01, 1.0),
       _minEmitInterval = minEmitInterval;

  final double _baseSmoothingFactor;

  final double _spikeThresholdDegrees;

  final double _spikeDampingFactor;

  final Duration _minEmitInterval;

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<MagnetometerEvent>? _magnetSub;

  List<double>? _lastAccel;
  List<double>? _lastMagnet;

  double? _smoothedHeading;
  DateTime? _lastEmitTime;

  StreamController<HeadingReading>? _controller;

  bool _isActive = false;

  bool get isListening => _accelSub != null && _magnetSub != null;

  Stream<HeadingReading> headingStream() {
    _controller ??= StreamController<HeadingReading>.broadcast(
      onListen: _startListening,
      onCancel: _stopListening,
    );
    return _controller!.stream;
  }

  void _startListening() {
    if (_isActive) return;
    _isActive = true;

    _accelSub ??= accelerometerEventStream().listen((event) {
      _lastAccel = [event.x, event.y, event.z];
      _emitIfReady();
    });

    _magnetSub ??= magnetometerEventStream().listen((event) {
      _lastMagnet = [event.x, event.y, event.z];
      _emitIfReady();
    });
  }

  void _stopListening() {
    if (!_isActive) return;
    _isActive = false;

    _accelSub?.cancel();
    _magnetSub?.cancel();
    _accelSub = null;
    _magnetSub = null;
    _lastAccel = null;
    _lastMagnet = null;
    _smoothedHeading = null;
    _lastEmitTime = null;
  }

  void _emitIfReady() {
    final accel = _lastAccel;
    final magnet = _lastMagnet;
    if (accel == null || magnet == null) return;

    final rawHeading = _computeTiltCompensatedHeading(accel, magnet);
    if (rawHeading == null) return;

    final smoothed = _applyLowPassFilter(rawHeading);

    final now = DateTime.now();
    final lastEmit = _lastEmitTime;
    if (lastEmit != null && now.difference(lastEmit) < _minEmitInterval) {
      return;
    }
    _lastEmitTime = now;

    _controller?.add(HeadingReading(smoothed));
  }

  double? _computeTiltCompensatedHeading(
    List<double> accel,
    List<double> magnet,
  ) {
    final ax = accel[0], ay = accel[1], az = accel[2];
    final mx = magnet[0], my = magnet[1], mz = magnet[2];

    final normA = math.sqrt(ax * ax + ay * ay + az * az);
    if (normA == 0) return null;
    final nax = ax / normA, nay = ay / normA, naz = az / normA;

    // East vector = magnetic field x gravity.
    var ex = my * naz - mz * nay;
    var ey = mz * nax - mx * naz;
    var ez = mx * nay - my * nax;
    final normE = math.sqrt(ex * ex + ey * ey + ez * ez);
    if (normE == 0) return null;
    ex /= normE;
    ey /= normE;
    ez /= normE;

    // North vector = gravity x east (only the y-component is needed below).
    final ny = naz * ex - nax * ez;

    final heading = math.atan2(ey, ny) * (180 / math.pi);
    return _normalizeDegrees(heading);
  }

  double _applyLowPassFilter(double rawHeading) {
    final previous = _smoothedHeading;
    if (previous == null) {
      _smoothedHeading = rawHeading;
      return rawHeading;
    }

    var delta = rawHeading - previous;
    if (delta > 180) delta -= 360;
    if (delta < -180) delta += 360;

    final alpha = delta.abs() > _spikeThresholdDegrees
        ? _spikeDampingFactor
        : _baseSmoothingFactor;

    final filtered = _normalizeDegrees(previous + alpha * delta);
    _smoothedHeading = filtered;
    return filtered;
  }

  double _normalizeDegrees(double degrees) {
    var result = degrees % 360;
    if (result < 0) result += 360;
    return result;
  }

  /// Releases sensor subscriptions and closes the internal stream.
  Future<void> dispose() async {
    _stopListening();
    await _controller?.close();
    _controller = null;
  }
}
