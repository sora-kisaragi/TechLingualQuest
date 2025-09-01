---
author: "GitHub Copilot Agent"
date: "2025-09-01"
version: "2.0"
related_issues: ["#10", "#5"]
related_docs: ["HLD.md", "../../requirements/system-requirements.md", "../../requirements/user-requirements.md", "../development-tasks.md"]
---

# 低水準設計書（LLD）- TechLingual Quest

このドキュメントでは、TechLingual Quest アプリケーションの詳細な技術設計、クラス構造、アルゴリズム、実装仕様を提供します。

## 関連ドキュメント
- [高水準設計書](HLD.md) - システムアーキテクチャ概要
- [システム要件](../../requirements/system-requirements.md) - 技術システム要件
- [ユーザー要件](../../requirements/user-requirements.md) - ユーザーストーリーと機能要件
- [開発タスク](../development-tasks.md) - 実装タスク詳細

---

## 1. フロントエンドアーキテクチャ（Flutter）

### 1.1 プロジェクト構造

```
lib/
├── main.dart                    # アプリケーションエントリーポイント
├── app/
│   ├── app.dart                # アプリケーション設定
│   ├── router/                 # ルーティング設定
│   └── theme/                  # テーマ・スタイル定義
├── core/
│   ├── constants/              # 定数定義
│   ├── utils/                  # ユーティリティ関数
│   ├── services/               # 共通サービス
│   └── errors/                 # エラーハンドリング
├── features/                   # 機能別モジュール
│   ├── auth/                   # 認証機能
│   ├── vocabulary/             # 単語管理機能
│   ├── quests/                 # クエスト機能
│   ├── summaries/              # 記事要約機能
│   ├── dashboard/              # ダッシュボード機能
│   └── profile/                # プロフィール機能
└── shared/                     # 共有コンポーネント
    ├── widgets/                # 再利用可能なウィジェット
    ├── models/                 # データモデル
    └── providers/              # 状態管理プロバイダー
```

### 1.2 コアクラスとインターフェース

#### 1.2.1 状態管理（Riverpod）

```dart
// ベースプロバイダークラス
abstract class BaseNotifier<T> extends StateNotifier<AsyncValue<T>> {
  BaseNotifier() : super(const AsyncValue.loading());
  
  // 非同期処理の統一的なエラーハンドリング
  Future<void> execute(Future<T> Function() operation) async {
    state = const AsyncValue.loading();
    try {
      final result = await operation();
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// ユーザー状態プロバイダー
class UserNotifier extends BaseNotifier<User> {
  UserNotifier(this._userService);
  
  final UserService _userService;
  
  // 現在のユーザー情報を取得
  Future<void> getCurrentUser() async {
    await execute(() => _userService.getCurrentUser());
  }
  
  // プロフィール更新
  Future<void> updateProfile(UserProfile profile) async {
    await execute(() => _userService.updateProfile(profile));
  }
}

// ユーザー状態プロバイダーの定義
final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<User>>((ref) {
  return UserNotifier(ref.watch(userServiceProvider));
});
```

#### 1.2.2 データモデルクラス

```dart
// ユーザーモデル
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String username,
    required DateTime createdAt,
    required UserProfile profile,
    required UserProgress progress,
  }) = _User;
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

// ユーザープロフィール
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String displayName,
    String? avatarUrl,
    required List<String> learningGoals,
    required LearningPreferences preferences,
    String? timezone,
  }) = _UserProfile;
  
  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}

// ユーザー進捗データ
@freezed
class UserProgress with _$UserProgress {
  const factory UserProgress({
    required int totalXp,
    required int currentLevel,
    required int learningStreak,
    required int vocabularyCount,
    required int questsCompleted,
    required DateTime lastActivityDate,
  }) = _UserProgress;
  
  factory UserProgress.fromJson(Map<String, dynamic> json) => _$UserProgressFromJson(json);
}

// 単語データモデル
@freezed
class VocabularyWord with _$VocabularyWord {
  const factory VocabularyWord({
    required String id,
    required String userId,
    required String word,
    required String definition,
    required String example,
    required String pronunciation,
    required String category,
    required List<String> tags,
    required DateTime createdAt,
    required VocabularyReviewData reviewData,
  }) = _VocabularyWord;
  
  factory VocabularyWord.fromJson(Map<String, dynamic> json) => _$VocabularyWordFromJson(json);
}

// 復習データ
@freezed
class VocabularyReviewData with _$VocabularyReviewData {
  const factory VocabularyReviewData({
    required int reviewCount,
    required double retentionScore,
    required DateTime lastReviewed,
    required DateTime nextReviewDate,
    required SpacedRepetitionData spacedRepetition,
  }) = _VocabularyReviewData;
  
  factory VocabularyReviewData.fromJson(Map<String, dynamic> json) => _$VocabularyReviewDataFromJson(json);
}
```

