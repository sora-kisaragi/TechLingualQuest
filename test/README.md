# Tests (test/)

This directory contains unit tests and widget tests for the TechLingual Quest application.

## Structure

```
test/
├── unit/                     # Unit tests
│   ├── services/             # Service layer tests
│   ├── models/               # Model tests
│   └── utils/                # Utility function tests
├── widget/                   # Widget tests
│   ├── features/             # Feature widget tests
│   └── shared/               # Shared widget tests
└── helpers/                  # Test helpers and mocks
    ├── mocks/                # Mock objects
    └── fixtures/             # Test data fixtures
```

## Guidelines

- Write tests for all business logic
- Test widgets and user interactions
- Use descriptive test names
- Mock external dependencies
- Aim for high test coverage

## Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/services/auth_service_test.dart
```