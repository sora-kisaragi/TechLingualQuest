import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tech_lingual_quest/features/settings/pages/settings_page.dart';
import 'package:tech_lingual_quest/features/settings/models/user_settings.dart';
import 'package:tech_lingual_quest/features/settings/services/settings_service.dart';

void main() {
  group('SettingsPage Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should display all settings sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      // 初期読み込み完了を待機
      await tester.pumpAndSettle();

      // セクションヘッダーが表示されていることを確認
      expect(find.text('一般設定'), findsOneWidget);
      expect(find.text('通知設定'), findsOneWidget);
      expect(find.text('学習設定'), findsOneWidget);
      expect(find.text('データ設定'), findsOneWidget);

      // 設定項目が表示されていることを確認
      expect(find.text('言語'), findsOneWidget);
      expect(find.text('テーマ'), findsOneWidget);
      expect(find.text('通知を有効にする'), findsOneWidget);
      expect(find.text('リマインダー時刻'), findsOneWidget);
      expect(find.text('音声を有効にする'), findsOneWidget);
      expect(find.text('バイブレーションを有効にする'), findsOneWidget);
      expect(find.text('1日の学習目標'), findsOneWidget);
      expect(find.text('難易度設定'), findsOneWidget);
      expect(find.text('自動同期'), findsOneWidget);
    });

    testWidgets('should display default settings values', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // デフォルト値が表示されていることを確認
      expect(find.text('日本語'), findsOneWidget); // 言語
      expect(find.text('システム'), findsOneWidget); // テーマ
      expect(find.text('09:00'), findsOneWidget); // リマインダー時刻
      expect(find.text('30分'), findsOneWidget); // 学習目標
      expect(find.text('中級'), findsOneWidget); // 難易度

      // スイッチの状態を確認
      final notificationSwitch = find.byType(Switch).at(0);
      final soundSwitch = find.byType(Switch).at(1);
      final vibrationSwitch = find.byType(Switch).at(2);
      
      expect(tester.widget<Switch>(notificationSwitch).value, isTrue);
      expect(tester.widget<Switch>(soundSwitch).value, isTrue);
      expect(tester.widget<Switch>(vibrationSwitch).value, isTrue);
    });

    testWidgets('should change language setting', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 言語ドロップダウンを見つける
      final languageDropdown = find.byType(DropdownButton<String>).first;
      await tester.tap(languageDropdown);
      await tester.pumpAndSettle();

      // English を選択
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // 成功メッセージが表示されることを確認
      expect(find.text('設定が更新されました'), findsOneWidget);
    });

    testWidgets('should toggle notification setting', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 通知スイッチを見つけて切り替え
      final notificationSwitch = find.byType(Switch).first;
      await tester.tap(notificationSwitch);
      await tester.pumpAndSettle();

      // 成功メッセージが表示されることを確認
      expect(find.text('設定が更新されました'), findsOneWidget);
    });

    testWidgets('should change theme setting', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // テーマドロップダウンを見つける
      final themeDropdown = find.byType(DropdownButton<String>).at(1);
      await tester.tap(themeDropdown);
      await tester.pumpAndSettle();

      // ライトテーマを選択
      await tester.tap(find.text('ライト'));
      await tester.pumpAndSettle();

      // 成功メッセージが表示されることを確認
      expect(find.text('設定が更新されました'), findsOneWidget);
    });

    testWidgets('should open time picker for reminder time', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // リマインダー時刻の時計アイコンをタップ
      final timeButton = find.byIcon(Icons.access_time);
      await tester.tap(timeButton);
      await tester.pumpAndSettle();

      // タイムピッカーが表示されることを確認
      expect(find.byType(TimePickerDialog), findsOneWidget);

      // キャンセルボタンを押す
      await tester.tap(find.text('キャンセル'));
      await tester.pumpAndSettle();
    });

    testWidgets('should adjust study goal with plus/minus buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // プラスボタンをタップして学習目標を増やす
      final plusButton = find.byIcon(Icons.add);
      await tester.tap(plusButton);
      await tester.pumpAndSettle();

      // 40分に増加していることを確認
      expect(find.text('40分'), findsOneWidget);
      expect(find.text('設定が更新されました'), findsOneWidget);
    });

    testWidgets('should show reset confirmation dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // リセットボタンをタップ
      final resetButton = find.text('デフォルト設定にリセット');
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      // 確認ダイアログが表示されることを確認
      expect(find.text('設定のリセット'), findsOneWidget);
      expect(find.text('すべての設定をデフォルト値に戻しますか？'), findsOneWidget);
      expect(find.text('キャンセル'), findsOneWidget);
      expect(find.text('リセット'), findsOneWidget);

      // キャンセルを選択
      await tester.tap(find.text('キャンセル'));
      await tester.pumpAndSettle();
    });

    testWidgets('should reset settings when confirmed', (WidgetTester tester) async {
      // カスタム設定でプロバイダーをセットアップ
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userSettingsProvider.overrideWith((ref) => 
              _CustomUserSettingsNotifier(const UserSettings(language: 'en', themeMode: 'dark'))
            ),
          ],
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // リセットボタンをタップ
      final resetButton = find.text('デフォルト設定にリセット');
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      // リセットを確認
      await tester.tap(find.text('リセット'));
      await tester.pumpAndSettle();

      // リセット成功メッセージが表示されることを確認
      expect(find.text('設定をデフォルト値にリセットしました'), findsOneWidget);
    });

    testWidgets('should handle loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userSettingsProvider.overrideWith((ref) => _LoadingUserSettingsNotifier()),
          ],
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pump();

      // ローディング表示を確認
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle error state', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userSettingsProvider.overrideWith((ref) => _ErrorUserSettingsNotifier()),
          ],
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pump();

      // エラー表示を確認
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('設定の読み込みに失敗しました'), findsOneWidget);
      expect(find.text('再試行'), findsOneWidget);
    });

    testWidgets('should limit study goal adjustment', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userSettingsProvider.overrideWith((ref) => 
              _CustomUserSettingsNotifier(const UserSettings(studyGoalPerDay: 10))
            ),
          ],
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // マイナスボタンが無効化されていることを確認（最小値10）
      final minusButton = find.byIcon(Icons.remove);
      expect(tester.widget<IconButton>(minusButton).onPressed, isNull);
    });

    testWidgets('should show correct switch states for custom settings', (WidgetTester tester) async {
      const customSettings = UserSettings(
        notificationsEnabled: false,
        soundEnabled: false,
        vibrationEnabled: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userSettingsProvider.overrideWith((ref) => 
              _CustomUserSettingsNotifier(customSettings)
            ),
          ],
          child: MaterialApp(
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // スイッチの状態を確認
      final switches = find.byType(Switch);
      expect(tester.widget<Switch>(switches.at(0)).value, isFalse); // notifications
      expect(tester.widget<Switch>(switches.at(1)).value, isFalse); // sound
      expect(tester.widget<Switch>(switches.at(2)).value, isTrue); // vibration
    });
  });
}

// テスト用のカスタムノティファイア
class _CustomUserSettingsNotifier extends StateNotifier<AsyncValue<UserSettings>> {
  _CustomUserSettingsNotifier(UserSettings settings) : super(AsyncValue.data(settings));

  @override
  Future<void> updateSettings(UserSettings newSettings) async {
    state = AsyncValue.data(newSettings);
  }

  @override
  Future<void> resetSettings() async {
    state = const AsyncValue.data(UserSettings());
  }
}

class _LoadingUserSettingsNotifier extends StateNotifier<AsyncValue<UserSettings>> {
  _LoadingUserSettingsNotifier() : super(const AsyncValue.loading());
}

class _ErrorUserSettingsNotifier extends StateNotifier<AsyncValue<UserSettings>> {
  _ErrorUserSettingsNotifier() : super(AsyncValue.error('Test error', StackTrace.empty));
}