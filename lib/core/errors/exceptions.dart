class AppException implements Exception {
  final String message;
  final int? statusCode;

  /// The backend's stable, machine-readable failure name — `INVALID_CREDENTIALS`,
  /// `TRIP_FULL`, `INSUFFICIENT_CREDIT`. This is the part a screen may branch
  /// on; [message] is the sentence, and the API is free to reword it.
  ///
  /// Null for a failure that never reached the server (no connection, timeout).
  final String? code;

  /// The `details` object some failures carry so a screen can act rather than
  /// merely display — `INSUFFICIENT_CREDIT` reports the exact shortfall.
  final Map<String, dynamic>? details;

  const AppException(
    this.message, {
    this.statusCode,
    this.code,
    this.details,
  });

  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException(
    super.message, {
    super.statusCode,
    super.code,
    super.details,
  });
}

class NetworkException extends AppException {
  const NetworkException([String message = 'เชื่อมต่ออินเทอร์เน็ตไม่ได้'])
      : super(message);
}

class CacheException extends AppException {
  const CacheException([String message = 'อ่านข้อมูลที่เก็บไว้ไม่ได้'])
      : super(message);
}

/// The session is gone and cannot be renewed. `DioClient` raises this only
/// after a refresh has been tried and refused, so anything catching it may
/// safely send the user back to the sign-in screen.
class UnauthorizedException extends AppException {
  const UnauthorizedException([
    String message = 'เซสชันหมดอายุ กรุณาเข้าสู่ระบบใหม่',
    String? code,
  ]) : super(message, statusCode: 401, code: code);
}

class TimeoutException extends AppException {
  const TimeoutException([String message = 'เซิร์ฟเวอร์ตอบกลับช้าเกินไป'])
      : super(message);
}
