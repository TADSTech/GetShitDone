import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_shit_done/src/database/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

const String _defaultChannelId = 'task_deadlines';
const String _defaultChannelName = 'Task Deadlines';
const String _defaultChannelDescription =
    'Notifications for upcoming task deadlines.';

const String _alarmChannelId = 'must_do_alarms_v2';
const String _alarmChannelName = 'Must Do Alarms';
const String _alarmChannelDescription =
    'High-priority alarms for must-do tasks.';

const String _permissionRequestedKey = 'notification_permission_requested_v1';
const String _preReminderLeadMinutesKey = 'pre_reminder_lead_minutes_v1';
const int _alarmIdOffset = 100000;
const int _preReminderIdOffset = 200000;
const int _testNotificationId = 900000;
const int _testAlarmId = 900001;
const int _defaultPreReminderLeadMinutes = 15;
const int _minPreReminderLeadMinutes = 0;
const int _maxPreReminderLeadMinutes = 240;

@pragma('vm:entry-point')
Future<void> mustDoAlarmFallbackCallback() async {
  // In aggressive OEM power modes, scheduled notifications can be suppressed.
  // This fallback raises an alarm notification when the exact alarm callback runs.
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  final notifications = FlutterLocalNotificationsPlugin();
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: androidSettings);

  await notifications.initialize(settings);
  final androidPlugin = notifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(
      _alarmChannelId,
      _alarmChannelName,
      description: _alarmChannelDescription,
      importance: Importance.max,
      playSound: true,
    ),
  );

  final fallbackNotificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  await notifications.show(
    fallbackNotificationId,
    'Task alarm',
    'A due task requires your attention.',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        _alarmChannelId,
        _alarmChannelName,
        channelDescription: _alarmChannelDescription,
        importance: Importance.max,
        priority: Priority.max,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        playSound: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    ),
  );
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final StreamController<int> _taskTapController =
      StreamController<int>.broadcast();

  bool _initialized = false;

  static const int defaultPreReminderLeadMinutes =
      _defaultPreReminderLeadMinutes;
  static const int minPreReminderLeadMinutes = _minPreReminderLeadMinutes;
  static const int maxPreReminderLeadMinutes = _maxPreReminderLeadMinutes;

  Stream<int> get taskTapStream => _taskTapController.stream;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          notificationTapBackgroundHandler,
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _defaultChannelId,
        _defaultChannelName,
        description: _defaultChannelDescription,
        importance: Importance.high,
      ),
    );

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _alarmChannelId,
        _alarmChannelName,
        description: _alarmChannelDescription,
        importance: Importance.max,
        playSound: true,
      ),
    );

    await AndroidAlarmManager.initialize();
    tz_data.initializeTimeZones();

    final launchDetails = await _notifications
        .getNotificationAppLaunchDetails();
    final launchResponse = launchDetails?.notificationResponse;
    if (launchResponse != null) {
      _handlePayload(
        launchResponse.payload,
        actionId: launchResponse.actionId,
        notificationId: launchResponse.id,
      );
    }

    _initialized = true;
  }

  Future<void> requestPermissionsOnFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyRequested = prefs.getBool(_permissionRequestedKey) ?? false;
    if (alreadyRequested) {
      return;
    }

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    await prefs.setBool(_permissionRequestedKey, true);
  }

  Future<bool> ensureNotificationPermission() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await androidPlugin?.requestNotificationsPermission();
    return granted ?? true;
  }

  Future<bool> ensureExactAlarmPermission() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestExactAlarmsPermission();
    final canSchedule = await canScheduleExactAlarms();
    return canSchedule;
  }

  Future<bool> canScheduleExactAlarms() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await androidPlugin?.canScheduleExactNotifications() ?? true;
  }

  Future<AlarmPermissionResult> ensureAlarmPermissions() async {
    final notificationsGranted = await ensureNotificationPermission();
    final exactAlarmsGranted = await ensureExactAlarmPermission();
    return AlarmPermissionResult(
      notificationsGranted: notificationsGranted,
      exactAlarmsGranted: exactAlarmsGranted,
    );
  }

  Future<void> showTestNotification() async {
    if (!_initialized) {
      return;
    }

    await ensureNotificationPermission();
    await _notifications.show(
      _testNotificationId,
      'Test notification',
      'If you see this, local notifications are working.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _defaultChannelId,
          _defaultChannelName,
          channelDescription: _defaultChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<bool> triggerTestAlarm() async {
    if (!_initialized) {
      return false;
    }

    final permissionResult = await ensureAlarmPermissions();
    if (!permissionResult.exactAlarmsGranted) {
      return false;
    }

    await AndroidAlarmManager.cancel(_testAlarmId);
    await AndroidAlarmManager.oneShot(
      const Duration(seconds: 1),
      _testAlarmId,
      mustDoAlarmFallbackCallback,
      exact: true,
      wakeup: true,
      allowWhileIdle: true,
      rescheduleOnReboot: false,
    );
    return true;
  }

  Future<void> scheduleForTask(Task task) async {
    if (!_initialized) {
      return;
    }

    await cancelForTask(task.id);

    if (task.dueDate == null || task.isCompleted) {
      return;
    }

    final now = DateTime.now();
    final dueDate = task.dueDate!;
    final preReminderLeadMinutes = await _getPreReminderLeadMinutes();
    final isMustDo = task.useAlarm || task.priority >= 3;
    final notificationsGranted = await ensureNotificationPermission();
    var exactGranted = true;
    if (isMustDo) {
      exactGranted = await ensureExactAlarmPermission();
      if (!exactGranted) {
        debugPrint(
          'Exact alarm permission not granted for task ${task.id}. Falling back to notification only.',
        );
      }
    }

    if (!notificationsGranted) {
      debugPrint(
        'Notification permission not granted. Task ${task.id} reminders may not be shown.',
      );
    }

    if (dueDate.isBefore(now)) {
      // If task is already due (or just missed), deliver immediately instead of silently dropping it.
      final overdueBy = now.difference(dueDate);
      if (overdueBy.inMinutes <= 10) {
        await _notifications.show(
          _notificationIdForTask(task.id),
          task.title,
          'Task is due now.',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              _defaultChannelId,
              _defaultChannelName,
              channelDescription: _defaultChannelDescription,
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          payload: jsonEncode({'taskId': task.id}),
        );
      }
      return;
    }

    final notificationId = _notificationIdForTask(task.id);
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        isMustDo ? _alarmChannelId : _defaultChannelId,
        isMustDo ? _alarmChannelName : _defaultChannelName,
        channelDescription: isMustDo
            ? _alarmChannelDescription
            : _defaultChannelDescription,
        importance: isMustDo ? Importance.max : Importance.high,
        priority: isMustDo ? Priority.max : Priority.high,
        fullScreenIntent: isMustDo,
        category: isMustDo ? AndroidNotificationCategory.alarm : null,
        playSound: true,
        audioAttributesUsage: isMustDo
          ? AudioAttributesUsage.alarm
          : AudioAttributesUsage.notification,
        ongoing: isMustDo,
        autoCancel: !isMustDo,
        actions: isMustDo
            ? const [
                AndroidNotificationAction(
                  'dismiss_alarm',
                  'Dismiss',
                  cancelNotification: true,
                ),
              ]
            : null,
      ),
    );

    await _notifications.zonedSchedule(
      notificationId,
      task.title,
      (task.description ?? '').isEmpty
          ? 'Task deadline reached.'
          : task.description,
      tz.TZDateTime.from(dueDate, tz.local),
      details,
      payload: jsonEncode({'taskId': task.id}),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    final preReminderAt = dueDate.subtract(
      Duration(minutes: preReminderLeadMinutes),
    );
    if (preReminderLeadMinutes > 0 && preReminderAt.isAfter(now)) {
      await _notifications.zonedSchedule(
        _preReminderNotificationIdForTask(task.id),
        '${task.title} due soon',
        'Due in $preReminderLeadMinutes minutes.',
        tz.TZDateTime.from(preReminderAt, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _defaultChannelId,
            _defaultChannelName,
            channelDescription: _defaultChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: jsonEncode({'taskId': task.id}),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    if (isMustDo && exactGranted) {
      await AndroidAlarmManager.oneShotAt(
        dueDate,
        _alarmIdForTask(task.id),
        mustDoAlarmFallbackCallback,
        exact: true,
        wakeup: true,
        allowWhileIdle: true,
        rescheduleOnReboot: true,
      );
    }
  }

  Future<void> cancelForTask(int taskId) async {
    if (!_initialized) {
      return;
    }

    await _notifications.cancel(_notificationIdForTask(taskId));
    await _notifications.cancel(_preReminderNotificationIdForTask(taskId));
    await AndroidAlarmManager.cancel(_alarmIdForTask(taskId));
  }

  Future<void> _onNotificationResponse(NotificationResponse response) async {
    _handlePayload(
      response.payload,
      actionId: response.actionId,
      notificationId: response.id,
    );
  }

  void _handlePayload(
    String? payload, {
    String? actionId,
    int? notificationId,
  }) {
    if (actionId == 'dismiss_alarm' && notificationId != null) {
      _notifications.cancel(notificationId);
    }

    if (payload == null || payload.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        return;
      }
      final taskId = decoded['taskId'];
      if (taskId is int) {
        _taskTapController.add(taskId);
      }
    } catch (_) {
      // Ignore malformed payloads.
    }
  }

  int _notificationIdForTask(int taskId) => taskId;

  int _preReminderNotificationIdForTask(int taskId) =>
      taskId + _preReminderIdOffset;

  int _alarmIdForTask(int taskId) => taskId + _alarmIdOffset;

  Future<int> getPreReminderLeadMinutes() async {
    return _getPreReminderLeadMinutes();
  }

  Future<void> setPreReminderLeadMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _preReminderLeadMinutesKey,
      _clampPreReminderLeadMinutes(minutes),
    );
  }

  Future<int> _getPreReminderLeadMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_preReminderLeadMinutesKey);
    return _clampPreReminderLeadMinutes(
      saved ?? _defaultPreReminderLeadMinutes,
    );
  }

  int _clampPreReminderLeadMinutes(int minutes) {
    if (minutes < _minPreReminderLeadMinutes) {
      return _minPreReminderLeadMinutes;
    }
    if (minutes > _maxPreReminderLeadMinutes) {
      return _maxPreReminderLeadMinutes;
    }
    return minutes;
  }
}

class AlarmPermissionResult {
  const AlarmPermissionResult({
    required this.notificationsGranted,
    required this.exactAlarmsGranted,
  });

  final bool notificationsGranted;
  final bool exactAlarmsGranted;
}

@pragma('vm:entry-point')
void notificationTapBackgroundHandler(NotificationResponse response) {
  NotificationService.instance._handlePayload(
    response.payload,
    actionId: response.actionId,
    notificationId: response.id,
  );
}
