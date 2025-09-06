import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/utils/logger.dart';

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

/// 認証ユーザー情報クラス
class AuthUser {
  const AuthUser({required this.id, required this.email, this.name});

  final String id;
  final String email;
  final String? name;
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
    state = const AuthState(isAuthenticated: false, user: null, isLoading: false);
    
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
