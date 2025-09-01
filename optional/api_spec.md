---
author: "GitHub Copilot Agent"
date: "2025-08-29"
version: "1.0"
related_issues: ["#10"]
related_docs: ["../design/HLD.md", "../design/LLD.md", "db_design.md"]
---

# API Specification - TechLingual Quest

This document provides comprehensive API specifications for external integrations and internal service communications in the TechLingual Quest application.

## Related Documents
- [High-Level Design](../design/HLD.md) - System architecture overview
- [Low-Level Design](../design/LLD.md) - Detailed technical implementation
- [Database Design](db_design.md) - Database schema and relationships

---

## 1. API Overview

### 1.1 Base Configuration

```yaml
openapi: 3.0.3
info:
  title: TechLingual Quest API
  description: RESTful API for the TechLingual Quest gamified learning platform
  version: 1.0.0
  contact:
    name: TechLingual Quest Development Team
    email: api@techlingual-quest.dev
  license:
    name: MIT
    url: https://opensource.org/licenses/MIT

servers:
  - url: https://api.techlingual-quest.dev/v1
    description: Production server
  - url: https://staging-api.techlingual-quest.dev/v1
    description: Staging server
  - url: http://localhost:8080/v1
    description: Development server

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
    apiKey:
      type: apiKey
      in: header
      name: X-API-Key

security:
  - bearerAuth: []
```

### 1.2 Common Response Schemas

```yaml
components:
  schemas:
    ApiResponse:
      type: object
      properties:
        success:
          type: boolean
          description: Indicates if the request was successful
        message:
          type: string
          description: Human-readable message
        data:
          type: object
          description: Response payload
        errors:
          type: array
          items:
            $ref: '#/components/schemas/ApiError'
        meta:
          $ref: '#/components/schemas/ApiMeta'
      required:
        - success

    ApiError:
      type: object
      properties:
        code:
          type: string
          description: Error code for programmatic handling
        message:
          type: string
          description: Human-readable error message
        field:
          type: string
          description: Field name if error is field-specific
      required:
        - code
        - message

    ApiMeta:
      type: object
      properties:
        timestamp:
          type: string
          format: date-time
        requestId:
          type: string
        version:
          type: string
        pagination:
          $ref: '#/components/schemas/PaginationMeta'

    PaginationMeta:
      type: object
      properties:
        page:
          type: integer
          minimum: 1
        pageSize:
          type: integer
          minimum: 1
          maximum: 100
        totalPages:
          type: integer
        totalItems:
          type: integer
        hasNext:
          type: boolean
        hasPrevious:
          type: boolean
```

---

## 2. Authentication Endpoints

### 2.1 User Authentication

```yaml
paths:
  /auth/register:
    post:
      summary: Register new user
      tags: [Authentication]
      security: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                email:
                  type: string
                  format: email
                  example: user@example.com
                password:
                  type: string
                  minLength: 8
                  example: securePassword123
                username:
                  type: string
                  minLength: 3
                  maxLength: 30
                  pattern: '^[a-zA-Z0-9_]+$'
                  example: techlearner
                profile:
                  $ref: '#/components/schemas/UserProfileInput'
              required:
                - email
                - password
                - username
      responses:
        '201':
          description: User registered successfully
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        $ref: '#/components/schemas/AuthResponse'
        '400':
          $ref: '#/components/responses/BadRequest'
        '409':
          description: Email or username already exists
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ApiResponse'

  /auth/login:
    post:
      summary: User login
      tags: [Authentication]
      security: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                email:
                  type: string
                  format: email
                password:
                  type: string
              required:
                - email
                - password
      responses:
        '200':
          description: Login successful
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        $ref: '#/components/schemas/AuthResponse'
        '401':
          $ref: '#/components/responses/Unauthorized'

  /auth/refresh:
    post:
      summary: Refresh access token
      tags: [Authentication]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                refreshToken:
                  type: string
              required:
                - refreshToken
      responses:
        '200':
          description: Token refreshed successfully
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        $ref: '#/components/schemas/AuthResponse'

components:
  schemas:
    AuthResponse:
      type: object
      properties:
        accessToken:
          type: string
          description: JWT access token
        refreshToken:
          type: string
          description: JWT refresh token
        expiresIn:
          type: integer
          description: Token expiration time in seconds
        user:
          $ref: '#/components/schemas/User'
      required:
        - accessToken
        - expiresIn
        - user
```

