# ドキュメント

このディレクトリには、TechLingual Quest Flutter アプリケーションのプロジェクト固有ドキュメントが含まれています。

## 構造

```
TechLingualQuest/
├── design/                   # システム設計ドキュメント（ルートレベル）
│   ├── HLD.md               # 高水準設計書
│   └── LLD.md               # 低水準設計書
├── requirements/             # 要件ドキュメント（ルートレベル）
│   ├── system-requirements.md  # システム要件
│   └── user-requirements.md    # ユーザー要件
├── optional/                 # 補足ドキュメント（ルートレベル）
│   ├── db_design.md         # データベース設計
│   └── api_spec.md          # API仕様
└── docs/                    # Flutter固有ドキュメント
    ├── api/                 # APIドキュメント
    └── README.md            # このファイル
```

## ドキュメント統合

このプロジェクトは以下のドキュメント構造で整理されています：

- **design/**: システム全体の設計書（HLD、LLD）
- **requirements/**: システム要件とユーザー要件仕様
- **optional/**: データベース設計やAPI仕様等の補足資料
- **docs/**: Flutter固有の開発ドキュメント

## ガイドライン

- コード変更に合わせてドキュメントを最新に保つ
- テキストドキュメントにはMarkdownを使用
- 役立つ場合は図表を含める（Mermaid構文推奨）
- 明確で簡潔な説明を記述
- 関連する場合は例とコードスニペットを提供
- Flutterドキュメントのベストプラクティスに従う

## 関連ドキュメント

メインのプロジェクトドキュメントについては、以下を参照してください：
- [高水準設計書](../design/HLD.md) - システムアーキテクチャ概要
- [低水準設計書](../design/LLD.md) - 詳細実装設計
- [システム要件](../requirements/system-requirements.md) - 技術要件
- [ユーザー要件](../requirements/user-requirements.md) - ユーザーストーリー
- [データベース設計](../optional/db_design.md) - DB設計詳細
- [API仕様](../optional/api_spec.md) - RESTful API仕様