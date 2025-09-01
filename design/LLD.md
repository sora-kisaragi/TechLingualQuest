---
author: "GitHub Copilot Agent"
date: "2025-08-29"
version: "1.0"
related_issues: ["#10", "#5"]
related_docs: ["HLD.md", "../requirements/system-requirements.md", "../requirements/user-requirements.md"]
---

# 低水準設計書（LLD）- TechLingual Quest

このドキュメントでは、TechLingual Quest アプリケーションの詳細な技術設計、クラス構造、アルゴリズム、実装仕様を提供します。

## 関連ドキュメント
- [高水準設計書](HLD.md) - システムアーキテクチャ概要
- [システム要件](../requirements/system-requirements.md) - 技術システム要件
- [ユーザー要件](../requirements/user-requirements.md) - ユーザーストーリーと機能要件

---

## 1. フロントエンドアーキテクチャ（Flutter）

### 1.1 プロジェクト構造

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router/
│   └── theme/
├── core/
│   ├── constants/
│   ├── utils/
│   ├── services/
│   └── errors/
├── features/
│   ├── auth/
│   ├── vocabulary/
│   ├── quests/
│   ├── summaries/
│   ├── dashboard/
│   └── profile/
└── shared/
    ├── widgets/
    ├── models/
    └── providers/
```

### 1.2 コアクラスとインターフェース

#### 1.2.1 状態管理（Riverpod）

```dart
// コアプロバイダー基底クラス
abstract class BaseNotifier<T> extends StateNotifier<AsyncValue<T>> {
  BaseNotifier() : super(const AsyncValue.loading());
  
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
  
  Future<void> getCurrentUser() async {
    await execute(() => _userService.getCurrentUser());
  }
  
  Future<void> updateProfile(UserProfile profile) async {
    await execute(() => _userService.updateProfile(profile));
  }
}
```

#### 1.2.2 モデルクラス

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

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String displayName,
    String? avatarUrl,
    required List<String> learningGoals,
    required LearningPreferences preferences,
  }) = _UserProfile;
  
  factory UserProfile.fromJson(Map<String, dynamic> json) => 
      _$UserProfileFromJson(json);
}

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
  
  factory UserProgress.fromJson(Map<String, dynamic> json) => 
      _$UserProgressFromJson(json);
}

// 語彙モデル
@freezed
class VocabularyWord with _$VocabularyWord {
  const factory VocabularyWord({
    required String id,
    required String word,
    required String definition,
    required String exampleSentence,
    required List<String> categories,
    required int difficultyLevel,
    required DateTime createdAt,
    required VocabularyReviewData reviewData,
  }) = _VocabularyWord;
  
  factory VocabularyWord.fromJson(Map<String, dynamic> json) => 
      _$VocabularyWordFromJson(json);
}

@freezed
class VocabularyReviewData with _$VocabularyReviewData {
  const factory VocabularyReviewData({
    required DateTime lastReviewed,
    required int reviewCount,
    required double retentionScore,
    required DateTime nextReviewDate,
    required SpacedRepetitionData spacedRepetition,
  }) = _VocabularyReviewData;
  
  factory VocabularyReviewData.fromJson(Map<String, dynamic> json) => 
      _$VocabularyReviewDataFromJson(json);
}

// クエストモデル
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
  }) = _Quest;
  
  factory Quest.fromJson(Map<String, dynamic> json) => _$QuestFromJson(json);
}

enum QuestType {
  vocabularyReview,    // 語彙復習
  vocabularyQuiz,      // 語彙クイズ
  articleSummary,      // 記事要約
  readingChallenge,    // 読解チャレンジ
  writingExercise,     // ライティング練習
  listeningPractice,   // リスニング練習
  speakingPractice,    // スピーキング練習
}

enum QuestStatus {
  available,    // 利用可能
  inProgress,   // 進行中
  completed,    // 完了
  expired,      // 期限切れ
}
```

#### 1.2.3 サービス層

