/// アプリケーション定数
/// 
/// アプリ全体で使用される静的定数を定義する
class AppConstants {
  // アプリメタデータ
  static const String appName = 'TechLingual Quest';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A gamified learning app for improving technical English skills';
  
  // XPとレベリング
  static const int xpPerAction = 10;
  static const int xpPerLevel = 100;
  static const int maxLevel = 100;
  
  // データベース
  static const String defaultDatabaseName = 'tech_lingual_quest.db';
  static const int databaseVersion = 1;
  
  // UI定数
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double iconSizeLarge = 80.0;
  static const double iconSizeMedium = 48.0;
  static const double iconSizeSmall = 24.0;
  
  // ルート
  static const String homeRoute = '/';
  static const String authRoute = '/auth';
  static const String vocabularyRoute = '/vocabulary';
  static const String questsRoute = '/quests';
  static const String summariesRoute = '/summaries';
  
  // 機能フラグ（将来の使用のため）
  static const bool enableAnalytics = false;
  static const bool enableCrashlytics = false;
  static const bool enableOfflineMode = true;
}