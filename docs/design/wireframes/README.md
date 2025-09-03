# ワイヤーフレーム (Wireframes)

このディレクトリには、TechLingual Quest アプリケーションのUIワイヤーフレームが含まれています。

## 構造

```
wireframes/
├── README.md                    # このファイル
├── original_wireframe_reference.md # オリジナル画像の説明
├── mobile/                      # モバイルアプリのワイヤーフレーム
│   ├── dashboard.md             # ダッシュボード画面
│   ├── vocabulary.md            # 単語学習画面
│   ├── article_summary.md       # 記事要約画面
│   ├── discussion.md            # ディスカッション画面
│   ├── progress.md              # 進捗画面
│   ├── auth_onboarding.md       # 認証・オンボーディング画面
│   └── settings_profile.md      # 設定・プロフィール画面
├── web/                         # Webアプリケーションのワイヤーフレーム
│   └── desktop_layout.md        # デスクトップレイアウト
└── flows/                       # ユーザーフロー図
    ├── learning_flow.md         # 学習フロー
    └── quest_flow.md            # クエストフロー
```

## メインワイヤーフレーム

![TechLingual Quest Main App Wireframe](./main_app_wireframe.png)

*詳細な画面説明については [original_wireframe_reference.md](./original_wireframe_reference.md) を参照してください。*

### 主要画面構成

メインワイヤーフレーム（main_app_wireframe.png）には以下の画面が含まれています：

1. **ダッシュボード画面**
   - 今日のクエスト表示
   - XP進捗バー (レベル5、2450 XP)
   - 単語学習統計グラフ（曜日別）
   - クイックアクション（記事読み、要約作成、リスニング、ディスカッション）

2. **単語学習画面**
   - 学習済み単語リスト
   - 単語の意味と例文表示
   - 難易度表示（B2, B4など）
   - クイズボタン

3. **記事要約画面**
   - 記事タイトル「Summary of Quantum Computing」
   - 完了タスクのチェックリスト
   - XP獲得表示
   - 関連記事とリワード情報

4. **ディスカッション画面**
   - トピック「Discuss quantum」
   - 参加者情報（Sonde ampyaries）
   - 統計グラフ表示
   - 技術要約セクション

5. **データベース連携図**
   - モバイル⇔デスクトップ/ブラウザ間のデータ同期
   - データベース連携の概念図

## ワイヤーフレームの目的

- **ユーザビリティ**: 直感的なナビゲーションとインタラクション設計
- **機能配置**: 主要機能の効率的な配置
- **データフロー**: ユーザーアクションからデータ処理までの流れ
- **レスポンシブ対応**: モバイル・デスクトップ両対応のレイアウト
- **ゲーミフィケーション**: XP、レベル、リワード要素の統合

## 参照リンク

- [GitHub Issue](https://github.com/sora-kisaragi/TechLingualQuest/issues/7) - オリジナルワイヤーフレーム画像
- [HLD](../HLD.md) - 高水準設計書
- [LLD](../LLD.md) - 低水準設計書
- [システム要件](../../requirements/requirements.md) - 詳細要件

## 更新履歴

- 2025-09-02: 初期ワイヤーフレーム構造作成
- 2025-09-02: メインアプリケーションワイヤーフレーム追加
- 2025-09-02: 認証・オンボーディングフロー追加
- 2025-09-02: 設定・プロフィール管理画面追加
- 2025-09-02: クエストシステムフロー追加
- 2025-09-02: デスクトップレイアウト対応完了
