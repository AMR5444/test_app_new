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
