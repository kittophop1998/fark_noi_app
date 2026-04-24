class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => 'AppException: $message (status: $statusCode)';
}

class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

class NetworkException extends AppException {
  const NetworkException([String message = 'No internet connection'])
      : super(message);
}

class CacheException extends AppException {
  const CacheException([String message = 'Cache error']) : super(message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'Unauthorized'])
      : super(message, statusCode: 401);
}

class TimeoutException extends AppException {
  const TimeoutException([String message = 'Request timeout']) : super(message);
}
