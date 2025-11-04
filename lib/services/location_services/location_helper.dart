import 'dart:async';

import 'package:geolocator/geolocator.dart';

import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Future<bool> ensurePermissionAndService() async {
    // Step 1: Check if location service is enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }

    // Step 2: Check permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('❌ Location permission denied.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Ask user to enable manually
      print('⚠️ Permission permanently denied. Opening app settings...');
      await Geolocator.requestPermission();

      return false;
    }

    return true;
  }

  static Future<Stream<Position>?> getPositionStream(
      {int distanceFilter = 0}) async {
    if (!await ensurePermissionAndService()) {
      return null;
    }

    // Android-specific settings for Foreground Service
    var locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0, // Let the background service define the filter
      intervalDuration: Duration(seconds: 5),
      foregroundNotificationConfig: ForegroundNotificationConfig(
        notificationText: "Tracking your location...",
        notificationTitle: "Location Service Active",
        enableWakeLock: true,
      ),
    );

    print('📡 Creating position stream...');
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  // --- Foreground Tracking Methods (if needed in your main UI) ---

  static Future<Position?> getCurrentLocation() async {
    try {
      if (!await ensurePermissionAndService()) {
        throw Exception('Permission or service not enabled');
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      return pos;
    } catch (e) {
      print('LocationHelper.getCurrentLocation error: $e');
      return null;
    }
  }
}
