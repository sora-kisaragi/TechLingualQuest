/// Application constants
/// 
/// Defines static constants used throughout the app
class AppConstants {
  // App metadata
  static const String appName = 'TechLingual Quest';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A gamified learning app for improving technical English skills';
  
  // XP and leveling
  static const int xpPerAction = 10;
  static const int xpPerLevel = 100;
  static const int maxLevel = 100;
  
  // Database
  static const String defaultDatabaseName = 'tech_lingual_quest.db';
  static const int databaseVersion = 1;
  
  // UI constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double iconSizeLarge = 80.0;
  static const double iconSizeMedium = 48.0;
  static const double iconSizeSmall = 24.0;
  
  // Routes
  static const String homeRoute = '/';
  static const String authRoute = '/auth';
  static const String vocabularyRoute = '/vocabulary';
  static const String questsRoute = '/quests';
  static const String summariesRoute = '/summaries';
  
  // Feature flags (for future use)
  static const bool enableAnalytics = false;
  static const bool enableCrashlytics = false;
  static const bool enableOfflineMode = true;
}