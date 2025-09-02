import 'package:logger/logger.dart';
import '../app/config.dart';

/// アプリケーションの中央ログサービス
/// 
/// 異なるレベルと一貫したフォーマットで構造化ログを提供する
class AppLogger {
  static Logger? _logger;
  
  /// アプリ設定に基づいてロガーを初期化
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
  
  /// トレースレベルメッセージをログ
  static void trace(String message, [Object? error, StackTrace? stackTrace]) {
    _logger?.t(message, error: error, stackTrace: stackTrace);
  }
  
  /// デバッグレベルメッセージをログ
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _logger?.d(message, error: error, stackTrace: stackTrace);
  }
  
  /// 情報レベルメッセージをログ
  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    _logger?.i(message, error: error, stackTrace: stackTrace);
  }
  
  /// 警告レベルメッセージをログ
  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _logger?.w(message, error: error, stackTrace: stackTrace);
  }
  
  /// エラーレベルメッセージをログ
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger?.e(message, error: error, stackTrace: stackTrace);
  }
  
  /// 致命的レベルメッセージをログ
  static void fatal(String message, [Object? error, StackTrace? stackTrace]) {
    _logger?.f(message, error: error, stackTrace: stackTrace);
  }
}