```dart
// 抽象サービスインターフェース
abstract class IDataService<T, ID> {
  Future<T?> getById(ID id);
  Future<List<T>> getAll();
  Future<T> create(T entity);
  Future<T> update(T entity);
  Future<void> delete(ID id);
}

// ユーザーサービス実装
class UserService implements IDataService<User, String> {
  UserService(this._repository, this._authService);
  
  final IUserRepository _repository;
  final IAuthService _authService;
  
  @override
  Future<User?> getById(String id) async {
    try {
      return await _repository.getById(id);
    } on Exception catch (e) {
      throw UserServiceException('ユーザー取得に失敗しました: $e');
    }
  }
  
  Future<User> getCurrentUser() async {
    final authUser = await _authService.getCurrentUser();
    if (authUser == null) {
      throw UserNotAuthenticatedException();
    }
    return await getById(authUser.uid) ?? 
           throw UserNotFoundException('ユーザーが見つかりません');
  }
  
  Future<UserProgress> updateProgress(String userId, ProgressUpdate update) async {
    final user = await getById(userId);
    if (user == null) throw UserNotFoundException('ユーザーが見つかりません');
    
    final updatedProgress = _calculateProgressUpdate(user.progress, update);
    final updatedUser = user.copyWith(progress: updatedProgress);
    
    await update(updatedUser);
    return updatedProgress;
  }
  
  UserProgress _calculateProgressUpdate(UserProgress current, ProgressUpdate update) {
    return current.copyWith(
      totalXp: current.totalXp + update.xpGained,
      currentLevel: _calculateLevel(current.totalXp + update.xpGained),
      learningStreak: _updateStreak(current, update),
      vocabularyCount: current.vocabularyCount + update.vocabularyAdded,
      questsCompleted: current.questsCompleted + update.questsCompleted,
      lastActivityDate: DateTime.now(),
    );
  }
  
  int _calculateLevel(int totalXp) {
    // レベル計算：level = floor(sqrt(totalXp / 100))
    return (sqrt(totalXp / 100)).floor();
  }
  
  int _updateStreak(UserProgress current, ProgressUpdate update) {
    final lastActivity = current.lastActivityDate;
    final now = DateTime.now();
    final daysSinceLastActivity = now.difference(lastActivity).inDays;
    
    if (daysSinceLastActivity <= 1) {
      return current.learningStreak + 1;
    } else {
      return 1; // ストリークをリセット
    }
  }
}

// 語彙サービス実装
class VocabularyService implements IDataService<VocabularyWord, String> {
  VocabularyService(this._repository, this._spacedRepetitionEngine);
  
  final IVocabularyRepository _repository;
  final SpacedRepetitionEngine _spacedRepetitionEngine;
  
  Future<List<VocabularyWord>> getWordsForReview(String userId) async {
    final allWords = await _repository.getByUserId(userId);
    final now = DateTime.now();
    
    return allWords.where((word) => 
        word.reviewData.nextReviewDate.isBefore(now) ||
        word.reviewData.nextReviewDate.isAtSameMomentAs(now)
    ).toList();
  }
  
  Future<VocabularyWord> recordReview(
    String wordId, 
    ReviewPerformance performance
  ) async {
    final word = await getById(wordId);
    if (word == null) throw VocabularyNotFoundException('単語が見つかりません');
    
    final updatedReviewData = _spacedRepetitionEngine.calculateNextReview(
      word.reviewData,
      performance,
    );
    
    final updatedWord = word.copyWith(reviewData: updatedReviewData);
    return await update(updatedWord);
  }
  
  Future<List<VocabularyQuizQuestion>> generateQuiz(
    String userId,
    {int questionCount = 10}
  ) async {
    final words = await _repository.getByUserId(userId);
    final selectedWords = _selectWordsForQuiz(words, questionCount);
    
    return selectedWords.map((word) => VocabularyQuizQuestion(
      id: const Uuid().v4(),
      word: word,
      questionType: _selectQuestionType(word),
      options: _generateOptions(word),
    )).toList();
  }
  
  List<VocabularyWord> _selectWordsForQuiz(
    List<VocabularyWord> words, 
    int count
  ) {
    // 復習が必要な単語と定着度の低い単語を優先
    final sortedWords = words..sort((a, b) {
      final aScore = a.reviewData.retentionScore;
      final bScore = b.reviewData.retentionScore;
      return aScore.compareTo(bScore);
    });
    
    return sortedWords.take(count).toList();
  }
}
```

