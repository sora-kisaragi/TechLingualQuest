# 設定・プロフィール画面ワイヤーフレーム

## 画面概要
アプリ設定、ユーザープロフィール管理、データエクスポート等の機能。

## メイン設定画面

```
┌─────────────────────────────────────┐
│ [←] Settings                  [?]   │ ← ヘッダー
├─────────────────────────────────────┤
│                                     │
│ Profile                             │ ← プロフィールセクション
│ ┌─────────────────────────────────┐ │
│ │ [👤] Alex Johnson               │ │
│ │ Level 5 • 2450 XP               │ │
│ │ Intermediate (B1-B2)            │ │
│ │ [Edit Profile >]                │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Learning                            │ ← 学習設定セクション
│ ┌─────────────────────────────────┐ │
│ │ 🎯 Daily Goals                  │ │ ← 各設定項目
│ │ 🔔 Notifications                │ │
│ │ 🌐 Language & Region            │ │
│ │ 🤖 AI Integration               │ │
│ │ 📊 Privacy & Data               │ │
│ └─────────────────────────────────┘ │
│                                     │
│ App                                 │ ← アプリ設定セクション
│ ┌─────────────────────────────────┐ │
│ │ 🎨 Appearance                   │ │
│ │ 🔄 Data Sync                    │ │
│ │ 📱 Device Settings              │ │
│ │ 💾 Storage Management           │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Support                             │ ← サポートセクション
│ ┌─────────────────────────────────┐ │
│ │ ❓ Help & FAQ                   │ │
│ │ 📧 Contact Support              │ │
│ │ ⭐ Rate this App                │ │
│ │ 📄 About                        │ │
│ └─────────────────────────────────┘ │
│                                     │
├─────────────────────────────────────┤
│ [🏠] [📚] [📊] [⚙️]              │ ← ボトムナビゲーション
└─────────────────────────────────────┘
```

## プロフィール編集画面

```
┌─────────────────────────────────────┐
│ [←] [💾] Edit Profile          [⋮] │ ← ヘッダー
├─────────────────────────────────────┤
│                                     │
│ ┌─────────────────────────────────┐ │
│ │           [👤]                  │ │ ← プロフィール画像
│ │         [📷 Change Photo]        │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Display Name                        │
│ ┌─────────────────────────────────┐ │
│ │ Alex Johnson                    │ │ ← 名前編集
│ └─────────────────────────────────┘ │
│                                     │
│ Email                               │
│ ┌─────────────────────────────────┐ │
│ │ alex@example.com                │ │ ← メール表示
│ │ [Change Email]                  │ │   (変更可能)
│ └─────────────────────────────────┘ │
│                                     │
│ Current Level                       │
│ ┌─────────────────────────────────┐ │
│ │ ○ Beginner (A1-A2)             │ │ ← レベル選択
│ │ ● Intermediate (B1-B2)         │ │
│ │ ○ Advanced (C1-C2)             │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Tech Interests                      │
│ [Computer Science] [AI] [Web Dev]   │ ← 興味分野タグ
│ [+ Add Interest]                    │
│                                     │
│ Bio (Optional)                      │
│ ┌─────────────────────────────────┐ │
│ │ Software developer passionate   │ │ ← 自己紹介
│ │ about learning new technologies │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [Save Changes] [Cancel]             │ ← 保存・キャンセル
│                                     │
└─────────────────────────────────────┘
```

## 通知設定画面

```
┌─────────────────────────────────────┐
│ [←] Notifications             [?]   │ ← ヘッダー
├─────────────────────────────────────┤
│                                     │
│ Push Notifications                  │ ← プッシュ通知設定
│ ┌─────────────────────────────────┐ │
│ │ ☑️ Daily Quest Reminders        │ │ ← 各通知項目
│ │ ☑️ Learning Streak Alerts       │ │
│ │ ☑️ XP & Achievement Updates     │ │
│ │ ☐ Weekly Progress Reports       │ │
│ │ ☐ New Content Available         │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Reminder Schedule                   │ ← リマインダー時刻
│ ┌─────────────────────────────────┐ │
│ │ Daily Reminder Time             │ │
│ │ [9:00 AM ▼]                     │ │
│ │                                 │ │
│ │ Weekend Reminders               │ │
│ │ ☑️ Include weekends             │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Email Notifications                 │ ← メール通知
│ ┌─────────────────────────────────┐ │
│ │ ☑️ Weekly Progress Summary       │ │
│ │ ☑️ Monthly Achievement Report   │ │
│ │ ☐ Product Updates & News        │ │
│ │ ☐ Tips & Learning Strategies    │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Do Not Disturb                      │ ← 静音時間
│ ┌─────────────────────────────────┐ │
│ │ ☑️ Enable Do Not Disturb        │ │
│ │ From: [10:00 PM ▼]              │ │
│ │ To: [7:00 AM ▼]                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [Save Settings]                     │ ← 保存ボタン
│                                     │
└─────────────────────────────────────┘
```

