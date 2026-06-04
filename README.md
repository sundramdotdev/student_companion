# Student Companion

Student Companion is a production-ready Flutter application designed to help college and university students manage their academic life in one place. The app provides attendance tracking, bunk calculation, GPA/CGPA calculation, internal marks management, timetable scheduling, and smart local notifications, all while working completely offline.

## Overview

Managing attendance, internal assessments, assignments, and academic performance can become difficult when information is scattered across multiple apps and notebooks.

Student Companion solves this problem by providing a centralized academic dashboard that helps students:

*   Track attendance across multiple subjects
*   Calculate safe bunk limits
*   Monitor attendance percentage requirements
*   Calculate SGPA and CGPA
*   Manage internal marks and assessments
*   Receive class and academic reminders
*   Store academic data securely on-device
*   Work entirely offline without any backend dependency

## Features

### Attendance Tracker

*   Subject-wise attendance management
*   Daily attendance recording
*   Present, Absent, and Cancelled class tracking
*   Attendance percentage calculation
*   Weekly and monthly attendance insights
*   Low attendance alerts

### Bunk Calculator

*   Custom attendance requirement support
*   Safe bunk prediction
*   Whole-day bunk simulation
*   Future attendance forecasting
*   Recovery planning suggestions
*   Attendance risk analysis

### GPA Calculator

*   Semester GPA calculation
*   Cumulative GPA calculation
*   Custom grading system support
*   Credit-based GPA calculations
*   GPA target planning

### Internal Marks Manager

*   Assignment tracking
*   Class test management
*   Internal test tracking
*   Mid-semester marks management
*   Presentation marks storage
*   Lab and practical assessment tracking
*   Custom assessment categories
*   Passing criteria analysis

### Smart Notifications

*   Class reminders
*   Attendance update reminders
*   Assignment deadline alerts
*   Internal exam reminders
*   Low attendance warnings
*   Academic performance notifications

### Timetable Management

*   Weekly class schedules
*   Subject-specific timings
*   Custom class planning
*   Schedule-based notifications

### Offline First

*   No internet connection required
*   No backend infrastructure required
*   Fast local data access
*   Complete privacy and control

### Backup & Restore

*   Export academic data
*   Import previous backups
*   JSON-based data migration
*   Easy device transfer support

## Tech Stack

### Framework

*   Flutter
*   Dart

### Architecture

*   Clean Architecture
*   Feature-Based Modular Structure

### State Management

*   Riverpod

### Local Storage

*   Hive Database

### Routing

*   Go Router

### Notifications

*   Flutter Local Notifications

### Code Generation

*   Freezed
*   Build Runner

## Project Structure

lib/  
│  
├── core/  
│ ├── constants/  
│ ├── services/  
│ ├── utils/  
│ └── theme/  
│  
├── features/  
│ ├── attendance/  
│ ├── bunk\_calculator/  
│ ├── gpa/  
│ ├── internal\_marks/  
│ ├── timetable/  
│ └── dashboard/  
│  
├── shared/  
│ ├── widgets/  
│ ├── models/  
│ └── providers/  
│  
├── routes/  
│  
└── main.dart

## Key Objectives

*   Production-ready architecture
*   Fully offline functionality
*   High performance
*   Clean and maintainable codebase
*   Scalable feature development
*   Play Store deployment readiness

## Future Enhancements

*   Academic analytics dashboard
*   Study session tracker
*   Placement preparation module
*   Notes and document manager
*   AI-powered academic assistant
*   University-specific GPA systems
*   Multi-device synchronization

## Getting Started

### Prerequisites

*   Flutter SDK
*   Dart SDK
*   Android Studio or VS Code
*   Android Emulator or Physical Device

### Installation

Clone the repository:

git clone https://github.com/sundramdotdev/student_companion.git

Navigate to the project directory:

cd student-companion

Install dependencies:

flutter pub get

Generate required files:

dart run build\_runner build --delete-conflicting-outputs

Run the application:

flutter run

## Development Principles

*   Clean Architecture
*   SOLID Principles
*   Modular Feature Development
*   Offline-First Design
*   Testable Codebase
*   Production-Level Error Handling
*   Scalable State Management

## License

This project is intended for educational, portfolio, and production use.

## Author

Designed and Developed by Sundramdotdev