---

## 2. 間隔反復アルゴリズム

### 2.1 アルゴリズム実装

```dart
class SpacedRepetitionEngine {
  static const double _easyBonus = 1.3;
  static const double _hardPenalty = 0.6;
  static const int _minimumInterval = 1;
  static const int _maximumInterval = 365;
  
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
        adjustment = 0.1;
        break;
      case ReviewPerformance.easy:
        adjustment = 0.2;
        break;
    }
    
    // Weight adjustment based on review count (newer words have more volatile scores)
    final weight = min(1.0, reviewCount / 10.0);
    final weightedAdjustment = adjustment * weight;
    
    return (currentScore + weightedAdjustment).clamp(0.0, 1.0);
  }
  
  int _calculateInterval(
    int currentInterval,
    ReviewPerformance performance,
    double retentionScore,
  ) {
    double multiplier;
    switch (performance) {
      case ReviewPerformance.failed:
        multiplier = 0.5;
        break;
      case ReviewPerformance.hard:
        multiplier = _hardPenalty;
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
    
    return (currentFactor + adjustment).clamp(1.3, 2.5);
  }
}

enum ReviewPerformance {
  failed,   // 0 - 完全に思い出せない
  hard,     // 1 - かなり困難に思い出した
  good,     // 2 - 多少困難に思い出した
  easy,     // 3 - 簡単に思い出した
}

@freezed
class SpacedRepetitionData with _$SpacedRepetitionData {
  const factory SpacedRepetitionData({
    required int intervalDays,
    required double easinessFactor,
    required int repetitionNumber,
  }) = _SpacedRepetitionData;
  
  factory SpacedRepetitionData.initial() => const SpacedRepetitionData(
    intervalDays: 1,
    easinessFactor: 2.5,
    repetitionNumber: 0,
  );
  
  factory SpacedRepetitionData.fromJson(Map<String, dynamic> json) => 
      _$SpacedRepetitionDataFromJson(json);
}
```

---

## 3. クエスト生成システム

### 3.1 クエスト生成エンジン

