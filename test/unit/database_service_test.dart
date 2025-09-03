import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tech_lingual_quest/shared/utils/config.dart';
import 'package:tech_lingual_quest/shared/utils/logger.dart';
import 'package:tech_lingual_quest/services/database/database_service.dart';

void main() {
  group('DatabaseService Tests', () {
    setUpAll(() {
      // Initialize FFI for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      // Clean dotenv and initialize test configuration
      dotenv.clean();
      dotenv.testLoad(fileInput: '''
APP_ENV=test
DATABASE_NAME=test_database.db
LOG_LEVEL=error
''');
      await AppConfig.initialize();
      AppLogger.initialize();
    });

    tearDown(() async {
      // Close database after each test
      await DatabaseService.close();
      dotenv.clean();
    });

    test('should initialize database successfully', () async {
      // Act
      final db = await DatabaseService.database;

      // Assert
      expect(db, isNotNull);
      expect(DatabaseService.isOpen, true);
    });

    test('should return same database instance on multiple calls', () async {
      // Act
      final db1 = await DatabaseService.database;
      final db2 = await DatabaseService.database;

      // Assert
      expect(identical(db1, db2), true);
      expect(DatabaseService.isOpen, true);
    });

    test('should create all required tables', () async {
      // Act
      final db = await DatabaseService.database;

      // Assert - Check if all tables exist
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );
      
      final tableNames = tables.map((table) => table['name'] as String).toList();
      
      expect(tableNames, contains('users'));
      expect(tableNames, contains('vocabulary'));
      expect(tableNames, contains('user_vocabulary_progress'));
      expect(tableNames, contains('quests'));
      expect(tableNames, contains('user_quest_progress'));
    });

    test('should create users table with correct schema', () async {
      // Act
      final db = await DatabaseService.database;
      
      // Assert - Check users table schema
      final userTableInfo = await db.rawQuery("PRAGMA table_info(users)");
      final columnNames = userTableInfo.map((column) => column['name'] as String).toList();
      
      expect(columnNames, contains('id'));
      expect(columnNames, contains('username'));
      expect(columnNames, contains('email'));
      expect(columnNames, contains('total_xp'));
      expect(columnNames, contains('level'));
      expect(columnNames, contains('created_at'));
      expect(columnNames, contains('updated_at'));
    });

    test('should create vocabulary table with correct schema', () async {
      // Act
      final db = await DatabaseService.database;
      
      // Assert - Check vocabulary table schema
      final vocabularyTableInfo = await db.rawQuery("PRAGMA table_info(vocabulary)");
      final columnNames = vocabularyTableInfo.map((column) => column['name'] as String).toList();
      
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
    });

    test('should create user_vocabulary_progress table with correct schema', () async {
      // Act
      final db = await DatabaseService.database;
      
      // Assert - Check user_vocabulary_progress table schema
      final tableInfo = await db.rawQuery("PRAGMA table_info(user_vocabulary_progress)");
      final columnNames = tableInfo.map((column) => column['name'] as String).toList();
      
      expect(columnNames, contains('id'));
      expect(columnNames, contains('user_id'));
      expect(columnNames, contains('vocabulary_id'));
      expect(columnNames, contains('familiarity_level'));
      expect(columnNames, contains('correct_answers'));
      expect(columnNames, contains('total_attempts'));
      expect(columnNames, contains('last_reviewed_at'));
      expect(columnNames, contains('next_review_at'));
      expect(columnNames, contains('created_at'));
      expect(columnNames, contains('updated_at'));
    });

    test('should create quests table with correct schema', () async {
      // Act
      final db = await DatabaseService.database;
      
      // Assert - Check quests table schema
      final tableInfo = await db.rawQuery("PRAGMA table_info(quests)");
      final columnNames = tableInfo.map((column) => column['name'] as String).toList();
      
      expect(columnNames, contains('id'));
      expect(columnNames, contains('title'));
      expect(columnNames, contains('description'));
      expect(columnNames, contains('type'));
      expect(columnNames, contains('target_value'));
      expect(columnNames, contains('xp_reward'));
      expect(columnNames, contains('is_daily'));
      expect(columnNames, contains('created_at'));
      expect(columnNames, contains('updated_at'));
    });

    test('should create user_quest_progress table with correct schema', () async {
      // Act
      final db = await DatabaseService.database;
      
      // Assert - Check user_quest_progress table schema
      final tableInfo = await db.rawQuery("PRAGMA table_info(user_quest_progress)");
      final columnNames = tableInfo.map((column) => column['name'] as String).toList();
      
      expect(columnNames, contains('id'));
      expect(columnNames, contains('user_id'));
      expect(columnNames, contains('quest_id'));
      expect(columnNames, contains('current_progress'));
      expect(columnNames, contains('completed_at'));
      expect(columnNames, contains('created_at'));
      expect(columnNames, contains('updated_at'));
    });

    test('should handle database operations correctly', () async {
      // Act
      final db = await DatabaseService.database;
      
      // Insert test data with unique name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final userId = await db.insert('users', {
        'username': 'test_user_ops_$timestamp',
        'email': 'test_ops_$timestamp@example.com',
        'total_xp': 100,
        'level': 2,
        'created_at': timestamp,
        'updated_at': timestamp,
      });

      // Assert insertion worked
      expect(userId, greaterThan(0));

      // Query the data back
      final users = await db.query('users', where: 'id = ?', whereArgs: [userId]);
      expect(users.length, 1);
      expect(users.first['username'], 'test_user_ops_$timestamp');
      expect(users.first['email'], 'test_ops_$timestamp@example.com');
      expect(users.first['total_xp'], 100);
      expect(users.first['level'], 2);
    });

    test('should close database connection', () async {
      // Arrange
      await DatabaseService.database; // Initialize database
      expect(DatabaseService.isOpen, true);

      // Act
      await DatabaseService.close();

      // Assert
      expect(DatabaseService.isOpen, false);
    });

    test('should handle close when database is not initialized', () async {
      // Act & Assert - Should not throw
      expect(() => DatabaseService.close(), returnsNormally);
      expect(DatabaseService.isOpen, false);
    });

    test('should reopen database after close', () async {
      // Arrange
      await DatabaseService.database; // Initialize
      await DatabaseService.close(); // Close
      expect(DatabaseService.isOpen, false);

      // Act
      final db = await DatabaseService.database; // Reopen

      // Assert
      expect(db, isNotNull);
      expect(DatabaseService.isOpen, true);
    });

    test('should handle foreign key constraints', () async {
      // Act
      final db = await DatabaseService.database;

      // Insert user first with unique name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final userId = await db.insert('users', {
        'username': 'test_user_$timestamp',
        'email': 'test_$timestamp@example.com',
        'created_at': timestamp,
        'updated_at': timestamp,
      });

      // Insert vocabulary
      final vocabId = await db.insert('vocabulary', {
        'word': 'test_$timestamp',
        'definition': 'test definition',
        'created_at': timestamp,
        'updated_at': timestamp,
      });

      // Insert user vocabulary progress with foreign keys
      final progressId = await db.insert('user_vocabulary_progress', {
        'user_id': userId,
        'vocabulary_id': vocabId,
        'familiarity_level': 1,
        'created_at': timestamp,
        'updated_at': timestamp,
      });

      // Assert
      expect(progressId, greaterThan(0));

      // Verify the relationship
      final progress = await db.query(
        'user_vocabulary_progress',
        where: 'id = ?',
        whereArgs: [progressId],
      );
      expect(progress.length, 1);
      expect(progress.first['user_id'], userId);
      expect(progress.first['vocabulary_id'], vocabId);
    });
  });
}