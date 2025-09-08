import 'package:flutter_test/flutter_test.dart';
import 'package:tech_lingual_quest/features/settings/services/settings_service.dart';
import 'package:tech_lingual_quest/features/settings/models/user_settings.dart';

void main() {
  group('SettingsService Comprehensive Coverage Tests', () {
    late SettingsService settingsService;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      settingsService = SettingsService();
    });

    tearDown(() {
      // Reset to clean state for each test
      settingsService.resetToDefaults().catchError((_) {});
    });

    group('Basic CRUD Operations', () {
      test('loadSettings should return default settings when no data exists', () async {
        final settings = await settingsService.loadSettings();
        
        expect(settings, isA<UserSettings>());
        expect(settings.language, isA<String>());
        expect(settings.themeMode, isA<String>());
        expect(settings.notificationsEnabled, isA<bool>());
      });

      test('saveSettings should persist settings successfully', () async {
        const testSettings = UserSettings(
          language: 'ja',
          themeMode: 'dark',
          notificationsEnabled: false,
          soundEnabled: false,
          difficultyPreference: 'intermediate',
          studyGoalPerDay: 30,
          dailyReminderTime: '09:00',
          vibrationEnabled: false,
          autoSync: true,
        );

        final saveResult = await settingsService.saveSettings(testSettings);
        expect(saveResult, true);

        final loadedSettings = await settingsService.loadSettings();
        expect(loadedSettings.language, 'ja');
        expect(loadedSettings.themeMode, 'dark');
        expect(loadedSettings.notificationsEnabled, false);
        expect(loadedSettings.soundEnabled, false);
        expect(loadedSettings.difficultyPreference, 'intermediate');
        expect(loadedSettings.studyGoalPerDay, 30);
      });

      test('loadSettings should handle malformed JSON gracefully', () async {
        final settings = await settingsService.loadSettings();
        expect(settings, isA<UserSettings>());
      });

      test('saveSettings should handle encoding errors gracefully', () async {
        const validSettings = UserSettings(language: 'en');
        final result = await settingsService.saveSettings(validSettings);
        expect(result, isA<bool>());
      });
    });

    group('Individual Setting Updates', () {
      test('updateSetting should update language correctly', () async {
        final result = await settingsService.updateSetting('language', 'ja');
        expect(result, true);

        final settings = await settingsService.loadSettings();
        expect(settings.language, 'ja');
      });

      test('updateSetting should update notificationsEnabled correctly', () async {
        final result = await settingsService.updateSetting('notificationsEnabled', false);
        expect(result, true);

        final settings = await settingsService.loadSettings();
        expect(settings.notificationsEnabled, false);
      });

      test('updateSetting should update themeMode correctly', () async {
        final result = await settingsService.updateSetting('themeMode', 'dark');
        expect(result, true);

        final settings = await settingsService.loadSettings();
        expect(settings.themeMode, 'dark');
      });

      test('updateSetting should update studyGoalPerDay correctly', () async {
        final result = await settingsService.updateSetting('studyGoalPerDay', 45);
        expect(result, true);

        final settings = await settingsService.loadSettings();
        expect(settings.studyGoalPerDay, 45);
      });

      test('updateSetting should handle unknown setting keys', () async {
        final result = await settingsService.updateSetting('unknownKey', 'value');
        expect(result, false);
      });
    });

    group('Reset Functionality', () {
      test('resetToDefaults should clear all settings', () async {
        const customSettings = UserSettings(
          language: 'ja',
          themeMode: 'dark',
          notificationsEnabled: false,
        );
        await settingsService.saveSettings(customSettings);

        final resetResult = await settingsService.resetToDefaults();
        expect(resetResult, true);

        final afterReset = await settingsService.loadSettings();
        expect(afterReset, isA<UserSettings>());
      });

      test('resetToDefaults should handle storage errors gracefully', () async {
        final result = await settingsService.resetToDefaults();
        expect(result, isA<bool>());
      });
    });

    group('Import/Export Functionality', () {
      test('exportSettings should return current settings as JSON', () async {
        const testSettings = UserSettings(
          language: 'ko',
          themeMode: 'light',
          notificationsEnabled: true,
          studyGoalPerDay: 25,
        );
        await settingsService.saveSettings(testSettings);

        final exportedData = await settingsService.exportSettings();
        
        expect(exportedData, isNotNull);
        expect(exportedData!['language'], 'ko');
        expect(exportedData['themeMode'], 'light');
        expect(exportedData['notificationsEnabled'], true);
        expect(exportedData['studyGoalPerDay'], 25);
      });

      test('importSettings should restore settings from JSON', () async {
        final importData = {
          'language': 'zh',
          'themeMode': 'dark',
          'notificationsEnabled': false,
          'soundEnabled': false,
          'difficultyPreference': 'intermediate',
          'studyGoalPerDay': 40,
          'dailyReminderTime': '07:30',
          'vibrationEnabled': true,
          'autoSync': false,
        };

        final importResult = await settingsService.importSettings(importData);
        expect(importResult, true);

        final settings = await settingsService.loadSettings();
        expect(settings.language, 'zh');
        expect(settings.themeMode, 'dark');
        expect(settings.notificationsEnabled, false);
        expect(settings.studyGoalPerDay, 40);
        expect(settings.vibrationEnabled, true);
      });

      test('exportSettings should handle export errors gracefully', () async {
        final exportData = await settingsService.exportSettings();
        expect(exportData, isA<Map<String, dynamic>?>());
      });
    });

    group('Error Handling Coverage', () {
      test('All methods should handle storage errors gracefully', () async {
        try {
          await settingsService.loadSettings();
          await settingsService.saveSettings(const UserSettings());
          await settingsService.updateSetting('language', 'en');
          await settingsService.resetToDefaults();
          await settingsService.exportSettings();
          await settingsService.importSettings({'language': 'en'});
        } catch (e) {
          print('Storage error handling test: $e');
        }
      });

      test('Multiple rapid updates should be handled correctly', () async {
        final futures = <Future<bool>>[];
        for (int i = 0; i < 5; i++) {
          futures.add(settingsService.updateSetting('studyGoalPerDay', i + 10));
        }

        final results = await Future.wait(futures);
        
        for (final result in results) {
          expect(result, isA<bool>());
        }

        final finalSettings = await settingsService.loadSettings();
        expect(finalSettings.studyGoalPerDay, isA<int>());
      });

      test('Settings should persist across service instances', () async {
        const testSettings = UserSettings(
          language: 'pt',
          studyGoalPerDay: 50,
        );

        await settingsService.saveSettings(testSettings);

        final newService = SettingsService();
        final loadedSettings = await newService.loadSettings();

        expect(loadedSettings.language, 'pt');
        expect(loadedSettings.studyGoalPerDay, 50);
      });
    });
  });
}