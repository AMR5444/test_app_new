import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:test_app_new/Qibla_section/data/location_service.dart';
import 'package:test_app_new/Qibla_section/data/qibla_service.dart';
import 'package:test_app_new/Qibla_section/data/sensor_service.dart';
import 'package:test_app_new/Qibla_section/logic/qibla_state.dart';

export 'qibla_state.dart';

class QiblaCubit extends Cubit<QiblaState> {
  QiblaCubit({
    LocationService? locationService,
    SensorService? sensorService,
    QiblaService? qiblaService,
  }) : _locationService = locationService ?? LocationService(),
       _sensorService = sensorService ?? SensorService(),
       _qiblaService = qiblaService ?? const QiblaService(),
       super(const QiblaState()) {
    Future.microtask(_init);
  }

  final LocationService _locationService;
  final SensorService _sensorService;
  final QiblaService _qiblaService;

  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<HeadingReading>? _headingSubscription;

  bool _isInitializing = false;

  Future<void> _init() async {
    if (_isInitializing) return;
    _isInitializing = true;

    await _positionSubscription?.cancel();
    await _headingSubscription?.cancel();
    _positionSubscription = null;
    _headingSubscription = null;

    emit(state.copyWith(status: QiblaStatus.loading, clearErrorMessage: true));

    try {
      final position = await _locationService.getCurrentPosition();
      if (isClosed) return;
      _applyPosition(position);

      _positionSubscription = _locationService.watchPosition().listen(
        _applyPosition,
        onError: _handleError,
      );

      _headingSubscription = _sensorService.headingStream().listen(
        _applyHeading,
        onError: _handleError,
      );
    } on LocationException catch (e) {
      _handleError(e);
    } catch (e) {
      _handleError(e);
    } finally {
      _isInitializing = false;
    }
  }

  void _applyPosition(Position position) {
    if (isClosed) return;

    final bearing = _qiblaService.qiblaBearing(
      position.latitude,
      position.longitude,
    );
    final distance = _qiblaService.distanceToMeccaKm(
      position.latitude,
      position.longitude,
    );
    final heading = state.heading;

    if (heading == null) {
      emit(
        state.copyWith(
          status: QiblaStatus.success,
          latitude: position.latitude,
          longitude: position.longitude,
          qiblaBearing: bearing,
          distanceKm: distance,
          clearErrorMessage: true,
        ),
      );
      return;
    }

    final relativeAngle = _qiblaService.shortestAngleDifference(
      bearing,
      heading,
    );

    emit(
      state.copyWith(
        status: QiblaStatus.success,
        latitude: position.latitude,
        longitude: position.longitude,
        qiblaBearing: bearing,
        distanceKm: distance,
        relativeAngle: relativeAngle,
        isFacingQibla:
            relativeAngle.abs() <= _qiblaService.alignmentThresholdDegrees,
        clearErrorMessage: true,
      ),
    );
  }

  void _applyHeading(HeadingReading reading) {
    if (isClosed) return;

    final heading = reading.headingDegrees;
    final bearing = state.qiblaBearing;

    if (bearing == null) {
      emit(state.copyWith(heading: heading));
      return;
    }

    final relativeAngle = _qiblaService.shortestAngleDifference(
      bearing,
      heading,
    );

    emit(
      state.copyWith(
        status: QiblaStatus.success,
        heading: heading,
        relativeAngle: relativeAngle,
        isFacingQibla:
            relativeAngle.abs() <= _qiblaService.alignmentThresholdDegrees,
      ),
    );
  }

  void _handleError(Object error) {
    if (isClosed) return;

    final message = error is LocationException
        ? error.message
        : 'حدث خطأ غير متوقع أثناء تحديد اتجاه القبلة';

    emit(state.copyWith(status: QiblaStatus.error, errorMessage: message));
  }

  Future<void> retry() => _init();

  @override
  Future<void> close() async {
    await _positionSubscription?.cancel();
    await _headingSubscription?.cancel();
    await _sensorService.dispose();
    return super.close();
  }
}
