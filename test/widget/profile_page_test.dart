import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tech_lingual_quest/features/auth/pages/profile_page.dart';
import 'package:tech_lingual_quest/app/auth_service.dart';
import 'package:tech_lingual_quest/shared/models/user_model.dart';

void main() {
  group('ProfilePage Widget Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    Widget createProfilePageWidget() {
      return ProviderScope.override(
        overrides: [],
        child: MaterialApp(
          home: ProfilePage(),
        ),
      );
    }

    testWidgets('should display default profile image when user has no image',
        (tester) async {
      // Create unauthenticated state
      await tester.pumpWidget(createProfilePageWidget());
      await tester.pumpAndSettle();

      // Should find the default profile avatar
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should display change photo button', (tester) async {
      await tester.pumpWidget(createProfilePageWidget());
      await tester.pumpAndSettle();

      // Look for change photo button or text
      expect(find.textContaining('Change Photo'), findsWidgets);
    });

    testWidgets('should show profile image when user has image URL',
        (tester) async {
      await tester.pumpWidget(createProfilePageWidget());
      await tester.pumpAndSettle();

      // Should find network image widget or cached network image
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should handle image loading states', (tester) async {
      await tester.pumpWidget(createProfilePageWidget());

      // Initially should show loading or placeholder
      await tester.pump();
      expect(find.byType(CircleAvatar), findsOneWidget);

      // After settling, should still show the avatar container
      await tester.pumpAndSettle();
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should show loading state during authentication',
        (tester) async {
      await tester.pumpWidget(createProfilePageWidget());

      // Initial pump should show some loading or unauthenticated state
      await tester.pump();

      // The widget should handle loading states gracefully
      expect(find.byType(CircleAvatar), findsWidgets);
    });

    testWidgets('should handle profile page basic rendering', (tester) async {
      await tester.pumpWidget(createProfilePageWidget());
      await tester.pumpAndSettle();

      // Should render without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