### 1.3 サービス層設計

```dart
// ベースサービスインターフェース
abstract class IBaseService<T, ID> {
  Future<T?> getById(ID id);
  Future<List<T>> getAll();
  Future<T> create(T entity);
  Future<T> update(T entity);
  Future<void> delete(ID id);
}

// 単語管理サービス
class VocabularyService implements IBaseService<VocabularyWord, String> {
  VocabularyService(this._repository);
  
  final IVocabularyRepository _repository;
  
  @override
  Future<VocabularyWord?> getById(String id) async {
    return await _repository.getById(id);
  }
  
  // ユーザー固有の単語リスト取得
  Future<List<VocabularyWord>> getUserVocabulary(String userId) async {
    return await _repository.getByUserId(userId);
  }
  
  // 復習対象の単語取得
  Future<List<VocabularyWord>> getWordsForReview(String userId) async {
    return await _repository.getWordsForReview(userId, DateTime.now());
  }
  
  // 単語の復習完了処理
  Future<VocabularyWord> completeReview(
    String wordId, 
    ReviewPerformance performance
  ) async {
    final word = await _repository.getById(wordId);
    if (word == null) {
      throw VocabularyNotFoundException('Word not found: $wordId');
    }
    
    // 間隔反復アルゴリズムで次回復習日を計算
    final engine = SpacedRepetitionEngine();
    final updatedReviewData = engine.calculateNextReview(
      word.reviewData, 
      performance
    );
    
    final updatedWord = word.copyWith(reviewData: updatedReviewData);
    return await _repository.update(updatedWord);
  }
}
```

---

## 2. 間隔反復アルゴリズム

### 2.1 アルゴリズム実装

```dart
// 復習パフォーマンス評価
enum ReviewPerformance {
  failed,    // 不正解・忘れた
  hard,      // 難しかった
  good,      // 適切
  easy,      // 簡単
}

// 間隔反復エンジン
class SpacedRepetitionEngine {
  static const double _easyBonus = 1.3;
  static const double _hardPenalty = 0.6;
  static const int _minimumInterval = 1;
  static const int _maximumInterval = 365;
  
  // 次回復習日程の計算
  VocabularyReviewData calculateNextReview(
    VocabularyReviewData current,
    ReviewPerformance performance,
  ) {
    final newRetentionScore = _calculateRetentionScore(
      current.retentionScore,
      performance,
      current.reviewCount,
    );
    
    final intervalDays = _calculateInterval(
      current.spacedRepetition.intervalDays,
      performance,
      newRetentionScore,
    );
    
    final nextReviewDate = DateTime.now().add(Duration(days: intervalDays));
    
    return current.copyWith(
      lastReviewed: DateTime.now(),
      reviewCount: current.reviewCount + 1,
      retentionScore: newRetentionScore,
      nextReviewDate: nextReviewDate,
      spacedRepetition: current.spacedRepetition.copyWith(
        intervalDays: intervalDays,
        easinessFactor: _calculateEasinessFactor(
          current.spacedRepetition.easinessFactor,
          performance,
        ),
      ),
    );
  }
  
  // 保持率スコア計算
  double _calculateRetentionScore(
    double currentScore,
    ReviewPerformance performance,
    int reviewCount,
  ) {
    double adjustment;
    switch (performance) {
      case ReviewPerformance.failed:
        adjustment = -0.3;
        break;
      case ReviewPerformance.hard:
        adjustment = -0.1;
        break;
      case ReviewPerformance.good:
        adjustment = 0.0;
        break;
      case ReviewPerformance.easy:
        adjustment = 0.1;
        break;
    }
    
    // 復習回数が多いほど調整幅を小さくする
    final dampingFactor = 1.0 / (1.0 + reviewCount * 0.1);
    final newScore = currentScore + (adjustment * dampingFactor);
    
    return newScore.clamp(0.0, 1.0);
  }
  
  // 次回復習間隔の計算
  int _calculateInterval(
    int currentInterval,
    ReviewPerformance performance,
    double retentionScore,
  ) {
    double multiplier;
    switch (performance) {
      case ReviewPerformance.failed:
        multiplier = _hardPenalty;
        break;
      case ReviewPerformance.hard:
        multiplier = 0.8;
        break;
      case ReviewPerformance.good:
        multiplier = 1.0 + (retentionScore * 0.5);
        break;
      case ReviewPerformance.easy:
        multiplier = _easyBonus + (retentionScore * 0.7);
        break;
    }
    
    final newInterval = (currentInterval * multiplier).round();
    return newInterval.clamp(_minimumInterval, _maximumInterval);
  }
  
  // 難易度係数の計算
  double _calculateEasinessFactor(
    double currentFactor,
    ReviewPerformance performance,
  ) {
    double adjustment;
    switch (performance) {
      case ReviewPerformance.failed:
        adjustment = -0.2;
        break;
      case ReviewPerformance.hard:
        adjustment = -0.1;
        break;
      case ReviewPerformance.good:
        adjustment = 0.0;
        break;
      case ReviewPerformance.easy:
        adjustment = 0.1;
        break;
    }
    
    final newFactor = currentFactor + adjustment;
    return newFactor.clamp(1.3, 2.5);
  }
}
```

