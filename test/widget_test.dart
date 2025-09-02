import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tech_lingual_quest/main.dart';
import 'helpers/test_config.dart';

void main() {
  group('TechLingual Quest App Tests', () {
    // ウィジェットテストのセットアップ
    setUpAll(() async {
      // テスト用のモック環境設定
      await TestConfig.initializeForTest();
    });

    tearDownAll(() {
      // テスト終了後のクリーンアップ
      TestConfig.cleanup();
    });

    testWidgets('App should initialize and display home page',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester
          .pumpWidget(const ProviderScope(child: TechLingualQuestApp()));

      // Wait for initialization to complete
      await tester.pumpAndSettle();

      // Verify that the app title is displayed
      expect(find.text('TechLingual Quest'), findsOneWidget);

      // Verify that the welcome message is displayed
      expect(find.text('Welcome to TechLingual Quest!'), findsOneWidget);

      // Verify that XP counter starts at 0
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('Tap floating action button to earn XP',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester
          .pumpWidget(const ProviderScope(child: TechLingualQuestApp()));
      await tester.pumpAndSettle();

      // Verify initial XP is 0
      expect(find.text('0'), findsOneWidget);
      expect(find.text('10'), findsNothing);

      // Tap the '+' icon and trigger a frame.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify XP increased to 10
      expect(find.text('0'), findsNothing);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('Multiple taps should accumulate XP',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester
          .pumpWidget(const ProviderScope(child: TechLingualQuestApp()));
      await tester.pumpAndSettle();

      // Tap the '+' icon multiple times
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify XP accumulated to 30
      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('Should display feature list and navigation buttons',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester
          .pumpWidget(const ProviderScope(child: TechLingualQuestApp()));
      await tester.pumpAndSettle();

      // Verify that feature list is displayed
      expect(find.text('Features:'), findsOneWidget);
      expect(find.text('• Daily quests and challenges'), findsOneWidget);
      expect(find.text('• Vocabulary building with spaced repetition'),
          findsOneWidget);
      expect(find.text('• Technical article summaries'), findsOneWidget);
      expect(find.text('• Progress tracking and achievements'), findsOneWidget);
      expect(find.text('• AI-powered conversation practice'), findsOneWidget);

      // Verify navigation buttons are present
      expect(find.text('Vocabulary'), findsOneWidget);
      expect(find.text('Quests'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Should navigate to vocabulary page',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester
          .pumpWidget(const ProviderScope(child: TechLingualQuestApp()));
      await tester.pumpAndSettle();

      // Tap vocabulary button
      await tester.tap(find.text('Vocabulary'));
      await tester.pumpAndSettle();

      // Verify navigation to vocabulary page
      expect(find.text('Vocabulary Learning'), findsOneWidget);
      expect(
          find.text(
              'Vocabulary cards and learning features will be implemented here'),
          findsOneWidget);
    });

    testWidgets('Should navigate to quests page', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester
          .pumpWidget(const ProviderScope(child: TechLingualQuestApp()));
      await tester.pumpAndSettle();

      // Tap quests button
      await tester.tap(find.text('Quests'));
      await tester.pumpAndSettle();

      // Verify navigation to quests page
      expect(find.text('Daily Quests'), findsOneWidget);
      expect(
          find.text(
              'Quest system and gamification features will be implemented here'),
          findsOneWidget);
    });

    testWidgets('Should navigate to profile page',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester
          .pumpWidget(const ProviderScope(child: TechLingualQuestApp()));
      await tester.pumpAndSettle();

      // Tap profile button
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Verify navigation to profile page
      expect(find.text('Authentication'), findsOneWidget);
      expect(find.text('User authentication will be implemented here'),
          findsOneWidget);
    });

    testWidgets('Should navigate back to home from other pages',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester
          .pumpWidget(const ProviderScope(child: TechLingualQuestApp()));
      await tester.pumpAndSettle();

      // Navigate to vocabulary page
      await tester.tap(find.text('Vocabulary'));
      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back on home page
      expect(find.text('Welcome to TechLingual Quest!'), findsOneWidget);
    });
  });
}
