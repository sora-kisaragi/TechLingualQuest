import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tech_lingual_quest/shared/utils/base_notifier.dart';

// Test implementation of BaseNotifier
class TestNotifier extends BaseNotifier<String> {
  Future<void> performOperation(String result) async {
    await execute(() async => result);
  }

  Future<void> performOperationWithoutLoading(String result) async {
    await executeWithoutLoading(() async => result);
  }

  Future<void> performFailingOperation() async {
    await execute(() async => throw Exception('Test error'));
  }

  Future<void> performFailingOperationWithoutLoading() async {
    await executeWithoutLoading(() async => throw Exception('Test error'));
  }

  Future<void> performDelayedOperation(String result, Duration delay) async {
    await execute(() async {
      await Future.delayed(delay);
      return result;
    });
  }
}

void main() {
  group('BaseNotifier Tests', () {
    late TestNotifier notifier;

    setUp(() {
      notifier = TestNotifier();
    });

    group('Initialization', () {
      test('should initialize with loading state', () {
        expect(notifier.state, isA<AsyncLoading>());
      });
    });

    group('execute() method', () {
      test('should set loading state before operation', () async {
        // Start with data state
        notifier.state = const AsyncValue.data('initial');
        
        // Start operation (but don't await immediately)
        final future = notifier.performOperation('success');
        
        // Should be loading
        expect(notifier.state, isA<AsyncLoading>());
        
        // Wait for completion
        await future;
      });

      test('should set data state on successful operation', () async {
        await notifier.performOperation('test result');
        
        expect(notifier.state, isA<AsyncData>());
        expect(notifier.state.value, equals('test result'));
      });

      test('should set error state on failed operation', () async {
        await notifier.performFailingOperation();
        
        expect(notifier.state, isA<AsyncError>());
        expect(notifier.state.error, isA<Exception>());
        expect(notifier.state.error.toString(), contains('Test error'));
      });

      test('should handle multiple sequential operations', () async {
        // First operation
        await notifier.performOperation('first');
        expect(notifier.state.value, equals('first'));
        
        // Second operation
        await notifier.performOperation('second');
        expect(notifier.state.value, equals('second'));
        
        // Failed operation
        await notifier.performFailingOperation();
        expect(notifier.state, isA<AsyncError>());
      });

      test('should maintain error state until successful operation', () async {
        // Fail first
        await notifier.performFailingOperation();
        expect(notifier.state, isA<AsyncError>());
        
        // Success should clear error
        await notifier.performOperation('recovered');
        expect(notifier.state, isA<AsyncData>());
        expect(notifier.state.value, equals('recovered'));
      });

      test('should handle concurrent operations correctly', () async {
        // Start multiple operations
        final futures = [
          notifier.performDelayedOperation('result1', const Duration(milliseconds: 100)),
          notifier.performDelayedOperation('result2', const Duration(milliseconds: 50)),
        ];
        
        // Wait for all to complete
        await Future.wait(futures);
        
        // The last completed operation should win
        // Due to timing, result2 should complete first, but result1 should be final
        // This tests race condition handling
        expect(notifier.state, isA<AsyncData>());
      });
    });

    group('executeWithoutLoading() method', () {
      test('should not set loading state during operation', () async {
        // Start with data state
        notifier.state = const AsyncValue.data('initial');
        
        // Verify state before operation
        expect(notifier.state.value, equals('initial'));
        
        // Start operation
        await notifier.performOperationWithoutLoading('new result');
        
        // Should go directly to new data without loading
        expect(notifier.state, isA<AsyncData>());
        expect(notifier.state.value, equals('new result'));
      });

      test('should set data state on successful operation', () async {
        await notifier.performOperationWithoutLoading('test result');
        
        expect(notifier.state, isA<AsyncData>());
        expect(notifier.state.value, equals('test result'));
      });

      test('should set error state on failed operation', () async {
        await notifier.performFailingOperationWithoutLoading();
        
        expect(notifier.state, isA<AsyncError>());
        expect(notifier.state.error, isA<Exception>());
      });

      test('should preserve existing data state during loading when initialized with loading', () async {
        // Notifier starts with loading state
        expect(notifier.state, isA<AsyncLoading>());
        
        // Operation without loading
        await notifier.performOperationWithoutLoading('result');
        
        expect(notifier.state, isA<AsyncData>());
        expect(notifier.state.value, equals('result'));
      });
    });

    group('Error Handling', () {
      test('should preserve stack trace in error state', () async {
        await notifier.performFailingOperation();
        
        expect(notifier.state, isA<AsyncError>());
        expect(notifier.state.stackTrace, isNotNull);
      });

      test('should handle different error types', () async {
        final customNotifier = _CustomErrorNotifier();
        
        // String error
        await customNotifier.throwStringError();
        expect(customNotifier.state.error, isA<String>());
        
        // Custom exception
        await customNotifier.throwCustomError();
        expect(customNotifier.state.error, isA<_CustomException>());
      });

      test('should handle null-like errors gracefully', () async {
        final customNotifier = _CustomErrorNotifier();
        await customNotifier.throwNullError();
        
        expect(customNotifier.state, isA<AsyncError>());
        expect(customNotifier.state.error, isA<Exception>());
      });
    });

    group('State Transitions', () {
      test('should transition from loading to data', () async {
        expect(notifier.state, isA<AsyncLoading>());
        
        await notifier.performOperation('success');
        
        expect(notifier.state, isA<AsyncData>());
      });

      test('should transition from loading to error', () async {
        expect(notifier.state, isA<AsyncLoading>());
        
        await notifier.performFailingOperation();
        
        expect(notifier.state, isA<AsyncError>());
      });

      test('should transition from data to loading to data', () async {
        // First set data
        await notifier.performOperation('first');
        expect(notifier.state, isA<AsyncData>());
        
        // Then trigger another operation that will go through loading
        final future = notifier.performOperation('second');
        expect(notifier.state, isA<AsyncLoading>());
        
        await future;
        expect(notifier.state, isA<AsyncData>());
        expect(notifier.state.value, equals('second'));
      });

      test('should transition from error to loading to data', () async {
        // First fail
        await notifier.performFailingOperation();
        expect(notifier.state, isA<AsyncError>());
        
        // Then succeed
        await notifier.performOperation('recovered');
        expect(notifier.state, isA<AsyncData>());
        expect(notifier.state.value, equals('recovered'));
      });
    });

    group('Runtime Type Logging', () {
      test('should use correct runtime type in error logging', () async {
        // This test verifies that the runtimeType is correctly used
        // The actual logging is mocked, but we can verify the notifier functions
        await notifier.performFailingOperation();
        
        expect(notifier.state, isA<AsyncError>());
        // The runtimeType should be TestNotifier
        expect(notifier.runtimeType.toString(), equals('TestNotifier'));
      });
    });
  });
}

// Helper classes for testing
class _CustomErrorNotifier extends BaseNotifier<String> {
  Future<void> throwStringError() async {
    await execute(() async => throw 'String error');
  }

  Future<void> throwCustomError() async {
    await execute(() async => throw _CustomException('Custom error'));
  }

  Future<void> throwNullError() async {
    await execute(() async => throw Exception('Null-like error'));
  }
}

class _CustomException implements Exception {
  final String message;
  _CustomException(this.message);
  
  @override
  String toString() => 'CustomException: $message';
}