---

## 3. User Management Endpoints

### 3.1 User Profile Management

```yaml
paths:
  /users/me:
    get:
      summary: Get current user profile
      tags: [Users]
      responses:
        '200':
          description: User profile retrieved successfully
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        $ref: '#/components/schemas/User'

    put:
      summary: Update user profile
      tags: [Users]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UserProfileInput'
      responses:
        '200':
          description: Profile updated successfully
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        $ref: '#/components/schemas/User'

  /users/me/progress:
    get:
      summary: Get user learning progress
      tags: [Users]
      responses:
        '200':
          description: Progress retrieved successfully
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        $ref: '#/components/schemas/UserProgress'

  /users/me/preferences:
    get:
      summary: Get user preferences
      tags: [Users]
      responses:
        '200':
          description: Preferences retrieved successfully
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        $ref: '#/components/schemas/UserPreferences'

    put:
      summary: Update user preferences
      tags: [Users]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UserPreferences'
      responses:
        '200':
          description: Preferences updated successfully

components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
          example: user_123456789
        email:
          type: string
          format: email
        username:
          type: string
        profile:
          $ref: '#/components/schemas/UserProfile'
        progress:
          $ref: '#/components/schemas/UserProgress'
        createdAt:
          type: string
          format: date-time
        lastLogin:
          type: string
          format: date-time

    UserProfile:
      type: object
      properties:
        displayName:
          type: string
          example: Alex Chen
        avatarUrl:
          type: string
          format: uri
          nullable: true
        bio:
          type: string
          nullable: true
        learningGoals:
          type: array
          items:
            type: string
            enum: [vocabulary, speaking, writing, reading, listening]
        nativeLanguage:
          type: string
          example: zh-CN
        targetLanguageLevel:
          type: string
          enum: [beginner, intermediate, advanced]
        occupation:
          type: string
          nullable: true
        timeZone:
          type: string
          example: Asia/Tokyo

    UserProgress:
      type: object
      properties:
        totalXp:
          type: integer
          minimum: 0
        currentLevel:
          type: integer
          minimum: 1
        learningStreak:
          type: integer
          minimum: 0
        longestStreak:
          type: integer
          minimum: 0
        vocabularyCount:
          type: integer
          minimum: 0
        vocabularyMastered:
          type: integer
          minimum: 0
        questsCompleted:
          type: integer
          minimum: 0
        articlesCreated:
          type: integer
          minimum: 0
        totalStudyTimeMinutes:
          type: integer
          minimum: 0
        lastActivityDate:
          type: string
          format: date-time

    UserPreferences:
      type: object
      properties:
        notificationsEnabled:
          type: boolean
        dailyReminderTime:
          type: string
          pattern: '^([01]?[0-9]|2[0-3]):[0-5][0-9]$'
          example: '09:00'
        weeklyGoalMinutes:
          type: integer
          minimum: 0
          maximum: 10080
        preferredQuizTypes:
          type: array
          items:
            type: string
            enum: [multipleChoice, fillInBlank, matching, typing]
        spacedRepetitionIntensity:
          type: string
          enum: [conservative, normal, aggressive]
        uiTheme:
          type: string
          enum: [light, dark, auto]
        language:
          type: string
          example: en-US
```

---

## 4. Vocabulary Management Endpoints

### 4.1 Vocabulary Operations

