# ディスカッション画面ワイヤーフレーム

## 画面概要
技術トピックについての議論・会話練習画面。外部GPTアプリとの連携機能。

## メイン画面レイアウト

```
┌─────────────────────────────────────┐
│ [←] Discuss quantum            [⋮] │ ← ヘッダー
├─────────────────────────────────────┤
│                                     │
│ 🟢 Sonde ampyaries                  │ ← 参加者ステータス
│                                     │
│ ┌─────────────────────────────────┐ │
│ │      Activity Chart             │ │ ← 活動統計グラフ
│ │ 855 ┌─┐                        │ │
│ │     │ │ ┌─┐                    │ │
│ │     │ │ │ │     ┌─┐            │ │
│ │     │ │ │ │ ┌─┐ │ │            │ │
│ │     └─┘ └─┘ └─┘ └─┘            │ │
│ │ Apr 8     2023:1               │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Technical Summaries                 │ ← 技術要約セクション
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ⚛️ Quantum Computing            │ │ ← トピックカード
│ │ Quantum Computers               │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🕸️ Distributed Systems          │ │ ← トピックカード
│ │ Systems                         │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🧠 Neural Networks              │ │ ← トピックカード
│ │ AI                              │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [View Database]                     │ ← データベース連携
│                                     │
└─────────────────────────────────────┘
```

## トピック詳細画面

```
┌─────────────────────────────────────┐
│ [←] Quantum Computing         [🔗] │ ← トピック詳細ヘッダー
├─────────────────────────────────────┤
│                                     │
│ 🎯 Discussion Topic                 │ ← ディスカッションタイトル
│ Quantum Computing Fundamentals     │
│                                     │
│ 📊 Complexity Level: Advanced      │ ← 難易度
│ ⏱️ Estimated Time: 15-20 min       │ ← 予想時間
│                                     │
│ Key Points to Discuss:              │ ← 議論ポイント
│ • Quantum superposition            │
│ • Entanglement applications        │
│ • Quantum algorithms vs classical  │
│ • Current limitations & challenges │
│                                     │
│ Related Vocabulary:                 │ ← 関連単語
│ [superposition] [entanglement]      │
│ [qubit] [quantum-gate]              │
│ [coherence] [decoherence]           │
│                                     │
│ Your Progress:                      │ ← 進捗状況
│ ████████░░ 80% Complete             │
│                                     │
│ [🤖 Open in ChatGPT]                │ ← 外部アプリ連携
│ [📝 Save Discussion Notes]          │ ← ノート保存
│ [✅ Mark as Completed]              │ ← 完了マーク
│                                     │
└─────────────────────────────────────┘
```

## 会話履歴画面

```
┌─────────────────────────────────────┐
│ [←] Discussion History        [📤] │ ← 履歴ヘッダー
├─────────────────────────────────────┤
│                                     │
│ Sep 2, 2024 - Quantum Computing    │ ← 日付・トピック
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 👤 You:                         │ │ ← ユーザー発言
│ │ Can you explain quantum         │ │
│ │ superposition in simple terms?  │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🤖 Assistant:                   │ │ ← AI応答
│ │ Quantum superposition is like   │ │
│ │ a coin that's spinning in the   │ │
│ │ air - it's both heads and tails │ │
│ │ until it lands...               │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 👤 You:                         │ │ ← ユーザー発言
│ │ How does this apply to          │ │
│ │ quantum computing algorithms?   │ │
│ └─────────────────────────────────┘ │
│                                     │
│ XP Earned: +25 XP 🏆               │ ← 獲得XP
│ Discussion Duration: 12 minutes     │ ← 会話時間
│                                     │
│ [Export Chat] [Continue Discussion] │ ← アクション
│                                     │
└─────────────────────────────────────┘
```

## GPT連携画面

```
┌─────────────────────────────────────┐
│ [✕] Connect to ChatGPT         [?] │ ← 連携画面
├─────────────────────────────────────┤
│                                     │
│ 🔗 External App Integration         │ ← 統合タイトル
│                                     │
│ Choose your preferred AI assistant: │ ← AI選択
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🤖 ChatGPT                      │ │ ← OpenAI ChatGPT
│ │ OpenAI Official App             │ │
│ │ [Connect] ..................... │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🦙 Ollama                       │ │ ← ローカルLLM
│ │ Local LLM Instance              │ │
│ │ [Configure] ................... │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🏠 LM Studio                    │ │ ← LM Studio
│ │ Local AI Server                 │ │
│ │ [Setup] ....................... │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Conversation Context:               │ ← コンテキスト
│ ✅ Include topic background         │
│ ✅ Share vocabulary list            │
│ ✅ Set discussion goals             │
│                                     │
│ [Start Discussion]                  │ ← 開始ボタン
│                                     │
└─────────────────────────────────────┘
```

## データベースビュー画面

```
┌─────────────────────────────────────┐
│ [←] Database View             [↻]  │ ← データベースビュー
├─────────────────────────────────────┤
│                                     │
│ ┌─────────────┐   ┌─────────────┐   │
│ │   Mobile    │   │  Desktop/   │   │ ← デバイス表示
│ │     📱       │ ⟷ │  Browser    │   │
│ │   Device    │   │     💻      │   │
│ └─────────────┘   └─────────────┘   │
│                                     │
│ Sync Status: ✅ Connected           │ ← 同期状態
│ Last Sync: 2 minutes ago            │
│                                     │
│ Database Contents:                  │ ← DB内容
│ ┌─────────────────────────────────┐ │
│ │ 📚 Vocabulary: 127 words        │ │
│ │ 📰 Articles: 8 summaries        │ │
│ │ 💬 Discussions: 12 sessions     │ │
│ │ 🏆 Achievements: 5 badges       │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Data Export:                        │ ← エクスポート
│ [📊 Export Stats] [📄 Export All]   │
│                                     │
│ Cloud Backup:                       │ ← バックアップ
│ [☁️ Backup Now] [⚙️ Auto-Backup]    │
│                                     │
└─────────────────────────────────────┘
```

## インタラクション

1. **トピックカードタップ**: トピック詳細画面へ
2. **外部アプリ連携**: ChatGPT等への専用リンク
3. **会話記録**: ディスカッション履歴の自動保存
4. **XP計算**: 会話時間・品質に基づくXP付与
5. **データ同期**: デバイス間での会話履歴同期

## 外部アプリ連携

- **ChatGPT連携**: ディープリンクでトピック情報を渡す
- **Ollama統合**: ローカルLLMサーバーとの通信
- **LM Studio**: プライベートAIアシスタント連携
- **会話インポート**: 外部アプリからの会話履歴取り込み

## データ構造

```json
{
  "discussion": {
    "id": "disc_001",
    "topic": "Quantum Computing",
    "category": "Computer Science",
    "difficulty": "Advanced",
    "participants": ["user_001"],
    "startTime": "2024-09-02T10:00:00Z",
    "endTime": "2024-09-02T10:15:00Z",
    "xpEarned": 25,
    "status": "completed",
    "externalAppUsed": "ChatGPT",
    "conversationSummary": "Discussion about quantum superposition...",
    "relatedWords": ["superposition", "entanglement"],
    "keyPoints": ["Quantum mechanics basics", "Practical applications"]
  }
}
```