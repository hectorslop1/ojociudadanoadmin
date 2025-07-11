import 'package:logger/logger.dart';

/// Utility class for logging throughout the application
class LoggerUtils {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Log debug message
  static void d(String message) {
    _logger.d(message);
  }

  /// Log info message
  static void i(String message) {
    _logger.i(message);
  }

  /// Log warning message
  static void w(String message) {
    _logger.w(message);
  }

  /// Log error message
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
