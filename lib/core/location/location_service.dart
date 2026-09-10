import 'package:geolocator/geolocator.dart';

import '../constants/app_constants.dart';

/// Where the person asking for a feed is.
///
/// One coordinate, and it always answers. `GET /trips/nearby` refuses a request
/// without lat/lng, so every path that cannot produce a real fix — permission
/// denied, location services off, a cold lock that never arrives — falls back
/// to [AppConstants.fallbackLatitude] rather than surfacing a failure. A
/// requester who declined the permission still gets the campus feed, which is
/// the feed they were going to look at anyway; an error screen there would read
/// as "there are no trips" and be wrong.
///
/// [isPrecise] is how a screen tells the two apart when it matters — a distance
/// measured from a guess is a distance worth labelling.
class LocationService {
  LocationService();

  LatLng? _lastKnown;
  bool _lastWasPrecise = false;

  /// The most recent fix, or null before the first [current] call.
  LatLng? get lastKnown => _lastKnown;
  bool get isPrecise => _lastWasPrecise;

  static const LatLng fallback = LatLng(
    AppConstants.fallbackLatitude,
    AppConstants.fallbackLongitude,
  );

  /// The device's position, or the fallback.
  ///
  /// Never throws. [ask] is false on a refresh, where a permission dialog
  /// popping up over a list the user pulled is the wrong moment for it.
  Future<LatLng> current({bool ask = true}) async {
    final fix = await _resolve(ask: ask, accuracy: LocationAccuracy.medium);
    _lastKnown = fix ?? _lastKnown ?? fallback;
    _lastWasPrecise = fix != null;
    return _lastKnown!;
  }

  /// The device's own best fix, for the two calls the server actually checks
  /// a distance against — `start-purchasing` and `delivered` refuse outside a
  /// ~10 m radius (`TOO_FAR_FROM_STORE` / `TOO_FAR_FROM_DELIVERY_POINT`), which
  /// the feed's `medium` accuracy cannot reliably land inside.
  ///
  /// Returns null rather than a fallback: a milestone recorded from the
  /// campus coordinate because the device would not lock is a false claim
  /// about where the runner is, and the caller should refuse the action
  /// instead of sending it.
  Future<LatLng?> currentPrecise({bool ask = true}) => _resolve(
        ask: ask,
        accuracy: LocationAccuracy.best,
        timeout: AppConstants.preciseLocationTimeout,
      );

  Future<LatLng?> _resolve({
    required bool ask,
    required LocationAccuracy accuracy,
    Duration timeout = AppConstants.locationTimeout,
  }) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && ask) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: timeout,
        ),
      );
      return LatLng(
        position.latitude,
        position.longitude,
        accuracy: position.accuracy,
      );
    } catch (_) {
      // Includes the timeout, a platform channel that is not there, and a
      // permission the OS revoked between the check and the call. All of them
      // mean the same thing to the caller: no fix this time.
      return null;
    }
  }
}

/// A coordinate pair. Small enough to live beside the service that produces it.
class LatLng {
  const LatLng(this.latitude, this.longitude, {this.accuracy});

  final double latitude;
  final double longitude;

  /// The device's own error bar in metres, when the platform reports one —
  /// `ArrivalLocation.accuracy` on the wire.
  final double? accuracy;

  @override
  String toString() => '$latitude,$longitude';
}
