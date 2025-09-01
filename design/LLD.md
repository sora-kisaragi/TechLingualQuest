---
author: "GitHub Copilot Agent"
date: "2025-08-29"
version: "1.0"
related_issues: ["#10", "#5"]
related_docs: ["HLD.md", "../requirements/system-requirements.md", "../requirements/user-requirements.md", "../docs/development-tasks.md"]
---

# Low-Level Design (LLD) - TechLingual Quest

This document provides detailed technical design, class structures, algorithms, and implementation specifications for the TechLingual Quest application.

## Related Documents
- [High-Level Design](HLD.md) - System architecture overview
- [System Requirements](../requirements/system-requirements.md) - Technical system requirements
- [User Requirements](../requirements/user-requirements.md) - User stories and functional requirements
- [Development Tasks](../docs/development-tasks.md) - Implementation task breakdown

---

## 1. Frontend Architecture (Flutter)

### 1.1 Project Structure

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

### 1.2 Core Classes and Interfaces

#### 1.2.1 State Management (Riverpod)

```dart
// Core Provider Base Class
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

// User State Provider
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

#### 1.2.2 Model Classes

```dart
// User Models
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

// Vocabulary Models
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

// Quest Models
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
  vocabularyReview,
  vocabularyQuiz,
  articleSummary,
  readingChallenge,
  writingExercise,
  listeningPractice,
  speakingPractice,
}

enum QuestStatus {
  available,
  inProgress,
  completed,
  expired,
}
```

#### 1.2.3 Service Layer

```dart
// Abstract Service Interface
abstract class IDataService<T, ID> {
  Future<T?> getById(ID id);
  Future<List<T>> getAll();
  Future<T> create(T entity);
  Future<T> update(T entity);
  Future<void> delete(ID id);
}

// User Service Implementation
class UserService implements IDataService<User, String> {
  UserService(this._repository, this._authService);
  
  final IUserRepository _repository;
  final IAuthService _authService;
  
  @override
  Future<User?> getById(String id) async {
    try {
      return await _repository.getById(id);
    } on Exception catch (e) {
      throw UserServiceException('Failed to get user: $e');
    }
  }
  
  Future<User> getCurrentUser() async {
    final authUser = await _authService.getCurrentUser();
    if (authUser == null) {
      throw UserNotAuthenticatedException();
    }
    return await getById(authUser.uid) ?? 
           throw UserNotFoundException('User not found');
  }
  
  Future<UserProgress> updateProgress(String userId, ProgressUpdate update) async {
    final user = await getById(userId);
    if (user == null) throw UserNotFoundException('User not found');
    
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
    // Level calculation: level = floor(sqrt(totalXp / 100))
    return (sqrt(totalXp / 100)).floor();
  }
  
  int _updateStreak(UserProgress current, ProgressUpdate update) {
    final lastActivity = current.lastActivityDate;
    final now = DateTime.now();
    final daysSinceLastActivity = now.difference(lastActivity).inDays;
    
    if (daysSinceLastActivity <= 1) {
      return current.learningStreak + 1;
    } else {
      return 1; // Reset streak
    }
  }
}

// Vocabulary Service Implementation
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
    if (word == null) throw VocabularyNotFoundException('Word not found');
    
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
    // Prioritize words that need review and words with lower retention scores
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

## 2. Spaced Repetition Algorithm

### 2.1 Algorithm Implementation

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
  failed,   // 0 - Complete failure to recall
  hard,     // 1 - Recalled with significant difficulty
  good,     // 2 - Recalled with some difficulty
  easy,     // 3 - Recalled easily
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

## 3. Quest Generation System

