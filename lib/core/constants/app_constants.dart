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

  // Animation
  static const shortAnimation = Duration(milliseconds: 200);
  static const mediumAnimation = Duration(milliseconds: 400);
  static const longAnimation = Duration(milliseconds: 600);
}
