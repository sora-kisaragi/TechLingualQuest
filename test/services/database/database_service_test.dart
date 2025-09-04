import 'package:flutter_test/flutter_test.dart';
import 'package:tech_lingual_quest/services/database/database_service.dart';
import 'package:tech_lingual_quest/shared/utils/config.dart';
import '../../helpers/test_config.dart';

/// DatabaseServiceの包括的なテスト
///
/// データベース接続の確立、健全性チェック、リトライ機能、
/// 接続状態の管理をテストする
void main() {
  group('DatabaseService Connection Tests', () {
    setUpAll(() async {
      // テスト用の設定を初期化
      await TestConfig.initializeForTest();
    });

    tearDown(() async {
      // 各テスト後にデータベース接続をクリーンアップ
      try {
        await DatabaseService.close();
      } catch (e) {
        // クリーンアップエラーは無視
      }
    });

    tearDownAll(() {
      // テスト終了後のクリーンアップ
      TestConfig.cleanup();
    });

    group('Database Connection Establishment', () {
      test('should successfully establish database connection', () async {
        // Act: データベース接続を取得
        final database = await DatabaseService.database;

        // Assert: 接続が正常に確立されることを確認
        expect(database, isNotNull);
        expect(DatabaseService.isOpen, isTrue);
        expect(
          DatabaseService.connectionStatus,
          equals(DatabaseConnectionStatus.connected),
        );
      });

      test('should reuse existing connection when healthy', () async {
        // Arrange: 最初の接続を確立
        final firstDatabase = await DatabaseService.database;

        // Act: 2回目の接続を取得
        final secondDatabase = await DatabaseService.database;

        // Assert: 同じインスタンスが返されることを確認
        expect(identical(firstDatabase, secondDatabase), isTrue);
        expect(DatabaseService.isOpen, isTrue);
      });

      test('should create new connection after close', () async {
        // Arrange: 接続を確立してから閉じる
        await DatabaseService.database;
        await DatabaseService.close();

        expect(DatabaseService.isOpen, isFalse);
        expect(
          DatabaseService.connectionStatus,
          equals(DatabaseConnectionStatus.disconnected),
        );

        // Act: 新しい接続を確立
        final newDatabase = await DatabaseService.database;

        // Assert: 新しい接続が確立されることを確認
        expect(newDatabase, isNotNull);
        expect(DatabaseService.isOpen, isTrue);
        expect(
          DatabaseService.connectionStatus,
          equals(DatabaseConnectionStatus.connected),
        );
      });
    });

    group('Connection Health Checks', () {
      test('should detect healthy connection', () async {
        // Arrange: データベース接続を確立
        await DatabaseService.database;

        // Act: 健全性チェックを実行
        final isHealthy = await DatabaseService.isConnectionHealthy();

        // Assert: 接続が健全であることを確認
        expect(isHealthy, isTrue);
        expect(
          DatabaseService.connectionStatus,
          equals(DatabaseConnectionStatus.connected),
        );
      });

      test('should detect unhealthy connection when closed', () async {
        // Arrange: 接続を確立してから閉じる
        await DatabaseService.database;
        await DatabaseService.close();

        // Act: 健全性チェックを実行
        final isHealthy = await DatabaseService.isConnectionHealthy();

        // Assert: 接続が不健全であることを確認
        expect(isHealthy, isFalse);
        expect(
          DatabaseService.connectionStatus,
          equals(DatabaseConnectionStatus.disconnected),
        );
      });

      test(
        'should detect unhealthy connection when database is null',
        () async {
          // Arrange: データベースが初期化されていない状態を確保
          await DatabaseService.close();

          // Act: 健全性チェックを実行
          final isHealthy = await DatabaseService.isConnectionHealthy();

          // Assert: 接続が不健全であることを確認
          expect(isHealthy, isFalse);
          expect(
            DatabaseService.connectionStatus,
            equals(DatabaseConnectionStatus.disconnected),
          );
        },
      );
    });

    group('Connection Reconnection', () {
      test(
        'should successfully reconnect after forced disconnection',
        () async {
          // Arrange: 初期接続を確立
          final originalDatabase = await DatabaseService.database;
          expect(DatabaseService.isOpen, isTrue);

          // Act: 強制的に再接続
          final reconnectedDatabase = await DatabaseService.reconnect();

          // Assert: 新しい接続が確立されることを確認
          expect(reconnectedDatabase, isNotNull);
          expect(DatabaseService.isOpen, isTrue);
          expect(
            DatabaseService.connectionStatus,
            equals(DatabaseConnectionStatus.connected),
          );
          // 新しいインスタンスが作成されることを確認
          expect(identical(originalDatabase, reconnectedDatabase), isFalse);
        },
      );
    });

    group('Connection Information', () {
      test('should provide accurate connection information', () async {
        // Arrange: データベース接続を確立
        await DatabaseService.database;

        // Act: 接続情報を取得
        final connectionInfo = await DatabaseService.getConnectionInfo();

        // Assert: 接続情報が正確であることを確認
        expect(connectionInfo.version, equals(1));
        expect(connectionInfo.isOpen, isTrue);
        expect(
          connectionInfo.connectionStatus,
          equals(DatabaseConnectionStatus.connected),
        );

        // データベース名とパスが適切に設定されていることを確認
        // テスト環境では実際の設定値を使用する
        expect(connectionInfo.databaseName, equals(AppConfig.databaseName));
        expect(connectionInfo.databasePath, contains(AppConfig.databaseName));
      });

      test('should show correct status when disconnected', () async {
        // Arrange: データベースを閉じる
        await DatabaseService.close();

        // Act: 接続情報を取得
        final connectionInfo = await DatabaseService.getConnectionInfo();

        // Assert: 切断状態が正確に反映されることを確認
        expect(connectionInfo.isOpen, isFalse);
        expect(
          connectionInfo.connectionStatus,
          equals(DatabaseConnectionStatus.disconnected),
        );
      });
    });

    group('Database Table Creation', () {
      test('should create all required tables', () async {
        // Act: データベース接続を確立（テーブル作成を含む）
        final database = await DatabaseService.database;

        // Assert: 必要なテーブルが作成されることを確認
        final tables = await database.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table'",
        );

        final tableNames =
            tables.map((table) => table['name'] as String).toList();

        expect(tableNames, contains('users'));
        expect(tableNames, contains('vocabulary'));
        expect(tableNames, contains('user_vocabulary_progress'));
        expect(tableNames, contains('quests'));
        expect(tableNames, contains('user_quest_progress'));
      });

      test(
        'should create tables with correct schema for users table',
        () async {
          // Arrange: データベース接続を確立
          final database = await DatabaseService.database;

          // Act: usersテーブルのスキーマを確認
          final schema = await database.rawQuery('PRAGMA table_info(users)');

          // Assert: 正しいカラムが存在することを確認
          final columnNames =
              schema.map((col) => col['name'] as String).toList();

          expect(columnNames, contains('id'));
          expect(columnNames, contains('username'));
          expect(columnNames, contains('email'));
          expect(columnNames, contains('total_xp'));
          expect(columnNames, contains('level'));
          expect(columnNames, contains('created_at'));
          expect(columnNames, contains('updated_at'));
        },
      );

      test(
        'should create tables with correct schema for vocabulary table',
        () async {
          // Arrange: データベース接続を確立
          final database = await DatabaseService.database;

          // Act: vocabularyテーブルのスキーマを確認
          final schema = await database.rawQuery(
            'PRAGMA table_info(vocabulary)',
          );

          // Assert: 正しいカラムが存在することを確認
          final columnNames =
              schema.map((col) => col['name'] as String).toList();

          expect(columnNames, contains('id'));
          expect(columnNames, contains('word'));
          expect(columnNames, contains('definition'));
          expect(columnNames, contains('example'));
          expect(columnNames, contains('difficulty_level'));
          expect(columnNames, contains('category'));
          expect(columnNames, contains('learned_count'));
          expect(columnNames, contains('last_reviewed_at'));
          expect(columnNames, contains('created_at'));
          expect(columnNames, contains('updated_at'));
        },
      );
    });

    group('Connection Status Tracking', () {
      test('should track connection status throughout lifecycle', () async {
        // Assert: 初期状態は切断
        expect(
          DatabaseService.connectionStatus,
          equals(DatabaseConnectionStatus.disconnected),
        );

        // Act & Assert: 接続確立時の状態変化
        final database = await DatabaseService.database;
        expect(
          DatabaseService.connectionStatus,
          equals(DatabaseConnectionStatus.connected),
        );
        expect(database, isNotNull);

        // Act & Assert: 接続終了時の状態変化
        await DatabaseService.close();
        expect(
          DatabaseService.connectionStatus,
          equals(DatabaseConnectionStatus.disconnected),
        );
      });
    });
  });
}
