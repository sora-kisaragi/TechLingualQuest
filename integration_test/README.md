# 統合テスト

このディレクトリには、TechLingual Quest アプリケーションの統合テストが含まれています。

## 目的

統合テストは、アプリの異なる部分が正しく連携して動作することを確認します。対象には以下が含まれます：
- ユーザーフローとインタラクション
- 画面間のナビゲーション
- API統合
- データベース操作
- 認証フロー

## 構造

```
integration_test/
├── app_test.dart             # メインアプリ統合テスト
├── features/                 # 機能固有の統合テスト
│   ├── auth_flow_test.dart   # 認証フロー
│   ├── vocabulary_test.dart  # 語彙機能
│   ├── quest_system_test.dart # クエスト機能
│   └── dashboard_test.dart   # ダッシュボードインタラクション
└── helpers/                  # テストヘルパーとユーティリティ
    ├── test_utils.dart       # 共通テストユーティリティ
    └── mock_data.dart        # テスト用モックデータ
```

## 統合テストの実行

```bash
# すべての統合テストを実行
flutter test integration_test

# 特定の統合テストを実行
flutter test integration_test/features/auth_flow_test.dart

# デバイス/エミュレーター上で実行
flutter drive --target=integration_test/app_test.dart
```

## ガイドライン

- 完全なユーザージャーニーをテスト
- リアルなテストデータを使用
- 各テスト後にテストデータをクリーンアップ
- ハッピーパスとエラーシナリオの両方をテスト