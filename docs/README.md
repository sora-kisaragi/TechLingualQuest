# ドキュメント

このディレクトリには、TechLingual Quest Flutter アプリケーションのプロジェクトドキュメントが含まれています。

## 構造

```
docs/
├── design/                    # 設計（HLD/LLD、ワイヤーフレーム）
│   ├── HLD.md
│   ├── LLD.md
│   └── wireframes/
├── requirements/              # 要件
│   └── requirements.md
├── engineering/               # エンジニアリング運用
│   ├── ci-cd-setup.md        # CI/CD セットアップ
│   ├── pre-commit-setup.md   # pre-commit ガイド
│   ├── screenshot_guide.md   # スクリーンショット撮影ガイド
│   └── DEVELOPMENT.md        # 開発環境セットアップ
├── process/                   # 開発プロセス（Issue/タスクの派生）
│   ├── development-notes.md  # 開発ノート
│   ├── development-tasks.md  # タスク一覧
│   ├── github-issues-creation-guide.md # Issues作成ガイド
│   ├── issue-10-summary.md   # Issue #10 サマリ
│   └── issue-creation-plan.md# Issue作成計画
├── ui/                        # UI関連ドキュメント
│   └── ui-localization-preview.md
├── optional/                  # 任意の補足
│   └── db_design.md
└── api/                       # API系（プレースホルダ）
    └── .gitkeep

```

## ガイドライン

- コード変更に合わせてドキュメントを最新に保つ
- テキストドキュメントにはMarkdownを使用
- 役立つ場合は図表を含める（Mermaid構文推奨）
- 明確で簡潔な説明を記述
- 関連する場合は例とコードスニペットを提供
- Flutterドキュメントのベストプラクティスに従う
- 既存の設計・要件ドキュメントと統合
