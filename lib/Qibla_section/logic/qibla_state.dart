import 'package:equatable/equatable.dart';

/// Lifecycle status of [QiblaState].
enum QiblaStatus { initial, loading, success, error }

class QiblaState extends Equatable {
  final QiblaStatus status;

  final double? latitude;

  final double? longitude;

  final double? heading;

  final double? qiblaBearing;

  final double? relativeAngle;

  final double? distanceKm;

  final bool isFacingQibla;

  final String? errorMessage;

  const QiblaState({
    this.status = QiblaStatus.initial,
    this.latitude,
    this.longitude,
    this.heading,
    this.qiblaBearing,
    this.relativeAngle,
    this.distanceKm,
    this.isFacingQibla = false,
    this.errorMessage,
  });

  QiblaState copyWith({
    QiblaStatus? status,
    double? latitude,
    double? longitude,
    double? heading,
    double? qiblaBearing,
    double? relativeAngle,
    double? distanceKm,
    bool? isFacingQibla,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return QiblaState(
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
      qiblaBearing: qiblaBearing ?? this.qiblaBearing,
      relativeAngle: relativeAngle ?? this.relativeAngle,
      distanceKm: distanceKm ?? this.distanceKm,
      isFacingQibla: isFacingQibla ?? this.isFacingQibla,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    latitude,
    longitude,
    heading,
    qiblaBearing,
    relativeAngle,
    distanceKm,
    isFacingQibla,
    errorMessage,
  ];
}
