import 'package:logger/logger.dart';

final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

class Log {
  Log._();

  static void d(String message, [dynamic error, StackTrace? st]) =>
      appLogger.d(message, error: error, stackTrace: st);

  static void i(String message, [dynamic error, StackTrace? st]) =>
      appLogger.i(message, error: error, stackTrace: st);

  static void w(String message, [dynamic error, StackTrace? st]) =>
      appLogger.w(message, error: error, stackTrace: st);

  static void e(String message, [dynamic error, StackTrace? st]) =>
      appLogger.e(message, error: error, stackTrace: st);
}
