import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tech_lingual_quest/app/auth_service.dart';

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
  });
}
