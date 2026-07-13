# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-07-14

### Added
- Complete UI/UX redesign using a premium Material 3 design system.
- Centralized `AppInfoService` leveraging `package_info_plus` for dynamic versioning.
- In-app "About", "Privacy Policy", and "Open Source Licenses" screens.
- Export/Import JSON backup mechanism in settings.
- Bunk Calculator predictive insights in the Subject detail view.
- Complete Open-Source documentation suite (README, CONTRIBUTING, ROADMAP, etc.).

### Changed
- Refactored project to exclusively support Android and iOS. Removed desktop and web platforms.
- Fixed `Hero` animation tag conflicts during `GoRouter` shell route transitions.
- Improved dynamic theme toggle logic via Riverpod.
- Replaced hardcoded text styles with centralized theme text styles.

### Deprecated
- N/A

### Removed
- `windows/`, `macos/`, `linux/`, and `web/` platform targets.

### Fixed
- Fixed `RenderFlex` overflow errors in the Bunk Calculator screen.
- Resolved deprecation warnings regarding `DropdownButtonFormField` and `Color.withOpacity`.

## [1.0.0] - 2026-05-01

### Added
- Initial release.
- Subject creation and attendance tracking.
- Timetable scheduling.
- GPA Calculation with customizable grading scales.
- Local Hive database implementation for offline functionality.
