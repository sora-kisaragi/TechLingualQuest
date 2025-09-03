import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/routes.dart';
import '../utils/logger.dart';

/// ナビゲーションヘルパークラス
///
/// アプリケーション全体でナビゲーションを簡潔に行うためのユーティリティ
class NavigationHelper {
  // プライベートコンストラクタ（インスタンス化を防ぐ）
  NavigationHelper._();

  /// ホームページに移動
  static void goHome(BuildContext context) {
    AppLogger.debug('Navigating to home');
    context.go(AppRoutes.home);
  }

  /// 認証ページに移動
  static void goAuth(BuildContext context) {
    AppLogger.debug('Navigating to auth');
    context.go(AppRoutes.auth);
  }

  /// ログインページに移動
  static void goLogin(BuildContext context) {
    AppLogger.debug('Navigating to login');
    context.go(AppRoutes.login);
  }

  /// 登録ページに移動
  static void goRegister(BuildContext context) {
    AppLogger.debug('Navigating to register');
    context.go(AppRoutes.register);
  }

  /// プロフィールページに移動
  static void goProfile(BuildContext context) {
    AppLogger.debug('Navigating to profile');
    context.go(AppRoutes.profile);
  }

  /// 単語学習ページに移動
  static void goVocabulary(BuildContext context) {
    AppLogger.debug('Navigating to vocabulary');
    context.go(AppRoutes.vocabulary);
  }

  /// 単語詳細ページに移動
  static void goVocabularyDetail(BuildContext context, String id) {
    AppLogger.debug('Navigating to vocabulary detail: $id');
    context.go('/vocabulary/$id');
  }

  /// 単語追加ページに移動
  static void goVocabularyAdd(BuildContext context) {
    AppLogger.debug('Navigating to vocabulary add');
    context.go(AppRoutes.vocabularyAdd);
  }

  /// クエストページに移動
  static void goQuests(BuildContext context) {
    AppLogger.debug('Navigating to quests');
    context.go(AppRoutes.quests);
  }

  /// クエスト詳細ページに移動
  static void goQuestDetail(BuildContext context, String id) {
    AppLogger.debug('Navigating to quest detail: $id');
    context.go('/quests/$id');
  }

  /// アクティブクエストページに移動
  static void goActiveQuest(BuildContext context) {
    AppLogger.debug('Navigating to active quest');
    context.go(AppRoutes.questActive);
  }

  /// 設定ページに移動
  static void goSettings(BuildContext context) {
    AppLogger.debug('Navigating to settings');
    context.go(AppRoutes.settings);
  }

  /// アバウトページに移動
  static void goAbout(BuildContext context) {
    AppLogger.debug('Navigating to about');
    context.go(AppRoutes.about);
  }

  /// 名前付きルートに移動（パラメータ付き）
  static void goNamed(
    BuildContext context,
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    AppLogger.debug(
      'Navigating to named route: $name with params: $pathParameters',
    );
    context.goNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  /// 現在のページをプッシュ（戻ることができる）
  static void pushNamed(
    BuildContext context,
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    AppLogger.debug('Pushing named route: $name with params: $pathParameters');
    context.pushNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  /// 前のページに戻る
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      AppLogger.debug('Going back to previous page');
      context.pop();
    } else {
      AppLogger.debug('Cannot pop, going to home instead');
      goHome(context);
    }
  }

  /// 現在のルート情報を取得
  static String getCurrentRoute(BuildContext context) {
    final GoRouter router = GoRouter.of(context);
    final RouteMatch lastMatch =
        router.routerDelegate.currentConfiguration.last;
    final String location = lastMatch.matchedLocation;
    AppLogger.debug('Current route: $location');
    return location;
  }

  /// 指定されたルートが現在のルートかどうかを確認
  static bool isCurrentRoute(BuildContext context, String route) {
    final currentRoute = getCurrentRoute(context);
    return currentRoute == route;
  }

  /// ルートメタデータを取得
  static RouteMetadata? getRouteMetadata(String routeName) {
    return AppRouteMetadata.getMetadata(routeName);
  }

  /// ナビゲーションに表示するルートのリストを取得
  static List<MapEntry<String, RouteMetadata>> getNavigationRoutes() {
    return AppRouteMetadata.getNavigationRoutes();
  }

  /// 認証が必要なルートかどうかを確認
  static bool requiresAuth(String routeName) {
    final metadata = AppRouteMetadata.getMetadata(routeName);
    return metadata?.requiresAuth ?? false;
  }

  /// クエリパラメータを含むURLを構築
  static String buildUrlWithQuery(
    String path,
    Map<String, String> queryParameters,
  ) {
    if (queryParameters.isEmpty) return path;

    final uri = Uri.parse(path);
    final newUri = uri.replace(queryParameters: queryParameters);
    return newUri.toString();
  }

  /// URLからクエリパラメータを抽出
  static Map<String, String> extractQueryParameters(String url) {
    final uri = Uri.parse(url);
    return uri.queryParameters;
  }

  /// パスパラメータを含むURLを構築
  static String buildUrlWithPathParams(
    String template,
    Map<String, String> pathParameters,
  ) {
    String result = template;

    pathParameters.forEach((key, value) {
      result = result.replaceAll(':$key', value);
    });

    return result;
  }

  /// ディープリンクのサポート
  static void handleDeepLink(BuildContext context, String url) {
    AppLogger.info('Handling deep link: $url');

    try {
      final uri = Uri.parse(url);
      final path = uri.path;

      // クエリパラメータがある場合は保持
      if (uri.hasQuery) {
        final fullPath = '$path?${uri.query}';
        context.go(fullPath);
      } else {
        context.go(path);
      }
    } catch (e) {
      AppLogger.error('Failed to handle deep link: $url, error: $e');
      // エラーの場合はホームに移動
      goHome(context);
    }
  }
}
