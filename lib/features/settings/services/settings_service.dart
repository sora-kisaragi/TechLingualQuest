import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_settings.dart';
import '../../../shared/utils/logger.dart';

/// ユーザー設定の永続化サービス
/// Service for persisting user settings using SharedPreferences
class SettingsService {
  static const String _settingsKey = 'user_settings';
  SharedPreferences? _prefs;

  // 同時更新を防ぐためのロック機構
  // Lock mechanism to prevent concurrent updates
  static bool _isUpdating = false;

  /// SharedPreferences の初期化
  /// Initialize SharedPreferences
  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// ユーザー設定を読み込み
  /// Load user settings from storage
  Future<UserSettings> loadSettings() async {
    try {
      await _ensureInitialized();
      final settingsJson = _prefs!.getString(_settingsKey);

      if (settingsJson == null) {
        AppLogger.info('No saved settings found, returning default settings');
        return const UserSettings();
      }

      final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
      final settings = UserSettings.fromJson(settingsMap);

      AppLogger.info('User settings loaded successfully');
      return settings;
    } catch (e, stackTrace) {
      AppLogger.error(
          'Failed to load user settings, returning defaults', e, stackTrace);
      return const UserSettings();
    }
  }

  /// ユーザー設定を保存
  /// Save user settings to storage
  Future<bool> saveSettings(UserSettings settings) async {
    try {
      await _ensureInitialized();
      final settingsJson = json.encode(settings.toJson());
      final success = await _prefs!.setString(_settingsKey, settingsJson);

      if (success) {
        AppLogger.info('User settings saved successfully');
      } else {
        AppLogger.warning('Failed to save user settings');
      }

      return success;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save user settings', e, stackTrace);
      return false;
    }
  }

  /// 特定の設定項目を更新
  /// Update specific setting item
  Future<bool> updateSetting<T>(String key, T value) async {
    // 同時更新を防ぐための簡単なロック機構
    // Simple lock mechanism to prevent concurrent updates
    while (_isUpdating) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    _isUpdating = true;

    try {
      final currentSettings = await loadSettings();
      UserSettings updatedSettings;

      // 設定項目に応じて更新を実行
      // Update based on setting key
      switch (key) {
        case 'language':
          updatedSettings = currentSettings.copyWith(language: value as String);
          break;
        case 'notificationsEnabled':
          updatedSettings =
              currentSettings.copyWith(notificationsEnabled: value as bool);
          break;
        case 'dailyReminderTime':
          updatedSettings =
              currentSettings.copyWith(dailyReminderTime: value as String);
          break;
        case 'themeMode':
          updatedSettings =
              currentSettings.copyWith(themeMode: value as String);
          break;
        case 'studyGoalPerDay':
          updatedSettings =
              currentSettings.copyWith(studyGoalPerDay: value as int);
          break;
        case 'difficultyPreference':
          updatedSettings =
              currentSettings.copyWith(difficultyPreference: value as String);
          break;
        case 'soundEnabled':
          updatedSettings =
              currentSettings.copyWith(soundEnabled: value as bool);
          break;
        case 'vibrationEnabled':
          updatedSettings =
              currentSettings.copyWith(vibrationEnabled: value as bool);
          break;
        case 'autoSync':
          updatedSettings = currentSettings.copyWith(autoSync: value as bool);
          break;
        default:
          AppLogger.warning('Unknown setting key: $key');
          return false;
      }

      final result = await saveSettings(updatedSettings);
      return result;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update setting $key', e, stackTrace);
      return false;
    } finally {
      _isUpdating = false;
    }
  }

  /// 設定をデフォルト値にリセット
  /// Reset settings to default values
  Future<bool> resetToDefaults() async {
    try {
      await _ensureInitialized();
      final success = await _prefs!.remove(_settingsKey);

      if (success) {
        AppLogger.info('User settings reset to defaults');
      } else {
        AppLogger.warning('Failed to reset user settings');
      }

      return success;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to reset user settings', e, stackTrace);
      return false;
    }
  }

  /// 設定データのエクスポート（将来のデータ共有機能用）
  /// Export settings data for future data sharing features
  Future<Map<String, dynamic>?> exportSettings() async {
    try {
      final settings = await loadSettings();
      AppLogger.info('User settings exported successfully');
      return settings.toJson();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to export user settings', e, stackTrace);
      return null;
    }
  }

  /// 設定データのインポート（将来のデータ共有機能用）
  /// Import settings data for future data sharing features
  Future<bool> importSettings(Map<String, dynamic> settingsData) async {
    try {
      final settings = UserSettings.fromJson(settingsData);
      final success = await saveSettings(settings);

      if (success) {
        AppLogger.info('User settings imported successfully');
      }

      return success;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to import user settings', e, stackTrace);
      return false;
    }
  }
}

/// Riverpod プロバイダー
/// Riverpod provider for settings service
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

/// 現在の設定状態を管理するプロバイダー
/// Provider for managing current settings state
final userSettingsProvider =
    StateNotifierProvider<UserSettingsNotifier, AsyncValue<UserSettings>>(
        (ref) {
  return UserSettingsNotifier(ref.read(settingsServiceProvider));
});

/// ユーザー設定の状態管理クラス
/// State management class for user settings
class UserSettingsNotifier extends StateNotifier<AsyncValue<UserSettings>> {
  UserSettingsNotifier(this._settingsService)
      : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  final SettingsService _settingsService;

  /// 設定を読み込み
  /// Load settings
  Future<void> _loadSettings() async {
    try {
      final settings = await _settingsService.loadSettings();
      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      AppLogger.error('Failed to load settings in notifier', error, stackTrace);
    }
  }

  /// 設定を更新
  /// Update settings
  Future<void> updateSettings(UserSettings newSettings) async {
    final currentState = state;
    // 楽観的更新 / Optimistic update
    state = AsyncValue.data(newSettings);

    try {
      final success = await _settingsService.saveSettings(newSettings);
      if (!success) {
        // 保存に失敗した場合、元の状態に戻す
        // Revert to previous state if save failed
        state = currentState;
        throw Exception('Failed to save settings');
      }
    } catch (error, stackTrace) {
      // エラー時は元の状態に戻す
      // Revert to previous state on error
      state = currentState;
      AppLogger.error('Failed to update settings', error, stackTrace);
      rethrow;
    }
  }

  /// 設定をリセット
  /// Reset settings
  Future<void> resetSettings() async {
    try {
      await _settingsService.resetToDefaults();
      await _loadSettings();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to reset settings', error, stackTrace);
      rethrow;
    }
  }
}
