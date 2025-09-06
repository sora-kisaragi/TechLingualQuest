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

現在のワークフローは実行効率を最適化し、重複実行を避けるように構成されています：

### メインワークフロー
- `.github/workflows/flutter.yml` - **Flutter CI/CD**
  - main ブランチ: pull_request でのみトリガー
  - develop ブランチ: push でのみトリガー
  - 並列実行: テストとビルドが並列実行
  - ビルドマトリクス: Android APK、App Bundle、Web を並列ビルド

- `.github/workflows/security-scan.yml` - **セキュリティスキャン**
  - main ブランチ: pull_request でのみトリガー
  - develop ブランチ: push でのみトリガー
  - スケジュール実行: 毎日午前2時（UTC）

- `.github/workflows/release.yml` - **リリースビルド**
  - タグ作成時、または手動実行時のみトリガー

### 専用ワークフロー
- `.github/workflows/format-fix.yml` - **フォーマット自動修正**
  - 調査 → 修正 → 報告 の3段階プロセス
  - 自動でフォーマットを修正し、Slack/Discord に結果を通知

- `.github/workflows/windows-build.yml` - **Windows ビルド**
  - Windows アプリケーションの自動ビルド
  - 成果物の自動圧縮・Slack 配信機能

### トリガー最適化

| ブランチ | Flutter CI/CD | セキュリティ | フォーマット | Windows |
|---------|--------------|------------|------------|---------|
| main | PR のみ | PR のみ | PR のみ | PR のみ |
| develop | push のみ | push のみ | push のみ | push のみ |
| その他 | 実行されない | 実行されない | 実行されない | 実行されない |

この構成により、push と pull_request の重複実行を避け、処理時間を大幅に短縮しています。

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

### 改善された通知機能

新しいCI/CDワークフローでは、通知メッセージが大幅に改善されています：

#### 成功時の通知
- 完了した全処理の一覧表示
- 実行時間の表示
- 詳細ログへの直接リンク

#### 失敗時の通知
- **具体的な失敗箇所の特定**：
  - コード品質チェック（フォーマット・静的解析）
  - テスト実行（単体・ウィジェットテスト）
  - ビルド処理（Android・Web）
- 失敗原因の詳細説明
- 緊急対応が必要な旨の明示

### Webhook URL 設定

1) テスト送信でURLの動作確認

```
./scripts/setup_ci_cd.sh webhook discord YOUR_DISCORD_WEBHOOK_URL
# または
./scripts/setup_ci_cd.sh webhook slack YOUR_SLACK_WEBHOOK_URL
```

2) GitHub リポジトリ設定 → Secrets and variables → Actions → Variables に登録

- `DISCORD_WEBHOOK_URL` または `SLACK_WEBHOOK_URL`

### 特殊通知

- **フォーマット自動修正**: 修正されたファイル数と詳細を報告
- **Windows ビルド完了**: 成果物のサイズと圧縮結果をSlackに配信
- **セキュリティ警告**: 重大なセキュリティ問題の即座通知

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
