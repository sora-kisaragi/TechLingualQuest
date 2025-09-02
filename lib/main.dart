import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/config.dart';
import 'app/router.dart';
import 'shared/utils/logger.dart';
import 'services/database/database_service.dart';

/// Main entry point for the TechLingual Quest application
/// 
/// Initializes app configuration, logging, and database before starting the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize app configuration and environment
    await AppConfig.initialize();
    AppLogger.initialize();
    
    AppLogger.info('Starting TechLingual Quest...');
    AppLogger.debug('Environment: ${AppConfig.environment.name}');
    
    // Initialize database
    await DatabaseService.database;
    AppLogger.info('Database initialized successfully');
    
    runApp(const ProviderScope(child: TechLingualQuestApp()));
  } catch (e, stackTrace) {
    AppLogger.error('Failed to initialize app', e, stackTrace);
    // Still run the app but with a fallback configuration
    runApp(const ProviderScope(child: TechLingualQuestApp()));
  }
}

/// Main application widget for TechLingual Quest
///
/// A gamified learning app for improving technical English skills.
/// This app combines quests, vocabulary building, and technical article
/// summaries with a game-like experience.
class TechLingualQuestApp extends StatelessWidget {
  const TechLingualQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TechLingual Quest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: AppConfig.isDevelopment,
    );
  }
}
