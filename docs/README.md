# ドキュメント

このディレクトリには、TechLingual Quest Flutter アプリケーションのプロジェクトドキュメントが含まれています。

## 構造

```
docs/
├── design/                   # 設計ドキュメント（既存）
│   ├── HLD.md               # 高水準設計書（既存）
│   ├── LLD.md               # 低水準設計書（既存）
│   ├── wireframes/          # UIワイヤーフレーム（将来）
│   ├── mockups/             # ビジュアルモックアップ（将来）
│   └── style_guide.md       # UI/UXスタイルガイド（将来）
├── requirements/             # 要件ドキュメント（既存）
│   └── requirements.md      # システム要件（既存）
├── optional/                 # オプションドキュメント（既存）
│   └── db_design.md         # データベース設計（既存）
├── api/                     # APIドキュメント（Flutter固有）
│   ├── endpoints/           # APIエンドポイント仕様
│   ├── schemas/             # データスキーマ
│   └── authentication.md   # 認証ドキュメント
├── pre-commit-setup.md      # pre-commit セットアップと運用ガイド
└── architecture/            # 追加アーキテクチャドキュメント（将来）
    ├── flutter_architecture.md  # Flutter固有アーキテクチャ
    ├── state_management.md      # 状態管理パターン
    └── data_flow.md             # Flutterデータフロー図
```

## 既存ドキュメントとの統合

このFlutterプロジェクトは既存のドキュメント構造と統合されています：

- **design/**: システム設計ドキュメント（HLD.md、LLD.md）を含む - 既存内容は保持されます
- **requirements/**: プロジェクト要件仕様を含む - 既存内容は保持されます
- **optional/**: データベース設計などの補足ドキュメントを含む - 既存内容は保持されます
- **api/**: Flutter固有のAPIドキュメント用新ディレクトリ

## ガイドライン

- コード変更に合わせてドキュメントを最新に保つ
- テキストドキュメントにはMarkdownを使用
- 役立つ場合は図表を含める（Mermaid構文推奨）
- 明確で簡潔な説明を記述
- 関連する場合は例とコードスニペットを提供
- Flutterドキュメントのベストプラクティスに従う
- 既存の設計・要件ドキュメントと統合
