import 'package:logger/logger.dart';
import '../app/config.dart';

/// Centralized logging service for the application
/// 
/// Provides structured logging with different levels and consistent formatting
class AppLogger {
  static Logger? _logger;
  
  /// Initialize the logger based on app configuration
  static void initialize() {
    final level = _getLogLevelFromConfig();
    
    _logger = Logger(
      level: level,
      printer: AppConfig.isDevelopment 
          ? PrettyPrinter(
              methodCount: 2,
              errorMethodCount: 8,
              lineLength: 120,
              colors: true,
              printEmojis: true,
              printTime: true,
            )
          : SimplePrinter(),
    );
  }
  
  static Level _getLogLevelFromConfig() {
    switch (AppConfig.logLevel.toLowerCase()) {
      case 'trace':
        return Level.trace;
      case 'debug':
        return Level.debug;
      case 'info':
        return Level.info;
      case 'warning':
      case 'warn':
        return Level.warning;
      case 'error':
        return Level.error;
      case 'fatal':
        return Level.fatal;
      default:
        return Level.info;
    }
  }
  
  /// Log trace level message
  static void trace(String message, [Object? error, StackTrace? stackTrace]) {
    _logger?.t(message, error: error, stackTrace: stackTrace);
  }
  
  /// Log debug level message
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _logger?.d(message, error: error, stackTrace: stackTrace);
  }
  
  /// Log info level message
  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    _logger?.i(message, error: error, stackTrace: stackTrace);
  }
  
  /// Log warning level message
  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _logger?.w(message, error: error, stackTrace: stackTrace);
  }
  
  /// Log error level message
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger?.e(message, error: error, stackTrace: stackTrace);
  }
  
  /// Log fatal level message
  static void fatal(String message, [Object? error, StackTrace? stackTrace]) {
    _logger?.f(message, error: error, stackTrace: stackTrace);
  }
}