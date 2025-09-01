# 設定

このディレクトリには、異なる環境とサービス用の設定ファイルが含まれています。

## 構造

```
config/
├── environments/             # 環境固有の設定
│   ├── development.json      # 開発環境
│   ├── staging.json          # ステージング環境
│   └── production.json       # プロダクション環境
├── firebase/                 # Firebase設定
│   ├── dev-firebase-config.json
│   ├── staging-firebase-config.json
│   └── prod-firebase-config.json
├── api/                      # API設定
│   ├── endpoints.json        # APIエンドポイントURL
│   └── api_keys.template.json # APIキーテンプレート（実際のキーなし）
└── app/                      # アプリ固有設定
    ├── features.json         # 機能フラグ
    ├── themes.json           # テーマ設定
    └── constants.json        # アプリ定数
```

## ガイドライン

- **機密データは絶対にコミットしない**（APIキー、パスワード、シークレット）
- 機密設定にはテンプレートファイルを使用
- 環境固有設定は明確にラベル付け
- 設定ファイルにはJSONまたはYAMLフォーマットを使用
- すべての設定オプションを文書化
- デプロイ前に設定ファイルを検証

## セキュリティ注意事項

- `*.key`、`*secret*`、`*password*`を.gitignoreに追加
- プロダクションでは機密データに環境変数を使用
- サンプル値を含むテンプレートファイルを提供
- 各環境で異なる設定を使用