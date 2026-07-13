# Contributing to Student Companion

First off, thank you for considering contributing to Student Companion! It's people like you that make open-source software such a great community to learn, inspire, and create.

## Where do I go from here?

If you've noticed a bug or have a feature request, make sure to check our [Issues](../../issues) first to see if it's already being addressed. If not, go ahead and open a new issue!

## Development Process

1. **Fork the repo** and create your branch from `main`.
2. **Install dependencies:** run `flutter pub get`.
3. **Generate code:** run `dart run build_runner build -d` to generate any missing Freezed or Hive adapters.
4. **Code your feature/fix:**
   - Adhere to the existing Clean Architecture pattern.
   - Keep business logic in `domain/` and UI in `presentation/`.
   - Use `flutter_riverpod` for state management.
5. **Format and analyze:** run `flutter format .` and `flutter analyze`. Ensure there are no warnings or errors.
6. **Submit a PR:** Provide a clear description of the problem you solved or the feature you added. Use the Pull Request template provided.

## Coding Guidelines

- Use `camelCase` for variables and methods.
- Use `PascalCase` for classes.
- File names should be in `snake_case`.
- Do not use hardcoded strings for errors or UI text where possible (prepare for localization).
- Do not introduce breaking changes to the Hive database schema without providing a migration strategy.

## Code of Conduct

By participating in this project, you are expected to uphold our [Code of Conduct](CODE_OF_CONDUCT.md).

Thank you for contributing!
