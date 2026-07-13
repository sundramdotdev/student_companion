<div align="center">
  <img src="assets/images/logo.png" alt="Student Companion Logo" width="120" height="120">
  
  # Student Companion
  **Your Ultimate Offline Academic Assistant**
  
  [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
  [![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?logo=Flutter&logoColor=white)](https://flutter.dev/)
  [![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-brightgreen)](#)
  [![Version](https://img.shields.io/badge/Version-1.1.0-orange)](#)

  *Manage attendance, track GPA, predict bunks, and organize your academic life—all completely offline.*
</div>

---

## 📖 Overview

**Student Companion** is a privacy-first, offline mobile application designed to solve the everyday organizational challenges faced by university and college students. 

From keeping track of strict attendance requirements to predicting whether you can safely "bunk" a class, calculating your GPA using custom grading scales, and tracking your internal assessments—Student Companion handles it all locally on your device without requiring an internet connection or an account.

## ✨ Key Features

- **✅ Attendance Tracker:** Log your daily attendance with a single tap.
- **🔮 Bunk Calculator:** Instantly calculate how many classes you can miss or need to attend to maintain your minimum requirement.
- **📅 Timetable:** A dynamic weekly schedule to keep you on time.
- **🎓 GPA Calculator:** Define your university's custom grading scale and calculate semester and cumulative GPAs.
- **📝 Internal Marks:** Track assignments, midterms, and lab scores for every subject.
- **🔔 Notifications:** Get timely reminders for upcoming classes and critical attendance drops.
- **📴 Offline Storage:** Your data stays on your device, ensuring maximum privacy and lightning-fast performance.
- **⚙️ Settings & Aesthetics:** Beautiful Material 3 design, dynamic theme mode, and seamless backup/restore capabilities.

## 📸 Screenshots

<div align="center">
  <img src="assets/screenshots/home.png" width="200" alt="Home Screen">
  <img src="assets/screenshots/attendance.png" width="200" alt="Attendance Screen">
  <img src="assets/screenshots/dashboard.png" width="200" alt="Dashboard Screen">
  <img src="assets/screenshots/gpa.png" width="200" alt="GPA Screen">
  <img src="assets/screenshots/settings.png" width="200" alt="Settings Screen">
  <img src="assets/screenshots/planner.png" width="200" alt="Planner Screen">
</div>

*Note: Add actual screenshots to the `assets/screenshots/` directory.*

## 🏛️ Architecture

Student Companion follows **Clean Architecture** principles to separate concerns, making the codebase highly testable and scalable.

`Presentation Layer` -> UI components and State Notifiers (Riverpod).
↓
`Domain Layer` -> Core business logic, entities, and repository interfaces.
↓
`Data Layer` -> Local storage implementations (Hive) and external data mapping.

For more details, see [ARCHITECTURE.md](ARCHITECTURE.md).

## 📂 Folder Structure

```text
lib/
├── core/             # Shared utilities, routing, themes, storage services
├── features/         # Feature-first organization
│   ├── attendance/   # Subject logging and bunk calculation logic
│   ├── dashboard/    # Main entry point and overview UI
│   ├── gpa/          # Grade scales, semesters, and CGPA calculation
│   ├── internals/    # Internal marks and assessment tracking
│   └── settings/     # Preferences, backups, about, and privacy policy
└── main.dart         # Application entry point
```

## 🛠️ Tech Stack

We carefully chose each technology to ensure maximum performance, developer experience, and maintainability:

- **[Flutter](https://flutter.dev/):** The UI toolkit for crafting native-like, compiled applications from a single codebase.
- **[Riverpod](https://riverpod.dev/):** A robust and compile-safe state management solution that allows dependency injection and reactive UI.
- **[Hive](https://pub.dev/packages/hive):** A lightweight, extremely fast NoSQL database for local, offline-first data persistence.
- **[Go Router](https://pub.dev/packages/go_router):** A declarative routing package that simplifies complex nested navigation.
- **[Freezed](https://pub.dev/packages/freezed):** A code generator for immutable data classes, drastically reducing boilerplate.
- **[Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications):** Used to schedule completely offline, local class reminders.
- **[Package Info Plus](https://pub.dev/packages/package_info_plus):** Dynamically retrieves application version from `pubspec.yaml`.

## 🚀 Installation Guide

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.11.4 or higher)
- Android Studio or Xcode (for iOS builds)

### Clone & Run

```bash
# Clone the repository
git clone https://github.com/sundramdotdev/student_companion.git

# Navigate into the project
cd student_companion

# Fetch dependencies
flutter pub get

# Generate necessary Freezed and Hive files (Run this if you make model changes)
dart run build_runner build -d

# Run the app in debug mode
flutter run
```

### Release Build
```bash
# For Android APK
flutter build apk --release

# For Android App Bundle (Play Store)
flutter build appbundle --release

# For iOS (Requires Mac)
flutter build ios --release
```

## 👨‍💻 Development Guide

If you wish to contribute to the codebase, please review our [CONTRIBUTING.md](CONTRIBUTING.md) and development standards:
- **Clean Architecture Rules:** Never call data repositories directly from the UI. Use Riverpod providers.
- **Naming Conventions:** Use `camelCase` for variables/methods, `PascalCase` for classes, and `snake_case` for file names.
- **Widget Organization:** Keep widgets small. Extract complex UI parts into private widgets within the same file or a `widgets/` folder for reuse.

## 🗺️ Roadmap

**Phase 1 (Completed)**
- [x] Basic Subject and Attendance Tracking
- [x] GPA Calculator with Custom Scales
- [x] Hive Database Setup & Backup System

**Phase 2 (Current)**
- [x] Material 3 UI Redesign
- [x] Bunk Calculator & Predictions
- [x] Open-Source Documentation & Privacy Policy

**Phase 3 (Upcoming)**
- [ ] PDF Report Generation
- [ ] Cloud Sync & Google Drive Backup
- [ ] Dark Mode Enhancements
- [ ] Exam Countdown Timer

Check [ROADMAP.md](ROADMAP.md) for more details.

## ❓ FAQ

**Q: Does this app require the internet to work?**
No, Student Companion is 100% offline-first. All data is saved on your local device.

**Q: Does this collect personal data?**
Absolutely not. No analytics or tracking SDKs are installed. Please read our [Privacy Policy](lib/features/settings/presentation/screens/privacy_policy_screen.dart) for more details.

**Q: Can I contribute to this project?**
Yes! We welcome pull requests. Please check the `CONTRIBUTING.md` file.

**Q: Is cloud storage available?**
Not currently, but you can export your data as a JSON file via the Settings menu and restore it on any device.

## 🤝 Contributing

We love the open-source community! 
1. **Fork** the repository
2. **Create a branch** (`git checkout -b feature/AmazingFeature`)
3. **Commit your changes** (`git commit -m 'Add some AmazingFeature'`)
4. **Push to the branch** (`git push origin feature/AmazingFeature`)
5. **Open a Pull Request**

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and review process.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 💖 Credits

Designed and Developed with ❤️ by **Sundramdotdev**.