### 2.2 復習スケジューリング

```dart
// 復習スケジューラー
class ReviewScheduler {
  ReviewScheduler(this._vocabularyService);
  
  final VocabularyService _vocabularyService;
  
  // 今日の復習対象単語を取得
  Future<List<VocabularyWord>> getTodaysReviews(String userId) async {
    final allWords = await _vocabularyService.getUserVocabulary(userId);
    final now = DateTime.now();
    
    return allWords.where((word) {
      return word.reviewData.nextReviewDate.isBefore(now) ||
             word.reviewData.nextReviewDate.isAtSameMomentAs(now);
    }).toList();
  }
  
  // 復習優先度の計算
  List<VocabularyWord> prioritizeReviews(List<VocabularyWord> words) {
    return words..sort((a, b) {
      // 期限切れの時間が長いほど優先度高
      final aDaysPast = DateTime.now().difference(a.reviewData.nextReviewDate).inDays;
      final bDaysPast = DateTime.now().difference(b.reviewData.nextReviewDate).inDays;
      
      if (aDaysPast != bDaysPast) {
        return bDaysPast.compareTo(aDaysPast);
      }
      
      // 保持率が低いほど優先度高
      return a.reviewData.retentionScore.compareTo(b.reviewData.retentionScore);
    });
  }
}
```

---

## 3. クエスト生成システム

### 3.1 クエストタイプ定義

```dart
// クエストタイプ列挙
enum QuestType {
  vocabularyReview,     // 単語復習
  vocabularyQuiz,       // 単語クイズ
  readingComprehension, // 読解問題
  writingSummary,       // 要約作成
  listeningPractice,    // リスニング練習
  speakingPractice,     // スピーキング練習
}

// クエスト状態
enum QuestStatus {
  available,    // 利用可能
  inProgress,   // 進行中
  completed,    // 完了
  expired,      // 期限切れ
}

// クエストデータモデル
@freezed
class Quest with _$Quest {
  const factory Quest({
    required String id,
    required QuestType type,
    required String title,
    required String description,
    required Map<String, dynamic> questData,
    required QuestStatus status,
    required int xpReward,
    required DateTime createdAt,
    DateTime? completedAt,
    DateTime? expiresAt,
  }) = _Quest;
  
  factory Quest.fromJson(Map<String, dynamic> json) => _$QuestFromJson(json);
}
```

### 3.2 クエスト生成器インターフェース

