# テスト（test/）

このディレクトリには、TechLingual Quest アプリケーションのユニットテストとウィジェットテストが含まれています。

## 構造

```
test/
├── unit/                     # ユニットテスト
│   ├── services/             # サービス層テスト
│   ├── models/               # モデルテスト
│   └── utils/                # ユーティリティ関数テスト
├── widget/                   # ウィジェットテスト
│   ├── features/             # 機能ウィジェットテスト
│   └── shared/               # 共有ウィジェットテスト
└── helpers/                  # テストヘルパーとモック
    ├── mocks/                # モックオブジェクト
    └── fixtures/             # テストデータフィクスチャー
```

## ガイドライン

- すべてのビジネスロジックにテストを記述
- ウィジェットとユーザーインタラクションをテスト
- 説明的なテスト名を使用
- 外部依存関係をモック化
- 高いテストカバレッジを目指す

## テストの実行

```bash
# すべてのテストを実行
flutter test

# カバレッジ付きでテストを実行
flutter test --coverage

# 特定のテストファイルを実行
flutter test test/unit/services/auth_service_test.dart
```