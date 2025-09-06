# CI/CD パイプライン設定ガイド

<!-- Authors: GitHub Copilot -->
<!-- Date: 2024-12-19 -->
<!-- Version: 1.2.0 -->

## 概要

TechLinguralQuest プロジェクトでは、品質保証と効率的なデプロイメントを実現するため、包括的なCI/CDパイプラインを構築しています。

## ワークフロー構成

### 1. Flutter CI/CD (`flutter.yml`)
**トリガー**: pull_request, workflow_dispatch  
**実行環境**: ubuntu-latest  
**Flutter版本**: 3.35.3

#### 実行内容
- **品質チェック**: コード解析、依存関係検証、プロジェクト構造確認
- **テスト実行**: 単体テスト、ウィジェットテスト、カバレッジ取得
- **ビルド**: Android APK/AAB、Web版の並列ビルド

#### 特徴
- **条件付きAndroidビルド**: mainブランチへのPRでのみ実行
- **Web ビルドフォールバック**: canvaskit → html レンダラーの自動切り替え
- **成果物保持**: 7日間のArtifacts保存

### 2. Windows Build (`windows-build.yml`)
**トリガー**: pull_request, workflow_dispatch  
**実行環境**: windows-latest  

#### 実行内容
- Windows デスクトップ向けアプリケーションのビルド
- パッケージ最適化とZIP圧縮
- ビルド成果物の自動アップロード

#### 通知機能
- **Slack通知**: ダウンロードボタン付き
- **Discord通知**: 成果物リンク埋め込み
- **成果物情報**: サイズ、保管場所の詳細

### 3. Security Scan (`security-scan.yml`)
**トリガー**: pull_request, schedule (毎日午前2時)  
**実行環境**: ubuntu-latest

#### 実行内容
- 依存関係の脆弱性チェック
- Dart静的解析
- セキュリティ警告の検出と通知

### 4. Format Fix (`format-fix.yml`)
**トリガー**: pull_request, workflow_dispatch  
**実行環境**: ubuntu-latest

#### 実行内容
- コードフォーマットの自動検出
- `dart format` による自動修正
- フォーマット修正内容の通知

### 5. CI/CD Summary (`ci-cd-summary.yml`)
**トリガー**: workflow_run (他ワークフロー完了時), workflow_dispatch  
**実行環境**: ubuntu-latest

#### 実行内容
- 全ワークフローの結果収集
- 統合レポート生成
- Slack/Discord への一括通知

#### 通知内容
- 各ワークフローの成功/失敗状況
- 全体的な実行ステータス
- GitHub Actions とビルド成果物への直接リンク

### 6. Release Build (`release.yml`)
**トリガー**: push (tags), pull_request (merged to main), schedule, workflow_dispatch

#### 実行内容
- リリース前品質チェック
- Android・Web向け本番ビルド
- GitHub Release の自動作成
- リリース通知の送信

## ビルド成果物管理

### 保管場所
- **GitHub Actions Artifacts**: 全ビルド成果物
- **保持期間**: 7日間 (通常ビルド), 30日間 (リリースビルド)

### アクセス方法
1. GitHub Actions ページにアクセス
2. 該当のワークフロー実行を選択
3. Artifacts セクションからダウンロード
4. または Slack/Discord 通知の「📦 ビルド成果物をダウンロード」ボタン

### 成果物タイプ
- **Android APK**: `app-release.apk`
- **Android Bundle**: `app-release.aab`
- **Windows**: `TechLingualQuest-Windows-{ビルド番号}.zip`
- **Web版**: `web-build.zip`

## 通知システム

### 統合通知
- **送信タイミング**: 全ワークフロー完了後
- **内容**: 各ワークフローのステータス、全体結果、直接アクセスリンク
- **配信先**: Slack, Discord

### 個別通知
- **Windows ビルド**: 成功時にダウンロードリンク付き通知
- **セキュリティ**: 脆弱性検出時に緊急通知
- **フォーマット**: 自動修正時に修正内容通知

## 環境変数設定

### 必須設定
```yaml
# Repository Variables
SLACK_WEBHOOK_URL: Slack通知用WebhookURL
DISCORD_WEBHOOK_URL: Discord通知用WebhookURL

# Repository Secrets  
CODECOV_TOKEN: コードカバレッジ送信用トークン
GITHUB_TOKEN: 自動生成（設定不要）
```

### アプリケーション環境変数
```bash
APP_ENV=prod|dev
DATABASE_NAME=tech_lingual_quest.db
API_BASE_URL=https://api.example.com
LOG_LEVEL=error|debug
```

## トラブルシューティング

### よくある問題

#### 1. Webビルドの失敗
**原因**: `sqflite`パッケージがWeb環境で非対応  
**対策**: 自動的にHTMLレンダラーで再試行される

#### 2. Android ビルドがスキップされる
**原因**: mainブランチへのPR以外では条件付きスキップ  
**対策**: 設計通りの動作

#### 3. 統合通知が届かない
**原因**: webhook URL が未設定またはワークフロー実行条件不一致  
**対策**: Repository Variables の確認、手動実行での確認

### デバッグ方法

1. **ログ確認**: GitHub Actions の詳細ログ
2. **手動実行**: workflow_dispatch での個別テスト
3. **統合通知テスト**: ci-cd-summary.yml の手動実行

## メンテナンス

### 定期確認項目
- Flutter SDK バージョンの更新
- 依存関係の脆弱性チェック
- 成果物保持期間の最適化
- 通知設定の動作確認

### Flutter バージョン管理

#### 最新版確認コマンド
```bash
# 公式リリースページから最新安定版を取得
curl -s https://api.flutter.dev/releases/releases_linux.json | jq -r '.releases[0].version'

# または公式アーカイブページを確認
# https://docs.flutter.dev/install/archive
```

#### 現在のプロジェクト設定確認
```bash
# ワークフローファイルから現在のFlutterバージョンを確認
grep -r "FLUTTER_VERSION" .github/workflows/

# セットアップスクリプトから確認
grep -r "flutter-version\|FLUTTER_VERSION" validate_flutter_setup.sh
```

#### バージョン更新時の注意事項
- **ダウングレード禁止**: バージョンは上げることのみ許可
- **安定版のみ**: ベータ版やdev版は使用禁止
- **動作確認**: 更新前に最新バージョンでのビルドテスト実施
- **統一性**: 全ワークフローファイルで同一バージョンを使用

### アップデート手順
1. Flutter バージョン確認 (`FLUTTER_VERSION` 環境変数)
2. ワークフロー設定の動作テスト
3. 通知機能の確認
4. ドキュメントの更新

## 参考リンク

- [Flutter公式アーカイブ](https://docs.flutter.dev/install/archive)
- [GitHub Actions ドキュメント](https://docs.github.com/en/actions)
- [Slack Webhook API](https://api.slack.com/messaging/webhooks)
- [Discord Webhook ガイド](https://support.discord.com/hc/en-us/articles/228383668)