```dart
// クエスト生成器の基底インターフェース
abstract class QuestGenerator {
  List<QuestType> get supportedTypes;
  Future<Quest> generateQuest(String userId, QuestType type);
  bool canGenerateQuest(String userId, QuestType type);
}

// 単語クエスト生成器
class VocabularyQuestGenerator implements QuestGenerator {
  VocabularyQuestGenerator(this._vocabularyService, this._userService);
  
  final VocabularyService _vocabularyService;
  final UserService _userService;
  
  @override
  List<QuestType> get supportedTypes => [
    QuestType.vocabularyReview,
    QuestType.vocabularyQuiz,
  ];
  
  @override
  Future<Quest> generateQuest(String userId, QuestType type) async {
    switch (type) {
      case QuestType.vocabularyReview:
        return await _generateReviewQuest(userId);
      case QuestType.vocabularyQuiz:
        return await _generateQuizQuest(userId);
      default:
        throw UnsupportedQuestTypeException('サポートされていないクエストタイプ: $type');
    }
  }
  
  @override
  bool canGenerateQuest(String userId, QuestType type) {
    // ユーザーが十分な単語数を持っているかチェック
    // 最近同様のクエストを完了していないかチェック
    return true; // 簡略化
  }
  
  // 復習クエスト生成
  Future<Quest> _generateReviewQuest(String userId) async {
    final wordsToReview = await _vocabularyService.getWordsForReview(userId);
    final reviewCount = min(10, wordsToReview.length);
    
    return Quest(
      id: const Uuid().v4(),
      type: QuestType.vocabularyReview,
      title: '日次単語復習',
      description: '$reviewCount個の単語を復習して学習ストリークを維持しましょう',
      questData: {
        'targetReviewCount': reviewCount,
        'wordIds': wordsToReview.take(reviewCount).map((w) => w.id).toList(),
      },
      status: QuestStatus.available,
      xpReward: _calculateXpReward(reviewCount),
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );
  }
  
  // クイズクエスト生成
  Future<Quest> _generateQuizQuest(String userId) async {
    final user = await _userService.getById(userId);
    final difficulty = _calculateQuizDifficulty(user?.progress.currentLevel ?? 1);
    
    return Quest(
      id: const Uuid().v4(),
      type: QuestType.vocabularyQuiz,
      title: '単語チャレンジ',
      description: '$difficultyレベルの単語クイズで知識をテストしましょう',
      questData: {
        'questionCount': 10,
        'difficulty': difficulty,
        'timeLimit': 300, // 5分
      },
      status: QuestStatus.available,
      xpReward: _calculateXpReward(10, difficulty: difficulty),
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 12)),
    );
  }
  
  // XP報酬計算
  int _calculateXpReward(int baseCount, {String difficulty = 'normal'}) {
    int baseXp = baseCount * 10;
    
    switch (difficulty) {
      case 'easy':
        return baseXp;
      case 'normal':
        return (baseXp * 1.2).round();
      case 'hard':
        return (baseXp * 1.5).round();
      default:
        return baseXp;
    }
  }
  
  // クイズ難易度計算
  String _calculateQuizDifficulty(int userLevel) {
    if (userLevel < 5) return 'easy';
    if (userLevel < 15) return 'normal';
    return 'hard';
  }
}
```

### 3.3 クエスト管理サービス

```dart
// クエスト管理サービス
class QuestManagementService {
  QuestManagementService(this._repository, this._generators, this._userService);
  
  final IQuestRepository _repository;
  final List<QuestGenerator> _generators;
  final UserService _userService;
  
  // 日次クエスト生成
  Future<List<Quest>> generateDailyQuests(String userId) async {
    final existingQuests = await _repository.getTodaysQuests(userId);
    if (existingQuests.isNotEmpty) {
      return existingQuests;
    }
    
    final newQuests = <Quest>[];
    
    // 各タイプのクエストを1つずつ生成（最大3つ）
    for (final generator in _generators) {
      for (final type in generator.supportedTypes) {
        if (generator.canGenerateQuest(userId, type) && newQuests.length < 3) {
          try {
            final quest = await generator.generateQuest(userId, type);
            newQuests.add(quest);
            await _repository.create(quest);
          } catch (e) {
            // エラーログ出力、他のクエスト生成は継続
            print('クエスト生成失敗 ($type): $e');
          }
        }
      }
    }
    
    return newQuests;
  }
  
  // クエスト完了処理
  Future<Quest> completeQuest(String questId, Map<String, dynamic> completionData) async {
    final quest = await _repository.getById(questId);
    if (quest == null) {
      throw QuestNotFoundException('クエストが見つかりません');
    }
    
    if (quest.status != QuestStatus.inProgress) {
      throw InvalidQuestStateException('クエストが進行中ではありません');
    }
    
    final completedQuest = quest.copyWith(
      status: QuestStatus.completed,
      completedAt: DateTime.now(),
    );
    
    await _repository.update(completedQuest);
    
    // ユーザーにXPを付与
    await _userService.updateProgress(
      completionData['userId'] as String,
      ProgressUpdate(xpGained: quest.xpReward, questsCompleted: 1),
    );
    
    return completedQuest;
  }
}
```

---

## 4. データベース層

