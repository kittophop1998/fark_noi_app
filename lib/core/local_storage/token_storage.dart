import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

/// Where the session lives.
///
/// The keystore rather than Hive, and that is the whole reason this exists as
/// its own service: the other three boxes hold things whose worst case is a
/// stale screen, and a refresh token's worst case is somebody else's account.
/// Reads are async here for the same reason — the platform keystore is a
/// channel call, not a map.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  /// Kept in memory as well so the request interceptor does not pay a platform
  /// round trip on every call. The keystore stays the source of truth: this is
  /// filled from it by [restore] at start-up and by every write below.
  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get hasSession => (_refreshToken ?? '').isNotEmpty;

  /// Reads the keystore into memory. Called once, from `main`, before the
  /// router decides whether to open the app or the sign-in screen.
  Future<void> restore() async {
    _accessToken = await _storage.read(key: AppConstants.accessTokenKey);
    _refreshToken = await _storage.read(key: AppConstants.refreshTokenKey);
  }

  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await _storage.write(key: AppConstants.accessTokenKey, value: accessToken);
    await _storage.write(
      key: AppConstants.refreshTokenKey,
      value: refreshToken,
    );
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }
}
