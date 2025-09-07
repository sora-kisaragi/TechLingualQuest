# TechLingual Quest

**技術英語力向上**のためのゲーミフィケーション学習アプリです。
このプロジェクトは、**クエスト、語彙構築、技術記事要約**をゲームライクな体験と組み合わせています。
すべてのデータ（語彙、要約、進捗）は中央データベースに保存され、**学習**と**業務参考**の両方で再利用できます。

---

## ⚠️ 重要な開発ルール (CRITICAL DEVELOPMENT RULES)

### 🚫 依存関係のダウングレード禁止
**いかなる理由があっても、明示的な許可なしに依存関係のバージョンをダウングレードすることは絶対に禁止されています。**

- **適用対象**: Flutter SDK、すべてのパッケージ（intl、shared_preferencesなど）、dev_dependencies
- **禁止事項**:
  - コンパイルエラー修正のためのダウングレード
  - 互換性問題解決のためのバージョン削減
  - 「動作させる」ためのパッケージバージョン変更
- **正しい対応方法**:
  - 現在のバージョンで動作するようにコードを修正
  - 新しいバージョンに対応したコードの更新
  - どうしても解決できない場合はメンテナーに相談

違反した場合は即座に修正が必要です。

---

## ✨ 機能

- **多言語対応**
  - 日本語・英語UI切り替え
  - 初学者向けの分かりやすい日本語表示
  - 設定保存でアプリ再起動時も言語維持
- **クエスト**
  - 日次/週次タスク：読む、書く、聞く、話す
  - XP、レベルアップ、実績バッジ
- **語彙管理**
  - 例文付きカードスタイルの単語管理
  - 間隔反復を使ったクイズ
- **要約機能**
  - 技術記事要約をDBに保存
  - アプリとブラウザ/PCからアクセス可能
- **進捗ダッシュボード**
  - XP進捗バー
  - 学習語彙数、記事要約数、獲得XPのグラフ
- **連携機能**
  - 会話練習用の公式GPTアプリとのリンク
  - アプリ外（業務、研究）からのデータベースアクセス

---

## 🏗️ 技術スタック（予定）

- **フロントエンド:** Flutter 3.35.x（モバイル & ウェブ）
- **バックエンド:** Firebase / Supabase / PostgreSQL
- **認証:** Firebase Auth
- **データストレージ:** Firestore / Supabase DB
- **AI統合:** OpenAI API（自動要約、クイズ、添削用）

---

## 🚀 ロードマップ

1. 基本プロジェクトセットアップ（Flutter + DB接続）
2. ユーザー認証 & プロファイル
3. 語彙モジュール（DB + UI）
4. クエストシステム（XP、バッジ）
5. 記事要約の保存 & 表示
6. 進捗可視化ダッシュボード
7. GPT公式アプリとの連携（リンク共有）
8. ゲーミフィケーションアニメーションによるUI/UX磨き上げ

---

## 🔧 開発・デプロイメント

### CI/CD パイプライン

本プロジェクトは **GitHub Actions** を使用した自動CI/CDパイプラインを構築しています。

#### 🚀 自動実行される処理

| ワークフロー | トリガー | 実行内容 |
|-------------|----------|----------|
| **Flutter CI/CD** | push, PR | コード品質チェック、テスト、ビルド、通知 |
| **Security Scan** | push, PR, 定期実行 | 脆弱性スキャン、依存関係チェック |
| **Release Build** | タグプッシュ | リリースビルド、GitHub Release作成 |

#### 📢 通知機能

- **Discord**: リアルタイムでCI/CD結果を通知
- **Slack**: チーム向けに構造化されたビルド情報を配信
- **カバレッジレポート**: Codecovでテストカバレッジを追跡

#### ⚙️ 設定方法

詳細な設定手順は [CI/CDセットアップガイド](docs/engineering/ci-cd-setup.md) を参照してください。

```bash
# CI/CD環境の初期設定
./scripts/setup_ci_cd.sh setup

# Webhook設定とテスト
./scripts/setup_ci_cd.sh webhook discord YOUR_WEBHOOK_URL
./scripts/setup_ci_cd.sh webhook slack YOUR_WEBHOOK_URL

# ローカルでCI/CDテスト
./scripts/setup_ci_cd.sh test all
```

### 🧭 開発フロー（Git Flow）

本プロジェクトは Git Flow を採用します。以後の開発は `develop` ブランチを基点に進めてください。

- ブランチ種別
  - `main`: 常にデプロイ可能な安定版
  - `develop`: 日常開発の統合先（PRのデフォルトターゲット）
  - `feature/*` `fix/*` `chore/*` `docs/*`: 機能/修正/雑務/ドキュメント用
  - `release/*`: リリース準備。`main` にマージ後タグ付け（例: `v1.2.3`）
  - `hotfix/*`: 本番緊急修正。`main` と `develop` 双方に反映

- 運用ルール
  - すべての通常PRは `develop` 宛てに作成
  - `main` への変更は `release/*` または `hotfix/*` 経由
  - コミットは Conventional Commits を推奨（例: `feat: add vocabulary card UI`）
  - CIは `main` / `develop` の push と PR で自動実行（.github/workflows/flutter.yml）

- 命名例
  - `feature/vocabulary-card-ui-123`
  - `fix/android-build-java17-issue-456`
  - `chore/update-deps-2025-09`
  - `docs/ci-cd-notes`

### 📱 ビルド成果物

- **Android APK**: デバッグ・リリース版
- **Android App Bundle**: Google Play Store向け
- **Web版**: ブラウザで動作するバージョン

---

## 📜 ライセンス
MIT License