### 4.1 リポジトリパターン実装

```dart
// 基底リポジトリインターフェース
abstract class IRepository<T, ID> {
  Future<T?> getById(ID id);
  Future<List<T>> getAll();
  Future<T> create(T entity);
  Future<T> update(T entity);
  Future<void> delete(ID id);
}

// 単語リポジトリインターフェース
abstract class IVocabularyRepository extends IRepository<VocabularyWord, String> {
  Future<List<VocabularyWord>> getByUserId(String userId);
  Future<List<VocabularyWord>> getWordsForReview(String userId, DateTime date);
  Future<List<VocabularyWord>> searchWords(String userId, String searchTerm);
}

// Firestoreリポジトリ実装
class FirestoreVocabularyRepository implements IVocabularyRepository {
  FirestoreVocabularyRepository(this._firestore);
  
  final FirebaseFirestore _firestore;
  static const String _collection = 'vocabulary';
  
  @override
  Future<VocabularyWord?> getById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;
      
      return VocabularyWord.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      throw RepositoryException('単語取得に失敗しました: $e');
    }
  }
  
  @override
  Future<List<VocabularyWord>> getByUserId(String userId) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return query.docs.map((doc) => VocabularyWord.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e) {
      throw RepositoryException('ユーザー単語取得に失敗しました: $e');
    }
  }
  
  @override
  Future<List<VocabularyWord>> getWordsForReview(String userId, DateTime date) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('reviewData.nextReviewDate', isLessThanOrEqualTo: Timestamp.fromDate(date))
          .orderBy('reviewData.nextReviewDate')
          .get();
      
      return query.docs.map((doc) => VocabularyWord.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e) {
      throw RepositoryException('復習対象単語取得に失敗しました: $e');
    }
  }
  
  @override
  Future<VocabularyWord> create(VocabularyWord word) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
        word.toJson()..remove('id'),
      );
      
      return word.copyWith(id: docRef.id);
    } catch (e) {
      throw RepositoryException('単語作成に失敗しました: $e');
    }
  }
  
  @override
  Future<VocabularyWord> update(VocabularyWord word) async {
    try {
      await _firestore.collection(_collection).doc(word.id).update(
        word.toJson()..remove('id'),
      );
      
      return word;
    } catch (e) {
      throw RepositoryException('単語更新に失敗しました: $e');
    }
  }
  
  @override
  Future<void> delete(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw RepositoryException('単語削除に失敗しました: $e');
    }
  }
  
  @override
  Future<List<VocabularyWord>> searchWords(
    String userId,
    String searchTerm,
  ) async {
    try {
      // Firestoreは全文検索をネイティブサポートしていないため、
      // 簡略化された実装
      final query = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('word', isGreaterThanOrEqualTo: searchTerm)
          .where('word', isLessThan: searchTerm + '\uf8ff')
          .get();
      
      return query.docs.map((doc) => VocabularyWord.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e) {
      throw RepositoryException('単語検索に失敗しました: $e');
    }
  }
}
```

### 4.2 データベースマイグレーション戦略

```dart
// データベースマイグレーション管理
class DatabaseMigrationService {
  DatabaseMigrationService(this._firestore);
  
  final FirebaseFirestore _firestore;
  static const String _migrationsCollection = 'migrations';
  
  // マイグレーション実行
  Future<void> runMigrations() async {
    final appliedMigrations = await _getAppliedMigrations();
    final availableMigrations = _getAvailableMigrations();
    
    for (final migration in availableMigrations) {
      if (!appliedMigrations.contains(migration.version)) {
        await _runMigration(migration);
        await _recordMigration(migration);
      }
    }
  }
  
  // 利用可能なマイグレーション定義
  List<DatabaseMigration> _getAvailableMigrations() {
    return [
      DatabaseMigration(
        version: '1.0.0',
        description: '初期スキーマ設定',
        migrationFunction: _migration_1_0_0,
      ),
      DatabaseMigration(
        version: '1.1.0',
        description: '単語カテゴリフィールド追加',
        migrationFunction: _migration_1_1_0,
      ),
      DatabaseMigration(
        version: '1.2.0',
        description: '間隔反復データ構造更新',
        migrationFunction: _migration_1_2_0,
      ),
    ];
  }
  
  // 初期スキーママイグレーション
  Future<void> _migration_1_0_0() async {
    // 初期コレクション作成とインデックス設定
    await _createIndexes();
  }
  
  // カテゴリフィールド追加マイグレーション
  Future<void> _migration_1_1_0() async {
    final batch = _firestore.batch();
    
    final vocabularyQuery = await _firestore.collection('vocabulary').get();
    for (final doc in vocabularyQuery.docs) {
      if (!doc.data().containsKey('category')) {
        batch.update(doc.reference, {'category': 'general'});
      }
    }
    
    await batch.commit();
  }
  
  // インデックス作成
  Future<void> _createIndexes() async {
    // Firestoreインデックスは Firebase Console または firebase CLI で管理
    // ここではログ出力のみ
    print('データベースインデックスを作成しています...');
  }
}

// マイグレーション情報
class DatabaseMigration {
  const DatabaseMigration({
    required this.version,
    required this.description,
    required this.migrationFunction,
  });
  
  final String version;
  final String description;
  final Future<void> Function() migrationFunction;
}
```

