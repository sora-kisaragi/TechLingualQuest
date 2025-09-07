import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tech_lingual_quest/app/auth_service.dart';
import 'package:tech_lingual_quest/features/settings/models/user_settings.dart';

void main() {
  group('AuthService Tests - Login/Logout Functionality', () {
    late ProviderContainer container;
    late AuthService authService;

    setUp(() {
      container = ProviderContainer();
      authService = container.read(authServiceProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state should be unauthenticated', () {
      final authState = container.read(authServiceProvider);

      expect(authState.isAuthenticated, false);
      expect(authState.user, null);
      expect(authState.isLoading, false);
    });

    test('Successful login should update state correctly', () async {
      const email = 'test@example.com';
      const password = 'password123';

      final loginResult = await authService.login(email, password);

      expect(loginResult, true);

      final authState = container.read(authServiceProvider);
      expect(authState.isAuthenticated, true);
      expect(authState.user, isNotNull);
      expect(authState.user!.email, email);
      expect(authState.user!.name, 'test'); // Email prefix
      expect(authState.isLoading, false);
    });

    test('Failed login should not change authentication state', () async {
      const email = '';
      const password = 'short';

      final loginResult = await authService.login(email, password);

      expect(loginResult, false);

      final authState = container.read(authServiceProvider);
      expect(authState.isAuthenticated, false);
      expect(authState.user, null);
      expect(authState.isLoading, false);
    });

    test('Logout should clear authentication state', () async {
      // First login
      const email = 'test@example.com';
      const password = 'password123';
      await authService.login(email, password);

      // Verify logged in
      final authStateAfterLogin = container.read(authServiceProvider);
      expect(authStateAfterLogin.isAuthenticated, true);
      expect(authStateAfterLogin.user, isNotNull);

      // Logout
      await authService.logout();

      // Verify logged out
      final authStateAfterLogout = container.read(authServiceProvider);
      expect(authStateAfterLogout.isAuthenticated, false);
      expect(authStateAfterLogout.user, null);
      expect(authStateAfterLogout.isLoading, false);
    });

    test('Registration should authenticate user', () async {
      const email = 'newuser@example.com';
      const password = 'password123';
      const name = 'New User';

      final registerResult = await authService.register(email, password, name);

      expect(registerResult, true);

      final authState = container.read(authServiceProvider);
      expect(authState.isAuthenticated, true);
      expect(authState.user, isNotNull);
      expect(authState.user!.email, email);
      expect(authState.user!.name, name);
      expect(authState.isLoading, false);
    });

    test('Failed registration should not authenticate user', () async {
      const email = '';
      const password = 'short';
      const name = '';

      final registerResult = await authService.register(email, password, name);

      expect(registerResult, false);

      final authState = container.read(authServiceProvider);
      expect(authState.isAuthenticated, false);
      expect(authState.user, null);
      expect(authState.isLoading, false);
    });

    test('isAuthenticatedProvider should reflect current auth state', () async {
      // Initially not authenticated
      expect(container.read(isAuthenticatedProvider), false);

      // Login
      await authService.login('test@example.com', 'password123');
      expect(container.read(isAuthenticatedProvider), true);

      // Logout
      await authService.logout();
      expect(container.read(isAuthenticatedProvider), false);
    });

    test('currentUserProvider should reflect current user', () async {
      // Initially no user
      expect(container.read(currentUserProvider), null);

      // Login
      await authService.login('test@example.com', 'password123');
      final user = container.read(currentUserProvider);
      expect(user, isNotNull);
      expect(user!.email, 'test@example.com');

      // Logout
      await authService.logout();
      expect(container.read(currentUserProvider), null);
    });

    test('Successful password reset request should return true', () async {
      const email = 'test@example.com';

      final resetResult = await authService.requestPasswordReset(email);

      expect(resetResult, true);

      // Password reset should not change authentication state
      final authState = container.read(authServiceProvider);
      expect(authState.isLoading, false);
    });

    test('Failed password reset (invalid email) should return false', () async {
      const email = 'invalid-email';

      final resetResult = await authService.requestPasswordReset(email);

      expect(resetResult, false);

      // Password reset should not change authentication state
      final authState = container.read(authServiceProvider);
      expect(authState.isLoading, false);
    });

    test('Password reset with empty email should return false', () async {
      const email = '';

      final resetResult = await authService.requestPasswordReset(email);

      expect(resetResult, false);

      // Password reset should not change authentication state
      final authState = container.read(authServiceProvider);
      expect(authState.isLoading, false);
    });
  });

  group('AuthService Tests - Profile Update Functionality', () {
    late ProviderContainer container;
    late AuthService authService;

    setUp(() async {
      container = ProviderContainer();
      authService = container.read(authServiceProvider.notifier);

      // Login first to have an authenticated user
      await authService.login('test@example.com', 'password123');
    });

    tearDown(() {
      container.dispose();
    });

    test('Successful profile update should modify user data', () async {
      const newName = 'Updated Name';
      const newBio = 'Updated bio text';
      final newLevel = UserLevel.intermediate;
      final newInterests = ['Flutter', 'Dart', 'Mobile Development'];

      final updateResult = await authService.updateProfile(
        name: newName,
        bio: newBio,
        level: newLevel,
        interests: newInterests,
      );

      expect(updateResult, true);

      final authState = container.read(authServiceProvider);
      expect(authState.user, isNotNull);
      expect(authState.user!.name, newName);
      expect(authState.user!.bio, newBio);
      expect(authState.user!.level, newLevel);
      expect(authState.user!.interests, newInterests);
      expect(authState.isLoading, false);
    });

    test('Profile update without authentication should fail', () async {
      // Logout first
      await authService.logout();

      final updateResult = await authService.updateProfile(
        name: 'Should fail',
      );

      expect(updateResult, false);
    });

    test('Profile update with partial data should work', () async {
      const newName = 'Partial Update Name';

      // Get current user state
      final currentUser = container.read(authServiceProvider).user!;

      final updateResult = await authService.updateProfile(
        name: newName,
      );

      expect(updateResult, true);

      final authState = container.read(authServiceProvider);
      expect(authState.user!.name, newName);
      // Other fields should remain unchanged
      expect(authState.user!.email, currentUser.email);
      expect(authState.user!.id, currentUser.id);
    });

    test('Profile update with empty name should still work', () async {
      const emptyName = '';

      final updateResult = await authService.updateProfile(
        name: emptyName,
      );

      expect(updateResult, true);

      final authState = container.read(authServiceProvider);
      expect(authState.user!.name, emptyName);
    });

    test('Profile update with empty bio should clear bio field', () async {
      // First set a bio
      await authService.updateProfile(bio: 'Some bio');

      // Then clear it with empty string
      final updateResult = await authService.updateProfile(
        bio: '',
      );

      expect(updateResult, true);

      final authState = container.read(authServiceProvider);
      expect(authState.user!.bio, '');
    });

    test('Profile update with empty interests list should clear interests',
        () async {
      // First set interests
      await authService.updateProfile(interests: ['Interest1', 'Interest2']);

      // Then clear them
      final updateResult = await authService.updateProfile(
        interests: [],
      );

      expect(updateResult, true);

      final authState = container.read(authServiceProvider);
      expect(authState.user!.interests, isEmpty);
    });

    test('Profile update with new image URL should update profileImageUrl',
        () async {
      const newImageUrl = 'https://example.com/new-profile-image.jpg';

      final updateResult = await authService.updateProfile(
        profileImageUrl: newImageUrl,
      );

      expect(updateResult, true);

      final authState = container.read(authServiceProvider);
      expect(authState.user!.profileImageUrl, newImageUrl);
    });

    test('Profile update with null image URL should clear profileImageUrl',
        () async {
      // まず画像URLを設定
      // First set an image URL
      await authService.updateProfile(
        profileImageUrl: 'https://example.com/temp-image.jpg',
      );

      // 次にclearProfileImageフラグでクリア
      // Then clear with clearProfileImage flag
      final updateResult = await authService.updateProfile(
        clearProfileImage: true,
      );

      expect(updateResult, true);

      final authState = container.read(authServiceProvider);
      expect(authState.user!.profileImageUrl, isNull);
    });

    test('Profile update with valid image URL formats should succeed',
        () async {
      const testUrls = [
        'https://example.com/image.jpg',
        'https://cdn.example.com/profile/user123.png',
        'https://storage.googleapis.com/bucket/profile.webp',
        'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ==',
      ];

      for (final url in testUrls) {
        final updateResult = await authService.updateProfile(
          profileImageUrl: url,
        );

        expect(updateResult, true);

        final authState = container.read(authServiceProvider);
        expect(authState.user!.profileImageUrl, url);
      }
    });

    test('Profile update with empty image URL should clear profile image',
        () async {
      // Set initial image URL
      await authService.updateProfile(
        profileImageUrl: 'https://example.com/initial.jpg',
      );

      // Update with empty string
      final updateResult = await authService.updateProfile(
        profileImageUrl: '',
      );

      expect(updateResult, true);

      final authState = container.read(authServiceProvider);
      expect(authState.user!.profileImageUrl, '');
    });

    test('Profile update with mixed data including image URL should work',
        () async {
      const newName = 'John Doe';
      const newBio = 'Software Developer';
      const newImageUrl = 'https://example.com/john-doe.jpg';
      final newInterests = ['Programming', 'Technology'];

      final updateResult = await authService.updateProfile(
        name: newName,
        bio: newBio,
        profileImageUrl: newImageUrl,
        interests: newInterests,
      );

      expect(updateResult, true);

      final authState = container.read(authServiceProvider);
      final user = authState.user!;
      expect(user.name, newName);
      expect(user.bio, newBio);
      expect(user.profileImageUrl, newImageUrl);
      expect(user.interests, newInterests);
    });

    test('Profile update should maintain other fields when only updating image',
        () async {
      // Set initial profile data
      const initialName = 'Initial Name';
      const initialBio = 'Initial Bio';
      final initialInterests = ['Initial', 'Interests'];

      await authService.updateProfile(
        name: initialName,
        bio: initialBio,
        interests: initialInterests,
      );

      // Update only image URL
      const newImageUrl = 'https://example.com/new-avatar.png';
      final updateResult = await authService.updateProfile(
        profileImageUrl: newImageUrl,
      );

      expect(updateResult, true);

      final authState = container.read(authServiceProvider);
      final user = authState.user!;
      expect(user.name, initialName);
      expect(user.bio, initialBio);
      expect(user.interests, initialInterests);
      expect(user.profileImageUrl, newImageUrl);
    });

    test('Profile update should handle settings updates', () async {
      const initialSettings = UserSettings(
        language: 'ja',
        themeMode: 'system',
        studyGoalPerDay: 30,
      );

      // ユーザーを作成して初期設定を設定
      const user = AuthUser(
        id: 'test-id',
        email: 'test@example.com',
        name: 'Test User',
        settings: initialSettings,
      );

      // 手動でユーザーを設定（ログインをシミュレート）
      container.read(authServiceProvider.notifier).state = AuthState(
        isAuthenticated: true,
        user: user,
        isLoading: false,
      );

      const newSettings = UserSettings(
        language: 'en',
        themeMode: 'dark',
        studyGoalPerDay: 60,
      );

      final updateResult = await authService.updateUserSettings(newSettings);

      expect(updateResult, true);

      final authState = container.read(authServiceProvider);
      expect(authState.user!.settings, equals(newSettings));
    });
  });

  group('User Settings Integration Tests', () {
    late ProviderContainer container;
    late AuthService authService;

    setUp(() {
      container = ProviderContainer();
      authService = container.read(authServiceProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('Settings should be null for new users', () async {
      final loginResult =
          await authService.login('test@example.com', 'password123');
      expect(loginResult, true);

      final authState = container.read(authServiceProvider);
      expect(authState.user!.settings, isNull);
    });

    test('Should fail to update settings when not authenticated', () async {
      const settings = UserSettings(language: 'en');
      final updateResult = await authService.updateUserSettings(settings);

      expect(updateResult, false);
    });

    test('Settings update should preserve other user fields', () async {
      // ログインしてユーザーを作成
      await authService.login('test@example.com', 'password123');

      // プロフィールを更新
      await authService.updateProfile(
        name: 'Test Name',
        bio: 'Test Bio',
        level: UserLevel.advanced,
      );

      // 設定を更新
      const newSettings = UserSettings(
        language: 'en',
        themeMode: 'dark',
      );

      final updateResult = await authService.updateUserSettings(newSettings);
      expect(updateResult, true);

      final authState = container.read(authServiceProvider);
      final user = authState.user!;

      // 設定が更新されていることを確認
      expect(user.settings, equals(newSettings));

      // 他のフィールドが保持されていることを確認
      expect(user.name, equals('Test Name'));
      expect(user.bio, equals('Test Bio'));
      expect(user.level, equals(UserLevel.advanced));
    });
  });

  group('AuthService Tests - Profile Image Integration', () {
    late ProviderContainer container;
    late AuthService authService;

    setUp(() async {
      container = ProviderContainer();
      authService = container.read(authServiceProvider.notifier);
      await authService.login('test@example.com', 'password123');
    });

    tearDown(() {
      container.dispose();
    });

    test('Multiple profile image updates should work correctly', () async {
      final imageUrls = [
        'https://example.com/profile1.jpg',
        'https://example.com/profile2.png',
        'https://example.com/profile3.webp',
      ];

      for (final url in imageUrls) {
        final result = await authService.updateProfile(profileImageUrl: url);
        expect(result, true);

        final authState = container.read(authServiceProvider);
        expect(authState.user!.profileImageUrl, url);
      }
    });

    test('Clear and set profile image cycle should work', () async {
      const imageUrl = 'https://example.com/test-image.jpg';

      // Set image
      await authService.updateProfile(profileImageUrl: imageUrl);
      var authState = container.read(authServiceProvider);
      expect(authState.user!.profileImageUrl, imageUrl);

      // Clear image
      await authService.updateProfile(clearProfileImage: true);
      authState = container.read(authServiceProvider);
      expect(authState.user!.profileImageUrl, isNull);

      // Set image again
      await authService.updateProfile(profileImageUrl: imageUrl);
      authState = container.read(authServiceProvider);
      expect(authState.user!.profileImageUrl, imageUrl);
    });

    test('Profile image state should persist across service reads', () async {
      const imageUrl = 'https://example.com/persistent-image.jpg';

      await authService.updateProfile(profileImageUrl: imageUrl);

      // Read state multiple times
      for (int i = 0; i < 3; i++) {
        final authState = container.read(authServiceProvider);
        expect(authState.user!.profileImageUrl, imageUrl);
      }
    });

    test('Profile image should be included in user serialization', () async {
      const imageUrl = 'https://example.com/serialization-test.jpg';

      await authService.updateProfile(profileImageUrl: imageUrl);

      final authState = container.read(authServiceProvider);
      final user = authState.user!;

      // Verify that profile image is accessible through the user object
      expect(user.profileImageUrl, isNotNull);
      expect(user.profileImageUrl, imageUrl);

      // Verify other standard fields are still available
      expect(user.email, isNotEmpty);
      expect(user.name, isNotEmpty);
    });
  });
}
