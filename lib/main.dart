import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_shit_done/src/database/database.dart';
import 'package:get_shit_done/src/features/notifications/notification_providers.dart';
import 'package:get_shit_done/src/features/notifications/notification_service.dart';
import 'package:get_shit_done/src/routing/app_router.dart';
import 'package:get_shit_done/src/theme/app_theme.dart';
import 'package:get_shit_done/src/theme/theme_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await IsarDB.initialize();
  await NotificationService.instance.initialize();
  await NotificationService.instance.requestPermissionsOnFirstLaunch();

  runApp(const ProviderScope(child: GetShitDoneApp()));
}

class GetShitDoneApp extends ConsumerWidget {
  const GetShitDoneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    final themeSettings = ref.watch(themeSettingsProvider);
    ref.listen(taskNotificationTapProvider, (previous, next) {
      next.whenData((taskId) {
        goRouter.pushNamed(
          AppRoutes.editTaskName,
          pathParameters: {'taskId': '$taskId'},
        );
      });
    });

    return MaterialApp.router(
      title: 'GetShitDone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(themeSettings.palette),
      darkTheme: AppTheme.darkTheme(themeSettings.palette),
      themeMode: themeSettings.mode,
      routerConfig: goRouter,
    );
  }
}