---

## 5. API統合層

### 5.1 外部API統合設計

```dart
// OpenAI API統合サービス
class OpenAIService {
  OpenAIService(this._httpClient, this._apiKey);
  
  final http.Client _httpClient;
  final String _apiKey;
  static const String _baseUrl = 'https://api.openai.com/v1';
  
  // 自動要約生成
  Future<String> generateSummary(String articleText) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '技術記事の要点を3〜5行で簡潔にまとめてください。専門用語は適切に説明してください。',
            },
            {
              'role': 'user',
              'content': articleText,
            },
          ],
          'max_tokens': 500,
          'temperature': 0.3,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw OpenAIException('要約生成に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      throw OpenAIException('API呼び出しエラー: $e');
    }
  }
  
  // クイズ問題生成
  Future<List<QuizQuestion>> generateQuizQuestions(
    List<VocabularyWord> words,
    int questionCount,
  ) async {
    try {
      final wordsText = words.map((w) => '${w.word}: ${w.definition}').join('\n');
      
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '''
与えられた単語リストから${questionCount}問の選択式クイズを作成してください。
JSON形式で以下の構造で返してください：
{
  "questions": [
    {
      "question": "質問文",
      "options": ["選択肢A", "選択肢B", "選択肢C", "選択肢D"],
      "correct_answer": 0,
      "explanation": "解説"
    }
  ]
}
''',
            },
            {
              'role': 'user',
              'content': wordsText,
            },
          ],
          'max_tokens': 1000,
          'temperature': 0.5,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final quizData = jsonDecode(content);
        
        return (quizData['questions'] as List)
            .map((q) => QuizQuestion.fromJson(q))
            .toList();
      } else {
        throw OpenAIException('クイズ生成に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      throw OpenAIException('クイズ生成エラー: $e');
    }
  }
}

// クイズ問題モデル
@freezed
class QuizQuestion with _$QuizQuestion {
  const factory QuizQuestion({
    required String question,
    required List<String> options,
    required int correctAnswer,
    required String explanation,
  }) = _QuizQuestion;
  
  factory QuizQuestion.fromJson(Map<String, dynamic> json) => _$QuizQuestionFromJson(json);
}
```

### 5.2 Firebase Functions統合

```dart
// Firebase Functions呼び出しサービス
class FirebaseFunctionsService {
  FirebaseFunctionsService(this._functions);
  
  final FirebaseFunctions _functions;
  
  // ユーザー統計データ計算
  Future<UserStatistics> calculateUserStatistics(String userId) async {
    try {
      final callable = _functions.httpsCallable('calculateUserStatistics');
      final result = await callable.call({'userId': userId});
      
      return UserStatistics.fromJson(result.data);
    } catch (e) {
      throw FunctionsException('統計計算に失敗しました: $e');
    }
  }
  
  // 日次レポート生成
  Future<DailyReport> generateDailyReport(String userId, DateTime date) async {
    try {
      final callable = _functions.httpsCallable('generateDailyReport');
      final result = await callable.call({
        'userId': userId,
        'date': date.toIso8601String(),
      });
      
      return DailyReport.fromJson(result.data);
    } catch (e) {
      throw FunctionsException('日次レポート生成に失敗しました: $e');
    }
  }
}
```

---

## 6. テスト戦略

### 6.1 ユニットテスト