```dart
abstract class QuestGenerator {
  List<QuestType> get supportedTypes;
  Future<Quest> generateQuest(String userId, QuestType type);
  bool canGenerateQuest(String userId, QuestType type);
}

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
        throw UnsupportedQuestTypeException('Unsupported quest type: $type');
    }
  }
  
  @override
  bool canGenerateQuest(String userId, QuestType type) {
    // ユーザーが十分な語彙数を持ち、最近同様のクエストを完了していないかチェック
    return true; // 例として簡略化
  }
  
  Future<Quest> _generateReviewQuest(String userId) async {
    final wordsToReview = await _vocabularyService.getWordsForReview(userId);
    final reviewCount = min(10, wordsToReview.length);
    
    return Quest(
      id: const Uuid().v4(),
      type: QuestType.vocabularyReview,
      title: '日次語彙復習',
      description: '学習ストリークを維持するために$reviewCount個の語彙を復習しましょう',
      questData: {
        'targetReviewCount': reviewCount,
        'wordIds': wordsToReview.take(reviewCount).map((w) => w.id).toList(),
      },
      status: QuestStatus.available,
      xpReward: _calculateXpReward(reviewCount),
      createdAt: DateTime.now(),
    );
  }
  
  Future<Quest> _generateQuizQuest(String userId) async {
    final user = await _userService.getById(userId);
    final difficulty = _calculateQuizDifficulty(user?.progress.currentLevel ?? 1);
    
    return Quest(
      id: const Uuid().v4(),
      type: QuestType.vocabularyQuiz,
      title: '語彙チャレンジ',
      description: '$difficulty難易度の語彙クイズで知識をテストしましょう',
      questData: {
        'questionCount': 10,
        'difficulty': difficulty,
        'timeLimit': 300, // 5分
      },
      status: QuestStatus.available,
      xpReward: _calculateXpReward(10, difficulty: difficulty),
      createdAt: DateTime.now(),
    );
  }
  
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
  
  String _calculateQuizDifficulty(int userLevel) {
    if (userLevel < 5) return 'easy';      // 簡単
    if (userLevel < 15) return 'normal';   // 普通
    return 'hard';                         // 難しい
  }
}

class QuestManagementService {
  QuestManagementService(this._repository, this._generators);
  
  final IQuestRepository _repository;
  final List<QuestGenerator> _generators;
  
  Future<List<Quest>> generateDailyQuests(String userId) async {
    final existingQuests = await _repository.getTodaysQuests(userId);
    if (existingQuests.isNotEmpty) {
      return existingQuests;
    }
    
    final newQuests = <Quest>[];
    
    // 可能であれば各タイプのクエストを1つずつ生成
    for (final generator in _generators) {
      for (final type in generator.supportedTypes) {
        if (generator.canGenerateQuest(userId, type) && newQuests.length < 3) {
          try {
            final quest = await generator.generateQuest(userId, type);
            newQuests.add(quest);
            await _repository.create(quest);
          } catch (e) {
            // エラーをログに記録するが、他のクエスト生成は継続
            print('タイプ $type のクエスト生成に失敗: $e');
          }
        }
      }
    }
    
    return newQuests;
  }
  
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
      quest.questData['userId'] as String,
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
// 抽象リポジトリインターフェース
abstract class IRepository<T, ID> {
  Future<T?> getById(ID id);
  Future<List<T>> getAll();
  Future<T> create(T entity);
  Future<T> update(T entity);
  Future<void> delete(ID id);
}

// Firestore リポジトリ実装
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
      throw RepositoryException('語彙の取得に失敗しました: $e');
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
      throw RepositoryException('ユーザー語彙の取得に失敗しました: $e');
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
      throw RepositoryException('語彙の作成に失敗しました: $e');
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
      throw RepositoryException('語彙の更新に失敗しました: $e');
    }
  }
  
  @override
  Future<void> delete(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw RepositoryException('語彙の削除に失敗しました: $e');
    }
  }
  
  Future<List<VocabularyWord>> searchWords(
    String userId,
    String searchTerm,
  ) async {
    try {
      // Firestoreはネイティブな全文検索をサポートしていません
      // これは簡略化された実装です
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
      throw RepositoryException('語彙検索に失敗しました: $e');
    }
  }
}
```

### 4.2 データベースマイグレーション戦略

```dart
class DatabaseMigrationService {
  DatabaseMigrationService(this._firestore);
  
  final FirebaseFirestore _firestore;
  static const String _migrationsCollection = 'migrations';
  
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
  
  List<DatabaseMigration> _getAvailableMigrations() {
    return [
      DatabaseMigration(
        version: '1.0.0',
        description: '初期スキーマセットアップ',
        migrationFunction: _migration_1_0_0,
      ),
      DatabaseMigration(
        version: '1.1.0',
        description: '語彙に間隔反復データを追加',
        migrationFunction: _migration_1_1_0,
      ),
      // 必要に応じて更多のマイグレーションを追加
    ];
  }
  
  Future<void> _migration_1_0_0() async {
    // 初期スキーマセットアップ - 通常はアプリ初期化時に処理
    print('初期スキーマセットアップを実行中');
  }
  
  Future<void> _migration_1_1_0() async {
    // 既存の語彙に間隔反復データを追加
    final vocabularyQuery = await _firestore.collection('vocabulary').get();
    
    for (final doc in vocabularyQuery.docs) {
      final data = doc.data();
      if (!data.containsKey('reviewData')) {
        await doc.reference.update({
          'reviewData': {
            'lastReviewed': FieldValue.serverTimestamp(),
            'reviewCount': 0,
            'retentionScore': 0.5,
            'nextReviewDate': FieldValue.serverTimestamp(),
            'spacedRepetition': {
              'intervalDays': 1,
              'easinessFactor': 2.5,
              'repetitionNumber': 0,
            },
          },
        });
      }
    }
  }
  
  Future<List<String>> _getAppliedMigrations() async {
    final query = await _firestore.collection(_migrationsCollection).get();
    return query.docs.map((doc) => doc.data()['version'] as String).toList();
  }
  
  Future<void> _runMigration(DatabaseMigration migration) async {
    try {
      await migration.migrationFunction();
      print('マイグレーション成功: ${migration.version}');
    } catch (e) {
      throw MigrationException('マイグレーション ${migration.version} の実行に失敗: $e');
    }
  }
  
  Future<void> _recordMigration(DatabaseMigration migration) async {
    await _firestore.collection(_migrationsCollection).add({
      'version': migration.version,
      'description': migration.description,
      'appliedAt': FieldValue.serverTimestamp(),
    });
  }
}

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

### 5.1 OpenAI API統合

```dart
class OpenAIService {
  OpenAIService(this._httpClient, this._apiKey);
  