## データ同期・バックアップ画面

```
┌─────────────────────────────────────┐
│ [←] Data Sync                 [?]   │ ← ヘッダー
├─────────────────────────────────────┤
│                                     │
│ Sync Status                         │ ← 同期状態
│ ┌─────────────────────────────────┐ │
│ │ ✅ All devices synchronized     │ │
│ │ Last sync: 2 minutes ago        │ │
│ │                                 │ │
│ │ Connected Devices:              │ │
│ │ • 📱 iPhone (this device)       │ │
│ │ • 💻 MacBook Pro                │ │
│ │ • 🌐 Web Browser                │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Sync Settings                       │ ← 同期設定
│ ┌─────────────────────────────────┐ │
│ │ ☑️ Auto-sync when connected     │ │
│ │ ☑️ Sync over Wi-Fi only         │ │
│ │ ☑️ Backup progress data         │ │
│ │ ☐ Sync multimedia content       │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Manual Actions                      │ ← 手動操作
│ ┌─────────────────────────────────┐ │
│ │ [🔄] Sync Now                   │ │
│ │ [☁️] Backup to Cloud            │ │
│ │ [📱] Restore from Backup        │ │
│ │ [🗑️] Clear Local Data           │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Storage Usage                       │ ← ストレージ使用量
│ ┌─────────────────────────────────┐ │
│ │ Total: 45.2 MB                  │ │
│ │ ████████████░░░░░░░░ 60%         │ │
│ │                                 │ │
│ │ • Vocabulary: 15.3 MB           │ │
│ │ • Articles: 22.1 MB             │ │
│ │ • Progress: 4.8 MB              │ │
│ │ • Cache: 3.0 MB                 │ │
│ └─────────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

## AI統合設定画面

```
┌─────────────────────────────────────┐
│ [←] AI Integration            [?]   │ ← ヘッダー
├─────────────────────────────────────┤
│                                     │
│ Connected AI Services               │ ← 接続済みAIサービス
│ ┌─────────────────────────────────┐ │
│ │ 🤖 ChatGPT                      │ │
│ │ ✅ Connected • Premium Plan     │ │
│ │ [Configure] [Disconnect]        │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🦙 Ollama (Local)               │ │
│ │ ⚙️ Not configured               │ │
│ │ [Setup Local Server]            │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🏠 LM Studio                    │ │
│ │ ⚙️ Not configured               │ │
│ │ [Setup Connection]              │ │
│ └─────────────────────────────────┘ │
│                                     │
│ AI Features                         │ ← AI機能設定
│ ┌─────────────────────────────────┐ │
│ │ ☑️ Auto-generate summaries      │ │
│ │ ☑️ Vocabulary difficulty hints  │ │
│ │ ☑️ Discussion topic suggestions │ │
│ │ ☐ Real-time grammar checking   │ │
│ │ ☐ Pronunciation feedback       │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Content Sharing                     │ ← コンテンツ共有
│ ┌─────────────────────────────────┐ │
│ │ ☑️ Share learning context       │ │
│ │ ☑️ Include vocabulary list      │ │
│ │ ☐ Share progress statistics     │ │
│ │ ☐ Send conversation history     │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [Save Settings]                     │ ← 保存ボタン
│                                     │
└─────────────────────────────────────┘
```

## エクスポート・インポート画面

```
┌─────────────────────────────────────┐
│ [←] Export & Import           [?]   │ ← ヘッダー
├─────────────────────────────────────┤
│                                     │
│ Export Data                         │ ← データエクスポート
│ ┌─────────────────────────────────┐ │
│ │ Select data to export:          │ │
│ │                                 │ │
│ │ ☑️ Vocabulary (127 words)       │ │ ← エクスポート項目
│ │ ☑️ Article summaries (8)        │ │
│ │ ☑️ Learning progress            │ │
│ │ ☑️ Discussion history           │ │
│ │ ☐ Achievement data              │ │
│ │ ☐ Settings & preferences        │ │
│ │                                 │ │
│ │ Format: [JSON ▼] [CSV] [PDF]    │ │ ← 形式選択
│ │                                 │ │
│ │ [📤 Export Data]                │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Import Data                         │ ← データインポート
│ ┌─────────────────────────────────┐ │
│ │ Import from:                    │ │
│ │                                 │ │
│ │ [📁] Choose File                │ │ ← ファイル選択
│ │                                 │ │
│ │ Supported formats:              │ │
│ │ • JSON (TechLingual format)     │ │
│ │ • CSV (vocabulary lists)        │ │
│ │ • Anki deck files              │ │
│ │                                 │ │
│ │ [📥 Import Data]                │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Quick Actions                       │ ← クイックアクション
│ ┌─────────────────────────────────┐ │
│ │ [📊] Generate Progress Report   │ │
│ │ [📧] Email Learning Summary     │ │
│ │ [📋] Copy Statistics to Clipboard│ │
│ │ [🔗] Share Achievement Link     │ │
│ └─────────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

