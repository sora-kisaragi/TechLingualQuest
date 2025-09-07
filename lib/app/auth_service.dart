import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/utils/logger.dart';
import '../features/settings/models/user_settings.dart';

/// 認証状態を管理するクラス
class AuthState {
  const AuthState({
    required this.isAuthenticated,
    this.user,
    this.isLoading = false,
  });

  final bool isAuthenticated;
  final AuthUser? user;
  final bool isLoading;

  AuthState copyWith({bool? isAuthenticated, AuthUser? user, bool? isLoading}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// ユーザーレベル列挙型
enum UserLevel {
  beginner('beginner', 'A1-A2'),
  intermediate('intermediate', 'B1-B2'),
  advanced('advanced', 'C1-C2');

  const UserLevel(this.key, this.description);
  final String key;
  final String description;
}

/// 認証ユーザー情報クラス
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.name,
    this.profileImageUrl,
    this.level,
    this.interests,
    this.bio,
    this.settings,
  });

  final String id;
  final String email;
  final String? name;
  final String? profileImageUrl;
  final UserLevel? level;
  final List<String>? interests;
  final String? bio;
  final UserSettings? settings;

  /// コピーコンストラクタ - プロフィール更新時に使用
  AuthUser copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    UserLevel? level,
    List<String>? interests,
    String? bio,
    UserSettings? settings,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      level: level ?? this.level,
      interests: interests ?? this.interests,
      bio: bio ?? this.bio,
      settings: settings ?? this.settings,
    );
  }
}

/// 認証サービスクラス
///
/// 現在はモックサービスとして実装
/// 将来的にFirebaseやSupabaseに置き換える予定
class AuthService extends StateNotifier<AuthState> {
  AuthService() : super(const AuthState(isAuthenticated: false));

  /// ログイン処理（モック実装）
  Future<bool> login(String email, String password) async {
    AppLogger.info('Login attempt for email: $email');

    state = state.copyWith(isLoading: true);

    // モック認証処理（2秒待機）
    await Future.delayed(const Duration(seconds: 2));

    // 簡単な認証ロジック（デモ用）
    if (email.isNotEmpty && password.length >= 6) {
      final user = AuthUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: email.split('@').first,
      );

      state = AuthState(isAuthenticated: true, user: user, isLoading: false);

      AppLogger.info('Login successful for user: ${user.id}');
      return true;
    } else {
      state = state.copyWith(isLoading: false);
      AppLogger.warning('Login failed for email: $email');
      return false;
    }
  }

  /// ログアウト処理
  Future<void> logout() async {
    AppLogger.info('User logout');
    // Clear authentication state completely
    state =
        const AuthState(isAuthenticated: false, user: null, isLoading: false);

    // In the future, this will also clear stored tokens and session data
    // from SharedPreferences or SecureStorage
  }

  /// ユーザー登録処理（モック実装）
  Future<bool> register(String email, String password, String name) async {
    AppLogger.info('Registration attempt for email: $email');

    state = state.copyWith(isLoading: true);

    // モック登録処理（2秒待機）
    await Future.delayed(const Duration(seconds: 2));

    // 簡単な登録ロジック（デモ用）
    if (email.isNotEmpty && password.length >= 6 && name.isNotEmpty) {
      final user = AuthUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
      );

      state = AuthState(isAuthenticated: true, user: user, isLoading: false);

      AppLogger.info('Registration successful for user: ${user.id}');
      return true;
    } else {
      state = state.copyWith(isLoading: false);
      AppLogger.warning('Registration failed for email: $email');
      return false;
    }
  }

  /// パスワードリセット処理（モック実装）
  Future<bool> requestPasswordReset(String email) async {
    AppLogger.info('Password reset request for email: $email');

    state = state.copyWith(isLoading: true);

    // モックパスワードリセット処理（2秒待機）
    await Future.delayed(const Duration(seconds: 2));

    // 簡単なメールアドレス検証（デモ用）
    if (email.isNotEmpty && email.contains('@')) {
      state = state.copyWith(isLoading: false);
      AppLogger.info('Password reset email sent successfully for: $email');
      return true;
    } else {
      state = state.copyWith(isLoading: false);
      AppLogger.warning('Password reset failed for email: $email');
      return false;
    }
  }

  /// プロフィール更新処理（モック実装）
  Future<bool> updateProfile({
    String? name,
    String? profileImageUrl,
    UserLevel? level,
    List<String>? interests,
    String? bio,
    bool clearProfileImage =
        false, // 新しいフラグ / New flag to explicitly clear image
  }) async {
    if (state.user == null) {
      AppLogger.warning('Cannot update profile: user not authenticated');
      return false;
    }

    AppLogger.info('Updating profile for user: ${state.user!.id}');

    state = state.copyWith(isLoading: true);

    // モックプロフィール更新処理（1秒待機）
    await Future.delayed(const Duration(seconds: 1));

    try {
      // 現在のユーザー情報を更新 - Only update fields that are explicitly provided
      final currentUser = state.user!;
      String? updatedProfileImageUrl;

      if (clearProfileImage) {
        updatedProfileImageUrl = null;
      } else {
        updatedProfileImageUrl = profileImageUrl ?? currentUser.profileImageUrl;
      }

      final updatedUser = AuthUser(
        id: currentUser.id,
        email: currentUser.email,
        name: name ?? currentUser.name,
        profileImageUrl: updatedProfileImageUrl,
        level: level ?? currentUser.level,
        interests: interests ?? currentUser.interests,
        bio: bio ?? currentUser.bio,
      );

      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
      );

      AppLogger.info(
          'Profile updated successfully for user: ${updatedUser.id}');
      return true;
    } catch (error) {
      AppLogger.error('Profile update failed: $error');
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  /// ユーザー設定を更新（モック実装）
  Future<bool> updateUserSettings(UserSettings newSettings) async {
    if (state.user == null) {
      AppLogger.warning('Cannot update settings: user not authenticated');
      return false;
    }

    AppLogger.info('Updating user settings for user: ${state.user!.id}');

    state = state.copyWith(isLoading: true);

    try {
      // モック設定更新処理（1秒待機）
      await Future.delayed(const Duration(seconds: 1));

      final updatedUser = state.user!.copyWith(settings: newSettings);

      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
      );

      AppLogger.info('User settings updated successfully for user: ${updatedUser.id}');
      return true;
    } catch (error) {
      AppLogger.error('Settings update failed: $error');
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  /// 認証状態を確認
  bool get isAuthenticated => state.isAuthenticated;

  /// 現在のユーザーを取得
  AuthUser? get currentUser => state.user;

  /// ローディング状態を確認
  bool get isLoading => state.isLoading;

  /// 初期化時に保存された認証状態を復元（モック実装）
  Future<void> initializeAuth() async {
    AppLogger.info('Initializing authentication state');

    // 実際の実装では、SharedPreferencesやSecureStorageから
    // 保存されたトークンを読み込んで認証状態を復元する

    // 現在はモック実装のため、何もしない
    await Future.delayed(const Duration(milliseconds: 500));

    AppLogger.info('Authentication initialization complete');
  }
}

/// 認証サービスプロバイダー
final authServiceProvider = StateNotifierProvider<AuthService, AuthState>((
  ref,
) {
  return AuthService();
});

/// 認証状態プロバイダー（簡単なアクセス用）
final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authServiceProvider);
});

/// 認証状態ブールプロバイダー（条件分岐用）
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authServiceProvider).isAuthenticated;
});

/// 現在のユーザープロバイダー
final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authServiceProvider).user;
});
