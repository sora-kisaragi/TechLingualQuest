// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) => UserSettings(
      language: json['language'] as String? ?? 'ja',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      dailyReminderTime: json['dailyReminderTime'] as String? ?? '09:00',
      themeMode: json['themeMode'] as String? ?? 'system',
      studyGoalPerDay: json['studyGoalPerDay'] as int? ?? 30,
      difficultyPreference:
          json['difficultyPreference'] as String? ?? 'intermediate',
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      autoSync: json['autoSync'] as bool? ?? false,
    );

Map<String, dynamic> _$UserSettingsToJson(UserSettings instance) =>
    <String, dynamic>{
      'language': instance.language,
      'notificationsEnabled': instance.notificationsEnabled,
      'dailyReminderTime': instance.dailyReminderTime,
      'themeMode': instance.themeMode,
      'studyGoalPerDay': instance.studyGoalPerDay,
      'difficultyPreference': instance.difficultyPreference,
      'soundEnabled': instance.soundEnabled,
      'vibrationEnabled': instance.vibrationEnabled,
      'autoSync': instance.autoSync,
    };
