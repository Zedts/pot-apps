import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Service managing device GPS location and geofence calculations.
class LocationService {
  /// Checks if device GPS service is currently turned on.
  Future<bool> isServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  /// Checks if location permission is granted, requesting it if denied.
  Future<bool> checkAndRequestPermission() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    } catch (e) {
      debugPrint('[LocationService] Error checking/requesting permission: $e');
      return false;
    }
  }

  /// Fetches the user's current GPS position after verifying services and permissions.
  /// Returns `null` if location services are disabled or permissions are denied.
  Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[LocationService] Location services are disabled.');
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('[LocationService] Location permissions are denied.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('[LocationService] Location permissions are permanently denied.');
        return null;
      }

      // Try last known position for fast responsiveness
      Position? fallbackPosition;
      try {
        fallbackPosition = await Geolocator.getLastKnownPosition();
      } catch (_) {}

      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (err) {
        debugPrint('[LocationService] High accuracy fix failed, trying fallback: $err');
        if (fallbackPosition != null) {
          return fallbackPosition;
        }
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      debugPrint('[LocationService] Error fetching current position: $e');
      return null;
    }
  }

  /// Calculates geodesic distance between two coordinate pairs in meters.
  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Checks if current position falls within the stall's geofenced radius.
  bool isWithinRadius({
    required double userLatitude,
    required double userLongitude,
    required double stallLatitude,
    required double stallLongitude,
    required int radiusMeter,
  }) {
    final distance = calculateDistance(
      startLatitude: userLatitude,
      startLongitude: userLongitude,
      endLatitude: stallLatitude,
      endLongitude: stallLongitude,
    );
    return distance <= radiusMeter;
  }
}
