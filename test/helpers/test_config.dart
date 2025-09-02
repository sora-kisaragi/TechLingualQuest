import 'package:flutter_test/flutter_test.dart';
import 'package:tech_lingual_quest/shared/utils/config.dart';

/// テスト用の設定ヘルパー
///
/// テスト実行時の環境設定とモック化を管理する
class TestConfig {
  /// テスト用のアプリ設定を初期化
  static Future<void> initializeForTest() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // テスト環境用のモック設定で初期化
    await AppConfig.initialize();
  }
  
  /// テスト後のクリーンアップ
  static void cleanup() {
    // 必要に応じてテスト後のクリーンアップ処理
  }
}