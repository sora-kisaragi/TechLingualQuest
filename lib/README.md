# ソースコード（lib/）

このディレクトリには、TechLingual Quest Flutter アプリケーションのメインDartソースコードが含まれています。

## 構造

```
lib/
├── main.dart                 # アプリエントリーポイント
├── app/                      # アプリレベル設定
├── features/                 # 機能ベースモジュール
│   ├── auth/                 # 認証
│   ├── vocabulary/           # 語彙管理
│   ├── quests/               # クエストシステム
│   ├── summaries/            # 記事要約
│   └── dashboard/            # 進捗ダッシュボード
├── shared/                   # 共有コンポーネント
│   ├── widgets/              # 再利用可能UIウィジェット
│   ├── utils/                # ユーティリティ関数
│   ├── constants/            # アプリ定数
│   └── models/               # データモデル
└── services/                 # 外部サービス
    ├── api/                  # APIクライアント
    ├── database/             # データベースサービス
    └── auth/                 # 認証サービス
```

## ガイドライン

- Flutter/Dartネーミング規則に従う
- 機能ベースアーキテクチャを使用
- 適切なエラーハンドリングを実装
- クリーンで保守可能なコードを記述
