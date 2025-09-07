import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/utils/logger.dart';
import '../services/settings_service.dart';
import '../models/user_settings.dart';
import '../../../app/auth_service.dart';

/// ユーザー設定画面
/// User settings page for managing application preferences
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(userSettingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        elevation: 0,
      ),
      body: settingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                '設定の読み込みに失敗しました',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(userSettingsProvider);
                },
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
        data: (settings) => _buildSettingsContent(context, settings),
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, UserSettings settings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 一般設定セクション
          _buildSectionHeader(context, '一般設定', Icons.settings),
          const SizedBox(height: 8),
          _buildSettingsCard([
            _buildLanguageSetting(context, settings),
            _buildThemeSetting(context, settings),
          ]),
          
          const SizedBox(height: 24),

          // 通知設定セクション
          _buildSectionHeader(context, '通知設定', Icons.notifications),
          const SizedBox(height: 8),
          _buildSettingsCard([
            _buildNotificationToggle(context, settings),
            _buildReminderTimeSetting(context, settings),
            _buildSoundToggle(context, settings),
            _buildVibrationToggle(context, settings),
          ]),

          const SizedBox(height: 24),

          // 学習設定セクション
          _buildSectionHeader(context, '学習設定', Icons.school),
          const SizedBox(height: 8),
          _buildSettingsCard([
            _buildStudyGoalSetting(context, settings),
            _buildDifficultyPreference(context, settings),
          ]),

          const SizedBox(height: 24),

          // データ設定セクション
          _buildSectionHeader(context, 'データ設定', Icons.sync),
          const SizedBox(height: 8),
          _buildSettingsCard([
            _buildAutoSyncToggle(context, settings),
          ]),

          const SizedBox(height: 24),

          // アクションボタン
          _buildActionButtons(context, settings),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 2,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildLanguageSetting(BuildContext context, UserSettings settings) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: const Text('言語'),
      subtitle: Text(_getLanguageDisplayName(settings.language)),
      trailing: DropdownButton<String>(
        value: settings.language,
        onChanged: _isLoading ? null : (String? newValue) {
          if (newValue != null) {
            _updateSetting(settings.copyWith(language: newValue));
          }
        },
        items: const [
          DropdownMenuItem(value: 'ja', child: Text('日本語')),
          DropdownMenuItem(value: 'en', child: Text('English')),
        ],
      ),
    );
  }

  Widget _buildThemeSetting(BuildContext context, UserSettings settings) {
    return ListTile(
      leading: const Icon(Icons.brightness_6),
      title: const Text('テーマ'),
      subtitle: Text(_getThemeDisplayName(settings.themeMode)),
      trailing: DropdownButton<String>(
        value: settings.themeMode,
        onChanged: _isLoading ? null : (String? newValue) {
          if (newValue != null) {
            _updateSetting(settings.copyWith(themeMode: newValue));
          }
        },
        items: const [
          DropdownMenuItem(value: 'system', child: Text('システム')),
          DropdownMenuItem(value: 'light', child: Text('ライト')),
          DropdownMenuItem(value: 'dark', child: Text('ダーク')),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle(BuildContext context, UserSettings settings) {
    return SwitchListTile(
      secondary: const Icon(Icons.notifications),
      title: const Text('通知を有効にする'),
      subtitle: const Text('学習リマインダーやアップデート通知'),
      value: settings.notificationsEnabled,
      onChanged: _isLoading ? null : (bool value) {
        _updateSetting(settings.copyWith(notificationsEnabled: value));
      },
    );
  }

  Widget _buildReminderTimeSetting(BuildContext context, UserSettings settings) {
    return ListTile(
      leading: const Icon(Icons.schedule),
      title: const Text('リマインダー時刻'),
      subtitle: Text(settings.dailyReminderTime),
      trailing: IconButton(
        icon: const Icon(Icons.access_time),
        onPressed: _isLoading ? null : () => _selectReminderTime(context, settings),
      ),
    );
  }

  Widget _buildSoundToggle(BuildContext context, UserSettings settings) {
    return SwitchListTile(
      secondary: const Icon(Icons.volume_up),
      title: const Text('音声を有効にする'),
      subtitle: const Text('効果音や音声フィードバック'),
      value: settings.soundEnabled,
      onChanged: _isLoading ? null : (bool value) {
        _updateSetting(settings.copyWith(soundEnabled: value));
      },
    );
  }

  Widget _buildVibrationToggle(BuildContext context, UserSettings settings) {
    return SwitchListTile(
      secondary: const Icon(Icons.vibration),
      title: const Text('バイブレーションを有効にする'),
      subtitle: const Text('フィードバック用の振動'),
      value: settings.vibrationEnabled,
      onChanged: _isLoading ? null : (bool value) {
        _updateSetting(settings.copyWith(vibrationEnabled: value));
      },
    );
  }

  Widget _buildStudyGoalSetting(BuildContext context, UserSettings settings) {
    return ListTile(
      leading: const Icon(Icons.timer),
      title: const Text('1日の学習目標'),
      subtitle: Text('${settings.studyGoalPerDay}分'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _isLoading || settings.studyGoalPerDay <= 10 ? null : () {
              _updateSetting(settings.copyWith(studyGoalPerDay: settings.studyGoalPerDay - 10));
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _isLoading || settings.studyGoalPerDay >= 180 ? null : () {
              _updateSetting(settings.copyWith(studyGoalPerDay: settings.studyGoalPerDay + 10));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyPreference(BuildContext context, UserSettings settings) {
    return ListTile(
      leading: const Icon(Icons.trending_up),
      title: const Text('難易度設定'),
      subtitle: Text(_getDifficultyDisplayName(settings.difficultyPreference)),
      trailing: DropdownButton<String>(
        value: settings.difficultyPreference,
        onChanged: _isLoading ? null : (String? newValue) {
          if (newValue != null) {
            _updateSetting(settings.copyWith(difficultyPreference: newValue));
          }
        },
        items: const [
          DropdownMenuItem(value: 'beginner', child: Text('初級')),
          DropdownMenuItem(value: 'intermediate', child: Text('中級')),
          DropdownMenuItem(value: 'advanced', child: Text('上級')),
        ],
      ),
    );
  }

  Widget _buildAutoSyncToggle(BuildContext context, UserSettings settings) {
    return SwitchListTile(
      secondary: const Icon(Icons.cloud_sync),
      title: const Text('自動同期'),
      subtitle: const Text('将来のクラウド同期機能用（現在は無効）'),
      value: settings.autoSync,
      onChanged: null, // 現在は無効化
    );
  }

  Widget _buildActionButtons(BuildContext context, UserSettings settings) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () => _resetSettings(context),
            icon: const Icon(Icons.refresh),
            label: const Text('デフォルト設定にリセット'),
          ),
        ),
      ],
    );
  }

  // Helper methods for display names
  String _getLanguageDisplayName(String language) {
    switch (language) {
      case 'ja': return '日本語';
      case 'en': return 'English';
      default: return language;
    }
  }

  String _getThemeDisplayName(String theme) {
    switch (theme) {
      case 'system': return 'システム';
      case 'light': return 'ライト';
      case 'dark': return 'ダーク';
      default: return theme;
    }
  }

  String _getDifficultyDisplayName(String difficulty) {
    switch (difficulty) {
      case 'beginner': return '初級';
      case 'intermediate': return '中級';
      case 'advanced': return '上級';
      default: return difficulty;
    }
  }

  // Action methods
  Future<void> _updateSetting(UserSettings newSettings) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(userSettingsProvider.notifier).updateSettings(newSettings);
      
      // 認証されている場合は、AuthServiceの設定も更新
      final authService = ref.read(authServiceProvider.notifier);
      if (authService.isAuthenticated) {
        await authService.updateUserSettings(newSettings);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('設定が更新されました'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Failed to update settings', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('設定の更新に失敗しました: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectReminderTime(BuildContext context, UserSettings settings) async {
    final currentTime = _parseTime(settings.dailyReminderTime);
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (selectedTime != null) {
      final timeString = '${selectedTime.hour.toString().padLeft(2, '0')}:'
                        '${selectedTime.minute.toString().padLeft(2, '0')}';
      _updateSetting(settings.copyWith(dailyReminderTime: timeString));
    }
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  Future<void> _resetSettings(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('設定のリセット'),
        content: const Text('すべての設定をデフォルト値に戻しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('リセット'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(userSettingsProvider.notifier).resetSettings();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('設定をデフォルト値にリセットしました'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        AppLogger.error('Failed to reset settings', e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('設定のリセットに失敗しました: $e'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}