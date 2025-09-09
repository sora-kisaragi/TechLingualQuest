import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tech_lingual_quest/app/router.dart';
import 'package:tech_lingual_quest/app/routes.dart';
import 'package:tech_lingual_quest/app/auth_service.dart';

/// 保護されたルートの統合テスト
/// 
/// 認証ガード機能と実際のナビゲーション動作を検証する
void main() {
  group('Protected Routes Integration Tests', () {
    late ProviderContainer container;
    late AuthService authService;

    setUp(() {
      container = ProviderContainer();
      authService = container.read(authServiceProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('should redirect unauthenticated user from protected route to auth page', (tester) async {
      // Test widget setup
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Home')),
          ),
          GoRoute(
            path: '/auth',
            builder: (context, state) => const Scaffold(body: Text('Auth Page')),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const Scaffold(body: Text('Dashboard')),
          ),
        ],
        redirect: (context, state) {
          // Simulate the route guard logic
          final path = state.uri.toString();
          if (path == '/dashboard') {
            // Check auth state from container
            final isAuthenticated = container.read(isAuthenticatedProvider);
            if (!isAuthenticated) {
              return '/auth';
            }
          }
          return null;
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Verify initial state (should be on home page)
      expect(find.text('Home'), findsOneWidget);

      // Try to navigate to protected route
      router.go('/dashboard');
      await tester.pumpAndSettle();

      // Should be redirected to auth page
      expect(find.text('Auth Page'), findsOneWidget);
      expect(find.text('Dashboard'), findsNothing);
    });

    testWidgets('should allow authenticated user to access protected route', (tester) async {
      // Login the user first
      await authService.login('test@example.com', 'password123');

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Home')),
          ),
          GoRoute(
            path: '/auth',
            builder: (context, state) => const Scaffold(body: Text('Auth Page')),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const Scaffold(body: Text('Dashboard')),
          ),
        ],
        redirect: (context, state) {
          final path = state.uri.toString();
          if (path == '/dashboard') {
            final isAuthenticated = container.read(isAuthenticatedProvider);
            if (!isAuthenticated) {
              return '/auth';
            }
          }
          return null;
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Navigate to protected route
      router.go('/dashboard');
      await tester.pumpAndSettle();

      // Should be able to access dashboard
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Auth Page'), findsNothing);
    });

    test('route guard should return correct redirect for protected routes', () {
      // This tests the logic without widget rendering
      
      // Mock route state
      final mockState = _MockGoRouterState('/dashboard');
      
      // Test unauthenticated access
      container.read(authServiceProvider.notifier).logout();
      
      // Simulate route guard check
      final isAuthenticated = container.read(isAuthenticatedProvider);
      final shouldRedirect = !isAuthenticated && _isProtectedRoute('/dashboard');
      
      expect(shouldRedirect, isTrue);
    });

    test('route guard should allow access to public routes', () {
      final publicRoutes = [
        AppRoutes.home,
        AppRoutes.auth,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.vocabulary,
        AppRoutes.quests,
        AppRoutes.settings,
      ];

      for (final route in publicRoutes) {
        final shouldRedirect = _isProtectedRoute(route);
        expect(shouldRedirect, isFalse, reason: 'Route $route should be public');
      }
    });

    test('route guard should protect authenticated routes', () {
      final protectedRoutes = [
        AppRoutes.profile,
        AppRoutes.profileEdit,
        AppRoutes.dashboard,
        AppRoutes.vocabularyAdd,
        AppRoutes.questActive,
      ];

      for (final route in protectedRoutes) {
        final shouldRedirect = _isProtectedRoute(route);
        expect(shouldRedirect, isTrue, reason: 'Route $route should be protected');
      }
    });
  });

  group('Route Guard Edge Cases', () {
    test('should handle invalid routes gracefully', () {
      final invalidRoutes = [
        '/nonexistent',
        '/auth/invalid',
        '/vocabulary/invalid/nested',
        '',
        '/',
      ];

      for (final route in invalidRoutes) {
        expect(() => _isProtectedRoute(route), returnsNormally);
      }
    });

    test('should handle route parameters correctly', () {
      final parametrizedRoutes = [
        '/vocabulary/123',
        '/quests/456',
        '/vocabulary/add', // This should be protected
      ];

      // Only vocabulary/add should be protected
      expect(_isProtectedRoute('/vocabulary/123'), isFalse);
      expect(_isProtectedRoute('/quests/456'), isFalse);
      expect(_isProtectedRoute('/vocabulary/add'), isTrue);
    });
  });
}

// Helper function to determine if a route is protected
// This simulates the logic from _getRouteNameFromPath and route metadata
bool _isProtectedRoute(String path) {
  String routeName;
  
  // Simplified version of _getRouteNameFromPath logic
  if (path == AppRoutes.home) routeName = AppRoutes.homeName;
  else if (path.startsWith('/auth/profile/edit')) routeName = AppRoutes.profileEditName;
  else if (path.startsWith('/auth/profile')) routeName = AppRoutes.profileName;
  else if (path.startsWith('/auth/login')) routeName = AppRoutes.loginName;
  else if (path.startsWith('/auth/register')) routeName = AppRoutes.registerName;
  else if (path.startsWith('/auth/password-reset')) routeName = AppRoutes.passwordResetName;
  else if (path.startsWith('/auth')) routeName = AppRoutes.authName;
  else if (path.startsWith('/vocabulary/add')) routeName = AppRoutes.vocabularyAddName;
  else if (path.contains('/vocabulary/') && path.split('/').length > 2) routeName = AppRoutes.vocabularyDetailName;
  else if (path.startsWith('/vocabulary')) routeName = AppRoutes.vocabularyName;
  else if (path.startsWith('/quests/active')) routeName = AppRoutes.questActiveName;
  else if (path.contains('/quests/') && path.split('/').length > 2) routeName = AppRoutes.questDetailName;
  else if (path.startsWith('/quests')) routeName = AppRoutes.questsName;
  else if (path.startsWith('/dashboard')) routeName = AppRoutes.dashboardName;
  else if (path.startsWith('/settings')) routeName = AppRoutes.settingsName;
  else if (path.startsWith('/about')) routeName = AppRoutes.aboutName;
  else routeName = AppRoutes.homeName;

  final metadata = AppRouteMetadata.getMetadata(routeName);
  return metadata?.requiresAuth ?? false;
}

// Mock GoRouterState for testing
class _MockGoRouterState extends GoRouterState {
  _MockGoRouterState(String path) : super(
    location: path,
    subloc: path,
    name: null,
    path: path,
    fullpath: path,
    params: {},
    queryParams: {},
    queryParametersAll: {},
    extra: null,
    error: null,
    pageKey: const ValueKey('test'),
    uri: Uri.parse(path),
  );
}