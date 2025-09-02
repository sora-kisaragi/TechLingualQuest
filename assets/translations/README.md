# 動的多言語対応システム / Dynamic Localization System

このシステムはJSONベースの翻訳データを使用して、簡単に新しい言語を追加できる柔軟な多言語対応を提供します。

## 特徴

- **JSONベースの翻訳**: `translations.json`ファイルで全ての翻訳を管理
- **動的言語サポート**: 新しい言語を追加する際はコード変更不要
- **英語をキーとした1対多の関係**: 英語テキストをキーとして、他言語との翻訳を管理
- **拡張性**: 韓国語、中国語などの追加言語もサポート済み

## 新しい言語の追加方法

### 1. translations.jsonに言語情報を追加

```json
{
  "supportedLanguages": {
    "fr": {
      "nativeName": "Français",
      "englishName": "French"
    }
  }
}
```

### 2. 翻訳データを追加

各翻訳キーに新しい言語コードでの翻訳を追加：

```json
{
  "translations": {
    "Welcome to TechLingual Quest!": {
      "en": "Welcome to TechLingual Quest!",
      "ja": "テックリンガルクエストへようこそ！",
      "ko": "TechLingual Quest에 오신 것을 환영합니다!",
      "zh": "欢迎来到TechLingual Quest！",
      "fr": "Bienvenue à TechLingual Quest!"
    }
  }
}
```

### 3. 言語選択UIの更新（オプション）

`DynamicLanguageSelector`は自動的に新しい言語に対応しますが、言語名の翻訳を追加したい場合は：

```json
{
  "translations": {
    "French": {
      "en": "French",
      "ja": "フランス語",
      "ko": "프랑스어",
      "zh": "法语",
      "fr": "Français"
    }
  }
}
```

## 使用方法

### コンポーネントでの翻訳使用例

```dart
// ConsumerWidgetを使用
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationsAsync = ref.watch(appTranslationsProvider);

    return translationsAsync.when(
      data: (translations) => FutureBuilder<String>(
        future: translations.get('Welcome to TechLingual Quest!'),
        builder: (context, snapshot) {
          return Text(snapshot.data ?? 'Default text');
        },
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### 直接翻訳サービスの使用

```dart
// 現在の言語での翻訳を取得
final translation = await DynamicLocalizationService.translate(
  'Welcome to TechLingual Quest!',
  'ja'  // 言語コード
);
```

## システム設計の利点

1. **コード変更不要**: 新しい言語を追加する際、Dartコードの変更は不要
2. **一元管理**: すべての翻訳データが1つのJSONファイルで管理
3. **英語キー方式**: 英語テキストをキーとして使用することで、翻訳漏れを防止
4. **フォールバック機能**: 翻訳が見つからない場合は英語または元のキーを返す
5. **パフォーマンス**: 翻訳データはキャッシュされ、効率的にアクセス可能

## 技術的な詳細

- **LanguageInfo**: 言語メタデータ（コード、ネイティブ名、英語名、ロケール）
- **DynamicLocalizationService**: 翻訳データの読み込みと管理
- **AppTranslations**: 便利な翻訳アクセス用ヘルパークラス
- **DynamicLanguageNotifier**: Riverpodを使用した言語状態管理
- **DynamicLanguageSelector**: 自動適応型言語選択UI

このシステムにより、従来のARBファイルベースのシステムから、より柔軟で拡張性の高い多言語対応システムに移行できました。
