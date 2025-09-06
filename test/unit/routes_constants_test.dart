import 'package:flutter_test/flutter_test.dart';
import 'package:tech_lingual_quest/app/routes.dart';

void main() {
  group('AppRoutes Profile Routes Tests', () {
    test('should have correct profile route path', () {
      expect(AppRoutes.profile, equals('/auth/profile'));
    });

    test('should have correct profile route name', () {
      expect(AppRoutes.profileName, equals('profile'));
    });

    test('should have correct profile edit route path', () {
      expect(AppRoutes.profileEdit, equals('/auth/profile/edit'));
    });

    test('should have correct profile edit route name', () {
      expect(AppRoutes.profileEditName, equals('profile-edit'));
    });

    test('should maintain correct route hierarchy', () {
      expect(AppRoutes.profileEdit.startsWith(AppRoutes.profile), isTrue);
    });

    test('should have consistent naming pattern', () {
      // Profile routes should follow the pattern
      expect(AppRoutes.profileName, matches(r'^[a-z]+(-[a-z]+)*$'));
      expect(AppRoutes.profileEditName, matches(r'^[a-z]+(-[a-z]+)*$'));
    });

    test('should have all required auth routes', () {
      // Verify that auth routes exist and are consistent
      expect(AppRoutes.auth, equals('/auth'));
      expect(AppRoutes.login, equals('/auth/login'));
      expect(AppRoutes.register, equals('/auth/register'));
      expect(AppRoutes.passwordReset, equals('/auth/password-reset'));
      expect(AppRoutes.profile, equals('/auth/profile'));
      expect(AppRoutes.profileEdit, equals('/auth/profile/edit'));
    });

    test('should have proper route depth structure', () {
      // Profile should be one level deeper than auth
      final authDepth = '/auth'.split('/').length - 1;
      final profileDepth = AppRoutes.profile.split('/').length - 1;
      final profileEditDepth = AppRoutes.profileEdit.split('/').length - 1;

      expect(profileDepth, equals(authDepth + 1));
      expect(profileEditDepth, equals(profileDepth + 1));
    });

    test('should have correct route name constants', () {
      // All route names should be non-empty strings
      expect(AppRoutes.profileName, isA<String>());
      expect(AppRoutes.profileName, isNotEmpty);
      expect(AppRoutes.profileEditName, isA<String>());
      expect(AppRoutes.profileEditName, isNotEmpty);
    });

    test('should have unique route paths', () {
      final routes = {
        AppRoutes.auth,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.passwordReset,
        AppRoutes.profile,
        AppRoutes.profileEdit,
        AppRoutes.home,
        AppRoutes.vocabulary,
        AppRoutes.quests,
      };

      // All routes should be unique
      expect(routes, hasLength(9));
    });

    test('should have unique route names', () {
      final routeNames = {
        AppRoutes.authName,
        AppRoutes.loginName,
        AppRoutes.registerName,
        AppRoutes.passwordResetName,
        AppRoutes.profileName,
        AppRoutes.profileEditName,
        AppRoutes.homeName,
        AppRoutes.vocabularyName,
        AppRoutes.questsName,
      };

      // All route names should be unique
      expect(routeNames, hasLength(9));
    });
  });

  group('Route Path Validation Tests', () {
    test('should start with forward slash', () {
      expect(AppRoutes.profile, startsWith('/'));
      expect(AppRoutes.profileEdit, startsWith('/'));
    });

    test('should not end with forward slash', () {
      expect(AppRoutes.profile, isNot(endsWith('/')));
      expect(AppRoutes.profileEdit, isNot(endsWith('/')));
    });

    test('should use lowercase paths', () {
      expect(AppRoutes.profile, equals(AppRoutes.profile.toLowerCase()));
      expect(
          AppRoutes.profileEdit, equals(AppRoutes.profileEdit.toLowerCase()));
    });

    test('should use hyphens for multi-word paths', () {
      // Route paths should use hyphens instead of underscores or spaces
      expect(AppRoutes.passwordReset, contains('-'));
      expect(AppRoutes.passwordReset, isNot(contains('_')));
      expect(AppRoutes.passwordReset, isNot(contains(' ')));
    });

    test('should be valid URL paths', () {
      final routes = [
        AppRoutes.profile,
        AppRoutes.profileEdit,
        AppRoutes.auth,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.passwordReset,
      ];

      for (final route in routes) {
        // Should be valid URL path (no spaces, special chars except /, -, _)
        expect(route, matches(r'^/[a-zA-Z0-9/_-]*$'));
      }
    });
  });

  group('Route Name Validation Tests', () {
    test('should use lowercase names', () {
      expect(
          AppRoutes.profileName, equals(AppRoutes.profileName.toLowerCase()));
      expect(AppRoutes.profileEditName,
          equals(AppRoutes.profileEditName.toLowerCase()));
    });

    test('should use hyphens for multi-word names', () {
      expect(AppRoutes.profileEditName, contains('-'));
      expect(AppRoutes.passwordResetName, contains('-'));
    });

    test('should not contain slashes in names', () {
      expect(AppRoutes.profileName, isNot(contains('/')));
      expect(AppRoutes.profileEditName, isNot(contains('/')));
    });

    test('should be valid identifier-like strings', () {
      final routeNames = [
        AppRoutes.profileName,
        AppRoutes.profileEditName,
        AppRoutes.authName,
        AppRoutes.loginName,
        AppRoutes.registerName,
        AppRoutes.passwordResetName,
      ];

      for (final name in routeNames) {
        // Should be valid identifier-like string (letters, numbers, hyphens)
        expect(name, matches(r'^[a-zA-Z0-9-]+$'));
      }
    });
  });
}
