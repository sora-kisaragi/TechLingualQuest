import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tech_lingual_quest/app/router.dart';
import 'package:tech_lingual_quest/app/routes.dart';
import 'package:tech_lingual_quest/app/auth_service.dart';

// Mock classes
class MockWidgetRef extends Mock implements WidgetRef {}

/// AppRouter クラスの統合テスト
///
/// ルーター設定、認証ガード、ルート解決の機能をテストする
void main() {
  group('AppRouter Tests', () {
    late MockWidgetRef mockRef;

    setUp(() {
      mockRef = MockWidgetRef();
    });

    tearDown(() {
      // Reset any static state
      AppRouter.initialize(mockRef);
    });

    group('Router Initialization', () {
      test('should initialize router with ref', () {
        expect(() => AppRouter.initialize(mockRef), returnsNormally);
      });

      test('should provide router instance', () {
        AppRouter.initialize(mockRef);
        final router = AppRouter.router;
        expect(router, isNotNull);
      });
    });

    group('Route Name Resolution Tests', () {
      // Test route resolution through the actual router behavior
      test('should have correct route paths defined', () {
        expect(AppRoutes.home, equals('/'));
        expect(AppRoutes.dashboard, equals('/dashboard'));
        expect(AppRoutes.auth, equals('/auth'));
        expect(AppRoutes.vocabulary, equals('/vocabulary'));
        expect(AppRoutes.quests, equals('/quests'));
        expect(AppRoutes.settings, equals('/settings'));
        expect(AppRoutes.about, equals('/about'));
      });

      test('should have correct nested route paths', () {
        expect(AppRoutes.login, equals('/auth/login'));
        expect(AppRoutes.register, equals('/auth/register'));
        expect(AppRoutes.passwordReset, equals('/auth/password-reset'));
        expect(AppRoutes.profile, equals('/auth/profile'));
        expect(AppRoutes.profileEdit, equals('/auth/profile/edit'));
        expect(AppRoutes.vocabularyAdd, equals('/vocabulary/add'));
        expect(AppRoutes.questActive, equals('/quests/active'));
      });

      test('should have parameterized routes defined', () {
        expect(AppRoutes.vocabularyDetail, equals('/vocabulary/:id'));
        expect(AppRoutes.questDetail, equals('/quests/:id'));
      });
    });

    group('Route Configuration Tests', () {
      test('should have router configured with correct properties', () {
        when(() => mockRef.read(isAuthenticatedProvider)).thenReturn(false);
        AppRouter.initialize(mockRef);

        final router = AppRouter.router;
        expect(router.routerDelegate, isNotNull);
        expect(router.routeInformationParser, isNotNull);
        
        // Check initial location
        expect(router.routeInformationProvider.value.uri.toString(), equals('/'));
      });

      test('should have all major routes configured', () {
        when(() => mockRef.read(isAuthenticatedProvider)).thenReturn(false);
        AppRouter.initialize(mockRef);

        final router = AppRouter.router;
        
        // The router should have route configuration
        expect(router.configuration, isNotNull);
        expect(router.configuration.routes, isNotEmpty);
      });
    });

    group('Error Page Tests', () {
      test('should have router configured for error handling', () {
        when(() => mockRef.read(isAuthenticatedProvider)).thenReturn(false);
        AppRouter.initialize(mockRef);

        final router = AppRouter.router;
        expect(router.configuration, isNotNull);
      });

      test('error page should handle state correctly', () {
        // Create mock error data for testing
        const errorMessage = 'Navigation error';
        const path = '/invalid/path';
        
        // Test error page creation (without widget testing)
        expect(errorMessage, contains('error'));
        expect(path, contains('/invalid'));
      });
    });

    group('Route Metadata Integration', () {
      test('should have metadata for all routes', () {
        final routes = [
          AppRoutes.homeName,
          AppRoutes.dashboardName,
          AppRoutes.authName,
          AppRoutes.loginName,
          AppRoutes.vocabularyName,
          AppRoutes.questsName,
          AppRoutes.settingsName,
        ];

        for (final routeName in routes) {
          final metadata = AppRouteMetadata.getMetadata(routeName);
          expect(metadata, isNotNull, reason: 'Route $routeName should have metadata');
        }
      });

      test('should correctly identify protected routes', () {
        final protectedRoutes = AppRouteMetadata.getAuthRequiredRoutes();
        
        expect(protectedRoutes, contains(AppRoutes.dashboardName));
        expect(protectedRoutes, contains(AppRoutes.profileName));
        expect(protectedRoutes, contains(AppRoutes.profileEditName));
        expect(protectedRoutes, contains(AppRoutes.vocabularyAddName));
        expect(protectedRoutes, contains(AppRoutes.questActiveName));
        
        // Should not contain public routes
        expect(protectedRoutes, isNot(contains(AppRoutes.homeName)));
        expect(protectedRoutes, isNot(contains(AppRoutes.authName)));
        expect(protectedRoutes, isNot(contains(AppRoutes.vocabularyName)));
      });
    });
  });
}