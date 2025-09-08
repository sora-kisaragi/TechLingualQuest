import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tech_lingual_quest/shared/utils/error_handler.dart';
import 'package:tech_lingual_quest/shared/utils/base_notifier.dart';

void main() {
  group('ErrorHandler Tests', () {
    group('Error Handling', () {
      testWidgets('should handle errors without context', (tester) async {
        const error = 'test error';
        final stackTrace = StackTrace.current;

        // Should not throw when context is null
        expect(
          () => ErrorHandler.handleError(error, stackTrace),
          returnsNormally,
        );
      });

      testWidgets('should handle errors with null context', (tester) async {
        const error = 'test error';
        final stackTrace = StackTrace.current;

        // Should not throw when context is explicitly null
        expect(
          () => ErrorHandler.handleError(
            error,
            stackTrace,
            context: null,
          ),
          returnsNormally,
        );
      });

      testWidgets('should show SnackBar when context is provided', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      ErrorHandler.handleError(
                        'test error',
                        StackTrace.current,
                        context: context,
                        userMessage: 'Test user message',
                      );
                    },
                    child: const Text('Trigger Error'),
                  );
                },
              ),
            ),
          ),
        );

        // Trigger the error
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Verify SnackBar is shown
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Test user message'), findsOneWidget);
      });

      testWidgets('should use default error message when no user message provided', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      ErrorHandler.handleError(
                        'database error occurred',
                        StackTrace.current,
                        context: context,
                      );
                    },
                    child: const Text('Trigger Error'),
                  );
                },
              ),
            ),
          ),
        );

        // Trigger the error
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Verify SnackBar is shown with default error message
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('should allow dismissing SnackBar', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      ErrorHandler.handleError(
                        'test error',
                        StackTrace.current,
                        context: context,
                      );
                    },
                    child: const Text('Trigger Error'),
                  );
                },
              ),
            ),
          ),
        );

        // Trigger the error
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Verify SnackBar is shown
        expect(find.byType(SnackBar), findsOneWidget);

        // Tap the close button
        await tester.tap(find.text('閉じる'));
        await tester.pump();

        // SnackBar should start dismissing
        await tester.pump(const Duration(milliseconds: 100));
      });
    });
  });

  group('AsyncValueErrorHandling Extension Tests', () {
    testWidgets('should show data when AsyncValue has data', (tester) async {
      final asyncValue = AsyncValue.data('test data');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: asyncValue.whenOrError(
              data: (data) => Text('Data: $data'),
              loading: () => const CircularProgressIndicator(),
            ),
          ),
        ),
      );

      expect(find.text('Data: test data'), findsOneWidget);
    });

    testWidgets('should show loading when AsyncValue is loading', (tester) async {
      final asyncValue = const AsyncValue<String>.loading();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: asyncValue.whenOrError(
              data: (data) => Text('Data: $data'),
              loading: () => const CircularProgressIndicator(),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show default error widget when AsyncValue has error', (tester) async {
      final asyncValue = AsyncValue<String>.error(
        'test error',
        StackTrace.current,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: asyncValue.whenOrError(
              data: (data) => Text('Data: $data'),
              loading: () => const CircularProgressIndicator(),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('再試行'), findsOneWidget);
    });

    testWidgets('should use custom error widget when provided', (tester) async {
      final asyncValue = AsyncValue<String>.error(
        'test error',
        StackTrace.current,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: asyncValue.whenOrError(
              data: (data) => Text('Data: $data'),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => const Text('Custom Error'),
            ),
          ),
        ),
      );

      expect(find.text('Custom Error'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });
  });

}

// Helper classes for testing different error types
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

// Helper class for custom exception testing
class _CustomException implements Exception {
  final String message;
  _CustomException(this.message);
  
  @override
  String toString() => 'CustomException: $message';
}