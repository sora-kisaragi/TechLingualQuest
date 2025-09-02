import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../app/config.dart';
import '../../shared/utils/logger.dart';

/// ローカルSQLiteデータベースのサービス
///
/// データベース接続、初期化、基本操作を管理する
/// 設計書に基づき、最初はSQLiteを使用し、後にFirestoreに移行する
class DatabaseService {
  static Database? _database;
  static const int _databaseVersion = 1;

  /// データベースインスタンスを取得（シングルトンパターン）
  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
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
    }
  }

  /// データベースが開いているかチェック
  static bool get isOpen => _database?.isOpen ?? false;
}
