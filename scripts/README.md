# スクリプト

このディレクトリには、TechLingual Quest プロジェクトのビルドスクリプト、デプロイメントスクリプト、ユーティリティスクリプトが含まれています。

## 構造

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

## 使用方法

```bash
# スクリプトを実行可能にする
chmod +x scripts/build/build_android.sh

# スクリプトを実行
./scripts/build/build_android.sh
```