```yaml
paths:
  /vocabulary:
    get:
      summary: Get user's vocabulary words
      tags: [Vocabulary]
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            minimum: 1
            default: 1
        - name: pageSize
          in: query
          schema:
            type: integer
            minimum: 1
            maximum: 100
            default: 20
        - name: category
          in: query
          schema:
            type: string
        - name: search
          in: query
          schema:
            type: string
        - name: sortBy
          in: query
          schema:
            type: string
            enum: [createdAt, word, difficulty, nextReview]
            default: createdAt
        - name: sortOrder
          in: query
          schema:
            type: string
            enum: [asc, desc]
            default: desc
      responses:
        '200':
          description: Vocabulary words retrieved successfully
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        type: array
                        items:
                          $ref: '#/components/schemas/VocabularyWord'

    post:
      summary: Add new vocabulary word
      tags: [Vocabulary]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/VocabularyWordInput'
      responses:
        '201':
          description: Vocabulary word created successfully
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        $ref: '#/components/schemas/VocabularyWord'

  /vocabulary/{wordId}:
    get:
      summary: Get vocabulary word by ID
      tags: [Vocabulary]
      parameters:
        - name: wordId
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Vocabulary word retrieved successfully
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        $ref: '#/components/schemas/VocabularyWord'

    put:
      summary: Update vocabulary word
      tags: [Vocabulary]
      parameters:
        - name: wordId
          in: path
          required: true
          schema:
            type: string
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/VocabularyWordInput'
      responses:
        '200':
          description: Vocabulary word updated successfully

    delete:
      summary: Delete vocabulary word
      tags: [Vocabulary]
      parameters:
        - name: wordId
          in: path
          required: true
          schema:
            type: string
      responses:
        '204':
          description: Vocabulary word deleted successfully

  /vocabulary/review:
    get:
      summary: Get words due for review
      tags: [Vocabulary]
      parameters:
        - name: limit
          in: query
          schema:
            type: integer
            minimum: 1
            maximum: 50
            default: 20
      responses:
        '200':
          description: Review words retrieved successfully
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        type: array
                        items:
                          $ref: '#/components/schemas/VocabularyWord'

  /vocabulary/{wordId}/review:
    post:
      summary: Record vocabulary review
      tags: [Vocabulary]
      parameters:
        - name: wordId
          in: path
          required: true
          schema:
            type: string
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                performance:
                  type: integer
                  minimum: 0
                  maximum: 3
                  description: "0=failed, 1=hard, 2=good, 3=easy"
                timeSpentSeconds:
                  type: integer
                  minimum: 0
                wasCorrect:
                  type: boolean
              required:
                - performance
                - timeSpentSeconds
                - wasCorrect
      responses:
        '200':
          description: Review recorded successfully
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        $ref: '#/components/schemas/VocabularyWord'

components:
  schemas:
    VocabularyWord:
      type: object
      properties:
        id:
          type: string
        word:
          type: string
          example: algorithm
        definition:
          type: string
          example: A step-by-step procedure for solving a problem
        exampleSentence:
          type: string
          example: The sorting algorithm efficiently organizes data
        pronunciation:
          type: string
          nullable: true
          example: /ˈælɡəˌrɪðəm/
        categories:
          type: array
          items:
            type: string
          example: [programming, computer-science]
        tags:
          type: array
          items:
            type: string
        difficultyLevel:
          type: integer
          minimum: 1
          maximum: 5
        source:
          type: string
          nullable: true
        isPublic:
          type: boolean
        createdAt:
          type: string
          format: date-time
        reviewData:
          $ref: '#/components/schemas/ReviewData'
        analytics:
          $ref: '#/components/schemas/VocabularyAnalytics'

    VocabularyWordInput:
      type: object
      properties:
        word:
          type: string
          minLength: 1
          maxLength: 100
        definition:
          type: string
          minLength: 1
          maxLength: 1000
        exampleSentence:
          type: string
          maxLength: 500
        pronunciation:
          type: string
          nullable: true
        categories:
          type: array
          items:
            type: string
        tags:
          type: array
          items:
            type: string
        difficultyLevel:
          type: integer
          minimum: 1
          maximum: 5
          default: 3
        source:
          type: string
          nullable: true
        isPublic:
          type: boolean
          default: false
      required:
        - word
        - definition

    ReviewData:
      type: object
      properties:
        lastReviewed:
          type: string
          format: date-time
        reviewCount:
          type: integer
          minimum: 0
        retentionScore:
          type: number
          minimum: 0
          maximum: 1
        nextReviewDate:
          type: string
          format: date-time
        spacedRepetition:
          $ref: '#/components/schemas/SpacedRepetitionData'

    SpacedRepetitionData:
      type: object
      properties:
        intervalDays:
          type: integer
          minimum: 1
        easinessFactor:
          type: number
          minimum: 1.3
          maximum: 2.5
        repetitionNumber:
          type: integer
          minimum: 0

    VocabularyAnalytics:
      type: object
      properties:
        firstLearnedDate:
          type: string
          format: date-time
        lastCorrectAnswer:
          type: string
          format: date-time
          nullable: true
        totalReviewTime:
          type: integer
          minimum: 0
        averageResponseTime:
          type: number
          minimum: 0
        successRate:
          type: number
          minimum: 0
          maximum: 1
        mistakeCount:
          type: integer
          minimum: 0
        streakCount:
          type: integer
          minimum: 0
```

