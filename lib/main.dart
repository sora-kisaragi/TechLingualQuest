import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared/utils/config.dart';
import 'app/router.dart';
import 'shared/utils/logger.dart';
import 'services/database/database_service.dart';
import 'shared/services/dynamic_localization_service.dart';

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
class TechLingualQuestApp extends ConsumerWidget {
  const TechLingualQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(dynamicLanguageProvider);
    // ルーターにRiverpod refを初期化
    AppRouter.initialize(ref);
    return MaterialApp.router(
      title: 'TechLingual Quest',
      locale: currentLocale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ja'),
        Locale('ko'),
        Locale('zh'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: AppConfig.isDevelopment,
    );
  }
}
