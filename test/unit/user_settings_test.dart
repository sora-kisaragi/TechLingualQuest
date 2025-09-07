import 'package:flutter_test/flutter_test.dart';
import 'package:tech_lingual_quest/features/settings/models/user_settings.dart';

void main() {
  group('UserSettings Model Tests', () {
    test('should create UserSettings with default values', () {
      const settings = UserSettings();

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

    test('should create UserSettings with custom values', () {
      const settings = UserSettings(
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

      expect(settings.language, equals('en'));
      expect(settings.notificationsEnabled, equals(false));
      expect(settings.dailyReminderTime, equals('10:30'));
      expect(settings.themeMode, equals('dark'));
      expect(settings.studyGoalPerDay, equals(60));
      expect(settings.difficultyPreference, equals('advanced'));
      expect(settings.soundEnabled, equals(false));
      expect(settings.vibrationEnabled, equals(false));
      expect(settings.autoSync, equals(true));
    });

    test('should create copy with modified values', () {
      const originalSettings = UserSettings();
      final modifiedSettings = originalSettings.copyWith(
        language: 'en',
        themeMode: 'light',
        studyGoalPerDay: 45,
      );

      // Modified values
      expect(modifiedSettings.language, equals('en'));
      expect(modifiedSettings.themeMode, equals('light'));
      expect(modifiedSettings.studyGoalPerDay, equals(45));

      // Unchanged values
      expect(modifiedSettings.notificationsEnabled, equals(true));
      expect(modifiedSettings.dailyReminderTime, equals('09:00'));
      expect(modifiedSettings.difficultyPreference, equals('intermediate'));
      expect(modifiedSettings.soundEnabled, equals(true));
      expect(modifiedSettings.vibrationEnabled, equals(true));
      expect(modifiedSettings.autoSync, equals(false));
    });

    test('should preserve original settings when copying', () {
      const originalSettings = UserSettings(language: 'ja');
      final copiedSettings = originalSettings.copyWith(language: 'en');

      expect(originalSettings.language, equals('ja'));
      expect(copiedSettings.language, equals('en'));

      // Verify they are different instances
      expect(identical(originalSettings, copiedSettings), isFalse);
    });

    test('should handle equality comparison correctly', () {
      const settings1 = UserSettings(
        language: 'en',
        themeMode: 'dark',
        studyGoalPerDay: 45,
      );
      const settings2 = UserSettings(
        language: 'en',
        themeMode: 'dark',
        studyGoalPerDay: 45,
      );
      const settings3 = UserSettings(
        language: 'ja',
        themeMode: 'dark',
        studyGoalPerDay: 45,
      );

      expect(settings1 == settings2, isTrue);
      expect(settings1 == settings3, isFalse);
      expect(settings1.hashCode == settings2.hashCode, isTrue);
      expect(settings1.hashCode == settings3.hashCode, isFalse);
    });

    test('should convert to JSON correctly', () {
      const settings = UserSettings(
        language: 'en',
        notificationsEnabled: false,
        dailyReminderTime: '08:30',
        themeMode: 'light',
        studyGoalPerDay: 90,
        difficultyPreference: 'beginner',
        soundEnabled: false,
        vibrationEnabled: true,
        autoSync: true,
      );

      final json = settings.toJson();

      expect(json['language'], equals('en'));
      expect(json['notificationsEnabled'], equals(false));
      expect(json['dailyReminderTime'], equals('08:30'));
      expect(json['themeMode'], equals('light'));
      expect(json['studyGoalPerDay'], equals(90));
      expect(json['difficultyPreference'], equals('beginner'));
      expect(json['soundEnabled'], equals(false));
      expect(json['vibrationEnabled'], equals(true));
      expect(json['autoSync'], equals(true));
    });

    test('should create from JSON correctly', () {
      final json = {
        'language': 'en',
        'notificationsEnabled': false,
        'dailyReminderTime': '07:15',
        'themeMode': 'dark',
        'studyGoalPerDay': 120,
        'difficultyPreference': 'advanced',
        'soundEnabled': true,
        'vibrationEnabled': false,
        'autoSync': true,
      };

      final settings = UserSettings.fromJson(json);

      expect(settings.language, equals('en'));
      expect(settings.notificationsEnabled, equals(false));
      expect(settings.dailyReminderTime, equals('07:15'));
      expect(settings.themeMode, equals('dark'));
      expect(settings.studyGoalPerDay, equals(120));
      expect(settings.difficultyPreference, equals('advanced'));
      expect(settings.soundEnabled, equals(true));
      expect(settings.vibrationEnabled, equals(false));
      expect(settings.autoSync, equals(true));
    });

    test('should handle partial JSON correctly', () {
      final json = {
        'language': 'en',
        'studyGoalPerDay': 75,
      };

      final settings = UserSettings.fromJson(json);

      // Specified values
      expect(settings.language, equals('en'));
      expect(settings.studyGoalPerDay, equals(75));

      // Default values for unspecified fields
      expect(settings.notificationsEnabled, equals(true));
      expect(settings.dailyReminderTime, equals('09:00'));
      expect(settings.themeMode, equals('system'));
      expect(settings.difficultyPreference, equals('intermediate'));
      expect(settings.soundEnabled, equals(true));
      expect(settings.vibrationEnabled, equals(true));
      expect(settings.autoSync, equals(false));
    });

    test('should handle JSON roundtrip correctly', () {
      const originalSettings = UserSettings(
        language: 'en',
        notificationsEnabled: false,
        dailyReminderTime: '11:45',
        themeMode: 'light',
        studyGoalPerDay: 60,
        difficultyPreference: 'intermediate',
        soundEnabled: false,
        vibrationEnabled: true,
        autoSync: false,
      );

      final json = originalSettings.toJson();
      final restoredSettings = UserSettings.fromJson(json);

      expect(restoredSettings, equals(originalSettings));
    });

    test('should generate string representation correctly', () {
      const settings = UserSettings(
        language: 'en',
        themeMode: 'dark',
        studyGoalPerDay: 45,
      );

      final stringRepresentation = settings.toString();

      expect(stringRepresentation, contains('UserSettings'));
      expect(stringRepresentation, contains('language: en'));
      expect(stringRepresentation, contains('themeMode: dark'));
      expect(stringRepresentation, contains('studyGoalPerDay: 45'));
    });

    test('should handle edge cases for study goal', () {
      const settingsMin = UserSettings(studyGoalPerDay: 1);
      const settingsMax = UserSettings(studyGoalPerDay: 999);

      expect(settingsMin.studyGoalPerDay, equals(1));
      expect(settingsMax.studyGoalPerDay, equals(999));
    });

    test('should handle edge cases for reminder time', () {
      const settingsMidnight = UserSettings(dailyReminderTime: '00:00');
      const settingsNoon = UserSettings(dailyReminderTime: '12:00');
      const settingsEndOfDay = UserSettings(dailyReminderTime: '23:59');

      expect(settingsMidnight.dailyReminderTime, equals('00:00'));
      expect(settingsNoon.dailyReminderTime, equals('12:00'));
      expect(settingsEndOfDay.dailyReminderTime, equals('23:59'));
    });

    test('should validate all theme mode options', () {
      const lightTheme = UserSettings(themeMode: 'light');
      const darkTheme = UserSettings(themeMode: 'dark');
      const systemTheme = UserSettings(themeMode: 'system');

      expect(lightTheme.themeMode, equals('light'));
      expect(darkTheme.themeMode, equals('dark'));
      expect(systemTheme.themeMode, equals('system'));
    });

    test('should validate all difficulty preferences', () {
      const beginner = UserSettings(difficultyPreference: 'beginner');
      const intermediate = UserSettings(difficultyPreference: 'intermediate');
      const advanced = UserSettings(difficultyPreference: 'advanced');

      expect(beginner.difficultyPreference, equals('beginner'));
      expect(intermediate.difficultyPreference, equals('intermediate'));
      expect(advanced.difficultyPreference, equals('advanced'));
    });

    test('should validate all language options', () {
      const japanese = UserSettings(language: 'ja');
      const english = UserSettings(language: 'en');

      expect(japanese.language, equals('ja'));
      expect(english.language, equals('en'));
    });
  });
}