  final http.Client _httpClient;
  final String _apiKey;
  
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);
  
  Future<String> generateVocabularyDefinition(String word) async {
    final prompt = '''
    技術英語を学習している人にとって役立つ技術用語「$word」の明確で簡潔な定義を提供してください。
    以下を含めてください：
    1. 簡潔な定義（1-2文）
    2. 技術的文脈での単語を使用した例文
    
    レスポンスをJSONフォーマットで：
    {
      "definition": "...",
      "example": "..."
    }
    ''';
    
    final response = await _makeRequest(
      endpoint: '/chat/completions',
      payload: {
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 200,
        'temperature': 0.3,
      },
    );
    
    final content = response['choices'][0]['message']['content'] as String;
    final jsonData = json.decode(content);
    
    return jsonData['definition'] as String;
  }
  
  Future<List<VocabularyQuizQuestion>> generateQuizQuestions(
    List<VocabularyWord> words,
  ) async {
    final wordList = words.map((w) => '${w.word}: ${w.definition}').join('\n');
    
    final prompt = '''
    これらの語彙のための多肢選択クイズ問題を生成してください：
    
    $wordList
    
    各単語について、定義の理解をテストする問題を作成してください。
    4つの選択肢（A、B、C、D）を提供し、正解は1つだけです。
    
    JSON配列でフォーマット：
    [
      {
        "word": "example",
        "question": "'example'の意味は何ですか？",
        "options": ["選択肢A", "選択肢B", "選択肢C", "選択肢D"],
        "correctAnswer": 0
      }
    ]
    ''';
    
    final response = await _makeRequest(
      endpoint: '/chat/completions',
      payload: {
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 1000,
        'temperature': 0.3,
      },
    );
    
    final content = response['choices'][0]['message']['content'] as String;
    final List<dynamic> questionsData = json.decode(content);
    
    return questionsData.map((data) => VocabularyQuizQuestion.fromJson(data)).toList();
  }
  
  Future<Map<String, dynamic>> _makeRequest({
    required String endpoint,
    required Map<String, dynamic> payload,
  }) async {
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final response = await _httpClient.post(
          Uri.parse('$_baseUrl$endpoint'),
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          body: json.encode(payload),
        );
        
        if (response.statusCode == 200) {
          return json.decode(response.body) as Map<String, dynamic>;
        } else if (response.statusCode == 429) {
          // レート制限、待機してリトライ
          if (attempt < _maxRetries - 1) {
            await Future.delayed(_retryDelay * (attempt + 1));
            continue;
          }
        }
        
        throw OpenAIException(
          'APIリクエストが失敗しました: ${response.statusCode} ${response.body}',
        );
      } catch (e) {
        if (attempt == _maxRetries - 1) rethrow;
        await Future.delayed(_retryDelay);
      }
    }
    
    throw OpenAIException('$_maxRetries回の試行後、リクエストに失敗しました');
  }
}

// APIレスポンスキャッシュ
class CachedOpenAIService extends OpenAIService {
  CachedOpenAIService(
    super.httpClient,
    super.apiKey,
    this._cacheService,
  );
  
  final CacheService _cacheService;
  
