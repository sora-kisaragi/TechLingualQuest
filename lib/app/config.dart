import 'package:flutter_dotenv/flutter_dotenv.dart';

/// アプリケーション環境設定
/// 
/// 異なる環境（dev、staging、prod）とその設定を管理する
class AppConfig {
  static AppEnvironment _currentEnvironment = AppEnvironment.dev;
  
  /// 環境設定を初期化
  /// main()でrunApp()の前に呼び出す必要がある
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
  
  /// 現在の環境
  static AppEnvironment get environment => _currentEnvironment;
  
  /// 現在の環境のデータベース名
  static String get databaseName => 
      dotenv.env['DATABASE_NAME'] ?? 'tech_lingual_quest.db';
  
  /// 現在の環境のAPIベースURL
  static String get apiBaseUrl => 
      dotenv.env['API_BASE_URL'] ?? 'https://api.example.com';
  
  /// 現在の環境のAPIキー
  static String get apiKey => 
      dotenv.env['API_KEY'] ?? '';
  
  /// 現在の環境のログレベル
  static String get logLevel => 
      dotenv.env['LOG_LEVEL'] ?? 'info';
  
  /// アナリティクスが有効かどうか
  static bool get isAnalyticsEnabled => 
      dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';
  
  /// クラッシュリティクスが有効かどうか
  static bool get isCrashlyticsEnabled => 
      dotenv.env['ENABLE_CRASHLYTICS']?.toLowerCase() == 'true';
  
  /// アプリが開発モードかどうか
  static bool get isDevelopment => _currentEnvironment == AppEnvironment.dev;
  
  /// アプリがステージングモードかどうか
  static bool get isStaging => _currentEnvironment == AppEnvironment.staging;
  
  /// アプリが本番モードかどうか
  static bool get isProduction => _currentEnvironment == AppEnvironment.prod;
}

/// アプリケーション環境
enum AppEnvironment {
  dev,
  staging,
  prod,
}