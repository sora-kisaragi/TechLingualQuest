---
author: "GitHub Copilot"
date: "2025-09-04"
version: "1.0"
related_docs: ["DEVELOPMENT.md", "pre-commit-setup.md", "../../scripts/setup_ci_cd.sh"]
---

# CI/CD セットアップガイド（GitHub Actions）

本プロジェクトのCI/CDはGitHub Actionsを前提としています。ローカル検証やWebhook通知の設定は `scripts/setup_ci_cd.sh` で自動化されています。

## 前提条件

- Git / GitHub リポジトリ
- Flutter SDK（`flutter` コマンドが利用可能）
- curl（Webhook動作確認に使用）
- 任意: jq, yq（検証スクリプトの補助）

## ワークフロー構成

期待するファイル（存在しない場合は後述の検証で警告されます）:

- `.github/workflows/flutter.yml`
- `.github/workflows/security-scan.yml`
- `.github/workflows/release.yml`

## 初期セットアップ（ローカル）

1) 依存取得と設定ファイル生成を実施

```
./scripts/setup_ci_cd.sh setup
```

2) 状態確認（存在するワークフロー、Flutterバージョンなどを一覧）

```
./scripts/setup_ci_cd.sh status
```

## 通知Webhookの設定（Discord/Slack）

1) テスト送信でURLの動作確認

```
./scripts/setup_ci_cd.sh webhook discord YOUR_DISCORD_WEBHOOK_URL
# または
./scripts/setup_ci_cd.sh webhook slack YOUR_SLACK_WEBHOOK_URL
```

2) GitHub リポジトリ設定 → Secrets and variables → Actions → Variables に登録

- `DISCORD_WEBHOOK_URL` または `SLACK_WEBHOOK_URL`

## ローカルでのCI/CDテスト

まとめて検証できます。

```
./scripts/setup_ci_cd.sh test all
```

個別実行も可能です（`build | analyze | format | test`）。

## よくあるエラーと対処

- Flutterが見つからない: Flutter SDKをインストールし、ターミナルで `flutter --version` が動作することを確認
- ワークフローが見つからない: `.github/workflows/` に必要なYAMLを配置し、`setup_ci_cd.sh validate` で検証
- Windows (Git Bash) でのPATH問題: Git Bashから `flutter` や `python`/`pip` にパスが通っているか確認

## 参照

- スクリプト: `scripts/setup_ci_cd.sh`
- 事前準備・ローカル環境: `docs/engineering/DEVELOPMENT.md`
- pre-commit: `docs/engineering/pre-commit-setup.md`
