# 進捗管理画面ワイヤーフレーム

## 画面概要
学習進捗の詳細分析、統計表示、目標設定を行う画面。

## メイン統計画面

```
┌─────────────────────────────────────┐
│ [←] Progress Dashboard        [⚙️] │ ← ヘッダー
├─────────────────────────────────────┤
│                                     │
│ Overall Progress                    │ ← 全体進捗
│ ████████████████████  Level 5       │
│ 2450 / 3000 XP (82%)               │
│                                     │
│ [This Week] [This Month] [All Time] │ ← 期間フィルター
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📊 Weekly Activity              │ │ ← 週間活動グラフ
│ │ ┌─┐                            │ │
│ │ │8││6│   ┌─┐                    │ │
│ │ └─┘└─┘┌─┐│4│┌─┐                 │ │
│ │       │2││ ││1│                 │ │
│ │       └─┘└─┘└─┘                 │ │
│ │  M  T  W  T  F  S  S            │ │
│ │                                 │ │
│ │ Today: 8 words learned          │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🎯 Quest Completion             │ │ ← クエスト完了率
│ │ ████████████░░░░░░░░ 75%         │ │
│ │                                 │ │
│ │ Completed: 12/16 quests         │ │
│ │ Read: ✅  Write: ✅  Listen: ⏳ │ │
│ │ Speak: ✅  Review: ❌           │ │
│ └─────────────────────────────────┘ │
│                                     │
├─────────────────────────────────────┤
│ [🏠] [📚] [📊] [⚙️]              │ ← ボトムナビゲーション
└─────────────────────────────────────┘
```

## 詳細統計画面

