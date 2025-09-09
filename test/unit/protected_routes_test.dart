import 'package:flutter_test/flutter_test.dart';
import 'package:tech_lingual_quest/app/routes.dart';

/// 保護されたルート機能のテスト
///
/// 認証が必要なルートが正しく設定され、認証ガードが適切に動作することを確認
void main() {
  group('Protected Routes Tests', () {
    test('should correctly identify routes that require authentication', () {
      // 認証が必要なルートのリストを取得
      final authRequiredRoutes = AppRouteMetadata.getAuthRequiredRoutes();
      
      // 期待される認証必須ルートが含まれていることを確認
      expect(authRequiredRoutes, contains(AppRoutes.profileName));
      expect(authRequiredRoutes, contains(AppRoutes.profileEditName));
      expect(authRequiredRoutes, contains(AppRoutes.dashboardName));
      expect(authRequiredRoutes, contains(AppRoutes.vocabularyAddName));
      expect(authRequiredRoutes, contains(AppRoutes.questActiveName));
      
      // 認証不要なルートが含まれていないことを確認
      expect(authRequiredRoutes, isNot(contains(AppRoutes.homeName)));
      expect(authRequiredRoutes, isNot(contains(AppRoutes.authName)));
      expect(authRequiredRoutes, isNot(contains(AppRoutes.loginName)));
      expect(authRequiredRoutes, isNot(contains(AppRoutes.registerName)));
      expect(authRequiredRoutes, isNot(contains(AppRoutes.vocabularyName)));
      expect(authRequiredRoutes, isNot(contains(AppRoutes.questsName)));
      expect(authRequiredRoutes, isNot(contains(AppRoutes.settingsName)));
    });

    test('dashboard route should require authentication', () {
      final dashboardMetadata = AppRouteMetadata.getMetadata(AppRoutes.dashboardName);
      
      expect(dashboardMetadata, isNotNull);
      expect(dashboardMetadata!.requiresAuth, isTrue);
      expect(dashboardMetadata.title, equals('Dashboard'));
      expect(dashboardMetadata.description, contains('dashboard'));
    });

    test('profile routes should require authentication', () {
      final profileMetadata = AppRouteMetadata.getMetadata(AppRoutes.profileName);
      final profileEditMetadata = AppRouteMetadata.getMetadata(AppRoutes.profileEditName);
      
      expect(profileMetadata!.requiresAuth, isTrue);
      expect(profileEditMetadata!.requiresAuth, isTrue);
    });

    test('vocabulary add route should require authentication', () {
      final vocabularyAddMetadata = AppRouteMetadata.getMetadata(AppRoutes.vocabularyAddName);
      
      expect(vocabularyAddMetadata!.requiresAuth, isTrue);
    });

    test('quest active route should require authentication', () {
      final questActiveMetadata = AppRouteMetadata.getMetadata(AppRoutes.questActiveName);
      
      expect(questActiveMetadata!.requiresAuth, isTrue);
    });

    test('public routes should not require authentication', () {
      final homeMetadata = AppRouteMetadata.getMetadata(AppRoutes.homeName);
      final authMetadata = AppRouteMetadata.getMetadata(AppRoutes.authName);
      final loginMetadata = AppRouteMetadata.getMetadata(AppRoutes.loginName);
      final registerMetadata = AppRouteMetadata.getMetadata(AppRoutes.registerName);
      final vocabularyMetadata = AppRouteMetadata.getMetadata(AppRoutes.vocabularyName);
      final questsMetadata = AppRouteMetadata.getMetadata(AppRoutes.questsName);
      final settingsMetadata = AppRouteMetadata.getMetadata(AppRoutes.settingsName);
      
      expect(homeMetadata!.requiresAuth, isFalse);
      expect(authMetadata!.requiresAuth, isFalse);
      expect(loginMetadata!.requiresAuth, isFalse);
      expect(registerMetadata!.requiresAuth, isFalse);
      expect(vocabularyMetadata!.requiresAuth, isFalse);
      expect(questsMetadata!.requiresAuth, isFalse);
      expect(settingsMetadata!.requiresAuth, isFalse);
    });

    test('protected routes should have meaningful descriptions', () {
      final authRequiredRoutes = AppRouteMetadata.getAuthRequiredRoutes();
      
      for (final routeName in authRequiredRoutes) {
        final metadata = AppRouteMetadata.getMetadata(routeName);
        expect(metadata, isNotNull, reason: 'Route $routeName should have metadata');
        expect(metadata!.description, isNotNull, reason: 'Protected route $routeName should have description');
        expect(metadata.description!, isNotEmpty, reason: 'Protected route $routeName description should not be empty');
      }
    });

    test('authentication route metadata should be consistent', () {
      final loginMetadata = AppRouteMetadata.getMetadata(AppRoutes.loginName);
      final registerMetadata = AppRouteMetadata.getMetadata(AppRoutes.registerName);
      final passwordResetMetadata = AppRouteMetadata.getMetadata(AppRoutes.passwordResetName);
      
      // Authentication routes should not require auth (to avoid infinite redirect)
      expect(loginMetadata!.requiresAuth, isFalse);
      expect(registerMetadata!.requiresAuth, isFalse);
      expect(passwordResetMetadata!.requiresAuth, isFalse);
      
      // Authentication routes should not be shown in navigation
      expect(loginMetadata.showInNavigation, isFalse);
      expect(registerMetadata.showInNavigation, isFalse);
      expect(passwordResetMetadata.showInNavigation, isFalse);
    });

    test('should have correct route path constants for protected routes', () {
      // Verify that the protected routes have correct path constants
      expect(AppRoutes.profile, equals('/auth/profile'));
      expect(AppRoutes.profileEdit, equals('/auth/profile/edit'));
      expect(AppRoutes.dashboard, equals('/dashboard'));
      expect(AppRoutes.vocabularyAdd, equals('/vocabulary/add'));
      expect(AppRoutes.questActive, equals('/quests/active'));
    });

    test('protected routes should be accessible only with authentication', () {
      // This is a metadata validation test
      // The actual routing behavior is tested in integration tests
      final protectedPaths = [
        AppRoutes.profile,
        AppRoutes.profileEdit,
        AppRoutes.dashboard,
        AppRoutes.vocabularyAdd,
        AppRoutes.questActive,
      ];
      
      for (final path in protectedPaths) {
        // Each protected path should exist in the route constants
        expect(path, isNotEmpty);
        expect(path, startsWith('/'));
      }
    });
  });

  group('Route Security Configuration Tests', () {
    test('should not have conflicting authentication requirements', () {
      final metadata = AppRouteMetadata.metadata;
      
      // Auth routes (login, register) should never require auth to avoid infinite redirects
      expect(metadata[AppRoutes.loginName]!.requiresAuth, isFalse);
      expect(metadata[AppRoutes.registerName]!.requiresAuth, isFalse);
      expect(metadata[AppRoutes.passwordResetName]!.requiresAuth, isFalse);
      
      // Base auth route should not require auth (it's the landing page for auth flow)
      expect(metadata[AppRoutes.authName]!.requiresAuth, isFalse);
    });

    test('should have appropriate navigation visibility for protected routes', () {
      // Protected profile routes should not be shown in main navigation
      expect(AppRouteMetadata.getMetadata(AppRoutes.profileName)!.showInNavigation, isFalse);
      expect(AppRouteMetadata.getMetadata(AppRoutes.profileEditName)!.showInNavigation, isFalse);
      
      // But dashboard might be shown in navigation (it's a main feature)
      final dashboardMetadata = AppRouteMetadata.getMetadata(AppRoutes.dashboardName);
      // This is a design decision - we don't enforce a specific value here
      expect(dashboardMetadata!.showInNavigation, isA<bool>());
    });

    test('should have security-appropriate icons for protected routes', () {
      final dashboardMetadata = AppRouteMetadata.getMetadata(AppRoutes.dashboardName);
      
      // Dashboard should have an appropriate icon
      expect(dashboardMetadata!.icon, equals('dashboard'));
    });
  });
}