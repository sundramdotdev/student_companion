# Architecture Overview

Student Companion is built using a **Feature-First Clean Architecture**. This ensures the codebase is highly decoupled, easily testable, and strictly organized by domain rather than purely by technical layer.

## Folder Structure

```text
lib/
├── core/
│   ├── config/       # App-wide configurations (e.g., AppInfoService)
│   ├── constants/    # Hardcoded strings, colors, numbers
│   ├── notifications/# Local notification service
│   ├── router/       # GoRouter configuration
│   ├── storage/      # Global database services (Hive setup, Backup/Restore)
│   ├── theme/        # Material 3 ThemeData
│   └── widgets/      # Shared components (AppCard, SectionHeader, etc.)
│
├── features/
│   ├── attendance/
│   │   ├── domain/         # Entities (Subject), Logic
│   │   └── presentation/   # UI Screens, Widgets, Riverpod Providers
│   │
│   ├── dashboard/          # Aggregation screens and shell routing
│   │
│   ├── gpa/                # Entities (Semester, GradeScale), GPA logic
│   │
│   ├── internals/          # Internal marks tracking logic
│   │
│   └── settings/           # Theme toggle, backups, legal screens
```

## Layers within Features

Each feature module is conceptually divided into standard Clean Architecture layers:

1. **Domain Layer:** 
   - Contains pure Dart code. 
   - Defines the core business rules and entities.
   - Absolutely no Flutter dependencies here.
   
2. **Data Layer (Currently merged with Domain for simplicity via Hive):** 
   - Hive TypeAdapters directly serialize the domain entities. 
   - Repositories abstract the Hive boxes.
   
3. **Presentation Layer:**
   - Flutter Widgets and UI logic.
   - Riverpod StateNotifiers act as the bridge between UI and Domain.
   - UI should NEVER directly access a Hive box; it must read/write through Riverpod providers.

## State Management

We use **Riverpod** (`flutter_riverpod`) for declarative state management.
- Providers are scoped by feature.
- `StateNotifierProvider` or `AsyncNotifierProvider` are used to manage complex data like the list of subjects or semesters.
- UI reacts to state changes via `ref.watch()`.
