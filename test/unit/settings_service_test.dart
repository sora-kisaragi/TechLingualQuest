import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tech_lingual_quest/features/settings/models/user_settings.dart';
import 'package:tech_lingual_quest/features/settings/services/settings_service.dart';

void main() {
  group('SettingsService Tests', () {
    late SettingsService settingsService;

    setUp(() {
      // SharedPreferencesを初期化（テスト用）
      SharedPreferences.setMockInitialValues({});
      settingsService = SettingsService();
    });

    test('should load default settings when no saved settings exist', () async {
      final settings = await settingsService.loadSettings();

      expect(settings.language, equals('ja'));
      expect(settings.notificationsEnabled, equals(true));
      expect(settings.dailyReminderTime, equals('09:00'));
      expect(settings.themeMode, equals('system'));
      expect(settings.studyGoalPerDay, equals(30));
      expect(settings.difficultyPreference, equals('intermediate'));
      expect(settings.soundEnabled, equals(true));
      expect(settings.vibrationEnabled, equals(true));
      expect(settings.autoSync, equals(false));
    });

    test('should save and load settings correctly', () async {
      const testSettings = UserSettings(
        language: 'en',
        notificationsEnabled: false,
        dailyReminderTime: '10:30',
        themeMode: 'dark',
        studyGoalPerDay: 60,
        difficultyPreference: 'advanced',
        soundEnabled: false,
        vibrationEnabled: false,
        autoSync: true,
      );

      final saveSuccess = await settingsService.saveSettings(testSettings);
      expect(saveSuccess, isTrue);

      final loadedSettings = await settingsService.loadSettings();
      expect(loadedSettings, equals(testSettings));
    });

    test('should update specific setting correctly', () async {
      // 初期設定を保存
      const initialSettings = UserSettings();
      await settingsService.saveSettings(initialSettings);

      // 言語設定を更新
      final updateSuccess =
          await settingsService.updateSetting('language', 'en');
      expect(updateSuccess, isTrue);

      // 更新された設定を確認
      final updatedSettings = await settingsService.loadSettings();
      expect(updatedSettings.language, equals('en'));
      expect(updatedSettings.notificationsEnabled, equals(true)); // 変更されていない
    });

    test('should update notification settings correctly', () async {
      const initialSettings = UserSettings();
      await settingsService.saveSettings(initialSettings);

      final updateSuccess =
          await settingsService.updateSetting('notificationsEnabled', false);
      expect(updateSuccess, isTrue);

      final updatedSettings = await settingsService.loadSettings();
      expect(updatedSettings.notificationsEnabled, equals(false));
      expect(updatedSettings.language, equals('ja')); // 変更されていない
    });

    test('should update reminder time correctly', () async {
      const initialSettings = UserSettings();
      await settingsService.saveSettings(initialSettings);

      final updateSuccess =
          await settingsService.updateSetting('dailyReminderTime', '07:30');
      expect(updateSuccess, isTrue);

      final updatedSettings = await settingsService.loadSettings();
      expect(updatedSettings.dailyReminderTime, equals('07:30'));
    });

    test('should update theme mode correctly', () async {
      const initialSettings = UserSettings();
      await settingsService.saveSettings(initialSettings);

      final updateSuccess =
          await settingsService.updateSetting('themeMode', 'light');
      expect(updateSuccess, isTrue);

      final updatedSettings = await settingsService.loadSettings();
      expect(updatedSettings.themeMode, equals('light'));
    });

    test('should update study goal correctly', () async {
      const initialSettings = UserSettings();
      await settingsService.saveSettings(initialSettings);

      final updateSuccess =
          await settingsService.updateSetting('studyGoalPerDay', 90);
      expect(updateSuccess, isTrue);

      final updatedSettings = await settingsService.loadSettings();
      expect(updatedSettings.studyGoalPerDay, equals(90));
    });

    test('should update difficulty preference correctly', () async {
      const initialSettings = UserSettings();
      await settingsService.saveSettings(initialSettings);

      final updateSuccess = await settingsService.updateSetting(
          'difficultyPreference', 'beginner');
      expect(updateSuccess, isTrue);

      final updatedSettings = await settingsService.loadSettings();
      expect(updatedSettings.difficultyPreference, equals('beginner'));
    });

    test('should update sound settings correctly', () async {
      const initialSettings = UserSettings();
      await settingsService.saveSettings(initialSettings);

      final updateSuccess =
          await settingsService.updateSetting('soundEnabled', false);
      expect(updateSuccess, isTrue);

      final updatedSettings = await settingsService.loadSettings();
      expect(updatedSettings.soundEnabled, equals(false));
    });

    test('should update vibration settings correctly', () async {
      const initialSettings = UserSettings();
      await settingsService.saveSettings(initialSettings);

      final updateSuccess =
          await settingsService.updateSetting('vibrationEnabled', false);
      expect(updateSuccess, isTrue);

      final updatedSettings = await settingsService.loadSettings();
      expect(updatedSettings.vibrationEnabled, equals(false));
    });

    test('should update auto sync settings correctly', () async {
      const initialSettings = UserSettings();
      await settingsService.saveSettings(initialSettings);

      final updateSuccess =
          await settingsService.updateSetting('autoSync', true);
      expect(updateSuccess, isTrue);

      final updatedSettings = await settingsService.loadSettings();
      expect(updatedSettings.autoSync, equals(true));
    });

    test('should return false for unknown setting key', () async {
      const initialSettings = UserSettings();
      await settingsService.saveSettings(initialSettings);

      final updateSuccess =
          await settingsService.updateSetting('unknownKey', 'value');
      expect(updateSuccess, isFalse);
    });

    test('should reset settings to defaults', () async {
      // カスタム設定を保存
      const customSettings = UserSettings(
        language: 'en',
        notificationsEnabled: false,
        themeMode: 'dark',
        studyGoalPerDay: 120,
      );
      await settingsService.saveSettings(customSettings);

      // 設定をリセット
      final resetSuccess = await settingsService.resetToDefaults();
      expect(resetSuccess, isTrue);

      // デフォルト設定が読み込まれることを確認
      final defaultSettings = await settingsService.loadSettings();
      expect(defaultSettings.language, equals('ja'));
      expect(defaultSettings.notificationsEnabled, equals(true));
      expect(defaultSettings.themeMode, equals('system'));
      expect(defaultSettings.studyGoalPerDay, equals(30));
    });

    test('should export settings correctly', () async {
      const testSettings = UserSettings(
        language: 'en',
        notificationsEnabled: false,
        dailyReminderTime: '08:15',
        themeMode: 'light',
        studyGoalPerDay: 45,
        difficultyPreference: 'advanced',
        soundEnabled: false,
        vibrationEnabled: true,
        autoSync: false,
      );

      await settingsService.saveSettings(testSettings);

      final exportedData = await settingsService.exportSettings();
      expect(exportedData, isNotNull);

      final exportedSettings = UserSettings.fromJson(exportedData!);
      expect(exportedSettings, equals(testSettings));
    });

    test('should import settings correctly', () async {
      final importData = {
        'language': 'en',
        'notificationsEnabled': false,
        'dailyReminderTime': '11:30',
        'themeMode': 'dark',
        'studyGoalPerDay': 75,
        'difficultyPreference': 'beginner',
        'soundEnabled': true,
        'vibrationEnabled': false,
        'autoSync': true,
      };

      final importSuccess = await settingsService.importSettings(importData);
      expect(importSuccess, isTrue);

      final importedSettings = await settingsService.loadSettings();
      expect(importedSettings.language, equals('en'));
      expect(importedSettings.notificationsEnabled, equals(false));
      expect(importedSettings.dailyReminderTime, equals('11:30'));
      expect(importedSettings.themeMode, equals('dark'));
      expect(importedSettings.studyGoalPerDay, equals(75));
      expect(importedSettings.difficultyPreference, equals('beginner'));
      expect(importedSettings.soundEnabled, equals(true));
      expect(importedSettings.vibrationEnabled, equals(false));
      expect(importedSettings.autoSync, equals(true));
    });

    test('should handle corrupt settings data gracefully', () async {
      // 不正なJSONデータをSharedPreferencesに設定
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_settings', 'invalid json data');

      // デフォルト設定が返されることを確認
      final settings = await settingsService.loadSettings();
      expect(settings.language, equals('ja'));
      expect(settings.notificationsEnabled, equals(true));
    });

    test('should handle multiple rapid updates correctly', () async {
      const initialSettings = UserSettings();
      await settingsService.saveSettings(initialSettings);

      // 複数の更新を同時実行
      final futures = [
        settingsService.updateSetting('language', 'en'),
        settingsService.updateSetting('themeMode', 'dark'),
        settingsService.updateSetting('studyGoalPerDay', 60),
        settingsService.updateSetting('notificationsEnabled', false),
      ];

      final results = await Future.wait(futures);
      expect(results.every((result) => result), isTrue);

      final finalSettings = await settingsService.loadSettings();
      expect(finalSettings.language, equals('en'));
      expect(finalSettings.themeMode, equals('dark'));
      expect(finalSettings.studyGoalPerDay, equals(60));
      expect(finalSettings.notificationsEnabled, equals(false));
    });
  });

  group('UserSettingsNotifier Tests', () {
    late ProviderContainer container;
    late UserSettingsNotifier notifier;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      notifier = container.read(userSettingsProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('should load default settings on initialization', () async {
      // 少し待機して初期化完了を確認
      await Future.delayed(const Duration(milliseconds: 100));

      final settingsState = container.read(userSettingsProvider);
      expect(settingsState.hasValue, isTrue);

      final settings = settingsState.value!;
      expect(settings.language, equals('ja'));
      expect(settings.notificationsEnabled, equals(true));
    });

    test('should update settings and persist changes', () async {
      // 初期化完了を待機
      await Future.delayed(const Duration(milliseconds: 100));

      const newSettings = UserSettings(
        language: 'en',
        themeMode: 'dark',
        studyGoalPerDay: 45,
      );

      await notifier.updateSettings(newSettings);

      final updatedState = container.read(userSettingsProvider);
      expect(updatedState.hasValue, isTrue);
      expect(updatedState.value, equals(newSettings));
    });

    test('should reset settings to defaults', () async {
      // 初期化とカスタム設定の設定
      await Future.delayed(const Duration(milliseconds: 100));

      const customSettings = UserSettings(
        language: 'en',
        themeMode: 'dark',
        studyGoalPerDay: 90,
      );
      await notifier.updateSettings(customSettings);

      // リセット実行
      await notifier.resetSettings();

      final resetState = container.read(userSettingsProvider);
      expect(resetState.hasValue, isTrue);

      final resetSettings = resetState.value!;
      expect(resetSettings.language, equals('ja'));
      expect(resetSettings.themeMode, equals('system'));
      expect(resetSettings.studyGoalPerDay, equals(30));
    });

    test('should handle errors gracefully during update', () async {
      // 初期化完了を待機
      await Future.delayed(const Duration(milliseconds: 100));

      // モックで失敗を強制するため、無効なProviderContainerを作成
      final badContainer = ProviderContainer(
        overrides: [
          settingsServiceProvider
              .overrideWith((ref) => _FailingSettingsService()),
        ],
      );

      final badNotifier = badContainer.read(userSettingsProvider.notifier);

      try {
        const newSettings = UserSettings(language: 'en');
        await badNotifier.updateSettings(newSettings);
        fail('Expected an exception');
      } catch (e) {
        expect(e, isA<Exception>());
      }

      badContainer.dispose();
    });
  });
}

/// テスト用の失敗するSettingsService
class _FailingSettingsService extends SettingsService {
  @override
  Future<bool> saveSettings(UserSettings settings) async {
    return false; // 常に失敗を返す
  }

  @override
  Future<UserSettings> loadSettings() async {
    return const UserSettings(); // デフォルト設定を返す
  }
}
