import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tech_lingual_quest/main.dart';

void main() {
  group('TechLingual Quest App Tests', () {
    testWidgets('App should display title and welcome message', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const TechLingualQuestApp());

      // Verify that the app title is displayed
      expect(find.text('TechLingual Quest'), findsOneWidget);
      
      // Verify that the welcome message is displayed
      expect(find.text('Welcome to TechLingual Quest!'), findsOneWidget);
      
      // Verify that XP counter starts at 0
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('Tap floating action button to earn XP', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const TechLingualQuestApp());

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

    testWidgets('Multiple taps should accumulate XP', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const TechLingualQuestApp());

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

    testWidgets('Should display feature list', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const TechLingualQuestApp());

      // Verify that feature list is displayed
      expect(find.text('Features coming soon:'), findsOneWidget);
      expect(find.text('• Daily quests and challenges'), findsOneWidget);
      expect(find.text('• Vocabulary building with spaced repetition'), findsOneWidget);
      expect(find.text('• Technical article summaries'), findsOneWidget);
      expect(find.text('• Progress tracking and achievements'), findsOneWidget);
      expect(find.text('• AI-powered conversation practice'), findsOneWidget);
    });
  });
}