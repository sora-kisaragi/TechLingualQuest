# スクリプトディレクトリ

このディレクトリには、開発とCI/CDプロセスを支援するスクリプトが含まれています。

## 利用可能なスクリプト

### `setup_precommit_hooks.sh`
**自動コードフォーマッティング設定スクリプト**

- pre-commitフレームワークをインストール
- Git pre-commitフックを設定
- Dartコードの自動フォーマットを有効化
- CI/CDでのフォーマットエラーを防止

```bash
./scripts/setup_precommit_hooks.sh
```

### `format_dart.sh`
**スマートDartフォーマッター**

- 様々なFlutter/Dartインストール方法に対応
- pre-commitフックから自動実行される
- 手動実行も可能

```bash
./scripts/format_dart.sh
```

### `setup_ci_cd.sh`
**CI/CD環境設定スクリプト**

- CI/CD環境の初期セットアップ
- 依存関係の確認とインストール

```bash
./scripts/setup_ci_cd.sh
```

## 新しい開発者向けセットアップ

1. リポジトリをクローン後、まず自動フォーマッティングを設定：
   ```bash
   ./scripts/setup_precommit_hooks.sh
   ```

2. これで、コミット時に自動的にDartコードがフォーマットされ、CI/CDエラーを防げます。

## 既存プロジェクト構造（計画中）

```
scripts/
├── build/                    # ビルド関連スクリプト
│   ├── build_android.sh      # Android ビルドスクリプト
│   ├── build_ios.sh          # iOS ビルドスクリプト
│   └── build_web.sh          # Web ビルドスクリプト
├── deploy/                   # デプロイメントスクリプト
│   ├── deploy_staging.sh     # ステージング環境デプロイ
│   └── deploy_production.sh  # プロダクション環境デプロイ
├── setup/                    # セットアップ・インストールスクリプト
│   ├── setup_dev.sh          # 開発環境セットアップ
│   └── install_deps.sh       # 依存関係インストール
└── utils/                    # ユーティリティスクリプト
    ├── cleanup.sh            # ビルドアーティファクトのクリーンアップ
    ├── generate_icons.sh     # アプリアイコン生成
    └── backup_db.sh          # データベースバックアップ
```

## ガイドライン

- スクリプトを実行可能にする（`chmod +x script_name.sh`）
- エラーハンドリングと検証を含める
- スクリプトのパラメーターと使用方法を文書化
- 一貫したネーミング規則を使用
- 異なる環境でスクリプトをテスト

## トラブルシューティング

  ```bash
  chmod +x scripts/*.sh
  ```

  ```bash
  which flutter
  which dart
  ```

詳細なドキュメントは `docs/engineering/DEVELOPMENT.md` を参照してください。