---

## 5. Quest Management Endpoints

### 5.1 Quest Operations

```yaml
paths:
  /quests:
    get:
      summary: Get user's quests
      tags: [Quests]
      parameters:
        - name: status
          in: query
          schema:
            type: string
            enum: [available, inProgress, completed, expired]
        - name: type
          in: query
          schema:
            type: string
            enum: [vocabularyReview, vocabularyQuiz, articleSummary, readingChallenge]
        - name: page
          in: query
          schema:
            type: integer
            minimum: 1
            default: 1
        - name: pageSize
          in: query
          schema:
            type: integer
            minimum: 1
            maximum: 50
            default: 20
      responses:
        '200':
          description: Quests retrieved successfully
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        type: array
                        items:
                          $ref: '#/components/schemas/Quest'

  /quests/daily:
    get:
      summary: Get today's available quests
      tags: [Quests]
      responses:
        '200':
          description: Daily quests retrieved successfully
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        type: array
                        items:
                          $ref: '#/components/schemas/Quest'

    post:
      summary: Generate new daily quests
      tags: [Quests]
      responses:
        '200':
          description: Daily quests generated successfully
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        type: array
                        items:
                          $ref: '#/components/schemas/Quest'

  /quests/{questId}:
    get:
      summary: Get quest by ID
      tags: [Quests]
      parameters:
        - name: questId
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Quest retrieved successfully
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        $ref: '#/components/schemas/Quest'

  /quests/{questId}/start:
    post:
      summary: Start a quest
      tags: [Quests]
      parameters:
        - name: questId
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Quest started successfully
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        $ref: '#/components/schemas/Quest'

  /quests/{questId}/complete:
    post:
      summary: Complete a quest
      tags: [Quests]
      parameters:
        - name: questId
          in: path
          required: true
          schema:
            type: string
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                completionData:
                  type: object
                  description: Quest-specific completion data
              required:
                - completionData
      responses:
        '200':
          description: Quest completed successfully
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        type: object
                        properties:
                          quest:
                            $ref: '#/components/schemas/Quest'
                          xpAwarded:
                            type: integer
                          achievementsUnlocked:
                            type: array
                            items:
                              $ref: '#/components/schemas/Achievement'

components:
  schemas:
    Quest:
      type: object
      properties:
        id:
          type: string
        type:
          type: string
          enum: [vocabularyReview, vocabularyQuiz, articleSummary, readingChallenge, writingExercise]
        title:
          type: string
        description:
          type: string
        instructions:
          type: string
          nullable: true
        status:
          type: string
          enum: [available, inProgress, completed, expired, failed]
        priority:
          type: string
          enum: [low, normal, high]
        xpReward:
          type: integer
          minimum: 0
        streakBonus:
          type: integer
          minimum: 0
        timeEstimateMinutes:
          type: integer
          minimum: 1
        difficultyLevel:
          type: integer
          minimum: 1
          maximum: 5
        createdAt:
          type: string
          format: date-time
        availableUntil:
          type: string
          format: date-time
        startedAt:
          type: string
          format: date-time
          nullable: true
        completedAt:
          type: string
          format: date-time
          nullable: true
        expiresAt:
          type: string
          format: date-time
        questData:
          type: object
          description: Quest-specific configuration data
        progress:
          $ref: '#/components/schemas/QuestProgress'

    QuestProgress:
      type: object
      properties:
        currentStep:
          type: integer
          minimum: 0
        totalSteps:
          type: integer
          minimum: 1
        completedSteps:
          type: array
          items:
            type: string
        stepData:
          type: object
        lastUpdateAt:
          type: string
          format: date-time
```

