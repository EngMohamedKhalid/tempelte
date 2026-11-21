import 'package:geolocator/geolocator.dart';

/// Device location, asked for when a screen needs it.
///
/// The legacy app keeps the position in a **global mutable `Position?`** in
/// `main.dart`, requests it during startup before `runApp`, and imports that
/// global directly into a data-layer repository. Startup therefore waits on a
/// permission dialog, and any screen can silently read a stale fix.
///
/// Nothing is cached here: a position is asked for at the moment it is used.
class AppLocation {
  AppLocation._();

  /// Whether the user has granted location access.
  static Future<bool> hasPermission() async {
    final LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Asks for permission if it has not been refused for good.
  ///
  /// Returns false for [LocationPermission.deniedForever]: asking again does
  /// nothing, and the caller should fall back rather than loop.
  static Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// The current position, or null when it cannot be had.
  ///
  /// Null is an ordinary outcome — permission refused, location services off,
  /// no fix indoors — and callers show the list without distances rather than
  /// treating it as an error.
  static Future<Position?> current({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      if (!await requestPermission()) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(timeout);
    } catch (_) {
      // A refused permission, a disabled service or a slow fix are not errors
      // worth surfacing — the caller degrades to a list with no distances.
      return null;
    }
  }
}
