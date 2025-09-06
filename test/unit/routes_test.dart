import 'package:flutter_test/flutter_test.dart';
import 'package:tech_lingual_quest/app/routes.dart';

void main() {
  group('AppRoutes Tests', () {
    test('should have correct route path constants', () {
      expect(AppRoutes.home, equals('/'));
      expect(AppRoutes.auth, equals('/auth'));
      expect(AppRoutes.login, equals('/auth/login'));
      expect(AppRoutes.register, equals('/auth/register'));
      expect(AppRoutes.passwordReset, equals('/auth/password-reset'));
      expect(AppRoutes.profile, equals('/auth/profile'));
      expect(AppRoutes.profileEdit, equals('/auth/profile/edit'));
      expect(AppRoutes.vocabulary, equals('/vocabulary'));
      expect(AppRoutes.vocabularyDetail, equals('/vocabulary/:id'));
      expect(AppRoutes.vocabularyAdd, equals('/vocabulary/add'));
      expect(AppRoutes.quests, equals('/quests'));
      expect(AppRoutes.questDetail, equals('/quests/:id'));
      expect(AppRoutes.questActive, equals('/quests/active'));
      expect(AppRoutes.dashboard, equals('/dashboard'));
      expect(AppRoutes.settings, equals('/settings'));
      expect(AppRoutes.about, equals('/about'));
    });

    test('should have correct route name constants', () {
      expect(AppRoutes.homeName, equals('home'));
      expect(AppRoutes.authName, equals('auth'));
      expect(AppRoutes.loginName, equals('login'));
      expect(AppRoutes.registerName, equals('register'));
      expect(AppRoutes.passwordResetName, equals('password-reset'));
      expect(AppRoutes.profileName, equals('profile'));
      expect(AppRoutes.profileEditName, equals('profile-edit'));
      expect(AppRoutes.vocabularyName, equals('vocabulary'));
      expect(AppRoutes.vocabularyDetailName, equals('vocabulary-detail'));
      expect(AppRoutes.vocabularyAddName, equals('vocabulary-add'));
      expect(AppRoutes.questsName, equals('quests'));
      expect(AppRoutes.questDetailName, equals('quest-detail'));
      expect(AppRoutes.questActiveName, equals('quest-active'));
      expect(AppRoutes.dashboardName, equals('dashboard'));
      expect(AppRoutes.settingsName, equals('settings'));
      expect(AppRoutes.aboutName, equals('about'));
    });
  });

  group('RouteMetadata Tests', () {
    test('should create route metadata with required parameters', () {
      const metadata = RouteMetadata(title: 'Test Title');
      
      expect(metadata.title, equals('Test Title'));
      expect(metadata.description, isNull);
      expect(metadata.requiresAuth, isFalse);
      expect(metadata.showInNavigation, isTrue);
      expect(metadata.icon, isNull);
    });

    test('should create route metadata with all parameters', () {
      const metadata = RouteMetadata(
        title: 'Test Title',
        description: 'Test Description',
        requiresAuth: true,
        showInNavigation: false,
        icon: 'test_icon',
      );
      
      expect(metadata.title, equals('Test Title'));
      expect(metadata.description, equals('Test Description'));
      expect(metadata.requiresAuth, isTrue);
      expect(metadata.showInNavigation, isFalse);
      expect(metadata.icon, equals('test_icon'));
    });
  });

  group('AppRouteMetadata Tests', () {
    test('should get metadata for existing route', () {
      final metadata = AppRouteMetadata.getMetadata(AppRoutes.homeName);
      
      expect(metadata, isNotNull);
      expect(metadata!.title, equals('Home'));
      expect(metadata.description, equals('TechLingual Quest main dashboard'));
      expect(metadata.icon, equals('home'));
      expect(metadata.requiresAuth, isFalse);
      expect(metadata.showInNavigation, isTrue);
    });

    test('should return null for non-existing route', () {
      final metadata = AppRouteMetadata.getMetadata('non-existing-route');
      
      expect(metadata, isNull);
    });

    test('should get navigation routes correctly', () {
      final navigationRoutes = AppRouteMetadata.getNavigationRoutes();
      
      expect(navigationRoutes, isNotEmpty);
      
      // Check that all returned routes have showInNavigation = true
      for (final entry in navigationRoutes) {
        expect(entry.value.showInNavigation, isTrue);
      }
      
      // Check that some known navigation routes are included
      final routeNames = navigationRoutes.map((e) => e.key).toList();
      expect(routeNames, contains(AppRoutes.homeName));
      expect(routeNames, contains(AppRoutes.vocabularyName));
      expect(routeNames, contains(AppRoutes.questsName));
      
      // Check that non-navigation routes are excluded
      expect(routeNames, isNot(contains(AppRoutes.loginName)));
      expect(routeNames, isNot(contains(AppRoutes.registerName)));
    });

    test('should get auth required routes correctly', () {
      final authRequiredRoutes = AppRouteMetadata.getAuthRequiredRoutes();
      
      expect(authRequiredRoutes, isNotEmpty);
      
      // Check that known auth-required routes are included
      expect(authRequiredRoutes, contains(AppRoutes.profileName));
      expect(authRequiredRoutes, contains(AppRoutes.profileEditName));
      expect(authRequiredRoutes, contains(AppRoutes.dashboardName));
      expect(authRequiredRoutes, contains(AppRoutes.vocabularyAddName));
      expect(authRequiredRoutes, contains(AppRoutes.questActiveName));
      
      // Check that non-auth routes are excluded
      expect(authRequiredRoutes, isNot(contains(AppRoutes.homeName)));
      expect(authRequiredRoutes, isNot(contains(AppRoutes.loginName)));
    });

    test('should have consistent metadata for all routes', () {
      final metadata = AppRouteMetadata.metadata;
      
      expect(metadata, isNotEmpty);
      
      // Check that all metadata entries have required fields
      for (final entry in metadata.entries) {
        expect(entry.value.title, isNotNull);
        expect(entry.value.title, isNotEmpty);
        
        // Check that auth-required routes have meaningful descriptions
        if (entry.value.requiresAuth) {
          expect(entry.value.description, isNotNull);
          expect(entry.value.description!, isNotEmpty);
        }
      }
    });

    test('should have correct auth requirements for profile routes', () {
      final profileMetadata = AppRouteMetadata.getMetadata(AppRoutes.profileName);
      final profileEditMetadata = AppRouteMetadata.getMetadata(AppRoutes.profileEditName);
      
      expect(profileMetadata!.requiresAuth, isTrue);
      expect(profileEditMetadata!.requiresAuth, isTrue);
      expect(profileMetadata.showInNavigation, isFalse);
      expect(profileEditMetadata.showInNavigation, isFalse);
    });

    test('should have correct settings for authentication routes', () {
      final loginMetadata = AppRouteMetadata.getMetadata(AppRoutes.loginName);
      final registerMetadata = AppRouteMetadata.getMetadata(AppRoutes.registerName);
      final passwordResetMetadata = AppRouteMetadata.getMetadata(AppRoutes.passwordResetName);
      
      expect(loginMetadata!.requiresAuth, isFalse);
      expect(registerMetadata!.requiresAuth, isFalse);
      expect(passwordResetMetadata!.requiresAuth, isFalse);
      
      expect(loginMetadata.showInNavigation, isFalse);
      expect(registerMetadata.showInNavigation, isFalse);
      expect(passwordResetMetadata.showInNavigation, isFalse);
    });
  });
}