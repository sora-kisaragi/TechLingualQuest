import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/dashboard/pages/home_page.dart';
import '../features/auth/pages/auth_page.dart';
import '../features/vocabulary/pages/vocabulary_page.dart';
import '../features/quests/pages/quests_page.dart';
import '../shared/utils/logger.dart';
import 'routes.dart';
import 'auth_service.dart';

/// go_routerを使用したアプリケーションルーター設定
///
/// アプリのルートとナビゲーション構造を定義する
/// 認証ガード、ネストされたルート、メタデータ管理を含む
class AppRouter {
  /// Riverpod Refインスタンス（認証状態管理用）
  static WidgetRef? _ref;

  /// ルーターを初期化してRefを設定
  static void initialize(WidgetRef ref) {
    _ref = ref;
    AppLogger.info('Router initialized with Riverpod ref');
  }

  static final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      // ホームルート
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.homeName,
        builder: (BuildContext context, GoRouterState state) {
          return const HomePage();
        },
      ),

      // 認証関連ルート（ネストされたルート構造）
      GoRoute(
        path: AppRoutes.auth,
        name: AppRoutes.authName,
        builder: (BuildContext context, GoRouterState state) {
          return const AuthPage();
        },
        routes: [
          // ログインサブルート
          GoRoute(
            path: 'login',
            name: AppRoutes.loginName,
            builder: (BuildContext context, GoRouterState state) {
              return const Placeholder(); // 将来的にLoginPageを実装
            },
          ),
          // 登録サブルート
          GoRoute(
            path: 'register',
            name: AppRoutes.registerName,
            builder: (BuildContext context, GoRouterState state) {
              return const Placeholder(); // 将来的にRegisterPageを実装
            },
          ),
          // プロフィールサブルート（認証が必要）
          GoRoute(
            path: 'profile',
            name: AppRoutes.profileName,
            builder: (BuildContext context, GoRouterState state) {
              return const Placeholder(); // 将来的にProfilePageを実装
            },
          ),
        ],
      ),

      // 単語学習ルート（パラメータ付きサブルート）
      GoRoute(
        path: AppRoutes.vocabulary,
        name: AppRoutes.vocabularyName,
        builder: (BuildContext context, GoRouterState state) {
          return const VocabularyPage();
        },
        routes: [
          // 単語追加サブルート
          GoRoute(
            path: 'add',
            name: AppRoutes.vocabularyAddName,
            builder: (BuildContext context, GoRouterState state) {
              return const Placeholder(); // 将来的にVocabularyAddPageを実装
            },
          ),
          // 単語詳細サブルート（IDパラメータ付き）
          GoRoute(
            path: ':id',
            name: AppRoutes.vocabularyDetailName,
            builder: (BuildContext context, GoRouterState state) {
              final id = state.pathParameters['id']!;
              AppLogger.debug('Navigating to vocabulary detail: $id');
              return Placeholder(
                child: Center(child: Text('Vocabulary Detail: $id')),
              ); // 将来的にVocabularyDetailPageを実装
            },
          ),
        ],
      ),

      // クエストルート（パラメータ付きサブルート）
      GoRoute(
        path: AppRoutes.quests,
        name: AppRoutes.questsName,
        builder: (BuildContext context, GoRouterState state) {
          return const QuestsPage();
        },
        routes: [
          // アクティブクエストサブルート
          GoRoute(
            path: 'active',
            name: AppRoutes.questActiveName,
            builder: (BuildContext context, GoRouterState state) {
              return const Placeholder(); // 将来的にActiveQuestPageを実装
            },
          ),
          // クエスト詳細サブルート（IDパラメータ付き）
          GoRoute(
            path: ':id',
            name: AppRoutes.questDetailName,
            builder: (BuildContext context, GoRouterState state) {
              final id = state.pathParameters['id']!;
              AppLogger.debug('Navigating to quest detail: $id');
              return Placeholder(
                child: Center(child: Text('Quest Detail: $id')),
              ); // 将来的にQuestDetailPageを実装
            },
          ),
        ],
      ),

      // 設定ルート
      GoRoute(
        path: AppRoutes.settings,
        name: AppRoutes.settingsName,
        builder: (BuildContext context, GoRouterState state) {
          return const Placeholder(); // 将来的にSettingsPageを実装
        },
      ),

      // アバウトルート
      GoRoute(
        path: AppRoutes.about,
        name: AppRoutes.aboutName,
        builder: (BuildContext context, GoRouterState state) {
          return const Placeholder(); // 将来的にAboutPageを実装
        },
      ),
    ],
    errorBuilder: (context, state) =>
        _ErrorPage(error: state.error.toString(), path: state.uri.toString()),
    redirect: _routeGuard,
    initialLocation: AppRoutes.home,
  );

  /// ルート認証ガード
  ///
  /// 認証が必要なルートへの不正なアクセスを防ぐ
  static String? _routeGuard(BuildContext context, GoRouterState state) {
    final path = state.uri.toString();
    AppLogger.debug('Route guard checking path: $path');

    // 認証状態を確認
    final isAuthenticated = _ref?.read(isAuthenticatedProvider) ?? false;

    // 現在のルート名を取得
    final routeName = _getRouteNameFromPath(path);

    // ルートメタデータから認証要件を確認
    final metadata = AppRouteMetadata.getMetadata(routeName);
    final requiresAuth = metadata?.requiresAuth ?? false;

    if (requiresAuth && !isAuthenticated) {
      AppLogger.warning('Access denied to protected route: $path');
      // 認証が必要だが未認証の場合、認証ページにリダイレクト
      return AppRoutes.auth;
    }

    // リダイレクト不要
    return null;
  }

  /// パスからルート名を取得するヘルパーメソッド
  static String _getRouteNameFromPath(String path) {
    // 基本的なパスマッチング（より複雑なルートの場合は改善が必要）
    if (path == AppRoutes.home) return AppRoutes.homeName;
    if (path.startsWith('/auth/profile')) return AppRoutes.profileName;
    if (path.startsWith('/auth/login')) return AppRoutes.loginName;
    if (path.startsWith('/auth/register')) return AppRoutes.registerName;
    if (path.startsWith('/auth')) return AppRoutes.authName;
    if (path.startsWith('/vocabulary/add')) return AppRoutes.vocabularyAddName;
    if (path.contains('/vocabulary/') && path.split('/').length > 2) {
      return AppRoutes.vocabularyDetailName;
    }
    if (path.startsWith('/vocabulary')) return AppRoutes.vocabularyName;
    if (path.startsWith('/quests/active')) return AppRoutes.questActiveName;
    if (path.contains('/quests/') && path.split('/').length > 2) {
      return AppRoutes.questDetailName;
    }
    if (path.startsWith('/quests')) return AppRoutes.questsName;
    if (path.startsWith('/settings')) return AppRoutes.settingsName;
    if (path.startsWith('/about')) return AppRoutes.aboutName;

    return AppRoutes.homeName; // デフォルト
  }

  /// ルーターインスタンスを取得
  static GoRouter get router => _router;
}

/// ナビゲーションエラーを処理するエラーページ
class _ErrorPage extends StatelessWidget {
  const _ErrorPage({required this.error, this.path});

  final String error;
  final String? path;

  @override
  Widget build(BuildContext context) {
    AppLogger.error('Navigation error: $error for path: $path');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Error'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // ホームページに戻る
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Page not found',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (path != null) ...[
                Text(
                  'Path: $path',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                error,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => context.go(AppRoutes.home),
                    icon: const Icon(Icons.home),
                    label: const Text('Go Home'),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.home);
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'If this error persists, please contact support.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
