---
applyTo: "**/*.dart"
---

# Flutter / Dart Coding Standards

## Comments
- Use English for main comments, Japanese for clarification if necessary.
- Document public methods and classes with DartDoc style.

## Naming Conventions
- Classes: PascalCase
- Variables, functions: camelCase
- Constants: ALL_CAPS_WITH_UNDERSCORES
- Widget filenames: snake_case

## Widget Structure
- Prefer small reusable widgets
- Keep build methods concise
- Use StatelessWidget when possible

## State Management
- Follow chosen state management (Provider, Riverpod, Bloc, etc.)
- Separate UI and business logic

## Testing
- Write unit tests for business logic
- Widget tests for UI components

### Code Coverage Requirements
- **Overall Coverage**: Maintain 80% or higher code coverage across the entire project
- **New Code Coverage**: All new code additions (patches) must achieve 85% or higher coverage
- **Local Verification**: Always verify coverage locally before committing using `flutter test --coverage`
- **Coverage Reporting**: Use `genhtml coverage/lcov.info -o coverage/html` to generate coverage reports

### Test-Driven Development (xDD)
- **Test-First Approach**: Write tests before implementing functionality when possible
- **TDD/FDD Priority**: Follow Test-Driven Development (TDD) or Feature-Driven Development (FDD) methodologies
- **Quality Focus**: Prioritize tested, working code over merely working code
- **Continuous Improvement**: Regularly review and improve test coverage and quality

## Formatter & Lint
- Use `flutter format` / `dart format`
- Enable recommended lints (e.g., `flutter_lints`)

## Code Quality and Pre-commit Requirements
- **Always format before commit**: Run `dart format .` before every commit
- **Pre-commit hooks**: Install and use pre-commit hooks with `pre-commit install`
- **Syntax validation**: Ensure code compiles without syntax errors before formatting
- **CI/CD compliance**: All code must pass `dart format --set-exit-if-changed .` check
- **Automated formatting**: Pre-commit hooks will automatically format Dart files
- **Best practice**: Format code immediately after making changes to maintain consistency

### Code Coverage Pre-commit Verification
- **Coverage check**: Run `flutter test --coverage` locally before every commit
- **Coverage threshold**: Ensure new code meets 85% coverage requirement
- **Coverage report**: Use `genhtml coverage/lcov.info -o coverage/html` to review detailed coverage
- **Coverage validation**: Verify overall project coverage remains above 80%
