# Source Code (lib/)

This directory contains the main Dart source code for the TechLingual Quest Flutter application.

## Structure

```
lib/
├── main.dart                 # App entry point
├── app/                      # App-level configuration
├── features/                 # Feature-based modules
│   ├── auth/                 # Authentication
│   ├── vocabulary/           # Vocabulary management
│   ├── quests/               # Quest system
│   ├── summaries/            # Article summaries
│   └── dashboard/            # Progress dashboard
├── shared/                   # Shared components
│   ├── widgets/              # Reusable UI widgets
│   ├── utils/                # Utility functions
│   ├── constants/            # App constants
│   └── models/               # Data models
└── services/                 # External services
    ├── api/                  # API clients
    ├── database/             # Database services
    └── auth/                 # Authentication services
```

## Guidelines

- Follow Flutter/Dart naming conventions
- Use feature-based architecture
- Implement proper error handling
- Write clean, maintainable code