---

## 6. External Integration Endpoints

### 6.1 OpenAI Integration

```yaml
paths:
  /ai/vocabulary/definition:
    post:
      summary: Generate vocabulary definition using AI
      tags: [AI Integration]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                word:
                  type: string
                  minLength: 1
                  maxLength: 100
                context:
                  type: string
                  nullable: true
                  description: Optional context for better definition generation
              required:
                - word
      responses:
        '200':
          description: Definition generated successfully
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        type: object
                        properties:
                          word:
                            type: string
                          definition:
                            type: string
                          example:
                            type: string
                          confidence:
                            type: number
                            minimum: 0
                            maximum: 1

  /ai/quiz/generate:
    post:
      summary: Generate vocabulary quiz using AI
      tags: [AI Integration]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                vocabularyIds:
                  type: array
                  items:
                    type: string
                  minItems: 1
                  maxItems: 20
                questionCount:
                  type: integer
                  minimum: 1
                  maximum: 20
                  default: 10
                difficultyLevel:
                  type: integer
                  minimum: 1
                  maximum: 5
                  default: 3
                questionTypes:
                  type: array
                  items:
                    type: string
                    enum: [multipleChoice, fillInBlank, matching]
              required:
                - vocabularyIds
      responses:
        '200':
          description: Quiz generated successfully
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        type: object
                        properties:
                          quizId:
                            type: string
                          questions:
                            type: array
                            items:
                              $ref: '#/components/schemas/QuizQuestion'
                          timeLimit:
                            type: integer
                            description: Time limit in seconds

components:
  schemas:
    QuizQuestion:
      type: object
      properties:
        id:
          type: string
        type:
          type: string
          enum: [multipleChoice, fillInBlank, matching, typing]
        question:
          type: string
        vocabularyWord:
          $ref: '#/components/schemas/VocabularyWord'
        options:
          type: array
          items:
            type: string
          nullable: true
        correctAnswer:
          type: string
        explanation:
          type: string
          nullable: true
        points:
          type: integer
          minimum: 1
```

---

## 7. Analytics and Reporting Endpoints

### 7.1 Learning Analytics

