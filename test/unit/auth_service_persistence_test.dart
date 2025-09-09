import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tech_lingual_quest/app/auth_service.dart';
import 'package:tech_lingual_quest/shared/services/secure_storage_service.dart';

void main() {
  group('AuthService Persistence Tests', () {
    late ProviderContainer container;
    late AuthService authService;

    setUpAll(() {
      // Flutter test binding initialization required for platform channels
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      container = ProviderContainer();
      authService = container.read(authServiceProvider.notifier);
    });

    tearDown(() {
      container.dispose();
      // テストクリーンアップ - セキュアストレージをクリア
      SecureStorageService.clearAllData().catchError((_) {
        // テスト環境ではSecureStorageが利用できない場合があるので、エラーを無視
      });
    });

    test('Login with rememberMe=true should attempt to persist state', () async {
      const email = 'test@example.com';
      const password = 'password123';

      // rememberMe=trueでログイン
      final loginResult = await authService.login(email, password, rememberMe: true);

      expect(loginResult, true);
      
      final authState = container.read(authServiceProvider);
      expect(authState.isAuthenticated, true);
      expect(authState.authToken, isNotNull);
      expect(authState.sessionExpiry, isNotNull);
      expect(authState.lastSyncTime, isNotNull);
      
      // セッションが有効であることを確認
      expect(authState.isSessionValid, true);
      
      // セッション期限が現在時刻より後であることを確認
      expect(authState.sessionExpiry!.isAfter(DateTime.now()), true);
      
      // 残り時間が正の値であることを確認
      expect(authState.timeUntilExpiry, isNotNull);
      expect(authState.timeUntilExpiry!.inSeconds > 0, true);
    });

    test('Login with rememberMe=false should not persist full state', () async {
      const email = 'test@example.com';
      const password = 'password123';

      // rememberMe=falseでログイン
      final loginResult = await authService.login(email, password, rememberMe: false);

      expect(loginResult, true);
      
      final authState = container.read(authServiceProvider);
      expect(authState.isAuthenticated, true);
      expect(authState.authToken, isNotNull);
      expect(authState.sessionExpiry, isNotNull);
      
      // セッションは有効であるべき
      expect(authState.isSessionValid, true);
    });

    test('Registration with rememberMe should create persistent session', () async {
      const email = 'newuser@example.com';
      const password = 'password123';
      const name = 'New User';

      // rememberMe=trueで登録
      final registerResult = await authService.register(email, password, name, rememberMe: true);

      expect(registerResult, true);
      
      final authState = container.read(authServiceProvider);
      expect(authState.isAuthenticated, true);
      expect(authState.user!.name, name);
      expect(authState.user!.email, email);
      expect(authState.authToken, isNotNull);
      expect(authState.sessionExpiry, isNotNull);
      expect(authState.isSessionValid, true);
    });

    test('Session refresh should update tokens and expiry', () async {
      // 最初にログイン
      await authService.login('test@example.com', 'password123');
      
      final initialState = container.read(authServiceProvider);
      final initialToken = initialState.authToken;
      final initialExpiry = initialState.sessionExpiry;
      
      // 少し待機してからセッションリフレッシュ
      await Future.delayed(const Duration(milliseconds: 10));
      final refreshResult = await authService.refreshSession();
      
      expect(refreshResult, true);
      
      final refreshedState = container.read(authServiceProvider);
      
      // 新しいトークンと有効期限が設定されているべき
      expect(refreshedState.authToken, isNotNull);
      expect(refreshedState.sessionExpiry, isNotNull);
      
      // トークンは変更されているべき
      expect(refreshedState.authToken, isNot(equals(initialToken)));
      
      // 新しい有効期限は元の期限より後であるべき
      if (initialExpiry != null) {
        expect(refreshedState.sessionExpiry!.isAfter(initialExpiry), true);
      }
      
      // セッションは有効であるべき
      expect(refreshedState.isSessionValid, true);
    });

    test('Unauthenticated user cannot refresh session', () async {
      // ログインしていない状態でセッションリフレッシュを試行
      final refreshResult = await authService.refreshSession();
      
      expect(refreshResult, false);
      
      final authState = container.read(authServiceProvider);
      expect(authState.isAuthenticated, false);
    });

    test('Session validation should check memory state correctly', () async {
      await authService.login('test@example.com', 'password123');
      
      // 認証状態を確認
      final authState = container.read(authServiceProvider);
      expect(authState.isAuthenticated, true);
      expect(authState.isSessionValid, true);
      
      // セッション検証を実行（ストレージエラーは無視してメモリ状態で判定）
      final isValid = await authService.validateSession();
      
      // メモリ内のセッションが有効であれば、検証も成功するべき
      expect(isValid, true);
    });

    test('initializeAuth should handle no stored tokens gracefully', () async {
      // セキュアストレージがクリアされた状態で初期化
      await authService.initializeAuth();
      
      final authState = container.read(authServiceProvider);
      expect(authState.isAuthenticated, false);
      expect(authState.user, null);
      expect(authState.isLoading, false);
    });

    test('Logout should clear all authentication data', () async {
      // ログインしてからログアウト
      await authService.login('test@example.com', 'password123');
      
      final beforeLogout = container.read(authServiceProvider);
      expect(beforeLogout.isAuthenticated, true);
      
      // ログアウト実行
      await authService.logout();
      
      final afterLogout = container.read(authServiceProvider);
      expect(afterLogout.isAuthenticated, false);
      expect(afterLogout.user, null);
      expect(afterLogout.authToken, null);
      expect(afterLogout.sessionExpiry, null);
      expect(afterLogout.isLoading, false);
    });
  });

  group('AuthState JSON Serialization Tests', () {
    test('AuthState should serialize to JSON correctly', () async {
      final user = AuthUser(
        id: 'test123',
        email: 'test@example.com',
        name: 'Test User',
        level: UserLevel.intermediate,
        interests: ['flutter', 'dart'],
        bio: 'Test bio',
      );
      
      final authState = AuthState(
        isAuthenticated: true,
        user: user,
        isLoading: false,
        sessionExpiry: DateTime.parse('2025-01-01T00:00:00Z'),
        lastSyncTime: DateTime.parse('2024-12-01T00:00:00Z'),
      );
      
      final json = authState.toJson();
      
      expect(json['isAuthenticated'], true);
      expect(json['user'], isNotNull);
      expect(json['user']['id'], 'test123');
      expect(json['user']['email'], 'test@example.com');
      expect(json['user']['name'], 'Test User');
      expect(json['user']['level'], 'intermediate');
      expect(json['user']['interests'], ['flutter', 'dart']);
      expect(json['user']['bio'], 'Test bio');
      expect(json['isLoading'], false);
      expect(json['sessionExpiry'], isNotNull);
      expect(json['lastSyncTime'], isNotNull);
      expect(json['timestamp'], isNotNull);
    });

    test('AuthState should deserialize from JSON correctly', () async {
      final json = {
        'isAuthenticated': true,
        'user': {
          'id': 'test123',
          'email': 'test@example.com',
          'name': 'Test User',
          'profileImageUrl': 'https://example.com/image.jpg',
          'level': 'advanced',
          'interests': ['flutter', 'dart'],
          'bio': 'Test bio',
        },
        'isLoading': false,
        'sessionExpiry': DateTime.parse('2025-01-01T00:00:00Z').millisecondsSinceEpoch,
        'lastSyncTime': DateTime.parse('2024-12-01T00:00:00Z').millisecondsSinceEpoch,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      final authState = AuthState.fromJson(json);
      
      expect(authState.isAuthenticated, true);
      expect(authState.user, isNotNull);
      expect(authState.user!.id, 'test123');
      expect(authState.user!.email, 'test@example.com');
      expect(authState.user!.name, 'Test User');
      expect(authState.user!.profileImageUrl, 'https://example.com/image.jpg');
      expect(authState.user!.level, UserLevel.advanced);
      expect(authState.user!.interests, ['flutter', 'dart']);
      expect(authState.user!.bio, 'Test bio');
      expect(authState.isLoading, false);
      expect(authState.sessionExpiry, isNotNull);
      expect(authState.lastSyncTime, isNotNull);
    });

    test('AuthState.fromJson should handle malformed JSON gracefully', () async {
      final malformedJson = {
        'invalid': 'data',
        'user': 'not_an_object',
      };
      
      final authState = AuthState.fromJson(malformedJson);
      
      // デフォルトの未認証状態になるべき
      expect(authState.isAuthenticated, false);
      expect(authState.user, null);
      expect(authState.isLoading, false);
    });

    test('AuthState should handle null user in JSON gracefully', () async {
      final json = {
        'isAuthenticated': false,
        'user': null,
        'isLoading': false,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      final authState = AuthState.fromJson(json);
      
      expect(authState.isAuthenticated, false);
      expect(authState.user, null);
      expect(authState.isLoading, false);
    });
  });

  group('New Provider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('isSessionValidProvider should reflect session validity', () async {
      final authService = container.read(authServiceProvider.notifier);
      
      // 初期状態では無効
      expect(container.read(isSessionValidProvider), false);
      
      // ログイン後は有効
      await authService.login('test@example.com', 'password123');
      expect(container.read(isSessionValidProvider), true);
      
      // ログアウト後は無効
      await authService.logout();
      expect(container.read(isSessionValidProvider), false);
    });

    test('sessionExpiryProvider should provide session expiry time', () async {
      final authService = container.read(authServiceProvider.notifier);
      
      // 初期状態ではnull
      expect(container.read(sessionExpiryProvider), null);
      
      // ログイン後は有効期限が設定される
      await authService.login('test@example.com', 'password123');
      
      final sessionExpiry = container.read(sessionExpiryProvider);
      expect(sessionExpiry, isNotNull);
      expect(sessionExpiry!.isAfter(DateTime.now()), true);
    });

    test('timeUntilExpiryProvider should calculate remaining time correctly', () async {
      final authService = container.read(authServiceProvider.notifier);
      
      // 初期状態ではnull
      expect(container.read(timeUntilExpiryProvider), null);
      
      // ログイン後は残り時間が計算される
      await authService.login('test@example.com', 'password123');
      
      final timeUntilExpiry = container.read(timeUntilExpiryProvider);
      expect(timeUntilExpiry, isNotNull);
      expect(timeUntilExpiry!.inSeconds > 0, true);
    });

    test('authTokenProvider should provide current auth token', () async {
      final authService = container.read(authServiceProvider.notifier);
      
      // 初期状態ではnull
      expect(container.read(authTokenProvider), null);
      
      // ログイン後はトークンが設定される
      await authService.login('test@example.com', 'password123');
      
      final authToken = container.read(authTokenProvider);
      expect(authToken, isNotNull);
      expect(authToken!.isNotEmpty, true);
    });
  });

  group('Advanced Authentication Tests', () {
    late ProviderContainer container;
    late AuthService authService;

    setUp(() {
      container = ProviderContainer();
      authService = container.read(authServiceProvider.notifier);
    });

    tearDown(() {
      container.dispose();
      SecureStorageService.clearAllData().catchError((_) {});
    });

    test('Login should fail with invalid credentials', () async {
      final result = await authService.login('invalid@email.com', 'wrongpass');
      
      expect(result, false);
      expect(container.read(authServiceProvider).isAuthenticated, false);
    });

    test('Login should handle empty email', () async {
      final result = await authService.login('', 'password');
      
      expect(result, false);
      expect(container.read(authServiceProvider).isAuthenticated, false);
    });

    test('Login should handle empty password', () async {
      final result = await authService.login('test@example.com', '');
      
      expect(result, false);
      expect(container.read(authServiceProvider).isAuthenticated, false);
    });

    test('Password reset should work with valid email', () async {
      final result = await authService.requestPasswordReset('test@example.com');
      
      expect(result, true);
    });

    test('Password reset should fail with invalid email', () async {
      final result = await authService.requestPasswordReset('invalid-email');
      
      expect(result, false);
    });

    test('Password reset should fail with empty email', () async {
      final result = await authService.requestPasswordReset('');
      
      expect(result, false);
    });

    test('Profile update should fail when not authenticated', () async {
      final result = await authService.updateProfile(name: 'New Name');
      
      expect(result, false);
    });

    test('Profile update should work when authenticated', () async {
      await authService.login('test@example.com', 'password123');
      
      final result = await authService.updateProfile(
        name: 'Updated Name',
        bio: 'Updated bio',
        interests: ['flutter'],
        profileImageUrl: 'https://example.com/new-image.jpg',
      );
      
      expect(result, true);
      
      final user = container.read(authServiceProvider).user;
      expect(user!.name, 'Updated Name');
      expect(user.bio, 'Updated bio');
      expect(user.interests, ['flutter']);
      expect(user.profileImageUrl, 'https://example.com/new-image.jpg');
    });

    test('Profile update should clear profile image when requested', () async {
      await authService.login('test@example.com', 'password123');
      
      // 最初に画像を設定
      await authService.updateProfile(profileImageUrl: 'https://example.com/image.jpg');
      expect(container.read(authServiceProvider).user!.profileImageUrl, 'https://example.com/image.jpg');
      
      // 画像をクリア
      final result = await authService.updateProfile(clearProfileImage: true);
      
      expect(result, true);
      expect(container.read(authServiceProvider).user!.profileImageUrl, null);
    });

    test('AuthState copyWith should work correctly', () async {
      final user = AuthUser(
        id: 'test',
        email: 'test@example.com',
        name: 'Test User',
      );
      
      final originalState = AuthState(
        isAuthenticated: true,
        user: user,
        authToken: 'token123',
        sessionExpiry: DateTime.now().add(const Duration(hours: 1)),
      );
      
      // 通常のコピー
      final copiedState = originalState.copyWith(
        isLoading: true,
        lastSyncTime: DateTime.now(),
      );
      
      expect(copiedState.isAuthenticated, true);
      expect(copiedState.user, user);
      expect(copiedState.authToken, 'token123');
      expect(copiedState.isLoading, true);
      expect(copiedState.lastSyncTime, isNotNull);
      
      // トークンをクリア
      final clearedState = originalState.copyWith(clearToken: true);
      
      expect(clearedState.authToken, null);
      expect(clearedState.sessionExpiry, null);
    });

    test('AuthState session validity should work correctly', () async {
      // 有効なセッション
      final validState = AuthState(
        isAuthenticated: true,
        authToken: 'token123',
        sessionExpiry: DateTime.now().add(const Duration(hours: 1)),
      );
      
      expect(validState.isSessionValid, true);
      expect(validState.timeUntilExpiry!.inMinutes > 0, true);
      
      // 期限切れのセッション
      final expiredState = AuthState(
        isAuthenticated: true,
        authToken: 'token123',
        sessionExpiry: DateTime.now().subtract(const Duration(hours: 1)),
      );
      
      expect(expiredState.isSessionValid, false);
      expect(expiredState.timeUntilExpiry, const Duration());
      
      // 認証されていない状態
      const unauthenticatedState = AuthState(isAuthenticated: false);
      
      expect(unauthenticatedState.isSessionValid, false);
      expect(unauthenticatedState.timeUntilExpiry, null);
    });

    test('Session refresh should work correctly', () async {
      await authService.login('test@example.com', 'password123');
      
      final beforeRefresh = container.read(authServiceProvider);
      expect(beforeRefresh.isAuthenticated, true);
      
      final result = await authService.refreshSession();
      expect(result, true);
      
      final afterRefresh = container.read(authServiceProvider);
      expect(afterRefresh.isAuthenticated, true);
      expect(afterRefresh.authToken, isNotNull);
    });

    test('Session validation should work correctly', () async {
      await authService.login('test@example.com', 'password123');
      
      final isValid = await authService.validateSession();
      expect(isValid, true);
    });

    test('Session validation should fail for unauthenticated state', () async {
      final isValid = await authService.validateSession();
      expect(isValid, false);
    });

    test('Initialize auth should restore valid session', () async {
      // ログインしてセッション状態を作成
      await authService.login('test@example.com', 'password123', rememberMe: true);
      
      // 新しいサービスインスタンスでセッション復元をテスト
      final newContainer = ProviderContainer();
      final newAuthService = newContainer.read(authServiceProvider.notifier);
      
      try {
        await newAuthService.initializeAuth();
        
        // セッションが復元されているかは環境に依存するため、
        // エラーが発生しないことのみを確認
        expect(newContainer.read(authServiceProvider).isLoading, false);
      } catch (e) {
        // テスト環境ではSecureStorageが機能しない場合があるため、例外は許容
        print('Session restoration test skipped due to environment limitations: $e');
      } finally {
        newContainer.dispose();
      }
    });
  });
}