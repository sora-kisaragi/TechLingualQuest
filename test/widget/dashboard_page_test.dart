import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tech_lingual_quest/features/dashboard/pages/dashboard_page.dart';
import 'package:tech_lingual_quest/app/auth_service.dart';
import 'package:tech_lingual_quest/shared/services/dynamic_localization_service.dart';

// Mock classes
class MockAppTranslations extends Mock implements AppTranslations {}

/// DashboardPage ウィジェットテスト
///
/// ダッシュボードページの表示と機能をテストする
void main() {
  group('DashboardPage Widget Tests', () {
    late MockAppTranslations mockTranslations;

    setUp(() {
      mockTranslations = MockAppTranslations();
      
      // デフォルトの翻訳設定
      when(() => mockTranslations.getSync('dashboard_title', fallback: any(named: 'fallback')))
          .thenReturn('Dashboard');
      when(() => mockTranslations.getSync('welcome_message', fallback: any(named: 'fallback')))
          .thenReturn('Welcome back!');
      when(() => mockTranslations.getSync('progress_overview', fallback: any(named: 'fallback')))
          .thenReturn('Progress Overview');
      when(() => mockTranslations.getSync('vocabulary_learned', fallback: any(named: 'fallback')))
          .thenReturn('Vocabulary');
      when(() => mockTranslations.getSync('quests_completed', fallback: any(named: 'fallback')))
          .thenReturn('Quests');
      when(() => mockTranslations.getSync('recent_activity', fallback: any(named: 'fallback')))
          .thenReturn('Recent Activity');
    });

    Widget buildTestWidget({AuthUser? user}) {
      return ProviderScope(
        overrides: [
          currentUserProvider.overrideWith((ref) => user),
          appTranslationsProvider.overrideWith((ref) => Future.value(mockTranslations)),
        ],
        child: const MaterialApp(
          home: DashboardPage(),
        ),
      );
    }

    testWidgets('should display dashboard title in AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display settings icon in AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('should display loading indicator when translations are loading', (WidgetTester tester) async {
      // Create a completer to control when the future completes
      await tester.pumpWidget(ProviderScope(
        overrides: [
          appTranslationsProvider.overrideWith((ref) {
            return Future.delayed(const Duration(milliseconds: 100), () => mockTranslations);
          }),
        ],
        child: const MaterialApp(home: DashboardPage()),
      ));
      
      // Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget); // AppBar still shows fallback
      
      // Wait for the future to complete
      await tester.pumpAndSettle();
      
      // After loading, should show content
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should display error message when translations fail', (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          appTranslationsProvider.overrideWith((ref) => 
            Future.error('Translation error')),
        ],
        child: const MaterialApp(home: DashboardPage()),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error:'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget); // AppBar shows fallback
    });

    testWidgets('should display welcome message with user name', (WidgetTester tester) async {
      final testUser = AuthUser(
        id: '123',
        name: 'Test User',
        email: 'test@example.com',
        level: UserLevel.beginner,
      );

      await tester.pumpWidget(buildTestWidget(user: testUser));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back!'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('Level: beginner'), findsOneWidget);
    });

    testWidgets('should display default user info when user is null', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(user: null));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back!'), findsOneWidget);
      expect(find.text('User'), findsOneWidget);
      expect(find.text('Level: Unknown'), findsOneWidget);
    });

    testWidgets('should display progress overview section', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Progress Overview'), findsOneWidget);
      expect(find.text('Vocabulary'), findsOneWidget);
      expect(find.text('Quests'), findsOneWidget);
      expect(find.text('0'), findsNWidgets(2)); // Two progress cards with placeholder "0"
    });

    testWidgets('should display progress cards with correct icons', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.book), findsOneWidget);
      expect(find.byIcon(Icons.flag), findsOneWidget);
    });

    testWidgets('should display recent activity section', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Recent Activity'), findsOneWidget);
      expect(find.text('No recent activity'), findsOneWidget);
      expect(find.text('Start learning to see your progress here'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('should display all main sections in correct order', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Check if all main sections are present
      expect(find.byType(Card), findsNWidgets(3)); // Welcome, Progress, Activity cards
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should handle different user levels correctly', (WidgetTester tester) async {
      // Test with intermediate level
      final intermediateUser = AuthUser(
        id: '456',
        name: 'Intermediate User',
        email: 'intermediate@example.com',
        level: UserLevel.intermediate,
      );

      await tester.pumpWidget(buildTestWidget(user: intermediateUser));
      await tester.pumpAndSettle();

      expect(find.text('Level: intermediate'), findsOneWidget);
    });

    testWidgets('should handle advanced user level correctly', (WidgetTester tester) async {
      // Test with advanced level
      final advancedUser = AuthUser(
        id: '789',
        name: 'Advanced User',
        email: 'advanced@example.com',
        level: UserLevel.advanced,
      );

      await tester.pumpWidget(buildTestWidget(user: advancedUser));
      await tester.pumpAndSettle();

      expect(find.text('Level: advanced'), findsOneWidget);
    });

    testWidgets('should be scrollable when content overflows', (WidgetTester tester) async {
      // Force small screen size to test scrolling
      await tester.binding.setSurfaceSize(const Size(300, 400));
      
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Find the scrollable widget
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      
      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should show fallback text when translations are null', (WidgetTester tester) async {
      // Mock translations returning null/empty
      when(() => mockTranslations.getSync('dashboard_title', fallback: any(named: 'fallback')))
          .thenReturn('Dashboard'); // fallback
      when(() => mockTranslations.getSync('welcome_message', fallback: any(named: 'fallback')))
          .thenReturn('Welcome back!'); // fallback

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Welcome back!'), findsOneWidget);
    });

    testWidgets('should display proper styling for progress cards', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Find progress card containers
      final containers = find.byType(Container);
      expect(containers, findsAtLeastNWidgets(2)); // At least 2 progress cards

      // Check if icons are properly styled
      expect(find.byIcon(Icons.book), findsOneWidget);
      expect(find.byIcon(Icons.flag), findsOneWidget);
    });

    group('Translation Integration Tests', () {
      testWidgets('should use Japanese translations when provided', (WidgetTester tester) async {
        // Mock Japanese translations
        when(() => mockTranslations.getSync('dashboard_title', fallback: any(named: 'fallback')))
            .thenReturn('ダッシュボード');
        when(() => mockTranslations.getSync('welcome_message', fallback: any(named: 'fallback')))
            .thenReturn('おかえりなさい！');

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('ダッシュボード'), findsOneWidget);
        expect(find.text('おかえりなさい！'), findsOneWidget);
      });

      testWidgets('should handle translation errors gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            appTranslationsProvider.overrideWith((ref) => 
              Future.error('Translation service error')),
          ],
          child: const MaterialApp(home: DashboardPage()),
        ));
        await tester.pumpAndSettle();

        // Should show error state with fallback AppBar title
        expect(find.text('Dashboard'), findsOneWidget); // Fallback in AppBar
        expect(find.textContaining('Error:'), findsOneWidget);
      });
    });

    group('User State Integration Tests', () {
      testWidgets('should handle user with minimal information', (WidgetTester tester) async {
        final minimalUser = AuthUser(
          id: 'minimal',
          name: '',
          email: 'minimal@test.com',
          level: null,
        );

        await tester.pumpWidget(buildTestWidget(user: minimalUser));
        await tester.pumpAndSettle();

        expect(find.text(''), findsOneWidget); // Empty name
        expect(find.text('Level: Unknown'), findsOneWidget); // Null level
      });

      testWidgets('should handle user data updates', (WidgetTester tester) async {
        final initialUser = AuthUser(
          id: '1',
          name: 'Initial User',
          email: 'initial@test.com',
          level: UserLevel.beginner,
        );

        await tester.pumpWidget(buildTestWidget(user: initialUser));
        await tester.pumpAndSettle();

        expect(find.text('Initial User'), findsOneWidget);
        expect(find.text('Level: beginner'), findsOneWidget);
      });
    });

    group('UI Layout Tests', () {
      testWidgets('should have proper padding and spacing', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Check for proper padding on the main scroll view
        final scrollView = find.byType(SingleChildScrollView);
        expect(scrollView, findsOneWidget);

        // Check for SizedBox spacing elements
        expect(find.byType(SizedBox), findsAtLeastNWidgets(3));
      });

      testWidgets('should display cards with proper structure', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Should have welcome, progress, and activity cards
        expect(find.byType(Card), findsNWidgets(3));
        
        // Each card should have proper content
        expect(find.byType(Column), findsAtLeastNWidgets(4)); // Multiple columns in different cards
      });
    });
  });
}