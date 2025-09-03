/// アプリケーションのルート定数
///
/// ルートパスとナビゲーション名を一元管理する
class AppRoutes {
  // ルートパス定数
  static const String home = '/';
  static const String auth = '/auth';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/profile';
  static const String vocabulary = '/vocabulary';
  static const String vocabularyDetail = '/vocabulary/:id';
  static const String vocabularyAdd = '/vocabulary/add';
  static const String quests = '/quests';
  static const String questDetail = '/quests/:id';
  static const String questActive = '/quests/active';
  static const String dashboard = '/dashboard';
  static const String settings = '/settings';
  static const String about = '/about';

  // ルート名定数
  static const String homeName = 'home';
  static const String authName = 'auth';
  static const String loginName = 'login';
  static const String registerName = 'register';
  static const String profileName = 'profile';
  static const String vocabularyName = 'vocabulary';
  static const String vocabularyDetailName = 'vocabulary-detail';
  static const String vocabularyAddName = 'vocabulary-add';
  static const String questsName = 'quests';
  static const String questDetailName = 'quest-detail';
  static const String questActiveName = 'quest-active';
  static const String dashboardName = 'dashboard';
  static const String settingsName = 'settings';
  static const String aboutName = 'about';

  // プライベートコンストラクタ（インスタンス化を防ぐ）
  AppRoutes._();
}

/// ルートメタデータクラス
class RouteMetadata {
  const RouteMetadata({
    required this.title,
    this.description,
    this.requiresAuth = false,
    this.showInNavigation = true,
    this.icon,
  });

  final String title;
  final String? description;
  final bool requiresAuth;
  final bool showInNavigation;
  final String? icon;
}

/// ルートメタデータマップ
class AppRouteMetadata {
  static const Map<String, RouteMetadata> metadata = {
    AppRoutes.homeName: RouteMetadata(
      title: 'Home',
      description: 'TechLingual Quest main dashboard',
      icon: 'home',
    ),
    AppRoutes.authName: RouteMetadata(
      title: 'Authentication',
      description: 'User authentication and profile',
      icon: 'person',
    ),
    AppRoutes.loginName: RouteMetadata(
      title: 'Login',
      description: 'User login page',
      showInNavigation: false,
    ),
    AppRoutes.registerName: RouteMetadata(
      title: 'Register',
      description: 'User registration page',
      showInNavigation: false,
    ),
    AppRoutes.profileName: RouteMetadata(
      title: 'Profile',
      description: 'User profile management',
      requiresAuth: true,
      showInNavigation: false,
    ),
    AppRoutes.vocabularyName: RouteMetadata(
      title: 'Vocabulary',
      description: 'Vocabulary learning and management',
      icon: 'book',
    ),
    AppRoutes.vocabularyDetailName: RouteMetadata(
      title: 'Vocabulary Details',
      description: 'Detailed view of vocabulary word',
      showInNavigation: false,
    ),
    AppRoutes.vocabularyAddName: RouteMetadata(
      title: 'Add Vocabulary',
      description: 'Add new vocabulary word',
      requiresAuth: true,
      showInNavigation: false,
    ),
    AppRoutes.questsName: RouteMetadata(
      title: 'Quests',
      description: 'Learning quests and challenges',
      icon: 'flag',
    ),
    AppRoutes.questDetailName: RouteMetadata(
      title: 'Quest Details',
      description: 'Detailed view of quest',
      showInNavigation: false,
    ),
    AppRoutes.questActiveName: RouteMetadata(
      title: 'Active Quest',
      description: 'Currently active quest session',
      requiresAuth: true,
      showInNavigation: false,
    ),
    AppRoutes.dashboardName: RouteMetadata(
      title: 'Dashboard',
      description: 'User progress dashboard',
      requiresAuth: true,
      icon: 'dashboard',
    ),
    AppRoutes.settingsName: RouteMetadata(
      title: 'Settings',
      description: 'Application settings',
      icon: 'settings',
    ),
    AppRoutes.aboutName: RouteMetadata(
      title: 'About',
      description: 'About TechLingual Quest',
      icon: 'info',
    ),
  };

  // プライベートコンストラクタ（インスタンス化を防ぐ）
  AppRouteMetadata._();

  /// 指定されたルート名のメタデータを取得
  static RouteMetadata? getMetadata(String routeName) {
    return metadata[routeName];
  }

  /// ナビゲーションに表示するルートのリストを取得
  static List<MapEntry<String, RouteMetadata>> getNavigationRoutes() {
    return metadata.entries
        .where((entry) => entry.value.showInNavigation)
        .toList();
  }

  /// 認証が必要なルートのリストを取得
  static List<String> getAuthRequiredRoutes() {
    return metadata.entries
        .where((entry) => entry.value.requiresAuth)
        .map((entry) => entry.key)
        .toList();
  }
}