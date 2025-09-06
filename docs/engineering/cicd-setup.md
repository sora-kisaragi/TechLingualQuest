# CI/CD パイプライン設定ガイド

<!-- Authors: GitHub Copilot -->
<!-- Date: 2024-12-19 -->
<!-- Version: 2.0.0 -->

## 概要

TechLinguralQuest プロジェクトでは、品質保証と効率的なデプロイメントを実現するため、包括的なCI/CDパイプラインを構築しています。**各ワークフローは完了時に即座にSlack/Discord通知を送信**し、リアルタイムで状況を把握できます。

## 通知システム

### 個別通知方式
各ワークフローが完了するたびに即座にSlack/Discord通知を送信します：

- **即座の通知**: ワークフロー完了と同時に結果を通知
- **成功・失敗問わず**: 全ての完了パターンで通知送信
- **詳細情報**: エラー内容、成果物リンク、実行情報を含む
- **直接アクセス**: GitHub ActionsやArtifactsへの直接リンク付き

### 設定要件
通知を有効にするには、以下の環境変数を設定してください：
- `SLACK_WEBHOOK_URL` - Slack通知用WebhookURL
- `DISCORD_WEBHOOK_URL` - Discord通知用WebhookURL

## ワークフロー構成

### 1. Flutter CI/CD (`flutter.yml`)
**トリガー**: pull_request, workflow_dispatch  
**実行環境**: ubuntu-latest  
**Flutter版本**: 3.35.3

#### 実行内容
- **品質チェック**: コード解析、依存関係検証、プロジェクト構造確認
- **テスト実行**: 単体テスト、ウィジェットテスト、カバレッジ取得
- **ビルド**: Android APK/AAB、Web版の並列ビルド
- **通知**: 全ステップの結果を含む詳細通知

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
- **通知**: 成果物ダウンロードリンク付き

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
- **通知**: 成功・失敗両方で詳細レポート送信

#### 通知パターン
- **成功時**: ✅ 問題検出なしの確認通知
- **失敗時**: 🚨 緊急対応要求通知

### 4. Format Fix (`format-fix.yml`)
**トリガー**: pull_request, workflow_dispatch  
**実行環境**: ubuntu-latest

#### 実行内容
- コードフォーマットの自動検出
- `dart format` による自動修正
- **通知**: 全完了パターンで結果通知

#### 通知パターン
- **修正実行**: 🔧 修正完了通知（修正ファイル数含む）
- **修正不要**: ✅ 適切なフォーマット確認通知
- **問題検出・修正不要**: ⚠️ 状況報告通知

### 5. Release Build (`release.yml`)
**トリガー**: push (tags), pull_request (merged to main), schedule, workflow_dispatch

#### 実行内容
- リリース前品質チェック
- Android・Web向け本番ビルド
- GitHub Release の自動作成
- **通知**: リリース完了とダウンロードリンク

#### 通知機能
- **リリース通知**: 🎉 新バージョン公開通知
- **ダウンロードリンク**: GitHub Releasesへの直接アクセス

## ビルド成果物管理

### 保管場所
- **GitHub Actions Artifacts**: 全ビルド成果物
- **保持期間**: 7日間 (通常ビルド), 30日間 (リリースビルド)

### アクセス方法
1. GitHub Actions ページにアクセス
2. 該当のワークフロー実行を選択  
3. Artifacts セクションからダウンロード
4. または **Slack/Discord 通知の「📦 ビルド成果物をダウンロード」ボタン**

### 成果物タイプ
- **Android APK**: `app-release.apk`
- **Android Bundle**: `app-release.aab`
- **Windows**: `TechLingualQuest-Windows-{ビルド番号}.zip`
- **Web版**: `web-build.zip`

## 通知設定とトラブルシューティング

### 環境変数設定
通知機能を有効にするため、リポジトリの Settings > Secrets and variables > Actions で以下を設定：

#### Variables（環境変数）
- `SLACK_WEBHOOK_URL` - Slack Incoming Webhook URL
- `DISCORD_WEBHOOK_URL` - Discord Webhook URL

### 通知が送信されない場合
1. **環境変数確認**: SLACK_WEBHOOK_URL / DISCORD_WEBHOOK_URL が正しく設定されているか
2. **Webhook URL有効性**: URLが有効で、権限が適切か確認
3. **ワークフロー実行ログ**: GitHub Actions ログで通知ステップの実行状況を確認

### 個別通知の利点
- **即座の問題把握**: ワークフロー完了と同時に結果を通知
- **分散処理**: 各ワークフローが独立して通知を送信
- **詳細情報**: 各ワークフローの具体的な実行結果を含む
- **障害耐性**: 一つの通知が失敗しても他に影響しない

## Flutter版本管理

### 現在の設定
- **使用版本**: 3.35.3 (全ワークフローで統一)
- **チャンネル**: stable
- **キャッシュ**: 有効

### 版本確認コマンド
```bash
# 最新Flutter版本を確認
curl -s https://api.flutter.dev/releases/releases_linux.json | jq -r '.releases[0].version'

# プロジェクトで設定されている版本を確認
grep "FLUTTER_VERSION:" .github/workflows/*.yml
```

### 版本更新時の注意
- ⚠️ **ダウングレード禁止**: 版本の後退は行わない
- ✅ **安定版のみ**: beta/dev版本は使用しない  
- ✅ **統一性**: 全ワークフローファイルで同じ版本を使用
- ✅ **テスト**: 版本更新後は全てのワークフローをテスト実行

## トラブルシューティング

### よくある問題

#### 1. Webビルドの失敗
**原因**: 必要なWebアセットが不足  
**対策**: 自動的にクリーンビルドで再試行される

#### 2. Android ビルドがスキップされる
**原因**: mainブランチへのPR以外では条件付きスキップ  
**対策**: 設計通りの動作

#### 3. 個別通知が届かない
**原因**: webhook URL が未設定またはネットワークエラー  
**対策**: Repository Variables の確認、webhook URL有効性確認

### デバッグ方法

1. **ログ確認**: GitHub Actions の詳細ログで通知ステップを確認
2. **手動実行**: workflow_dispatch での個別テスト
3. **通知テスト**: 各ワークフローの手動実行で通知動作確認

### アプリケーション環境変数
```bash
APP_ENV=prod|dev
DATABASE_NAME=tech_lingual_quest.db
API_BASE_URL=https://api.example.com
LOG_LEVEL=error|debug
```

## メンテナンス

### 定期確認項目
- Flutter SDK バージョンの更新
- 依存関係の脆弱性チェック
- 成果物保持期間の最適化
- **個別通知設定の動作確認**

### CI/CD最適化とベストプラクティス

#### パフォーマンス最適化
- **キャッシュ活用**: Flutter SDK、パッケージ依存関係のキャッシュ
- **並列実行**: 独立したジョブの並列処理
- **条件付き実行**: 必要な場合のみビルドを実行

#### セキュリティ対策
- **権限制限**: 各ワークフローで最小限の権限設定
- **秘匿情報**: Secrets を使用して機密情報を保護
- **定期スキャン**: 自動セキュリティスキャンの実施

#### 監視とメンテナンス
- **通知レスポンス**: Slack/Discord通知の応答時間監視
- **Artifacts管理**: 不要な成果物の定期削除
- **ワークフロー最適化**: 実行時間とリソース使用量の定期見直し

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