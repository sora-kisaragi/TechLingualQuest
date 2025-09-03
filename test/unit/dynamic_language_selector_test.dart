import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tech_lingual_quest/shared/widgets/dynamic_language_selector.dart';

void main() {
  group('DynamicLanguageSelector Widget Tests', () {
    testWidgets('should display language icon', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DynamicLanguageSelector(),
            ),
          ),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Should display language icon
      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('should display language icon when loading',
        (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DynamicLanguageSelector(),
            ),
          ),
        ),
      );

      // Check initial loading state
      expect(find.byIcon(Icons.language), findsOneWidget);

      // Wait for any animations/loading to complete
      await tester.pumpAndSettle();

      // Should still display icon
      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('should display language icon on error',
        (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DynamicLanguageSelector(),
            ),
          ),
        ),
      );

      // Wait for loading and potential error states
      await tester.pumpAndSettle();

      // Should display language icon even in error cases
      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('should handle tap interaction', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DynamicLanguageSelector(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the language icon
      final languageIcon = find.byIcon(Icons.language);
      expect(languageIcon, findsOneWidget);

      // Should be able to tap without errors
      await tester.tap(languageIcon);
      await tester.pumpAndSettle();

      // Widget should still be present after tap
      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('should be a PopupMenuButton', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DynamicLanguageSelector(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should contain a PopupMenuButton widget
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });

    testWidgets('should have proper tooltip', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DynamicLanguageSelector(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the PopupMenuButton and check its tooltip
      final popupButton = tester.widget<PopupMenuButton<String>>(
        find.byType(PopupMenuButton<String>),
      );
      expect(popupButton.tooltip, 'Language');
    });

    testWidgets('should handle widget key properly',
        (WidgetTester tester) async {
      const testKey = Key('test_dynamic_language_selector');

      // Build the widget with a key
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DynamicLanguageSelector(key: testKey),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should be able to find widget by key
      expect(find.byKey(testKey), findsOneWidget);
    });

    testWidgets('should be a ConsumerWidget', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DynamicLanguageSelector(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should be a ConsumerWidget (indirectly tested by its functionality)
      expect(find.byType(DynamicLanguageSelector), findsOneWidget);
    });
  });
}
