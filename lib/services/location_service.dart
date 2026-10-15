import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../core/constants/app_constants.dart';

abstract class LocationService {
  Future<Position> getCurrentLocation();
  Stream<Position> locationStream();
}

/// Robust location service implementation with real GPS attempt and automatic fallback
class PartnerLocationService implements LocationService {
  @override
  Future<Position> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _fallbackPosition();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _fallbackPosition();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return _fallbackPosition();
      }

      return await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 4),
      );
    } catch (_) {
      return _fallbackPosition();
    }
  }

  @override
  Stream<Position> locationStream() {
    try {
      return Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).handleError((_) => _fallbackPosition());
    } catch (_) {
      return Stream.value(_fallbackPosition());
    }
  }

  Position _fallbackPosition() {
    return Position(
      latitude: AppConstants.defaultLatitude,
      longitude: AppConstants.defaultLongitude,
      timestamp: DateTime.now(),
      accuracy: 5.0,
      altitude: 10.0,
      altitudeAccuracy: 1.0,
      heading: 45.0,
      headingAccuracy: 1.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
  }
}