  @override
  Future<String> generateVocabularyDefinition(String word) async {
    final cacheKey = 'definition_$word';
    final cached = await _cacheService.get(cacheKey);
    
    if (cached != null) {
      return cached as String;
    }
    
    final result = await super.generateVocabularyDefinition(word);
    await _cacheService.set(cacheKey, result, Duration(hours: 24));
    
    return result;
  }
}
```

---

## 6. テスト戦略

### 6.1 ユニットテスト

```dart
// VocabularyService のユニットテスト例
class MockVocabularyRepository extends Mock implements IVocabularyRepository {}
class MockSpacedRepetitionEngine extends Mock implements SpacedRepetitionEngine {}

void main() {
  group('VocabularyService', () {
    late VocabularyService service;
    late MockVocabularyRepository mockRepository;
    late MockSpacedRepetitionEngine mockEngine;
    
    setUp(() {
      mockRepository = MockVocabularyRepository();
      mockEngine = MockSpacedRepetitionEngine();
      service = VocabularyService(mockRepository, mockEngine);
    });
    
    group('getWordsForReview', () {
      test('復習期限の単語を返す', () async {
        // Arrange
        final userId = 'test-user';
        final now = DateTime.now();
        final dueWord = VocabularyWord(
          id: '1',
          word: 'test',
          definition: 'テスト定義',
          exampleSentence: 'テスト例文',
          categories: ['test'],
          difficultyLevel: 1,
          createdAt: now,
          reviewData: VocabularyReviewData(
            lastReviewed: now.subtract(Duration(days: 2)),
            reviewCount: 1,
            retentionScore: 0.5,
            nextReviewDate: now.subtract(Duration(hours: 1)), // 期限切れ
            spacedRepetition: SpacedRepetitionData.initial(),
          ),
        );
        
        when(mockRepository.getByUserId(userId))
            .thenAnswer((_) async => [dueWord]);
        
        // Act
        final result = await service.getWordsForReview(userId);
        
        // Assert
        expect(result, hasLength(1));
        expect(result.first.id, equals('1'));
        verify(mockRepository.getByUserId(userId)).called(1);
      });
    });
    
    group('recordReview', () {
      test('新しい復習データで単語を更新', () async {
        // Arrange
        final wordId = 'test-word';
        final word = VocabularyWord(
          id: wordId,
          word: 'test',
          definition: 'テスト定義',
          exampleSentence: 'テスト例文',
          categories: ['test'],
          difficultyLevel: 1,
          createdAt: DateTime.now(),
          reviewData: VocabularyReviewData(
            lastReviewed: DateTime.now().subtract(Duration(days: 1)),
            reviewCount: 1,
            retentionScore: 0.5,
            nextReviewDate: DateTime.now(),
            spacedRepetition: SpacedRepetitionData.initial(),
          ),
        );
        
        final updatedReviewData = word.reviewData.copyWith(
          reviewCount: 2,
          retentionScore: 0.7,
        );
        
        when(mockRepository.getById(wordId))
            .thenAnswer((_) async => word);
        when(mockEngine.calculateNextReview(any, any))
            .thenReturn(updatedReviewData);
        when(mockRepository.update(any))
            .thenAnswer((invocation) async => invocation.positionalArguments[0]);
        
        // Act
        final result = await service.recordReview(
          wordId,
          ReviewPerformance.good,
        );
        
        // Assert
        expect(result.reviewData.reviewCount, equals(2));
        expect(result.reviewData.retentionScore, equals(0.7));
        verify(mockRepository.getById(wordId)).called(1);
        verify(mockEngine.calculateNextReview(any, ReviewPerformance.good)).called(1);
        verify(mockRepository.update(any)).called(1);
      });
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
          word: 'test-word-$i',
          definition: '定義 $i',
          exampleSentence: '例文 $i',
          categories: ['test'],
          difficultyLevel: 1,
          createdAt: DateTime.now(),
          reviewData: VocabularyReviewData(
            lastReviewed: DateTime.now().subtract(Duration(days: 1)),
            reviewCount: 0,
            retentionScore: 0.5,
            nextReviewDate: DateTime.now().subtract(Duration(hours: 1)),
            spacedRepetition: SpacedRepetitionData.initial(),
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

---

## バージョン履歴

| バージョン | 日付 | 作成者 | 変更内容 |
|---------|------|--------|---------|
| 1.0 | 2025-08-29 | GitHub Copilot Agent | 初期低水準設計ドキュメント |