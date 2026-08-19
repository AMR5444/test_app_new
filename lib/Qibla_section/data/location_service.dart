import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentPosition() async {
    await _ensureServiceEnabled();
    await _ensurePermissionGranted();

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      throw const LocationException('تعذر الحصول على الموقع الحالي');
    }
  }

  Stream<Position> watchPosition({int distanceFilterMeters = 10}) async* {
    await _ensureServiceEnabled();
    await _ensurePermissionGranted();

    yield* Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterMeters,
      ),
    );
  }

  /// Reverse geocodes [latitude]/[longitude] into a "City, Country" label.
  /// Returns null on any failure so the caller can fall back gracefully.
  Future<String?> getPlaceName(double latitude, double longitude) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) return null;

      final placemark = placemarks.first;
      final city = _firstNonEmpty([
        placemark.locality,
        placemark.subAdministrativeArea,
        placemark.administrativeArea,
      ]);
      final country = _firstNonEmpty([placemark.country]);

      if (city != null && country != null) return '$city, $country';
      return city ?? country;
    } catch (_) {
      return null;
    }
  }

  String formatCoordinatesFallback(double latitude, double longitude) {
    final latDir = latitude >= 0 ? 'شمال' : 'جنوب';
    final lngDir = longitude >= 0 ? 'شرق' : 'غرب';
    return '${latitude.abs().toStringAsFixed(2)}° $latDir، '
        '${longitude.abs().toStringAsFixed(2)}° $lngDir';
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    }
    return null;
  }

  Future<void> _ensureServiceEnabled() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw const LocationException('خدمة الموقع غير مفعلة');
    }
  }

  Future<void> _ensurePermissionGranted() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationException('تم رفض إذن الوصول إلى الموقع');
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'تم رفض إذن الموقع بشكل دائم، يرجى تفعيله من الإعدادات',
      );
    }
  }
}

class LocationException implements Exception {
  final String message;

  const LocationException(this.message);

  @override
  String toString() => message;
}
