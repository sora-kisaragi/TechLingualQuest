import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application environment configuration
/// 
/// Manages different environments (dev, staging, prod) and their configurations
class AppConfig {
  static AppEnvironment _currentEnvironment = AppEnvironment.dev;
  
  /// Initialize environment configuration
  /// Should be called in main() before runApp()
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
    _setEnvironmentFromConfig();
  }
  
  static void _setEnvironmentFromConfig() {
    final envString = dotenv.env['APP_ENV'] ?? 'dev';
    switch (envString.toLowerCase()) {
      case 'prod':
      case 'production':
        _currentEnvironment = AppEnvironment.prod;
        break;
      case 'staging':
        _currentEnvironment = AppEnvironment.staging;
        break;
      case 'dev':
      case 'development':
      default:
        _currentEnvironment = AppEnvironment.dev;
        break;
    }
  }
  
  /// Current environment
  static AppEnvironment get environment => _currentEnvironment;
  
  /// Database name for current environment
  static String get databaseName => 
      dotenv.env['DATABASE_NAME'] ?? 'tech_lingual_quest.db';
  
  /// API base URL for current environment
  static String get apiBaseUrl => 
      dotenv.env['API_BASE_URL'] ?? 'https://api.example.com';
  
  /// API key for current environment
  static String get apiKey => 
      dotenv.env['API_KEY'] ?? '';
  
  /// Log level for current environment
  static String get logLevel => 
      dotenv.env['LOG_LEVEL'] ?? 'info';
  
  /// Whether analytics is enabled
  static bool get isAnalyticsEnabled => 
      dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';
  
  /// Whether crashlytics is enabled
  static bool get isCrashlyticsEnabled => 
      dotenv.env['ENABLE_CRASHLYTICS']?.toLowerCase() == 'true';
  
  /// Whether app is in development mode
  static bool get isDevelopment => _currentEnvironment == AppEnvironment.dev;
  
  /// Whether app is in staging mode
  static bool get isStaging => _currentEnvironment == AppEnvironment.staging;
  
  /// Whether app is in production mode
  static bool get isProduction => _currentEnvironment == AppEnvironment.prod;
}

/// Application environments
enum AppEnvironment {
  dev,
  staging,
  prod,
}