import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tech_lingual_quest/shared/utils/navigation_helper.dart';
import 'package:tech_lingual_quest/app/routes.dart';

// Mock classes
class MockGoRouter extends Mock implements GoRouter {}

class MockRouterDelegate extends Mock implements GoRouterDelegate {}

class MockRouteMatch extends Mock implements RouteMatch {}

class MockGoRouterState extends Mock implements GoRouterState {}

void main() {
  late MockGoRouter mockRouter;
  late MockRouterDelegate mockRouterDelegate;
  late MockRouteMatch mockRouteMatch;

  setUpAll(() {
    registerFallbackValue(Uri.parse('/'));
  });

  setUp(() {
    mockRouter = MockGoRouter();
    mockRouterDelegate = MockRouterDelegate();
    mockRouteMatch = MockRouteMatch();
  });

  Widget createTestApp({required Widget child}) {
    return MaterialApp(
      home: Builder(
        builder: (context) => child,
      ),
    );
  }

  group('NavigationHelper Route Methods Tests', () {
    testWidgets('goHome should navigate to home route', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/other',
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () {
                      NavigationHelper.goHome(context);
                    },
                    child: const Text('Go Home'),
                  );
                },
              ),
              GoRoute(
                path: '/',
                builder: (context, state) => const Text('Home Page'),
              ),
            ],
            initialLocation: '/other',
          ),
        ),
      );

      expect(find.text('Go Home'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('goAuth should navigate to auth route', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () => NavigationHelper.goAuth(context),
                    child: const Text('Go Auth'),
                  );
                },
              ),
              GoRoute(
                path: AppRoutes.auth,
                builder: (context, state) => const Text('Auth Page'),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(find.text('Auth Page'), findsOneWidget);
    });

    testWidgets('goLogin should navigate to login route', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () => NavigationHelper.goLogin(context),
                    child: const Text('Go Login'),
                  );
                },
              ),
              GoRoute(
                path: AppRoutes.login,
                builder: (context, state) => const Text('Login Page'),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(find.text('Login Page'), findsOneWidget);
    });

    testWidgets('goRegister should navigate to register route', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () => NavigationHelper.goRegister(context),
                    child: const Text('Go Register'),
                  );
                },
              ),
              GoRoute(
                path: AppRoutes.register,
                builder: (context, state) => const Text('Register Page'),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(find.text('Register Page'), findsOneWidget);
    });

    testWidgets('goProfile should navigate to profile route', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () => NavigationHelper.goProfile(context),
                    child: const Text('Go Profile'),
                  );
                },
              ),
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const Text('Profile Page'),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(find.text('Profile Page'), findsOneWidget);
    });

    testWidgets('goVocabulary should navigate to vocabulary route', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () => NavigationHelper.goVocabulary(context),
                    child: const Text('Go Vocabulary'),
                  );
                },
              ),
              GoRoute(
                path: AppRoutes.vocabulary,
                builder: (context, state) => const Text('Vocabulary Page'),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(find.text('Vocabulary Page'), findsOneWidget);
    });

    testWidgets('goVocabularyDetail should navigate to vocabulary detail route', (tester) async {
      const testId = 'test-id';
      
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () => NavigationHelper.goVocabularyDetail(context, testId),
                    child: const Text('Go Vocabulary Detail'),
                  );
                },
              ),
              GoRoute(
                path: '/vocabulary/:id',
                builder: (context, state) => Text('Vocabulary Detail: ${state.pathParameters['id']}'),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(find.text('Vocabulary Detail: $testId'), findsOneWidget);
    });

    testWidgets('goQuests should navigate to quests route', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () => NavigationHelper.goQuests(context),
                    child: const Text('Go Quests'),
                  );
                },
              ),
              GoRoute(
                path: AppRoutes.quests,
                builder: (context, state) => const Text('Quests Page'),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(find.text('Quests Page'), findsOneWidget);
    });

    testWidgets('goVocabularyAdd should navigate to vocabulary add route', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () => NavigationHelper.goVocabularyAdd(context),
                    child: const Text('Go Vocabulary Add'),
                  );
                },
              ),
              GoRoute(
                path: AppRoutes.vocabularyAdd,
                builder: (context, state) => const Text('Vocabulary Add Page'),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(find.text('Vocabulary Add Page'), findsOneWidget);
    });

    testWidgets('goActiveQuest should navigate to active quest route', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () => NavigationHelper.goActiveQuest(context),
                    child: const Text('Go Active Quest'),
                  );
                },
              ),
              GoRoute(
                path: AppRoutes.questActive,
                builder: (context, state) => const Text('Active Quest Page'),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(find.text('Active Quest Page'), findsOneWidget);
    });

    testWidgets('goSettings should navigate to settings route', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () => NavigationHelper.goSettings(context),
                    child: const Text('Go Settings'),
                  );
                },
              ),
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const Text('Settings Page'),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(find.text('Settings Page'), findsOneWidget);
    });

    testWidgets('goAbout should navigate to about route', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () => NavigationHelper.goAbout(context),
                    child: const Text('Go About'),
                  );
                },
              ),
              GoRoute(
                path: AppRoutes.about,
                builder: (context, state) => const Text('About Page'),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(find.text('About Page'), findsOneWidget);
    });
  });

  group('NavigationHelper Named Route Tests', () {
    testWidgets('goNamed should navigate to named route', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () => NavigationHelper.goNamed(context, 'test'),
                    child: const Text('Go Named'),
                  );
                },
              ),
              GoRoute(
                path: '/test',
                name: 'test',
                builder: (context, state) => const Text('Test Page'),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(find.text('Test Page'), findsOneWidget);
    });

    testWidgets('goNamed should navigate with path parameters', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () => NavigationHelper.goNamed(
                      context, 
                      'test',
                      pathParameters: {'id': '123'},
                    ),
                    child: const Text('Go Named With Params'),
                  );
                },
              ),
              GoRoute(
                path: '/test/:id',
                name: 'test',
                builder: (context, state) => Text('Test Page: ${state.pathParameters['id']}'),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(find.text('Test Page: 123'), findsOneWidget);
    });

    testWidgets('pushNamed should push named route', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) {
                  return Column(
                    children: [
                      const Text('Home Page'),
                      ElevatedButton(
                        onPressed: () => NavigationHelper.pushNamed(context, 'test'),
                        child: const Text('Push Named'),
                      ),
                    ],
                  );
                },
              ),
              GoRoute(
                path: '/test',
                name: 'test',
                builder: (context, state) {
                  return Column(
                    children: [
                      const Text('Test Page'),
                      ElevatedButton(
                        onPressed: () => NavigationHelper.goBack(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      );

      // Verify home page
      expect(find.text('Home Page'), findsOneWidget);
      
      // Push to test page
      await tester.tap(find.text('Push Named'));
      await tester.pumpAndSettle();
      
      expect(find.text('Test Page'), findsOneWidget);
      
      // Go back to home
      await tester.tap(find.text('Go Back'));
      await tester.pumpAndSettle();
      
      expect(find.text('Home Page'), findsOneWidget);
    });
  });

  group('NavigationHelper Utility Methods Tests', () {
    test('buildUrlWithQuery should build URL with query parameters', () {
      const path = '/test';
      const queryParams = {'param1': 'value1', 'param2': 'value2'};
      
      final result = NavigationHelper.buildUrlWithQuery(path, queryParams);
      
      expect(result, contains('param1=value1'));
      expect(result, contains('param2=value2'));
    });

    test('buildUrlWithQuery should return original path if no query parameters', () {
      const path = '/test';
      const queryParams = <String, String>{};
      
      final result = NavigationHelper.buildUrlWithQuery(path, queryParams);
      
      expect(result, equals(path));
    });

    test('extractQueryParameters should extract query parameters from URL', () {
      const url = '/test?param1=value1&param2=value2';
      
      final result = NavigationHelper.extractQueryParameters(url);
      
      expect(result, hasLength(2));
      expect(result['param1'], equals('value1'));
      expect(result['param2'], equals('value2'));
    });

    test('extractQueryParameters should return empty map for URL without query', () {
      const url = '/test';
      
      final result = NavigationHelper.extractQueryParameters(url);
      
      expect(result, isEmpty);
    });

    test('buildUrlWithPathParams should build URL with path parameters', () {
      const template = '/quests/:id/items/:itemId';
      const pathParams = {'id': 'quest-123', 'itemId': 'item-456'};
      
      final result = NavigationHelper.buildUrlWithPathParams(template, pathParams);
      
      expect(result, equals('/quests/quest-123/items/item-456'));
    });

    test('buildUrlWithPathParams should handle empty parameters', () {
      const template = '/quests';
      const pathParams = <String, String>{};
      
      final result = NavigationHelper.buildUrlWithPathParams(template, pathParams);
      
      expect(result, equals(template));
    });
  });

  group('NavigationHelper Route Metadata Tests', () {
    test('getRouteMetadata should return metadata for existing route', () {
      final metadata = NavigationHelper.getRouteMetadata(AppRoutes.homeName);
      
      expect(metadata, isNotNull);
      expect(metadata!.title, equals('Home'));
    });

    test('getRouteMetadata should return null for non-existing route', () {
      final metadata = NavigationHelper.getRouteMetadata('non-existing-route');
      
      expect(metadata, isNull);
    });

    test('getNavigationRoutes should return navigation routes', () {
      final routes = NavigationHelper.getNavigationRoutes();
      
      expect(routes, isNotEmpty);
      
      // Check that returned routes have showInNavigation = true
      for (final entry in routes) {
        expect(entry.value.showInNavigation, isTrue);
      }
    });

    test('requiresAuth should return correct auth requirement', () {
      expect(NavigationHelper.requiresAuth(AppRoutes.profileName), isTrue);
      expect(NavigationHelper.requiresAuth(AppRoutes.dashboardName), isTrue);
      expect(NavigationHelper.requiresAuth(AppRoutes.homeName), isFalse);
      expect(NavigationHelper.requiresAuth(AppRoutes.loginName), isFalse);
    });

    test('requiresAuth should return false for non-existing route', () {
      expect(NavigationHelper.requiresAuth('non-existing-route'), isFalse);
    });
  });

  group('NavigationHelper Deep Link Tests', () {
    testWidgets('handleDeepLink should navigate to valid URL', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () => NavigationHelper.handleDeepLink(context, '/vocabulary'),
                    child: const Text('Handle Deep Link'),
                  );
                },
              ),
              GoRoute(
                path: '/vocabulary',
                builder: (context, state) => const Text('Vocabulary via Deep Link'),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(find.text('Vocabulary via Deep Link'), findsOneWidget);
    });

    testWidgets('handleDeepLink should navigate to URL with query parameters', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () => NavigationHelper.handleDeepLink(context, '/vocabulary?level=beginner'),
                    child: const Text('Handle Deep Link'),
                  );
                },
              ),
              GoRoute(
                path: '/vocabulary',
                builder: (context, state) => Text('Vocabulary: ${state.uri.queryParameters['level'] ?? 'no level'}'),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(find.text('Vocabulary: beginner'), findsOneWidget);
    });
  });

  group('NavigationHelper Back Navigation Tests', () {
    testWidgets('goBack should pop when context can pop', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const Text('Home Page'),
              ),
              GoRoute(
                path: '/other',
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () => NavigationHelper.goBack(context),
                    child: const Text('Go Back'),
                  );
                },
              ),
            ],
          ),
        ),
      );

      // Navigate to /other first
      await tester.pumpAndSettle();
      expect(find.text('Home Page'), findsOneWidget);
    });
  });
}