## プライバシー・データ管理画面

```
┌─────────────────────────────────────┐
│ [←] Privacy & Data            [?]   │ ← ヘッダー
├─────────────────────────────────────┤
│                                     │
│ Data Collection                     │ ← データ収集設定
│ ┌─────────────────────────────────┐ │
│ │ ☑️ Learning analytics           │ │
│ │ ☑️ Performance metrics          │ │
│ │ ☐ Crash reports                │ │
│ │ ☐ Usage patterns               │ │
│ │ ☐ Location data                │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Data Sharing                        │ ← データ共有設定
│ ┌─────────────────────────────────┐ │
│ │ ☐ Share with AI providers      │ │
│ │ ☐ Anonymous usage statistics   │ │
│ │ ☐ Educational research         │ │
│ │ ☐ Product improvement          │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Account Management                  │ ← アカウント管理
│ ┌─────────────────────────────────┐ │
│ │ [🔒] Change Password            │ │
│ │ [📧] Update Email               │ │
│ │ [📱] Two-Factor Authentication  │ │
│ │ [👥] Connected Accounts         │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Data Rights                         │ ← データ権利
│ ┌─────────────────────────────────┐ │
│ │ [📄] Download My Data           │ │
│ │ [🗑️] Delete Account             │ │
│ │ [📋] Privacy Policy             │ │
│ │ [⚖️] Terms of Service           │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ⚠️ Deleting your account will       │ ← 警告メッセージ
│ permanently remove all your data.   │
│                                     │
└─────────────────────────────────────┘
```

## アカウント削除確認画面

```
┌─────────────────────────────────────┐
│ [✕] Delete Account            [?]   │ ← ヘッダー
├─────────────────────────────────────┤
│                                     │
│ ⚠️ Are you sure?                    │ ← 確認メッセージ
│                                     │
│ This action cannot be undone.       │ ← 警告
│ All your data will be permanently   │
│ deleted, including:                 │
│                                     │
│ • 127 vocabulary words              │ ← 削除されるデータ
│ • 8 article summaries               │
│ • All learning progress (2450 XP)  │
│ • 12 discussion sessions            │
│ • Achievement history               │
│                                     │
│ Last chance to export your data:    │ ← エクスポート提案
│ [📤 Export Before Deleting]         │
│                                     │
│ Type "DELETE" to confirm:           │ ← 確認入力
│ ┌─────────────────────────────────┐ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [🗑️ Delete My Account Permanently] │ ← 削除ボタン
│                                     │
│ [Cancel]                            │ ← キャンセル
│                                     │
└─────────────────────────────────────┘
```

## インタラクション

1. **プロフィール画像変更**: ギャラリー・カメラ選択
2. **設定変更**: リアルタイム保存・同期
3. **データエクスポート**: 進捗表示付きダウンロード
4. **通知テスト**: 設定後のテスト通知送信
5. **同期状況**: リアルタイム同期状態表示

## データ管理

- **設定の同期**: デバイス間での設定共有
- **バックアップ**: 定期的な自動バックアップ
- **復元機能**: バックアップからの簡単復元
- **データ移行**: 端末変更時のデータ移行サポート
