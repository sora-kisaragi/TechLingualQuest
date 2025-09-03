import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:tech_lingual_quest/shared/utils/config.dart';
import 'package:tech_lingual_quest/shared/utils/logger.dart';

void main() {
  group('AppLogger Tests', () {
    setUp(() {
      // Clean dotenv before each test
      dotenv.clean();
    });

    tearDown(() {
      // Clean dotenv after each test  
      dotenv.clean();
    });

    test('should initialize logger with development configuration', () async {
      // Arrange
      dotenv.testLoad(fileInput: '''
APP_ENV=dev
LOG_LEVEL=debug
''');
      await AppConfig.initialize();

      // Act
      AppLogger.initialize();

      // Assert - No exceptions should be thrown
      expect(() => AppLogger.info('Test message'), returnsNormally);
      expect(() => AppLogger.debug('Debug message'), returnsNormally);
      expect(() => AppLogger.warning('Warning message'), returnsNormally);
      expect(() => AppLogger.error('Error message'), returnsNormally);
    });

    test('should initialize logger with production configuration', () async {
      // Arrange
      dotenv.testLoad(fileInput: '''
APP_ENV=production
LOG_LEVEL=error
''');
      await AppConfig.initialize();

      // Act
      AppLogger.initialize();

      // Assert - No exceptions should be thrown
      expect(() => AppLogger.error('Error message'), returnsNormally);
      expect(() => AppLogger.fatal('Fatal message'), returnsNormally);
    });

    test('should handle all log levels correctly', () async {
      // Arrange
      dotenv.testLoad(fileInput: '''
APP_ENV=dev
LOG_LEVEL=trace
''');
      await AppConfig.initialize();
      AppLogger.initialize();

      // Act & Assert - All log levels should work without throwing
      expect(() => AppLogger.trace('Trace message'), returnsNormally);
      expect(() => AppLogger.debug('Debug message'), returnsNormally);
      expect(() => AppLogger.info('Info message'), returnsNormally);
      expect(() => AppLogger.warning('Warning message'), returnsNormally);
      expect(() => AppLogger.error('Error message'), returnsNormally);
      expect(() => AppLogger.fatal('Fatal message'), returnsNormally);
    });

    test('should handle log levels with error and stack trace', () async {
      // Arrange
      dotenv.testLoad(fileInput: '''
APP_ENV=dev
LOG_LEVEL=debug
''');
      await AppConfig.initialize();
      AppLogger.initialize();

      final testError = Exception('Test error');
      final testStackTrace = StackTrace.current;

      // Act & Assert - Should handle error and stack trace parameters
      expect(() => AppLogger.trace('Trace', testError, testStackTrace), returnsNormally);
      expect(() => AppLogger.debug('Debug', testError, testStackTrace), returnsNormally);
      expect(() => AppLogger.info('Info', testError, testStackTrace), returnsNormally);
      expect(() => AppLogger.warning('Warning', testError, testStackTrace), returnsNormally);
      expect(() => AppLogger.error('Error', testError, testStackTrace), returnsNormally);
      expect(() => AppLogger.fatal('Fatal', testError, testStackTrace), returnsNormally);
    });

    test('should handle log levels with only error parameter', () async {
      // Arrange
      dotenv.testLoad(fileInput: '''
APP_ENV=dev
LOG_LEVEL=debug
''');
      await AppConfig.initialize();
      AppLogger.initialize();

      final testError = Exception('Test error');

      // Act & Assert - Should handle error parameter without stack trace
      expect(() => AppLogger.trace('Trace', testError), returnsNormally);
      expect(() => AppLogger.debug('Debug', testError), returnsNormally);
      expect(() => AppLogger.info('Info', testError), returnsNormally);
      expect(() => AppLogger.warning('Warning', testError), returnsNormally);
      expect(() => AppLogger.error('Error', testError), returnsNormally);
      expect(() => AppLogger.fatal('Fatal', testError), returnsNormally);
    });

    test('should handle different log level configurations', () async {
      // Test trace level
      dotenv.testLoad(fileInput: 'LOG_LEVEL=trace');
      await AppConfig.initialize();
      AppLogger.initialize();
      expect(() => AppLogger.trace('Trace message'), returnsNormally);

      // Test debug level
      dotenv.clean();
      dotenv.testLoad(fileInput: 'LOG_LEVEL=debug');
      await AppConfig.initialize();
      AppLogger.initialize();
      expect(() => AppLogger.debug('Debug message'), returnsNormally);

      // Test info level
      dotenv.clean();
      dotenv.testLoad(fileInput: 'LOG_LEVEL=info');
      await AppConfig.initialize();
      AppLogger.initialize();
      expect(() => AppLogger.info('Info message'), returnsNormally);

      // Test warning level variations
      dotenv.clean();
      dotenv.testLoad(fileInput: 'LOG_LEVEL=warning');
      await AppConfig.initialize();
      AppLogger.initialize();
      expect(() => AppLogger.warning('Warning message'), returnsNormally);

      dotenv.clean();
      dotenv.testLoad(fileInput: 'LOG_LEVEL=warn');
      await AppConfig.initialize();
      AppLogger.initialize();
      expect(() => AppLogger.warning('Warn message'), returnsNormally);

      // Test error level
      dotenv.clean();
      dotenv.testLoad(fileInput: 'LOG_LEVEL=error');
      await AppConfig.initialize();
      AppLogger.initialize();
      expect(() => AppLogger.error('Error message'), returnsNormally);

      // Test fatal level
      dotenv.clean();
      dotenv.testLoad(fileInput: 'LOG_LEVEL=fatal');
      await AppConfig.initialize();
      AppLogger.initialize();
      expect(() => AppLogger.fatal('Fatal message'), returnsNormally);
    });

    test('should default to info level for unknown log levels', () async {
      // Arrange
      dotenv.testLoad(fileInput: 'LOG_LEVEL=unknown_level');
      await AppConfig.initialize();

      // Act
      AppLogger.initialize();

      // Assert - Should not throw and allow info level logging
      expect(() => AppLogger.info('Info message'), returnsNormally);
    });

    test('should handle case insensitive log levels', () async {
      // Arrange
      dotenv.testLoad(fileInput: 'LOG_LEVEL=ERROR');
      await AppConfig.initialize();

      // Act
      AppLogger.initialize();

      // Assert
      expect(() => AppLogger.error('Error message'), returnsNormally);
    });

    test('should work without initialization in error case', () async {
      // Note: This tests the behavior when logger might not be initialized
      // The logger methods should handle null logger gracefully
      expect(() => AppLogger.info('Test message'), returnsNormally);
    });
  });
}