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
    final fix = await _resolve(ask: ask);
    _lastKnown = fix ?? _lastKnown ?? fallback;
    _lastWasPrecise = fix != null;
    return _lastKnown!;
  }

  Future<LatLng?> _resolve({required bool ask}) async {
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

      // `medium` rather than `best`: the feed is a 7 km circle, so metres of
      // accuracy buy nothing and cost a much longer lock.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: AppConstants.locationTimeout,
        ),
      );
      return LatLng(position.latitude, position.longitude);
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
  const LatLng(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  @override
  String toString() => '$latitude,$longitude';
}