```dart
// 間隔反復エンジンのテスト例
void main() {
  group('SpacedRepetitionEngine', () {
    late SpacedRepetitionEngine engine;
    
    setUp(() {
      engine = SpacedRepetitionEngine();
    });
    
    test('正解時に適切な間隔で次回復習日を計算する', () {
      // Arrange
      final reviewData = VocabularyReviewData(
        reviewCount: 3,
        retentionScore: 0.7,
        lastReviewed: DateTime.now().subtract(const Duration(days: 5)),
        nextReviewDate: DateTime.now(),
        spacedRepetition: const SpacedRepetitionData(
          intervalDays: 5,
          easinessFactor: 2.0,
        ),
      );
      
      // Act
      final result = engine.calculateNextReview(reviewData, ReviewPerformance.good);
      
      // Assert
      expect(result.reviewCount, equals(4));
      expect(result.retentionScore, equals(0.7)); // goodの場合変化なし
      expect(result.spacedRepetition.intervalDays, greaterThan(5));
      expect(result.nextReviewDate.isAfter(DateTime.now()), isTrue);
    });
    
    test('不正解時に間隔をリセットする', () {
      // Arrange
      final reviewData = VocabularyReviewData(
        reviewCount: 5,
        retentionScore: 0.8,
        lastReviewed: DateTime.now().subtract(const Duration(days: 10)),
        nextReviewDate: DateTime.now(),
        spacedRepetition: const SpacedRepetitionData(
          intervalDays: 10,
          easinessFactor: 2.2,
        ),
      );
      
      // Act
      final result = engine.calculateNextReview(reviewData, ReviewPerformance.failed);
      
      // Assert
      expect(result.retentionScore, lessThan(0.8));
      expect(result.spacedRepetition.intervalDays, lessThan(10));
      expect(result.spacedRepetition.easinessFactor, lessThan(2.2));
    });
  });
}

// 単語サービスのテスト例
void main() {
  group('VocabularyService', () {
    late VocabularyService service;
    late MockVocabularyRepository mockRepository;
    
    setUp(() {
      mockRepository = MockVocabularyRepository();
      service = VocabularyService(mockRepository);
    });
    
    test('復習完了時に単語データが適切に更新される', () async {
      // Arrange
      final word = VocabularyWord(
        id: 'test-word-1',
        userId: 'test-user',
        word: 'algorithm',
        definition: 'A process or set of rules',
        example: 'The sorting algorithm is efficient',
        pronunciation: '/ˈælɡərɪðəm/',
        category: 'computer-science',
        tags: ['programming', 'data-structure'],
        createdAt: DateTime.now(),
        reviewData: VocabularyReviewData(
          reviewCount: 2,
          retentionScore: 0.6,
          lastReviewed: DateTime.now().subtract(const Duration(days: 3)),
          nextReviewDate: DateTime.now(),
          spacedRepetition: const SpacedRepetitionData(
            intervalDays: 3,
            easinessFactor: 1.8,
          ),
        ),
      );
      
      when(mockRepository.getById('test-word-1')).thenAnswer((_) async => word);
      when(mockRepository.update(any)).thenAnswer((invocation) async => invocation.positionalArguments[0]);
      
      // Act
      final result = await service.completeReview('test-word-1', ReviewPerformance.good);
      
      // Assert
      expect(result.reviewData.reviewCount, equals(3));
      expect(result.reviewData.lastReviewed.day, equals(DateTime.now().day));
      verify(mockRepository.getById('test-word-1')).called(1);
      verify(mockRepository.update(any)).called(1);
    });
  });
}
```

### 6.2 統合テスト