```yaml
paths:
  /analytics/progress:
    get:
      summary: Get detailed learning progress analytics
      tags: [Analytics]
      parameters:
        - name: period
          in: query
          schema:
            type: string
            enum: [week, month, quarter, year]
            default: month
        - name: startDate
          in: query
          schema:
            type: string
            format: date
        - name: endDate
          in: query
          schema:
            type: string
            format: date
      responses:
        '200':
          description: Analytics retrieved successfully
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        $ref: '#/components/schemas/LearningAnalytics'

  /analytics/vocabulary:
    get:
      summary: Get vocabulary learning analytics
      tags: [Analytics]
      parameters:
        - name: category
          in: query
          schema:
            type: string
        - name: period
          in: query
          schema:
            type: string
            enum: [week, month, quarter]
            default: month
      responses:
        '200':
          description: Vocabulary analytics retrieved successfully
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        $ref: '#/components/schemas/VocabularyAnalyticsReport'

components:
  schemas:
    LearningAnalytics:
      type: object
      properties:
        summary:
          type: object
          properties:
            totalStudyTime:
              type: integer
              description: Total study time in minutes
            wordsLearned:
              type: integer
            questsCompleted:
              type: integer
            currentStreak:
              type: integer
            xpGained:
              type: integer
        dailyActivity:
          type: array
          items:
            type: object
            properties:
              date:
                type: string
                format: date
              studyTimeMinutes:
                type: integer
              wordsStudied:
                type: integer
              questsCompleted:
                type: integer
              xpGained:
                type: integer
        categoryBreakdown:
          type: array
          items:
            type: object
            properties:
              category:
                type: string
              wordCount:
                type: integer
              averageRetention:
                type: number
              timeSpent:
                type: integer
        streakHistory:
          type: array
          items:
            type: object
            properties:
              startDate:
                type: string
                format: date
              endDate:
                type: string
                format: date
              length:
                type: integer

    VocabularyAnalyticsReport:
      type: object
      properties:
        totalWords:
          type: integer
        masteredWords:
          type: integer
        averageRetentionScore:
          type: number
        reviewAccuracy:
          type: number
        categoryDistribution:
          type: array
          items:
            type: object
            properties:
              category:
                type: string
              count:
                type: integer
              percentage:
                type: number
        difficultyDistribution:
          type: array
          items:
            type: object
            properties:
              level:
                type: integer
              count:
                type: integer
        learningTrend:
          type: array
          items:
            type: object
            properties:
              date:
                type: string
                format: date
              wordsAdded:
                type: integer
              wordsReviewed:
                type: integer
              averageScore:
                type: number
```

---

## 8. Error Handling and Status Codes

### 8.1 Standard HTTP Status Codes

| Status Code | Description | Usage |
|-------------|-------------|-------|
| 200 | OK | Successful GET, PUT requests |
| 201 | Created | Successful POST requests creating resources |
| 204 | No Content | Successful DELETE requests |
| 400 | Bad Request | Invalid request data or parameters |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Valid authentication but insufficient permissions |
| 404 | Not Found | Requested resource not found |
| 409 | Conflict | Resource conflict (e.g., duplicate email) |
| 422 | Unprocessable Entity | Valid syntax but semantically incorrect |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server-side error |
| 503 | Service Unavailable | Temporary server unavailability |

### 8.2 Custom Error Codes

```yaml
components:
  schemas:
    ErrorCodes:
      type: string
      enum:
        # Authentication Errors
        - AUTH_INVALID_CREDENTIALS
        - AUTH_TOKEN_EXPIRED
        - AUTH_USER_DISABLED
        - AUTH_EMAIL_NOT_VERIFIED
        
        # Validation Errors
        - VALIDATION_REQUIRED_FIELD
        - VALIDATION_INVALID_FORMAT
        - VALIDATION_VALUE_TOO_LONG
        - VALIDATION_VALUE_TOO_SHORT
        
        # Business Logic Errors
        - VOCABULARY_ALREADY_EXISTS
        - QUEST_ALREADY_COMPLETED
        - QUEST_NOT_AVAILABLE
        - INSUFFICIENT_XP
        - DAILY_LIMIT_EXCEEDED
        
        # External Service Errors
        - AI_SERVICE_UNAVAILABLE
        - AI_QUOTA_EXCEEDED
        - AI_INVALID_RESPONSE
        
        # System Errors
        - DATABASE_CONNECTION_ERROR
        - CACHE_UNAVAILABLE
        - FILE_STORAGE_ERROR
```

---

## 9. Rate Limiting

### 9.1 Rate Limit Configuration

| Endpoint Category | Limit | Window | Headers |
|------------------|-------|---------|---------|
| Authentication | 10 requests | 1 minute | `X-RateLimit-*` |
| Vocabulary CRUD | 100 requests | 1 hour | `X-RateLimit-*` |
| Quest Operations | 50 requests | 1 hour | `X-RateLimit-*` |
| AI Integration | 20 requests | 1 hour | `X-RateLimit-*` |
| Analytics | 30 requests | 1 hour | `X-RateLimit-*` |

### 9.2 Rate Limit Headers

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640995200
X-RateLimit-Window: 3600
```

---

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-08-29 | GitHub Copilot Agent | Initial API specification documentation |