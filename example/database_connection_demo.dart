import 'package:tech_lingual_quest/services/database/database_service.dart';
import 'package:tech_lingual_quest/shared/utils/config.dart';
import 'package:tech_lingual_quest/shared/utils/logger.dart';

/// データベース接続デモ
///
/// 拡張されたデータベース接続機能のデモンストレーション
void main() async {
  // 設定とロガーを初期化
  await AppConfig.initialize();
  AppLogger.initialize();

  print('\n=== データベース接続デモ ===\n');

  try {
    // 1. 初期接続状態を確認
    print('1. 初期接続状態: ${DatabaseService.connectionStatus}');

    // 2. データベース接続を確立
    print('2. データベース接続を確立中...');
    final database = await DatabaseService.database;
    print('   接続状態: ${DatabaseService.connectionStatus}');
    print('   データベースが開いています: ${DatabaseService.isOpen}');

    // 3. 接続情報を取得
    final connectionInfo = await DatabaseService.getConnectionInfo();
    print('3. 接続情報:');
    print('   データベースパス: ${connectionInfo.databasePath}');
    print('   データベース名: ${connectionInfo.databaseName}');
    print('   バージョン: ${connectionInfo.version}');
    print('   接続状態: ${connectionInfo.connectionStatus}');

    // 4. 健全性チェック
    final isHealthy = await DatabaseService.isConnectionHealthy();
    print('4. 接続健全性チェック: ${isHealthy ? '健全' : '不健全'}');

    // 5. 簡単なクエリを実行してテーブルを確認
    final tables = await database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    print('5. 作成されたテーブル:');
    for (final table in tables) {
      print('   - ${table['name']}');
    }

    // 6. 接続を閉じる
    print('6. データベース接続を閉じます...');
    await DatabaseService.close();
    print('   接続状態: ${DatabaseService.connectionStatus}');
    print('   データベースが開いています: ${DatabaseService.isOpen}');

    // 7. 再接続
    print('7. データベースを再接続します...');
    await DatabaseService.reconnect();
    print('   接続状態: ${DatabaseService.connectionStatus}');

    // 最終クリーンアップ
    await DatabaseService.close();

    print('\n=== デモ完了 ===');
  } catch (e, stackTrace) {
    print('エラーが発生しました: $e');
    print('スタックトレース: $stackTrace');
  }
}
