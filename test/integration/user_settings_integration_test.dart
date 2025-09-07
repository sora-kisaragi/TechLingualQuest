import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tech_lingual_quest/app/auth_service.dart';
import 'package:tech_lingual_quest/features/settings/models/user_settings.dart';
import 'package:tech_lingual_quest/features/settings/services/settings_service.dart';

/// ユーザー設定の統合テスト
/// Integration tests for user settings persistence and state management
void main() {
  group('User Settings Integration Tests', () {
    late ProviderContainer container;
    late SettingsService settingsService;
    late AuthService authService;

    setUp(() {
      // SharedPreferences のモックデータを初期化
      SharedPreferences.setMockInitialValues({});

      // プロバイダーコンテナを作成
      container = ProviderContainer();

      // サービスインスタンスを取得
      settingsService = container.read(settingsServiceProvider);
      authService = container.read(authServiceProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('should persist settings across app restarts', () async {
      // 1. 初期状態の確認
      final initialSettings = await settingsService.loadSettings();
      expect(initialSettings.language, equals('ja'));
      expect(initialSettings.themeMode, equals('system'));
      expect(initialSettings.studyGoalPerDay, equals(30));

      // 2. カスタム設定を保存
      const customSettings = UserSettings(
        language: 'en',
        notificationsEnabled: false,
        dailyReminderTime: '08:30',
        themeMode: 'dark',
        studyGoalPerDay: 60,
        difficultyPreference: 'advanced',
        soundEnabled: false,
        vibrationEnabled: true,
        autoSync: false,
      );

      final saveSuccess = await settingsService.saveSettings(customSettings);
      expect(saveSuccess, isTrue);

      // 3. 新しいサービスインスタンス（アプリ再起動をシミュレート）
      final newSettingsService = SettingsService();
      final reloadedSettings = await newSettingsService.loadSettings();

      // 4. 保存された設定が正しく復元されることを確認
      expect(reloadedSettings, equals(customSettings));
      expect(reloadedSettings.language, equals('en'));
      expect(reloadedSettings.notificationsEnabled, equals(false));
      expect(reloadedSettings.dailyReminderTime, equals('08:30'));
      expect(reloadedSettings.themeMode, equals('dark'));
      expect(reloadedSettings.studyGoalPerDay, equals(60));
      expect(reloadedSettings.difficultyPreference, equals('advanced'));
      expect(reloadedSettings.soundEnabled, equals(false));
      expect(reloadedSettings.vibrationEnabled, equals(true));
      expect(reloadedSettings.autoSync, equals(false));
    });

    test('should integrate settings with user authentication', () async {
      // 1. ユーザーログイン
      final loginSuccess =
          await authService.login('test@example.com', 'password123');
      expect(loginSuccess, isTrue);

      // 2. 初期状態では設定がnull
      final authState1 = container.read(authServiceProvider);
      expect(authState1.user!.settings, isNull);

      // 3. 設定を作成・保存
      const userSettings = UserSettings(
        language: 'en',
        themeMode: 'light',
        studyGoalPerDay: 45,
        difficultyPreference: 'intermediate',
      );

      final updateSuccess = await authService.updateUserSettings(userSettings);
      expect(updateSuccess, isTrue);

      // 4. 認証状態に設定が反映されていることを確認
      final authState2 = container.read(authServiceProvider);
      expect(authState2.user!.settings, equals(userSettings));

      // 5. 独立してSettingsServiceでも同じ設定が取得できることを確認
      final loadedSettings = await settingsService.loadSettings();
      expect(loadedSettings, equals(userSettings));
    });

    test('should handle concurrent settings updates correctly', () async {
      // 1. 初期設定を保存
      const initialSettings = UserSettings(language: 'ja', studyGoalPerDay: 30);
      await settingsService.saveSettings(initialSettings);

      // 2. 複数の同時更新を実行
      final updateTasks = [
        settingsService.updateSetting('language', 'en'),
        settingsService.updateSetting('themeMode', 'dark'),
        settingsService.updateSetting('studyGoalPerDay', 60),
        settingsService.updateSetting('notificationsEnabled', false),
        settingsService.updateSetting('difficultyPreference', 'advanced'),
      ];

      final results = await Future.wait(updateTasks);
      expect(results.every((result) => result), isTrue);

      // 3. 最終的な設定状態を確認
      final finalSettings = await settingsService.loadSettings();
      expect(finalSettings.language, equals('en'));
      expect(finalSettings.themeMode, equals('dark'));
      expect(finalSettings.studyGoalPerDay, equals(60));
      expect(finalSettings.notificationsEnabled, equals(false));
      expect(finalSettings.difficultyPreference, equals('advanced'));
    });

    test('should maintain state consistency between providers', () async {
      // 1. UserSettingsNotifier を使用して設定を更新
      final settingsNotifier = container.read(userSettingsProvider.notifier);

      // 初期化完了を待機
      await Future.delayed(const Duration(milliseconds: 100));

      const newSettings = UserSettings(
        language: 'en',
        themeMode: 'dark',
        studyGoalPerDay: 90,
        notificationsEnabled: false,
      );

      await settingsNotifier.updateSettings(newSettings);

      // 2. プロバイダーの状態を確認
      final providerState = container.read(userSettingsProvider);
      expect(providerState.hasValue, isTrue);
      expect(providerState.value, equals(newSettings));

      // 3. SettingsService で直接読み込んでも同じ値であることを確認
      final serviceSettings = await settingsService.loadSettings();
      expect(serviceSettings, equals(newSettings));

      // 4. 認証済みユーザーの場合、AuthService でも整合性を確認
      await authService.login('test@example.com', 'password123');
      await authService.updateUserSettings(newSettings);

      final authState = container.read(authServiceProvider);
      expect(authState.user!.settings, equals(newSettings));
    });

    test('should handle settings export and import workflow', () async {
      // 1. カスタム設定を作成・保存
      const originalSettings = UserSettings(
        language: 'en',
        notificationsEnabled: false,
        dailyReminderTime: '07:15',
        themeMode: 'light',
        studyGoalPerDay: 75,
        difficultyPreference: 'beginner',
        soundEnabled: true,
        vibrationEnabled: false,
        autoSync: false,
      );

      await settingsService.saveSettings(originalSettings);

      // 2. 設定をエクスポート
      final exportedData = await settingsService.exportSettings();
      expect(exportedData, isNotNull);

      // 3. 設定をリセット
      await settingsService.resetToDefaults();
      final resetSettings = await settingsService.loadSettings();
      expect(resetSettings.language, equals('ja')); // デフォルト値

      // 4. 設定をインポート
      final importSuccess = await settingsService.importSettings(exportedData!);
      expect(importSuccess, isTrue);

      // 5. インポートした設定が正しく復元されていることを確認
      final restoredSettings = await settingsService.loadSettings();
      expect(restoredSettings, equals(originalSettings));
      expect(restoredSettings.language, equals('en'));
      expect(restoredSettings.studyGoalPerDay, equals(75));
      expect(restoredSettings.themeMode, equals('light'));
    });

    test('should gracefully handle corrupted settings data', () async {
      // 1. 有効な設定を保存
      const validSettings = UserSettings(language: 'en', studyGoalPerDay: 45);
      await settingsService.saveSettings(validSettings);

      // 2. SharedPreferences に不正なデータを直接書き込み
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_settings', 'invalid json data {malformed');

      // 3. 設定読み込み時にデフォルト値にフォールバックすることを確認
      final corruptedReadSettings = await settingsService.loadSettings();
      expect(corruptedReadSettings.language, equals('ja')); // デフォルト値
      expect(corruptedReadSettings.studyGoalPerDay, equals(30)); // デフォルト値

      // 4. 新しい設定を保存して正常状態に戻ることを確認
      const recoverySettings = UserSettings(language: 'en', themeMode: 'dark');
      final saveSuccess = await settingsService.saveSettings(recoverySettings);
      expect(saveSuccess, isTrue);

      final recoveredSettings = await settingsService.loadSettings();
      expect(recoveredSettings, equals(recoverySettings));
    });

    test('should handle edge cases for setting values', () async {
      // 1. 境界値でのテスト
      const edgeCaseSettings = UserSettings(
        studyGoalPerDay: 1, // 最小値
        dailyReminderTime: '00:00', // 深夜
        language: 'en',
        difficultyPreference: 'advanced',
      );

      final saveSuccess = await settingsService.saveSettings(edgeCaseSettings);
      expect(saveSuccess, isTrue);

      final loadedSettings = await settingsService.loadSettings();
      expect(loadedSettings.studyGoalPerDay, equals(1));
      expect(loadedSettings.dailyReminderTime, equals('00:00'));

      // 2. 高い値でのテスト
      const highValueSettings = UserSettings(
        studyGoalPerDay: 180, // 高い値
        dailyReminderTime: '23:59', // 深夜直前
      );

      await settingsService.saveSettings(highValueSettings);
      final highValueLoaded = await settingsService.loadSettings();
      expect(highValueLoaded.studyGoalPerDay, equals(180));
      expect(highValueLoaded.dailyReminderTime, equals('23:59'));
    });

    test('should maintain data integrity across multiple operations', () async {
      // 1. 複数回の読み書き操作
      for (int i = 0; i < 5; i++) {
        final settings = UserSettings(
          language: i.isEven ? 'ja' : 'en',
          studyGoalPerDay: 30 + (i * 10),
          themeMode: ['system', 'light', 'dark'][i % 3],
        );

        await settingsService.saveSettings(settings);
        final loadedSettings = await settingsService.loadSettings();

        expect(loadedSettings, equals(settings));
        expect(loadedSettings.studyGoalPerDay, equals(30 + (i * 10)));
      }

      // 2. 最終状態の確認
      final finalSettings = await settingsService.loadSettings();
      expect(finalSettings.studyGoalPerDay, equals(70)); // 30 + (4 * 10)
      expect(finalSettings.language, equals('ja')); // 4 は偶数
      expect(finalSettings.themeMode, equals('light')); // 4 % 3 = 1
    });
  });
}
