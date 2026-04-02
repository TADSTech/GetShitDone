# Task List

## Phase 1: Project Setup & Architecture
- [ ] Update `pubspec.yaml` with core dependencies (Riverpod, Isar, flutter_local_notifications, go_router).
- [ ] Configure Android-specific permissions in `AndroidManifest.xml` (Notifications, Exact Alarms, Boot Completed).
- [ ] Setup base Material 3 Theme and Color Schemes.
- [ ] Initialize GoRouter and basic screen templates (Home, Add Task, Settings).

## Phase 2: Data Layer (Local-First)
- [ ] Define Isar Collections / Models:
  - [ ] `Task` (id, title, description, dueDate, priority, isCompleted, categoryId)
  - [ ] `Category` (id, name, color, icon)
  - [ ] `UserStats` (id, currentStreak, highestStreak, totalCompleted)
- [ ] Run `build_runner` to generate Isar schema files.
- [ ] Implement `TaskRepository` and `StatsRepository` for database interactions.
- [ ] Create Riverpod providers for exposing streams of tasks to the UI.

## Phase 3: Core Features (UI & Logic)
- [x] Build Home Screen:
  - [x] Daily overview / Today's tasks.
  - [x] Streak indicator widget.
- [x] Build 'Add/Edit Task' Bottom Sheet or Screen:
  - [x] Title, notes input.
  - [x] Date & Time picker for deadlines.
  - [x] Priority selector.
- [x] Implement Task interaction (Swipe to complete, swipe to delete).

## Phase 4: Notifications & Alarms (The "Superpower")
- [x] Initialize `flutter_local_notifications` for Android.
- [x] Create permission request flow on first launch.
- [x] Implement `NotificationService` to schedule local notifications when a task is created with a due time.
- [x] Implement high-priority "Alarms" using `android_alarm_manager_plus` for tasks marked as "Must Do" (rings until dismissed).
- [x] Handle tap actions on notifications to open specific tasks.

## Phase 5: Engagement & Polish
- [x] Implement Streak Logic (calculates daily if a task was completed, resets if day missed).
- [x] Build Stats/Profile Screen (HeatMap calendar of activity, completion graphs).
- [x] Add satisfying animations (Confetti on task complete, smooth list transitions).
- [x] Implement settings page
- [x] Add custom themes, UX for priority as well as other juicy stuffs
- [ ] Final testing on physical Android device (especially testing background execution and alarms in Doze mode).
- [ ] Generate Android release build (`apk` / `aab`).