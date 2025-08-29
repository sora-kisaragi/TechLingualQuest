# Flutter Environment Setup

This document provides instructions for setting up the Flutter development environment for TechLingual Quest.

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** (3.10.0 or later)
   ```bash
   # Download Flutter SDK
   git clone https://github.com/flutter/flutter.git -b stable
   export PATH="$PATH:`pwd`/flutter/bin"
   
   # Or use snap (Ubuntu/Linux)
   sudo snap install flutter --classic
   
   # Or use homebrew (macOS)
   brew install --cask flutter
   ```

2. **IDE Setup**
   - VS Code with Flutter and Dart extensions
   - Android Studio with Flutter plugin
   - IntelliJ IDEA with Flutter plugin

## Project Structure

The project has been set up with the following structure:

```
TechLingualQuest/
├── lib/
│   └── main.dart           # Main application entry point
├── test/
│   └── widget_test.dart    # Widget tests
├── android/                # Android platform-specific files
├── ios/                    # iOS platform-specific files  
├── web/                    # Web platform-specific files
├── pubspec.yaml           # Project dependencies and metadata
├── analysis_options.yaml  # Dart analyzer configuration
└── README_FLUTTER.md      # This file
```

## Getting Started

1. **Verify Flutter Installation**
   ```bash
   flutter doctor
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   # Web
   flutter run -d chrome
   
   # Android (with connected device/emulator)
   flutter run -d android
   
   # iOS (macOS only, with simulator/device)
   flutter run -d ios
   ```

4. **Run Tests**
   ```bash
   flutter test
   ```

5. **Build for Production**
   ```bash
   # Web
   flutter build web
   
   # Android APK
   flutter build apk
   
   # Android App Bundle
   flutter build appbundle
   
   # iOS (macOS only)
   flutter build ios
   ```

## Development Guidelines

### Code Style
- Follow the Dart style guide
- Use `flutter format` to format code
- Run `flutter analyze` to check for issues
- All code comments should be in English with optional Japanese clarification

### Widget Guidelines
- Prefer StatelessWidget when possible
- Keep build methods concise
- Use small, reusable widgets
- Separate UI from business logic

### Testing
- Write widget tests for UI components
- Write unit tests for business logic
- Maintain good test coverage

## Available Features

The current app includes:
- ✅ Basic Flutter project structure
- ✅ Material Design 3 theme
- ✅ XP tracking system (basic)
- ✅ Progress bar visualization
- ✅ Multi-platform support (Android, iOS, Web)
- ✅ Widget tests

### Planned Features
- [ ] User authentication
- [ ] Vocabulary management
- [ ] Quest system
- [ ] Database integration (Firebase/Supabase)
- [ ] AI integration for summaries and quizzes

## Troubleshooting

### Common Issues

1. **Flutter not recognized**
   - Ensure Flutter is in your PATH
   - Run `flutter doctor` to verify installation

2. **Dependencies not found**
   - Run `flutter pub get` to install dependencies
   - Check `pubspec.yaml` for correct dependency versions

3. **Build issues**
   - Clean the project: `flutter clean`
   - Reinstall dependencies: `flutter pub get`
   - Check platform-specific setup (Android SDK, Xcode, etc.)

## Next Steps

1. Set up your preferred IDE with Flutter extensions
2. Configure device/emulator for testing
3. Run `flutter pub get` to install dependencies
4. Start the app with `flutter run`
5. Begin implementing the planned features

For more information, see the [official Flutter documentation](https://docs.flutter.dev/).