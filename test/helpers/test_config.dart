import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tech_lingual_quest/shared/utils/config.dart';
import 'package:tech_lingual_quest/shared/utils/logger.dart';

/// テスト用の設定ヘルパー
///
/// テスト実行時の環境設定とモック化を管理する
class TestConfig {
  /// テスト用のアプリ設定を初期化
  static Future<void> initializeForTest() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // デスクトップ/CI環境でのSQLiteサポートを初期化
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // テスト環境用のモック設定で直接dotenvを初期化
    dotenv.testLoad(
      fileInput: '''
APP_ENV=test
DATABASE_NAME=tech_lingual_quest_test.db
API_BASE_URL=https://api.test.example.com
API_KEY=test_api_key
LOG_LEVEL=error
ENABLE_ANALYTICS=false
ENABLE_CRASHLYTICS=false
''',
    );

    // AppConfigを初期化 - ここで環境設定が読み込まれる
    await AppConfig.initialize();

    // テスト用のロガーを初期化
    AppLogger.initialize();
  }

  /// テスト後のクリーンアップ
  static void cleanup() {
    // dotenvの内容をクリア
    dotenv.clean();
  }
}
