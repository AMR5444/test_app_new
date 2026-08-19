import 'dart:math' as math;

class QiblaCalculation {
  final double qiblaBearingDegrees;

  final double distanceToMeccaKm;

  final double relativeAngleDegrees;

  final bool isFacingQibla;

  const QiblaCalculation({
    required this.qiblaBearingDegrees,
    required this.distanceToMeccaKm,
    required this.relativeAngleDegrees,
    required this.isFacingQibla,
  });
}

class QiblaService {
  const QiblaService({this.alignmentThresholdDegrees = 5.0});

  /// Latitude/longitude of the Kaaba, Mecca.
  static const double meccaLatitude = 21.4225;
  static const double meccaLongitude = 39.8262;

  static const double _earthRadiusKm = 6371.0;

  /// [QiblaCalculation.isFacingQibla] to be true.
  final double alignmentThresholdDegrees;

  QiblaCalculation calculate({
    required double userLatitude,
    required double userLongitude,
    required double deviceHeadingDegrees,
  }) {
    _validateCoordinate(userLatitude, userLongitude);
    _validateFinite(deviceHeadingDegrees, 'deviceHeadingDegrees');

    final bearing = qiblaBearing(userLatitude, userLongitude);
    final distance = distanceToMeccaKm(userLatitude, userLongitude);
    final normalizedHeading = _normalizeDegrees(deviceHeadingDegrees);
    final relativeAngle = shortestAngleDifference(bearing, normalizedHeading);

    return QiblaCalculation(
      qiblaBearingDegrees: bearing,
      distanceToMeccaKm: distance,
      relativeAngleDegrees: relativeAngle,
      isFacingQibla: relativeAngle.abs() <= alignmentThresholdDegrees,
    );
  }

  /// Compass bearing (0-360°, clockwise from North) from the given user
  double qiblaBearing(double userLatitude, double userLongitude) {
    _validateCoordinate(userLatitude, userLongitude);

    final lat1 = _degToRad(userLatitude);
    final lat2 = _degToRad(meccaLatitude);
    final deltaLon = _degToRad(meccaLongitude - userLongitude);

    final y = math.sin(deltaLon) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLon);

    final bearingRad = math.atan2(y, x);
    return _normalizeDegrees(_radToDeg(bearingRad));
  }

  /// Great-circle distance (Haversine) from the given user location to the
  /// Kaaba, in kilometers.
  double distanceToMeccaKm(double userLatitude, double userLongitude) {
    _validateCoordinate(userLatitude, userLongitude);

    final lat1 = _degToRad(userLatitude);
    final lat2 = _degToRad(meccaLatitude);
    final deltaLat = _degToRad(meccaLatitude - userLatitude);
    final deltaLon = _degToRad(meccaLongitude - userLongitude);

    final a =
        math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(deltaLon / 2) *
            math.sin(deltaLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return _roundTo(_earthRadiusKm * c, 2);
  }

  double shortestAngleDifference(double target, double current) {
    _validateFinite(target, 'target');
    _validateFinite(current, 'current');

    var diff = (_normalizeDegrees(target) - _normalizeDegrees(current)) % 360;
    if (diff > 180) diff -= 360;
    if (diff <= -180) diff += 360;
    return _roundTo(diff, 2);
  }

  double _normalizeDegrees(double degrees) {
    var result = degrees % 360;
    if (result < 0) result += 360;
    return _roundTo(result, 2);
  }

  double _degToRad(double degrees) => degrees * math.pi / 180.0;

  double _radToDeg(double radians) => radians * 180.0 / math.pi;

  double _roundTo(double value, int decimals) {
    final factor = math.pow(10, decimals);
    return (value * factor).round() / factor;
  }

  void _validateFinite(double value, String name) {
    if (value.isNaN || value.isInfinite) {
      throw ArgumentError.value(value, name, 'Must be a finite number');
    }
  }

  void _validateCoordinate(double latitude, double longitude) {
    _validateFinite(latitude, 'latitude');
    _validateFinite(longitude, 'longitude');

    if (latitude < -90 || latitude > 90) {
      throw ArgumentError.value(
        latitude,
        'latitude',
        'Must be within [-90, 90]',
      );
    }
    if (longitude < -180 || longitude > 180) {
      throw ArgumentError.value(
        longitude,
        'longitude',
        'Must be within [-180, 180]',
      );
    }
  }
}