```
┌─────────────────────────────────────┐
│ [←] Detailed Analytics        [📤] │ ← 詳細分析ヘッダー
├─────────────────────────────────────┤
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📚 Vocabulary Progress          │ │ ← 単語学習進捗
│ │                                 │ │
│ │ Total Words: 127                │ │
│ │ ██████████████████░░ 85%         │ │
│ │                                 │ │
│ │ Mastered: 85 words (67%)        │ │
│ │ Learning: 32 words (25%)        │ │
│ │ New: 10 words (8%)              │ │
│ │                                 │ │
│ │ [View Details >]                │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📰 Article Summaries            │ │ ← 記事要約統計
│ │                                 │ │
│ │ Total Articles: 8               │ │
│ │ Total Words: 2,450              │ │
│ │ Categories:                     │ │
│ │ • Computer Science: 4           │ │
│ │ • AI/ML: 2                      │ │
│ │ • Systems: 2                    │ │
│ │                                 │ │
│ │ [View Library >]                │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 💬 Discussion Activity          │ │ ← ディスカッション統計
│ │                                 │ │
│ │ Sessions: 12                    │ │
│ │ Total Time: 3h 45m              │ │
│ │ Avg Duration: 18.8 min          │ │
│ │                                 │ │
│ │ Top Topics:                     │ │
│ │ • Quantum Computing (4)         │ │
│ │ • Machine Learning (3)          │ │
│ │                                 │ │
│ │ [View History >]                │ │
│ └─────────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

## 目標設定画面

```
┌─────────────────────────────────────┐
│ [←] Goal Setting              [💾] │ ← 目標設定ヘッダー
├─────────────────────────────────────┤
│                                     │
│ Daily Goals                         │ ← 日次目標
│ ┌─────────────────────────────────┐ │
│ │ Learn new words: [5] per day    │ │
│ │ ████████████████████ 100%       │ │
│ │ Today: 5/5 ✅                   │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Complete quests: [2] per day    │ │
│ │ ████████████░░░░░░░░ 60%         │ │
│ │ Today: 3/5 ⏳                    │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Weekly Goals                        │ ← 週次目標
│ ┌─────────────────────────────────┐ │
│ │ Write summaries: [3] per week   │ │
│ │ ██████████████████░░ 80%         │ │
│ │ This week: 4/5 ⏳               │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Discussion time: [60] min/week  │ │
│ │ ████████████████░░░░ 75%         │ │
│ │ This week: 45/60 min ⏳         │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Long-term Goals                     │ ← 長期目標
│ ┌─────────────────────────────────┐ │
│ │ 🎯 Reach Level 10               │ │
│ │ ████████████░░░░░░░░ 50%         │ │
│ │ Current: Level 5/10             │ │
│ │ ETA: 45 days                    │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [Save Goals] [Reset to Default]     │ ← 保存ボタン
│                                     │
└─────────────────────────────────────┘
```

## レポート生成画面

```
┌─────────────────────────────────────┐
│ [←] Progress Report           [📤] │ ← レポートヘッダー
├─────────────────────────────────────┤
│                                     │
│ Generate Report                     │ ← レポート生成
│                                     │
│ Period: [Last 30 Days ▼]            │ ← 期間選択
│                                     │
│ Include:                            │ ← 含める項目
│ ✅ Learning statistics              │
│ ✅ Vocabulary progress              │
│ ✅ Quest completion rates           │
│ ✅ Discussion summaries             │
│ ✅ Achievement timeline             │
│ ✅ Goals vs actual performance      │
│                                     │
│ Report Format:                      │ ← 形式選択
│ ◉ PDF Document                     │
│ ○ CSV Spreadsheet                  │
│ ○ Email Summary                    │
│                                     │
│ Preview:                            │ ← プレビュー
│ ┌─────────────────────────────────┐ │
│ │ TechLingual Quest               │ │
│ │ Learning Report                 │ │
│ │ Aug 3 - Sep 2, 2024            │ │
│ │                                 │ │
│ │ Summary:                        │ │
│ │ • XP Gained: 450 (+18%)         │ │
│ │ • Words Learned: 35             │ │
│ │ │ • Quests Completed: 24/30      │ │
│ │ • Discussion Time: 4h 15m       │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [Generate Report] [Schedule Email]  │ ← 生成ボタン
│                                     │
└─────────────────────────────────────┘
```

## バッジ・実績画面

```
┌─────────────────────────────────────┐
│ [←] Achievements & Badges     [🔍] │ ← 実績ヘッダー
├─────────────────────────────────────┤
│                                     │
│ Recent Achievements                 │ ← 最近の実績
│ ┌─────────────────────────────────┐ │
│ │ 🏆 Word Master                  │ │
│ │ Learn 100 vocabulary words      │ │
│ │ Unlocked: Sep 1, 2024           │ │
│ │ +50 XP                          │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📚 Knowledge Seeker             │ │
│ │ Summarize 5 technical articles  │ │
│ │ Unlocked: Aug 28, 2024          │ │
│ │ +30 XP                          │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [Earned] [In Progress] [Locked]     │ ← フィルタータブ
│                                     │
│ Progress Towards Next Badges:       │ ← 進行中バッジ
│ ┌─────────────────────────────────┐ │
│ │ 🎯 Consistency Champion         │ │
│ │ Complete daily goals for 30 days│ │
│ │ ████████████████░░░░ 80%         │ │
│ │ 24/30 days                      │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 💬 Conversation Expert          │ │
│ │ Have 50 discussion sessions     │ │
│ │ ██████████░░░░░░░░░░ 48%         │ │
│ │ 24/50 sessions                  │ │
│ └─────────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

## インタラクション

1. **グラフタップ**: 詳細データ表示
2. **目標設定**: スライダーで数値調整
3. **レポート生成**: PDF/CSV出力
4. **実績タップ**: 詳細説明とヒント
5. **データエクスポート**: 外部アプリ共有

## データ分析機能

- **学習パターン分析**: 最適な学習時間帯の提案
- **弱点識別**: 苦手分野の自動検出
- **目標達成予測**: 機械学習による到達日予測
- **モチベーション分析**: 継続要因の特定

## データ構造

```json
{
  "progress": {
    "userId": "user_001",
    "currentLevel": 5,
    "currentXP": 2450,
    "totalXP": 2450,
    "weeklyStats": {
      "wordsLearned": 35,
      "questsCompleted": 12,
      "discussionTime": 225, // minutes
      "articlesWritten": 3
    },
    "goals": {
      "daily": {
        "wordsTarget": 5,
        "questsTarget": 2
      },
      "weekly": {
        "articlesTarget": 3,
        "discussionTimeTarget": 60
      }
    },
    "achievements": [
      {
        "id": "word_master",
        "name": "Word Master",
        "description": "Learn 100 vocabulary words",
        "unlockedAt": "2024-09-01T10:00:00Z",
        "xpReward": 50
      }
    ]
  }
}
```
