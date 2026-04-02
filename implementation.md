# Implementation Strategy: GetShitDone

## Vision
A superpowered, local-first, no-cloud task management app exclusively for Android. Designed to maximize user engagement through reliable local notifications, precise alarms, and gamified productivity tracking.

## Tech Stack
*   **Framework:** Flutter (Android only)
*   **Local Database:** [Isar Database](https://isar.dev/) - Extremely fast, NoSQL, local-first database optimized for Flutter. Perfect for offline apps.
*   **State Management:** [Riverpod](https://riverpod.dev/) - Safe, scalable, and reactive state management.
*   **Notifications & Alarms:** 
    *   `flutter_local_notifications`: For standard engagement and reminders.
    *   `awesome_notifications` or `android_alarm_manager_plus`: For exact, reliable alarms that wake up the device or fire exactly on time.
*   **Routing:** `go_router`
*   **UI/UX:** Material 3 (Native Android feel) + Dynamic Color.

## Core Architecture
1.  **Data Layer:** 
    *   Isar schemas for `Task`, `Category`, and `UserStats`.
    *   Local repositories to handle CRUD operations.
2.  **Domain Layer:**
    *   Business logic for calculating streaks, engagement metrics, and scheduling logic.
3.  **Presentation Layer:**
    *   Riverpod providers linking the UI to the Domain layer.
    *   Aggressive UI caching for instant load times.
4.  **Background/Service Layer:**
    *   A dedicated notification manager to handle Android permissions (`POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`).
    *   WorkManager for background streak-calculation or cleanup tasks.

## Key Features
1.  **Task Management:** Quick add, categorization, priority levels, sub-tasks.
2.  **Relentless Alarms:** High-priority tasks get actual alarms (bypassing Doze mode where permitted) to ensure they aren't missed.
3.  **Engagement & Gamification:** Daily streaks, "tasks completed" heatmaps, and local achievements to keep the user coming back.
4.  **Focus Mode:** A built-in pomodoro timer or absolute focus screen for working on specific tasks lock-screen style.

## Android Specifics
*   We will strictly target Android `compileSdk` and `targetSdk` (typically 34+).
*   Need to handle exact alarm permissions (`<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />`).
*   Need foreground service permissions if we build a persistent focus timer.