```dart
// クエスト完了フローの統合テスト例
void main() {
  group('クエスト完了統合', () {
    late QuestManagementService questService;
    late UserService userService;
    late VocabularyService vocabularyService;
    
    setUpAll(() async {
      // 実際のFirebaseエミュレーターでテスト環境をセットアップ
      await Firebase.initializeApp();
      // テストリポジトリでサービスを設定
    });
    
    tearDownAll(() async {
      // テストデータをクリーンアップ
    });
    
    test('語彙復習クエスト完了でユーザーにXPが付与される', () async {
      // Arrange
      final userId = 'test-user-integration';
      final user = await userService.create(User(
        id: userId,
        email: 'test@example.com',
        username: 'testuser',
        createdAt: DateTime.now(),
        profile: UserProfile(
          displayName: 'テストユーザー',
          learningGoals: ['vocabulary'],
          preferences: LearningPreferences.defaultPreferences(),
        ),
        progress: UserProgress(
          totalXp: 100,
          currentLevel: 1,
          learningStreak: 1,
          vocabularyCount: 5,
          questsCompleted: 0,
          lastActivityDate: DateTime.now(),
        ),
      ));
      
      // 復習用語彙を作成
      for (int i = 0; i < 5; i++) {
        await vocabularyService.create(VocabularyWord(
          id: 'word-$i',
          userId: userId,
          word: 'testword$i',
          definition: 'Test definition $i',
          example: 'Test example $i',
          pronunciation: '/test$i/',
          category: 'test',
          tags: ['test'],
          createdAt: DateTime.now().subtract(Duration(days: i + 1)),
          reviewData: VocabularyReviewData(
            reviewCount: 1,
            retentionScore: 0.5,
            lastReviewed: DateTime.now().subtract(Duration(days: i + 2)),
            nextReviewDate: DateTime.now().subtract(const Duration(hours: 1)),
            spacedRepetition: const SpacedRepetitionData(
              intervalDays: 1,
              easinessFactor: 1.5,
            ),
          ),
        ));
      }
      
      // 日次クエストを生成
      final quests = await questService.generateDailyQuests(userId);
      final vocabularyQuest = quests.firstWhere(
        (q) => q.type == QuestType.vocabularyReview,
      );
      
      // Act
      final completedQuest = await questService.completeQuest(
        vocabularyQuest.id,
        {'reviewedWords': 5},
      );
      
      // Assert
      expect(completedQuest.status, equals(QuestStatus.completed));
      expect(completedQuest.completedAt, isNotNull);
      
      final updatedUser = await userService.getById(userId);
      expect(updatedUser?.progress.totalXp, greaterThan(100));
      expect(updatedUser?.progress.questsCompleted, equals(1));
    });
  });
}
```

### 6.3 ウィジェットテスト

```dart
// 単語カードウィジェットのテスト例
void main() {
  group('VocabularyCard Widget', () {
    testWidgets('単語カードが正しく表示される', (WidgetTester tester) async {
      // Arrange
      final word = VocabularyWord(
        id: 'test-word',
        userId: 'test-user',
        word: 'algorithm',
        definition: 'A process or set of rules',
        example: 'The sorting algorithm is efficient',
        pronunciation: '/ˈælɡərɪðəm/',
        category: 'computer-science',
        tags: ['programming'],
        createdAt: DateTime.now(),
        reviewData: VocabularyReviewData(
          reviewCount: 1,
          retentionScore: 0.5,
          lastReviewed: DateTime.now().subtract(const Duration(days: 1)),
          nextReviewDate: DateTime.now().add(const Duration(days: 1)),
          spacedRepetition: const SpacedRepetitionData(
            intervalDays: 2,
            easinessFactor: 1.5,
          ),
        ),
      );
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VocabularyCard(
              word: word,
              onReviewComplete: (performance) {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('algorithm'), findsOneWidget);
      expect(find.text('A process or set of rules'), findsOneWidget);
      expect(find.text('/ˈælɡərɪðəm/'), findsOneWidget);
      
      // カードタップでフリップ
      await tester.tap(find.byType(VocabularyCard));
      await tester.pumpAndSettle();
      
      expect(find.text('The sorting algorithm is efficient'), findsOneWidget);
    });
    
    testWidgets('復習ボタンが機能する', (WidgetTester tester) async {
      // Arrange
      bool reviewCompleted = false;
      ReviewPerformance? performance;
      
      final word = VocabularyWord(/* ... */);
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VocabularyCard(
              word: word,
              onReviewComplete: (p) {
                reviewCompleted = true;
                performance = p;
              },
            ),
          ),
        ),
      );
      
      // 'Good'ボタンをタップ
      await tester.tap(find.text('適切'));
      await tester.pump();
      
      // Assert
      expect(reviewCompleted, isTrue);
      expect(performance, equals(ReviewPerformance.good));
    });
  });
}
```

---

## バージョン履歴

| バージョン | 日付 | 作成者 | 変更内容 |
|---------|------|-----------|---------|
| 1.0 | 2025-08-29 | GitHub Copilot Agent | 初期低水準設計ドキュメント |
| 2.0 | 2025-09-01 | GitHub Copilot Agent | 包括的なLLD設計書完成 |

---

*このドキュメントは高水準設計書と要件定義書に基づいて作成され、システム実装の詳細指針となる技術設計文書です。*

*このドキュメントは高水準設計書と要件定義書に基づいて作成され、システム実装の詳細指針となる技術設計文書です。*