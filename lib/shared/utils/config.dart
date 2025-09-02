import 'dart:io' show Platform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// アプリケーション環境設定
///
/// 異なる環境（dev、staging、prod）とその設定を管理する
class AppConfig {
  static AppEnvironment _currentEnvironment = AppEnvironment.dev;

  /// 環境設定を初期化
  /// main()でrunApp()の前に呼び出す必要がある
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // .envファイルが存在しない場合、デフォルト設定を使用
      // CI/CDや本番環境では環境変数から設定を読み取る
      dotenv.testLoad(fileInput: '''
APP_ENV=dev
DATABASE_NAME=tech_lingual_quest.db
API_BASE_URL=https://api.example.com
API_KEY=
LOG_LEVEL=info
ENABLE_ANALYTICS=false
ENABLE_CRASHLYTICS=false
''');
    }
    _setEnvironmentFromConfig();
  }

  static void _setEnvironmentFromConfig() {
    // 最初に環境変数から取得を試行し、次に.envファイルから取得
    final envString =
        Platform.environment['APP_ENV'] ?? dotenv.env['APP_ENV'] ?? 'dev';
    switch (envString.toLowerCase()) {
      case 'prod':
      case 'production':
        _currentEnvironment = AppEnvironment.prod;
        break;
      case 'staging':
        _currentEnvironment = AppEnvironment.staging;
        break;
      case 'test':
        _currentEnvironment = AppEnvironment.dev; // テスト環境は開発環境として扱う
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
      Platform.environment['DATABASE_NAME'] ??
      dotenv.env['DATABASE_NAME'] ??
      'tech_lingual_quest.db';

  /// 現在の環境のAPIベースURL
  static String get apiBaseUrl =>
      Platform.environment['API_BASE_URL'] ??
      dotenv.env['API_BASE_URL'] ??
      'https://api.example.com';

  /// 現在の環境のAPIキー
  static String get apiKey =>
      Platform.environment['API_KEY'] ?? dotenv.env['API_KEY'] ?? '';

  /// 現在の環境のログレベル
  static String get logLevel =>
      Platform.environment['LOG_LEVEL'] ?? dotenv.env['LOG_LEVEL'] ?? 'info';

  /// アナリティクスが有効かどうか
  static bool get isAnalyticsEnabled =>
      (Platform.environment['ENABLE_ANALYTICS'] ??
              dotenv.env['ENABLE_ANALYTICS'] ??
              'false')
          .toLowerCase() ==
      'true';

  /// クラッシュリティクスが有効かどうか
  static bool get isCrashlyticsEnabled =>
      (Platform.environment['ENABLE_CRASHLYTICS'] ??
              dotenv.env['ENABLE_CRASHLYTICS'] ??
              'false')
          .toLowerCase() ==
      'true';

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
