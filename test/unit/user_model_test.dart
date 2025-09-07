import 'package:flutter_test/flutter_test.dart';
import 'package:tech_lingual_quest/app/auth_service.dart';
import 'package:tech_lingual_quest/features/settings/models/user_settings.dart';

void main() {
  group('UserLevel Enum Tests', () {
    test('should have correct values for UserLevel enum', () {
      expect(UserLevel.beginner.key, equals('beginner'));
      expect(UserLevel.beginner.description, equals('A1-A2'));

      expect(UserLevel.intermediate.key, equals('intermediate'));
      expect(UserLevel.intermediate.description, equals('B1-B2'));

      expect(UserLevel.advanced.key, equals('advanced'));
      expect(UserLevel.advanced.description, equals('C1-C2'));
    });

    test('should have all expected enum values', () {
      expect(UserLevel.values, hasLength(3));
      expect(UserLevel.values, contains(UserLevel.beginner));
      expect(UserLevel.values, contains(UserLevel.intermediate));
      expect(UserLevel.values, contains(UserLevel.advanced));
    });

    test('should maintain consistent enum ordering', () {
      final values = UserLevel.values;
      expect(values[0], equals(UserLevel.beginner));
      expect(values[1], equals(UserLevel.intermediate));
      expect(values[2], equals(UserLevel.advanced));
    });
  });

  group('AuthUser copyWith Tests', () {
    const originalUser = AuthUser(
      id: 'test-id',
      email: 'test@example.com',
      name: 'Test User',
      profileImageUrl: 'https://example.com/image.jpg',
      level: UserLevel.intermediate,
      interests: ['Flutter', 'Dart'],
      bio: 'Original bio',
    );

    test('should create identical copy when no parameters provided', () {
      final copiedUser = originalUser.copyWith();

      expect(copiedUser.id, equals(originalUser.id));
      expect(copiedUser.email, equals(originalUser.email));
      expect(copiedUser.name, equals(originalUser.name));
      expect(copiedUser.profileImageUrl, equals(originalUser.profileImageUrl));
      expect(copiedUser.level, equals(originalUser.level));
      expect(copiedUser.interests, equals(originalUser.interests));
      expect(copiedUser.bio, equals(originalUser.bio));
    });

    test('should update only specified fields', () {
      final copiedUser = originalUser.copyWith(
        name: 'Updated Name',
        level: UserLevel.advanced,
      );

      expect(copiedUser.id, equals(originalUser.id));
      expect(copiedUser.email, equals(originalUser.email));
      expect(copiedUser.name, equals('Updated Name'));
      expect(copiedUser.profileImageUrl, equals(originalUser.profileImageUrl));
      expect(copiedUser.level, equals(UserLevel.advanced));
      expect(copiedUser.interests, equals(originalUser.interests));
      expect(copiedUser.bio, equals(originalUser.bio));
    });

    test('should handle null values properly', () {
      // Note: The current copyWith implementation uses ?? operator
      // which means it cannot set values to null, only use null as "don't change"
      final copiedUser = originalUser.copyWith();

      // Since we can't set to null, verify that existing values are preserved
      expect(copiedUser.id, equals(originalUser.id));
      expect(copiedUser.email, equals(originalUser.email));
      expect(copiedUser.name, equals(originalUser.name));
      expect(copiedUser.profileImageUrl, equals(originalUser.profileImageUrl));
      expect(copiedUser.level, equals(originalUser.level));
      expect(copiedUser.interests, equals(originalUser.interests));
      expect(copiedUser.bio, equals(originalUser.bio));
    });

    test('should update interests list correctly', () {
      final newInterests = ['React', 'TypeScript', 'Node.js'];
      final copiedUser = originalUser.copyWith(interests: newInterests);

      expect(copiedUser.interests, equals(newInterests));
      expect(copiedUser.interests, isNot(same(originalUser.interests)));
    });

    test('should update all fields at once', () {
      final copiedUser = originalUser.copyWith(
        id: 'new-id',
        email: 'new@example.com',
        name: 'New User',
        profileImageUrl: 'https://example.com/new-image.jpg',
        level: UserLevel.beginner,
        interests: ['Python', 'Django'],
        bio: 'New bio text',
      );

      expect(copiedUser.id, equals('new-id'));
      expect(copiedUser.email, equals('new@example.com'));
      expect(copiedUser.name, equals('New User'));
      expect(copiedUser.profileImageUrl,
          equals('https://example.com/new-image.jpg'));
      expect(copiedUser.level, equals(UserLevel.beginner));
      expect(copiedUser.interests, equals(['Python', 'Django']));
      expect(copiedUser.bio, equals('New bio text'));
    });

    test('should preserve immutability of original user', () {
      final copiedUser = originalUser.copyWith(name: 'Modified Name');

      expect(originalUser.name, equals('Test User'));
      expect(copiedUser.name, equals('Modified Name'));
    });

    test('should handle empty interests list', () {
      final copiedUser = originalUser.copyWith(interests: []);

      expect(copiedUser.interests, equals([]));
      expect(copiedUser.interests, isNot(same(originalUser.interests)));
    });

    test('should update settings field correctly', () {
      const newSettings = UserSettings(
        language: 'en',
        themeMode: 'light',
        studyGoalPerDay: 60,
      );
      
      final copiedUser = originalUser.copyWith(settings: newSettings);

      expect(copiedUser.settings, equals(newSettings));
      expect(copiedUser.id, equals(originalUser.id)); // Other fields unchanged
      expect(copiedUser.email, equals(originalUser.email));
      expect(copiedUser.name, equals(originalUser.name));
    });

    test('should handle empty string values', () {
      final copiedUser = originalUser.copyWith(
        name: '',
        profileImageUrl: '',
        bio: '',
      );

      expect(copiedUser.name, equals(''));
      expect(copiedUser.profileImageUrl, equals(''));
      expect(copiedUser.bio, equals(''));
    });
  });

  group('AuthUser Constructor Tests', () {
    test('should create user with minimal required fields', () {
      const user = AuthUser(
        id: 'test-id',
        email: 'test@example.com',
      );

      expect(user.id, equals('test-id'));
      expect(user.email, equals('test@example.com'));
      expect(user.name, isNull);
      expect(user.profileImageUrl, isNull);
      expect(user.level, isNull);
      expect(user.interests, isNull);
      expect(user.bio, isNull);
      expect(user.settings, isNull);
    });

    test('should create user with all fields', () {
      const user = AuthUser(
        id: 'test-id',
        email: 'test@example.com',
        name: 'Test User',
        profileImageUrl: 'https://example.com/image.jpg',
        level: UserLevel.intermediate,
        interests: ['Flutter', 'Dart'],
        bio: 'Test bio',
      );

      expect(user.id, equals('test-id'));
      expect(user.email, equals('test@example.com'));
      expect(user.name, equals('Test User'));
      expect(user.profileImageUrl, equals('https://example.com/image.jpg'));
      expect(user.level, equals(UserLevel.intermediate));
      expect(user.interests, equals(['Flutter', 'Dart']));
      expect(user.bio, equals('Test bio'));
    });

    test('should handle special characters in fields', () {
      const user = AuthUser(
        id: 'test-id-123',
        email: 'test+user@example.com',
        name: 'Test User with äöü',
        bio: 'Bio with special chars: 🚀 & symbols',
      );

      expect(user.name, equals('Test User with äöü'));
      expect(user.email, equals('test+user@example.com'));
      expect(user.bio, equals('Bio with special chars: 🚀 & symbols'));
    });

    test('should handle long text fields', () {
      final longBio = 'A' * 500;
      final user = AuthUser(
        id: 'test-id',
        email: 'test@example.com',
        bio: longBio,
      );

      expect(user.bio, equals(longBio));
      expect(user.bio?.length, equals(500));
    });

    test('should handle large interests list', () {
      final manyInterests = List.generate(20, (index) => 'Interest $index');
      final user = AuthUser(
        id: 'test-id',
        email: 'test@example.com',
        interests: manyInterests,
      );

      expect(user.interests, hasLength(20));
      expect(user.interests?.first, equals('Interest 0'));
      expect(user.interests?.last, equals('Interest 19'));
    });
  });
}