### 3.1 Quest Generation Engine

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
    // Implementation would check if user has enough vocabulary words
    // and hasn't completed similar quest recently
    return true; // Simplified for example
  }
  
  Future<Quest> _generateReviewQuest(String userId) async {
    final wordsToReview = await _vocabularyService.getWordsForReview(userId);
    final reviewCount = min(10, wordsToReview.length);
    
    return Quest(
      id: const Uuid().v4(),
      type: QuestType.vocabularyReview,
      title: 'Daily Vocabulary Review',
      description: 'Review $reviewCount vocabulary words to maintain your learning streak',
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
      title: 'Vocabulary Challenge',
      description: 'Test your knowledge with a $difficulty vocabulary quiz',
      questData: {
        'questionCount': 10,
        'difficulty': difficulty,
        'timeLimit': 300, // 5 minutes
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
    if (userLevel < 5) return 'easy';
    if (userLevel < 15) return 'normal';
    return 'hard';
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
    
    // Generate one quest of each type if possible
    for (final generator in _generators) {
      for (final type in generator.supportedTypes) {
        if (generator.canGenerateQuest(userId, type) && newQuests.length < 3) {
          try {
            final quest = await generator.generateQuest(userId, type);
            newQuests.add(quest);
            await _repository.create(quest);
          } catch (e) {
            // Log error but continue generating other quests
            print('Failed to generate quest of type $type: $e');
          }
        }
      }
    }
    
    return newQuests;
  }
  
  Future<Quest> completeQuest(String questId, Map<String, dynamic> completionData) async {
    final quest = await _repository.getById(questId);
    if (quest == null) {
      throw QuestNotFoundException('Quest not found');
    }
    
    if (quest.status != QuestStatus.inProgress) {
      throw InvalidQuestStateException('Quest is not in progress');
    }
    
    final completedQuest = quest.copyWith(
      status: QuestStatus.completed,
      completedAt: DateTime.now(),
    );
    
    await _repository.update(completedQuest);
    
    // Award XP to user
    await _userService.updateProgress(
      quest.questData['userId'] as String,
      ProgressUpdate(xpGained: quest.xpReward, questsCompleted: 1),
    );
    
    return completedQuest;
  }
}
```

---

## 4. Database Layer

### 4.1 Repository Pattern Implementation

```dart
// Abstract Repository Interface
abstract class IRepository<T, ID> {
  Future<T?> getById(ID id);
  Future<List<T>> getAll();
  Future<T> create(T entity);
  Future<T> update(T entity);
  Future<void> delete(ID id);
}

// Firestore Repository Implementation
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
      throw RepositoryException('Failed to get vocabulary word: $e');
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
      throw RepositoryException('Failed to get user vocabulary: $e');
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
      throw RepositoryException('Failed to create vocabulary word: $e');
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
      throw RepositoryException('Failed to update vocabulary word: $e');
    }
  }
  
  @override
  Future<void> delete(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw RepositoryException('Failed to delete vocabulary word: $e');
    }
  }
  
  Future<List<VocabularyWord>> searchWords(
    String userId,
    String searchTerm,
  ) async {
    try {
      // Firestore doesn't support full-text search natively
      // This is a simplified implementation
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
      throw RepositoryException('Failed to search vocabulary: $e');
    }
  }
}
```

### 4.2 Database Migration Strategy

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
        description: 'Initial schema setup',
        migrationFunction: _migration_1_0_0,
      ),
      DatabaseMigration(
        version: '1.1.0',
        description: 'Add spaced repetition data to vocabulary',
        migrationFunction: _migration_1_1_0,
      ),
      // Add more migrations as needed
    ];
  }
  
  Future<void> _migration_1_0_0() async {
    // Initial schema setup - usually handled by app initialization
    print('Running initial schema setup');
  }
  
  Future<void> _migration_1_1_0() async {
    // Add spaced repetition data to existing vocabulary words
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
      print('Successfully ran migration: ${migration.version}');
    } catch (e) {
      throw MigrationException('Failed to run migration ${migration.version}: $e');
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

## 5. API Integration Layer

### 5.1 OpenAI API Integration

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
    Provide a clear, concise definition for the technical term "$word" 
    that would be helpful for someone learning technical English. 
    Include:
    1. A simple definition (1-2 sentences)
    2. An example sentence using the word in a technical context
    
    Format the response as JSON:
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
    Generate multiple choice quiz questions for these vocabulary words:
    
    $wordList
    
    For each word, create a question that tests understanding of the definition.
    Provide 4 options (A, B, C, D) with only one correct answer.
    
    Format as JSON array:
    [
      {
        "word": "example",
        "question": "What does 'example' mean?",
        "options": ["Option A", "Option B", "Option C", "Option D"],
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
          // Rate limited, wait and retry
          if (attempt < _maxRetries - 1) {
            await Future.delayed(_retryDelay * (attempt + 1));
            continue;
          }
        }
        
        throw OpenAIException(
          'API request failed: ${response.statusCode} ${response.body}',
        );
      } catch (e) {
        if (attempt == _maxRetries - 1) rethrow;
        await Future.delayed(_retryDelay);
      }
    }
    
    throw OpenAIException('Failed to make request after $_maxRetries attempts');
  }
}

// API Response Caching
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

## 6. Testing Strategy

### 6.1 Unit Testing

```dart
// Example unit tests for VocabularyService
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
      test('returns words that are due for review', () async {
        // Arrange
        final userId = 'test-user';
        final now = DateTime.now();
        final dueWord = VocabularyWord(
          id: '1',
          word: 'test',
          definition: 'test definition',
          exampleSentence: 'test sentence',
          categories: ['test'],
          difficultyLevel: 1,
          createdAt: now,
          reviewData: VocabularyReviewData(
            lastReviewed: now.subtract(Duration(days: 2)),
            reviewCount: 1,
            retentionScore: 0.5,
            nextReviewDate: now.subtract(Duration(hours: 1)), // Due
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
      test('updates word with new review data', () async {
        // Arrange
        final wordId = 'test-word';
        final word = VocabularyWord(
          id: wordId,
          word: 'test',
          definition: 'test definition',
          exampleSentence: 'test sentence',
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

### 6.2 Integration Testing

```dart
// Example integration test for quest completion flow
void main() {
  group('Quest Completion Integration', () {
    late QuestManagementService questService;
    late UserService userService;
    late VocabularyService vocabularyService;
    
    setUpAll(() async {
      // Set up test environment with real Firebase emulator
      await Firebase.initializeApp();
      // Configure services with test repositories
    });
    
    tearDownAll(() async {
      // Clean up test data
    });
    
    test('completing vocabulary review quest awards XP to user', () async {
      // Arrange
      final userId = 'test-user-integration';
      final user = await userService.create(User(
        id: userId,
        email: 'test@example.com',
        username: 'testuser',
        createdAt: DateTime.now(),
        profile: UserProfile(
          displayName: 'Test User',
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
      
      // Create vocabulary words for review
      for (int i = 0; i < 5; i++) {
        await vocabularyService.create(VocabularyWord(
          id: 'word-$i',
          word: 'test-word-$i',
          definition: 'definition $i',
          exampleSentence: 'example $i',
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
      
      // Generate daily quests
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

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-08-29 | GitHub Copilot Agent | Initial low-level design documentation |