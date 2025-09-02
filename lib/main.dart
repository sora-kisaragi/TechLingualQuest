import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/config.dart';
import 'app/router.dart';
import 'shared/utils/logger.dart';
import 'services/database/database_service.dart';

/// TechLingual Questアプリケーションのメインエントリーポイント
/// 
/// アプリ開始前に設定、ログ、データベースを初期化する
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // アプリ設定と環境を初期化
    await AppConfig.initialize();
    AppLogger.initialize();
    
    AppLogger.info('Starting TechLingual Quest...');
    AppLogger.debug('Environment: ${AppConfig.environment.name}');
    
    // データベースを初期化
    await DatabaseService.database;
    AppLogger.info('Database initialized successfully');
    
    runApp(const ProviderScope(child: TechLingualQuestApp()));
  } catch (e, stackTrace) {
    AppLogger.error('Failed to initialize app', e, stackTrace);
    // フォールバック設定でアプリを実行
    runApp(const ProviderScope(child: TechLingualQuestApp()));
  }
}

/// TechLingual Questのメインアプリケーションウィジェット
///
/// 技術英語スキル向上のためのゲーミフィケーション学習アプリ。
/// クエスト、語彙学習、技術記事要約をゲームライクな体験で提供する。
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
