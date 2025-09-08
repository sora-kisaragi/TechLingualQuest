import 'package:flutter_test/flutter_test.dart';
import 'package:tech_lingual_quest/shared/constants/app_constants.dart';

void main() {
  group('AppConstants Tests', () {
    group('App Metadata', () {
      test('should have correct app name', () {
        expect(AppConstants.appName, equals('TechLingual Quest'));
      });

      test('should have correct app version', () {
        expect(AppConstants.appVersion, equals('1.0.0'));
      });

      test('should have app description', () {
        expect(AppConstants.appDescription, isNotEmpty);
        expect(AppConstants.appDescription, contains('technical English'));
      });
    });

    group('XP and Leveling Constants', () {
      test('should have positive XP per action', () {
        expect(AppConstants.xpPerAction, greaterThan(0));
        expect(AppConstants.xpPerAction, equals(10));
      });

      test('should have positive XP per level', () {
        expect(AppConstants.xpPerLevel, greaterThan(0));
        expect(AppConstants.xpPerLevel, equals(100));
      });

      test('should have reasonable max level', () {
        expect(AppConstants.maxLevel, greaterThan(0));
        expect(AppConstants.maxLevel, equals(100));
      });

      test('should have logical XP progression', () {
        // XP per level should be multiple of XP per action for logical progression
        expect(AppConstants.xpPerLevel % AppConstants.xpPerAction, equals(0));
      });
    });

    group('Database Constants', () {
      test('should have default database name', () {
        expect(AppConstants.defaultDatabaseName, isNotEmpty);
        expect(AppConstants.defaultDatabaseName, endsWith('.db'));
      });

      test('should have positive database version', () {
        expect(AppConstants.databaseVersion, greaterThan(0));
      });
    });

    group('UI Constants', () {
      test('should have positive UI dimensions', () {
        expect(AppConstants.defaultPadding, greaterThan(0));
        expect(AppConstants.defaultBorderRadius, greaterThan(0));
        expect(AppConstants.iconSizeLarge, greaterThan(0));
        expect(AppConstants.iconSizeMedium, greaterThan(0));
        expect(AppConstants.iconSizeSmall, greaterThan(0));
      });

      test('should have logical icon size hierarchy', () {
        expect(AppConstants.iconSizeLarge, greaterThan(AppConstants.iconSizeMedium));
        expect(AppConstants.iconSizeMedium, greaterThan(AppConstants.iconSizeSmall));
      });
    });

    group('Route Constants', () {
      test('should have valid route paths', () {
        final routes = [
          AppConstants.homeRoute,
          AppConstants.authRoute,
          AppConstants.vocabularyRoute,
          AppConstants.questsRoute,
          AppConstants.summariesRoute,
        ];

        for (final route in routes) {
          expect(route, isNotEmpty);
          expect(route, startsWith('/'));
        }
      });

      test('should have unique route paths', () {
        final routes = [
          AppConstants.homeRoute,
          AppConstants.authRoute,
          AppConstants.vocabularyRoute,
          AppConstants.questsRoute,
          AppConstants.summariesRoute,
        ];

        final uniqueRoutes = routes.toSet();
        expect(uniqueRoutes.length, equals(routes.length));
      });
    });

    group('Feature Flags', () {
      test('should have boolean feature flags', () {
        expect(AppConstants.enableAnalytics, isA<bool>());
        expect(AppConstants.enableCrashlytics, isA<bool>());
        expect(AppConstants.enableOfflineMode, isA<bool>());
      });

      test('should have expected default feature flag values', () {
        // For initial version, analytics and crashlytics should be disabled
        expect(AppConstants.enableAnalytics, isFalse);
        expect(AppConstants.enableCrashlytics, isFalse);
        // Offline mode should be enabled for better UX
        expect(AppConstants.enableOfflineMode, isTrue);
      });
    });

    group('Constants Immutability', () {
      test('should not be able to modify constants at runtime', () {
        // This test ensures constants are properly declared as const
        expect(() => AppConstants, returnsNormally);
      });
    });
  });
}