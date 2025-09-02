# 記事要約画面ワイヤーフレーム

## 画面概要
技術記事の要約作成、保存、管理を行う画面。クエストシステムと連動。

## メイン画面レイアウト

```
┌─────────────────────────────────────┐
│ [✕] Summary of Quantum Computing   │ ← ヘッダー
├─────────────────────────────────────┤
│                                     │
│ 👤 Parders somvared                 │ ← 作成者情報
│                                     │
│ ✅ Read: Summary of                 │ ← 完了タスク
│     Quantum Computing               │
│                                     │
│ ✅ Write: Summarize last article    │ ← 完了タスク
│                                     │
│ ✅ Learn: Related vocabulary        │ ← 完了タスク
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📰 Articles                     │ │ ← 記事セクション
│ │ 44 XP                           │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📄 Reward: Un pon               │ │ ← リワードセクション
│ │ 25 XP                           │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [Quantum Computing]                 │ ← アクションボタン
│                                     │
└─────────────────────────────────────┘
```

## 記事作成/編集画面

```
┌─────────────────────────────────────┐
│ [←] [💾] New Article Summary   [⋮] │ ← 編集ヘッダー
├─────────────────────────────────────┤
│                                     │
│ Title:                              │
│ ┌─────────────────────────────────┐ │
│ │ Summary of Quantum Computing    │ │ ← タイトル入力
│ └─────────────────────────────────┘ │
│                                     │
│ URL:                                │
│ ┌─────────────────────────────────┐ │
│ │ https://arxiv.org/abs/...       │ │ ← URL入力
│ └─────────────────────────────────┘ │
│                                     │
│ Category:                           │
│ [Computer Science ▼]                │ ← カテゴリー選択
│                                     │
│ Summary:                            │
│ ┌─────────────────────────────────┐ │
│ │ Quantum computing leverages     │ │ ← 要約入力
│ │ quantum mechanical phenomena    │ │   (複数行)
│ │ to process information...       │ │
│ │                                 │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Tags: [+Add Tag]                    │ ← タグ管理
│ [quantum] [computing] [physics]     │
│                                     │
│ [🤖 Generate Summary]               │ ← AI要約生成
│ [Save Draft] [Publish]              │ ← 保存ボタン
│                                     │
└─────────────────────────────────────┘
```

## 記事一覧画面

```
┌─────────────────────────────────────┐
│ [←] Article Summaries    [🔍] [+]  │ ← 一覧ヘッダー
├─────────────────────────────────────┤
│                                     │
│ [All] [Recent] [Favorite] [Draft]   │ ← フィルタータブ
│                                     │
│ Category: [All ▼] Sort: [Date ▼]    │ ← ソート・フィルター
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🔬 Quantum Computing             │ │ ← 記事カード
│ │ Summary of quantum mechanics... │ │
│ │ Sep 2, 2024 • Computer Science │ │
│ │ [quantum] [computing]           │ │
│ │ 44 XP earned                    │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🤖 Machine Learning Basics      │ │ ← 記事カード
│ │ Introduction to neural networks │ │
│ │ Sep 1, 2024 • AI/ML            │ │
│ │ [machine-learning] [ai]         │ │
│ │ 35 XP earned                    │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📡 Distributed Systems          │ │ ← 記事カード
│ │ Microservices architecture...   │ │
│ │ Aug 30, 2024 • Systems         │ │
│ │ [distributed] [systems]         │ │
│ │ 50 XP earned                    │ │
│ └─────────────────────────────────┘ │
│                                     │
├─────────────────────────────────────┤
│ [🏠] [📚] [📊] [⚙️]              │ ← ボトムナビゲーション
└─────────────────────────────────────┘
```

## 記事詳細画面

```
┌─────────────────────────────────────┐
│ [←] [⭐] [🔗] [⋮]                 │ ← 詳細ヘッダー
├─────────────────────────────────────┤
│                                     │
│ Quantum Computing                   │ ← 記事タイトル
│ Computer Science • Sep 2, 2024     │ ← メタ情報
│                                     │
│ Original URL:                       │ ← 元記事リンク
│ 🔗 https://arxiv.org/abs/...        │
│                                     │
│ Summary:                            │ ← 要約本文
│ ┌─────────────────────────────────┐ │
│ │ Quantum computing leverages     │ │
│ │ quantum mechanical phenomena    │ │
│ │ such as superposition and       │ │
│ │ entanglement to process         │ │
│ │ information in fundamentally    │ │
│ │ different ways than classical   │ │
│ │ computers...                    │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Key Terms:                          │ ← 関連単語
│ [superposition] [entanglement]      │
│ [qubit] [quantum-gate]              │
│                                     │
│ XP Earned: 44 XP 🏆                │ ← 獲得XP
│                                     │
│ [Edit] [Share] [Delete]             │ ← アクション
│                                     │
└─────────────────────────────────────┘
```

## インタラクション

1. **記事カードタップ**: 詳細画面へ遷移
2. **+ボタン**: 新規記事作成画面
3. **AI要約生成**: URLから自動要約生成
4. **タグタップ**: 同じタグの記事一覧
5. **XP表示**: 獲得XPの詳細ポップアップ

## 状態管理

- **下書き自動保存**: 編集中の内容を自動保存
- **オフライン同期**: ローカル保存後、接続時に同期
- **XP計算**: 文字数、完成度に基づくXP付与

## AI連携機能

- **要約生成**: OpenAI/Ollamaを使用した自動要約
- **キーワード抽出**: 関連技術用語の自動抽出
- **翻訳機能**: 英語記事の日本語要約生成

## データ構造

```json
{
  "id": "article_001",
  "title": "Summary of Quantum Computing",
  "url": "https://arxiv.org/abs/...",
  "category": "Computer Science",
  "summary": "Quantum computing leverages...",
  "tags": ["quantum", "computing", "physics"],
  "authorId": "user_001",
  "createdAt": "2024-09-02T10:00:00Z",
  "updatedAt": "2024-09-02T10:30:00Z",
  "xpEarned": 44,
  "status": "published", // draft, published
  "relatedWords": ["superposition", "entanglement"],
  "readingTime": 5,
  "wordCount": 250
}
```