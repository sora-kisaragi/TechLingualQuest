import 'package:json_annotation/json_annotation.dart';

part 'user_settings.g.dart';

/// ユーザー設定データモデル
/// User settings data model for persistence and configuration management
@JsonSerializable()
class UserSettings {
  const UserSettings({
    this.language = 'ja',
    this.notificationsEnabled = true,
    this.dailyReminderTime = '09:00',
    this.themeMode = 'system',
    this.studyGoalPerDay = 30,
    this.difficultyPreference = 'intermediate',
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.autoSync = false,
  });

  /// アプリ言語設定 (ja, en, etc.)
  /// App language setting
  final String language;

  /// 通知有効フラグ
  /// Notifications enabled flag
  final bool notificationsEnabled;

  /// 毎日の学習リマインダー時間 (HH:mm format)
  /// Daily learning reminder time
  final String dailyReminderTime;

  /// テーマモード (light, dark, system)
  /// Theme mode setting
  final String themeMode;

  /// 1日の学習目標時間（分）
  /// Daily study goal in minutes
  final int studyGoalPerDay;

  /// 難易度設定 (beginner, intermediate, advanced)
  /// Difficulty preference
  final String difficultyPreference;

  /// 音声有効フラグ
  /// Sound enabled flag
  final bool soundEnabled;

  /// バイブレーション有効フラグ
  /// Vibration enabled flag
  final bool vibrationEnabled;

  /// 自動同期有効フラグ（将来のクラウド同期用）
  /// Auto sync enabled flag (for future cloud sync)
  final bool autoSync;

  /// JSON から UserSettings インスタンスを作成
  /// Create UserSettings instance from JSON
  factory UserSettings.fromJson(Map<String, dynamic> json) => 
      _$UserSettingsFromJson(json);

  /// UserSettings インスタンスを JSON に変換
  /// Convert UserSettings instance to JSON
  Map<String, dynamic> toJson() => _$UserSettingsToJson(this);

  /// コピーコンストラクタ - 設定更新時に使用
  /// Copy constructor for updating settings
  UserSettings copyWith({
    String? language,
    bool? notificationsEnabled,
    String? dailyReminderTime,
    String? themeMode,
    int? studyGoalPerDay,
    String? difficultyPreference,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? autoSync,
  }) {
    return UserSettings(
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      themeMode: themeMode ?? this.themeMode,
      studyGoalPerDay: studyGoalPerDay ?? this.studyGoalPerDay,
      difficultyPreference: difficultyPreference ?? this.difficultyPreference,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      autoSync: autoSync ?? this.autoSync,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSettings &&
        other.language == language &&
        other.notificationsEnabled == notificationsEnabled &&
        other.dailyReminderTime == dailyReminderTime &&
        other.themeMode == themeMode &&
        other.studyGoalPerDay == studyGoalPerDay &&
        other.difficultyPreference == difficultyPreference &&
        other.soundEnabled == soundEnabled &&
        other.vibrationEnabled == vibrationEnabled &&
        other.autoSync == autoSync;
  }

  @override
  int get hashCode {
    return Object.hash(
      language,
      notificationsEnabled,
      dailyReminderTime,
      themeMode,
      studyGoalPerDay,
      difficultyPreference,
      soundEnabled,
      vibrationEnabled,
      autoSync,
    );
  }

  @override
  String toString() {
    return 'UserSettings(language: $language, notificationsEnabled: $notificationsEnabled, '
           'dailyReminderTime: $dailyReminderTime, themeMode: $themeMode, '
           'studyGoalPerDay: $studyGoalPerDay, difficultyPreference: $difficultyPreference, '
           'soundEnabled: $soundEnabled, vibrationEnabled: $vibrationEnabled, autoSync: $autoSync)';
  }
}