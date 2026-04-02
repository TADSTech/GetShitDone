import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_shit_done/src/database/providers/task_providers.dart';
import 'package:get_shit_done/src/features/notifications/notification_providers.dart';
import 'package:get_shit_done/src/features/notifications/notification_service.dart';

class NotificationSettings {
  const NotificationSettings({required this.preReminderLeadMinutes});

  final int preReminderLeadMinutes;

  NotificationSettings copyWith({int? preReminderLeadMinutes}) {
    return NotificationSettings(
      preReminderLeadMinutes:
          preReminderLeadMinutes ?? this.preReminderLeadMinutes,
    );
  }
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsController, NotificationSettings>(
      NotificationSettingsController.new,
    );

class NotificationSettingsController extends Notifier<NotificationSettings> {
  @override
  NotificationSettings build() {
    _loadFromPrefs();
    return const NotificationSettings(
      preReminderLeadMinutes: NotificationService.defaultPreReminderLeadMinutes,
    );
  }

  Future<void> setPreReminderLeadMinutes(int minutes) async {
    final service = ref.read(notificationServiceProvider);
    await service.setPreReminderLeadMinutes(minutes);

    final normalized = await service.getPreReminderLeadMinutes();
    state = state.copyWith(preReminderLeadMinutes: normalized);

    await _reschedulePendingTasks();
  }

  Future<void> _loadFromPrefs() async {
    final service = ref.read(notificationServiceProvider);
    final leadMinutes = await service.getPreReminderLeadMinutes();
    state = state.copyWith(preReminderLeadMinutes: leadMinutes);
  }

  Future<void> _reschedulePendingTasks() async {
    final repository = ref.read(taskRepositoryProvider);
    final notifications = ref.read(notificationServiceProvider);
    final tasks = await repository.getAllTasks();

    for (final task in tasks) {
      if (task.isCompleted || task.dueDate == null) {
        continue;
      }
      await notifications.scheduleForTask(task);
    }
  }
}
