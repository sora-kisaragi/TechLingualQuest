import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tech_lingual_quest/shared/utils/config.dart';

void main() {
  group('AppConfig Tests', () {
    setUp(() {
      // Clean dotenv before each test
      dotenv.clean();
    });

    tearDown(() {
      // Clean dotenv after each test
      dotenv.clean();
    });

    test('should initialize with default values when no .env file exists',
        () async {
      // Act
      await AppConfig.initialize();

      // Assert
      expect(AppConfig.environment, AppEnvironment.dev);
      expect(AppConfig.databaseName, 'tech_lingual_quest.db');
      expect(AppConfig.apiBaseUrl, 'https://api.example.com');
      expect(AppConfig.apiKey, isEmpty);
      expect(AppConfig.logLevel, 'info');
      expect(AppConfig.isAnalyticsEnabled, false);
      expect(AppConfig.isCrashlyticsEnabled, false);
      expect(AppConfig.isDevelopment, true);
      expect(AppConfig.isStaging, false);
      expect(AppConfig.isProduction, false);
    });

    test('should handle development environment correctly', () async {
      // Act
      await AppConfig.initialize();

      // Assert development flags
      expect(AppConfig.isDevelopment, true);
      expect(AppConfig.isStaging, false);
      expect(AppConfig.isProduction, false);
      expect(AppConfig.environment, AppEnvironment.dev);
    });

    test('should return default configuration values correctly', () async {
      // Act
      await AppConfig.initialize();

      // Assert all getters return expected default values
      expect(AppConfig.databaseName, isNotEmpty);
      expect(AppConfig.apiBaseUrl, startsWith('https://'));
      expect(AppConfig.logLevel, isNotEmpty);
      expect(AppConfig.isAnalyticsEnabled, isA<bool>());
      expect(AppConfig.isCrashlyticsEnabled, isA<bool>());
    });

    test('should handle API key access safely', () async {
      // Act
      await AppConfig.initialize();

      // Assert - API key getter should not throw
      expect(() => AppConfig.apiKey, returnsNormally);
      expect(AppConfig.apiKey, isA<String>());
    });

    test('should handle boolean configuration flags', () async {
      // Act
      await AppConfig.initialize();

      // Assert - Boolean getters should work correctly
      expect(AppConfig.isAnalyticsEnabled, isA<bool>());
      expect(AppConfig.isCrashlyticsEnabled, isA<bool>());
      expect(AppConfig.isDevelopment, isA<bool>());
      expect(AppConfig.isStaging, isA<bool>());
      expect(AppConfig.isProduction, isA<bool>());

      // Only one environment should be true at a time
      int trueCount = 0;
      if (AppConfig.isDevelopment) trueCount++;
      if (AppConfig.isStaging) trueCount++;
      if (AppConfig.isProduction) trueCount++;
      expect(trueCount, 1);
    });

    test('should handle string configuration values', () async {
      // Act
      await AppConfig.initialize();

      // Assert - String getters should return valid values
      expect(AppConfig.databaseName, isA<String>());
      expect(AppConfig.databaseName, isNotEmpty);
      expect(AppConfig.apiBaseUrl, isA<String>());
      expect(AppConfig.apiBaseUrl, isNotEmpty);
      expect(AppConfig.logLevel, isA<String>());
      expect(AppConfig.logLevel, isNotEmpty);
      expect(AppConfig.apiKey, isA<String>());
    });

    test('should return consistent environment values', () async {
      // Act
      await AppConfig.initialize();

      // Assert - Environment should be consistent
      final env = AppConfig.environment;
      expect(env, isA<AppEnvironment>());

      // Check consistency between environment enum and boolean helpers
      switch (env) {
        case AppEnvironment.dev:
          expect(AppConfig.isDevelopment, true);
          expect(AppConfig.isStaging, false);
          expect(AppConfig.isProduction, false);
          break;
        case AppEnvironment.staging:
          expect(AppConfig.isDevelopment, false);
          expect(AppConfig.isStaging, true);
          expect(AppConfig.isProduction, false);
          break;
        case AppEnvironment.prod:
          expect(AppConfig.isDevelopment, false);
          expect(AppConfig.isStaging, false);
          expect(AppConfig.isProduction, true);
          break;
      }
    });

    test('should initialize multiple times safely', () async {
      // Act - Initialize multiple times
      await AppConfig.initialize();
      final firstDatabaseName = AppConfig.databaseName;
      final firstEnvironment = AppConfig.environment;

      await AppConfig.initialize();
      final secondDatabaseName = AppConfig.databaseName;
      final secondEnvironment = AppConfig.environment;

      // Assert - Values should remain consistent
      expect(secondDatabaseName, firstDatabaseName);
      expect(secondEnvironment, firstEnvironment);
    });

    test('should handle URL configuration formats correctly', () async {
      // Act
      await AppConfig.initialize();

      // Assert - URL should be properly formatted
      expect(AppConfig.apiBaseUrl, startsWith('http'));
      expect(AppConfig.apiBaseUrl, contains('://'));
    });

    test('should handle database name configuration correctly', () async {
      // Act
      await AppConfig.initialize();

      // Assert - Database name should be valid
      expect(AppConfig.databaseName, endsWith('.db'));
      expect(AppConfig.databaseName, isNotEmpty);
    });

    test('should handle log level configuration correctly', () async {
      // Act
      await AppConfig.initialize();

      // Assert - Log level should be a known value
      final validLogLevels = [
        'trace',
        'debug',
        'info',
        'warning',
        'warn',
        'error',
        'fatal'
      ];
      expect(validLogLevels, contains(AppConfig.logLevel.toLowerCase()));
    });

    test('should ensure AppEnvironment enum values work correctly', () {
      // Test enum values directly
      expect(AppEnvironment.dev, isA<AppEnvironment>());
      expect(AppEnvironment.staging, isA<AppEnvironment>());
      expect(AppEnvironment.prod, isA<AppEnvironment>());

      // Test enum comparison
      expect(AppEnvironment.dev, isNot(equals(AppEnvironment.staging)));
      expect(AppEnvironment.staging, isNot(equals(AppEnvironment.prod)));
      expect(AppEnvironment.prod, isNot(equals(AppEnvironment.dev)));
    });
  });
}
