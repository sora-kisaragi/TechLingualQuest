import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../shared/utils/config.dart';
import '../../shared/utils/logger.dart';

/// ローカルSQLiteデータベースのサービス
///
/// データベース接続、初期化、基本操作を管理する
/// 設計書に基づき、最初はSQLiteを使用し、後にFirestoreに移行する
class DatabaseService {
  static Database? _database;
  static const int _databaseVersion = 1;
  static const int _maxRetryAttempts = 3;
  static const Duration _retryDelay = Duration(seconds: 1);
  
  /// データベース接続状態
  static DatabaseConnectionStatus _connectionStatus = DatabaseConnectionStatus.disconnected;

  /// データベースインスタンスを取得（シングルトンパターン）
  static Future<Database> get database async {
    if (_database != null && await isConnectionHealthy()) {
      return _database!;
    }

    _database = await _initDatabaseWithRetry();
    return _database!;
  }

  /// リトライ機能付きデータベース初期化
  static Future<Database> _initDatabaseWithRetry() async {
    _connectionStatus = DatabaseConnectionStatus.connecting;
    
    for (int attempt = 1; attempt <= _maxRetryAttempts; attempt++) {
      try {
        AppLogger.info('Database connection attempt $attempt/$_maxRetryAttempts');
        final database = await _initDatabase();
        _connectionStatus = DatabaseConnectionStatus.connected;
        AppLogger.info('Database connection established successfully');
        return database;
      } catch (e, stackTrace) {
        AppLogger.warning(
          'Database connection attempt $attempt failed: $e',
          e,
          stackTrace,
        );
        
        if (attempt == _maxRetryAttempts) {
          _connectionStatus = DatabaseConnectionStatus.failed;
          AppLogger.error(
            'Failed to establish database connection after $_maxRetryAttempts attempts',
            e,
            stackTrace,
          );
          rethrow;
        }
        
        // 指数バックオフによる遅延
        final delay = Duration(
          milliseconds: _retryDelay.inMilliseconds * (1 << (attempt - 1))
        );
        AppLogger.debug('Retrying database connection in ${delay.inMilliseconds}ms');
        await Future.delayed(delay);
      }
    }
    
    throw Exception('Unable to establish database connection');
  }

  /// データベースを初期化
  static Future<Database> _initDatabase() async {
    AppLogger.info('Initializing database...');

    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, AppConfig.databaseName);

      AppLogger.debug('Database path: $path');

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize database', e, stackTrace);
      rethrow;
    }
  }

  /// データベーステーブルを作成
  static Future<void> _onCreate(Database db, int version) async {
    AppLogger.info('Creating database tables...');

    try {
      // 基本的なユーザー情報のためのユーザーテーブル
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE NOT NULL,
          email TEXT,
          total_xp INTEGER DEFAULT 0,
          level INTEGER DEFAULT 1,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      // 語彙カードを保存するための語彙テーブル
      await db.execute('''
        CREATE TABLE vocabulary (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          word TEXT NOT NULL,
          definition TEXT NOT NULL,
          example TEXT,
          difficulty_level INTEGER DEFAULT 1,
          category TEXT,
          learned_count INTEGER DEFAULT 0,
          last_reviewed_at INTEGER,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      // ユーザー語彙進捗テーブル
      await db.execute('''
        CREATE TABLE user_vocabulary_progress (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          vocabulary_id INTEGER NOT NULL,
          familiarity_level INTEGER DEFAULT 0,
          correct_answers INTEGER DEFAULT 0,
          total_attempts INTEGER DEFAULT 0,
          last_reviewed_at INTEGER,
          next_review_at INTEGER,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id),
          FOREIGN KEY (vocabulary_id) REFERENCES vocabulary (id),
          UNIQUE(user_id, vocabulary_id)
        )
      ''');

      // ゲーミフィケーションのためのクエストテーブル
      await db.execute('''
        CREATE TABLE quests (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          type TEXT NOT NULL,
          target_value INTEGER NOT NULL,
          xp_reward INTEGER NOT NULL,
          is_daily BOOLEAN DEFAULT FALSE,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      // ユーザークエスト進捗テーブル
      await db.execute('''
        CREATE TABLE user_quest_progress (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          quest_id INTEGER NOT NULL,
          current_progress INTEGER DEFAULT 0,
          completed_at INTEGER,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id),
          FOREIGN KEY (quest_id) REFERENCES quests (id),
          UNIQUE(user_id, quest_id)
        )
      ''');

      AppLogger.info('Database tables created successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create database tables', e, stackTrace);
      rethrow;
    }
  }

  /// データベースアップグレードを処理
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    AppLogger.info(
        'Upgrading database from version $oldVersion to $newVersion');
    // 将来のデータベースマイグレーションはここで処理される
  }

  /// データベース接続を閉じる
  static Future<void> close() async {
    if (_database != null) {
      AppLogger.info('Closing database connection');
      await _database!.close();
      _database = null;
      _connectionStatus = DatabaseConnectionStatus.disconnected;
    }
  }

  /// データベースが開いているかチェック
  static bool get isOpen => _database?.isOpen ?? false;
  
  /// データベース接続状態を取得
  static DatabaseConnectionStatus get connectionStatus => _connectionStatus;
  
  /// データベース接続の健全性をチェック
  static Future<bool> isConnectionHealthy() async {
    if (_database == null || !_database!.isOpen) {
      _connectionStatus = DatabaseConnectionStatus.disconnected;
      return false;
    }
    
    try {
      // 簡単なクエリを実行して接続をテスト
      await _database!.rawQuery('SELECT 1');
      _connectionStatus = DatabaseConnectionStatus.connected;
      return true;
    } catch (e) {
      AppLogger.warning('Database connection health check failed: $e');
      _connectionStatus = DatabaseConnectionStatus.failed;
      return false;
    }
  }
  
  /// データベース接続を強制的に再確立
  static Future<Database> reconnect() async {
    AppLogger.info('Forcing database reconnection');
    await close();
    return await database;
  }
  
  /// データベース接続情報を取得
  static Future<DatabaseConnectionInfo> getConnectionInfo() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConfig.databaseName);
    
    return DatabaseConnectionInfo(
      databasePath: path,
      databaseName: AppConfig.databaseName,
      version: _databaseVersion,
      isOpen: isOpen,
      connectionStatus: _connectionStatus,
    );
  }
}

/// データベース接続状態を表す列挙型
enum DatabaseConnectionStatus {
  /// 接続されていない
  disconnected,
  /// 接続中
  connecting,
  /// 接続済み
  connected,
  /// 接続失敗
  failed,
}

/// データベース接続情報を保持するクラス
class DatabaseConnectionInfo {
  const DatabaseConnectionInfo({
    required this.databasePath,
    required this.databaseName,
    required this.version,
    required this.isOpen,
    required this.connectionStatus,
  });

  /// データベースファイルパス
  final String databasePath;
  
  /// データベース名
  final String databaseName;
  
  /// データベースバージョン
  final int version;
  
  /// データベースが開いているかどうか
  final bool isOpen;
  
  /// 接続状態
  final DatabaseConnectionStatus connectionStatus;

  @override
  String toString() {
    return 'DatabaseConnectionInfo('
        'path: $databasePath, '
        'name: $databaseName, '
        'version: $version, '
        'isOpen: $isOpen, '
        'status: $connectionStatus'
        ')';
  }
}
