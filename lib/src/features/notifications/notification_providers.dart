import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_shit_done/src/features/notifications/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

final taskNotificationTapProvider = StreamProvider<int>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return service.taskTapStream;
});

final exactAlarmAccessProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  return service.canScheduleExactAlarms();
});
