class AppConstants {
  AppConstants._();

  // API
  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://farknoi-backend.onrender.com',
  );
  static const apiVersion = '/api/v1';
  static const connectTimeout = Duration(seconds: 30);
  static const receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const accessTokenKey = 'access_token';
  static const refreshTokenKey = 'refresh_token';
  static const userDataKey = 'user_data';
  static const themeModeKey = 'theme_mode';

  // Pagination
  static const defaultPageSize = 20;
  static const defaultPage = 1;

  // Location
  //
  // `GET /trips/nearby` takes a coordinate and has no default of its own — the
  // 7 km feed is measured from wherever the caller says they are. These are
  // what the app asks for when the device will not say: Thammasat Rangsit,
  // where the product's first users are. A feed drawn from here is still a real
  // feed, which is the point — an empty screen and a permission prompt would
  // read as "there are no trips".
  static const fallbackLatitude = 14.0705;
  static const fallbackLongitude = 100.6060;

  /// How long a fix may take before the fallback is used instead. A discovery
  /// feed that waits on a cold GPS lock is a discovery feed nobody sees.
  static const locationTimeout = Duration(seconds: 8);

  // Animation
  static const shortAnimation = Duration(milliseconds: 200);
  static const mediumAnimation = Duration(milliseconds: 400);
  static const longAnimation = Duration(milliseconds: 600);
}
