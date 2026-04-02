import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_shit_done/src/database/models/task.dart';
import 'package:go_router/go_router.dart';
import 'package:get_shit_done/src/features/dashboard/presentation/home_screen.dart';
import 'package:get_shit_done/src/features/settings/presentation/settings_screen.dart';
import 'package:get_shit_done/src/features/stats/presentation/stats_screen.dart';
import 'package:get_shit_done/src/features/tasks/presentation/task_editor_screen.dart';

class AppRoutes {
  static const String homePath = '/';
  static const String addTaskPath = '/tasks/new';
  static const String editTaskPath = '/tasks/:taskId';
  static const String settingsPath = '/settings';
  static const String statsPath = '/stats';

  static const String homeName = 'home';
  static const String addTaskName = 'add-task';
  static const String editTaskName = 'edit-task';
  static const String settingsName = 'settings';
  static const String statsName = 'stats';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.homePath,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.homePath,
        name: AppRoutes.homeName,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.addTaskPath,
        name: AppRoutes.addTaskName,
        builder: (context, state) => TaskEditorScreen(
          initialTask: state.extra is Task ? state.extra as Task : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.editTaskPath,
        name: AppRoutes.editTaskName,
        builder: (context, state) {
          final taskId = int.tryParse(state.pathParameters['taskId'] ?? '');
          return TaskEditorScreen(taskId: taskId);
        },
      ),
      GoRoute(
        path: AppRoutes.settingsPath,
        name: AppRoutes.settingsName,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.statsPath,
        name: AppRoutes.statsName,
        builder: (context, state) => const StatsScreen(),
      ),
    ],
  );
});
