import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_shit_done/src/features/notifications/notification_providers.dart';
import 'package:get_shit_done/src/features/notifications/notification_settings_provider.dart';
import 'package:get_shit_done/src/theme/theme_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsProvider);
    final notificationSettings = ref.watch(notificationSettingsProvider);
    final controller = ref.read(themeSettingsProvider.notifier);
    final notificationController = ref.read(
      notificationSettingsProvider.notifier,
    );
    final notificationService = ref.read(notificationServiceProvider);
    final exactAlarmAccess = ref.watch(exactAlarmAccessProvider);

    final selectedLeadMinutes = notificationSettings.preReminderLeadMinutes
        .clamp(0, 120);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            leading: Icon(Icons.notifications_active_outlined),
            title: Text('Notification permissions'),
            subtitle: Text('Will be requested on first launch of reminders.'),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.schedule_send_outlined),
            title: const Text('Pre-reminder lead time'),
            subtitle: DropdownButton<int>(
              value: selectedLeadMinutes,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 0, child: Text('Off')),
                DropdownMenuItem(value: 5, child: Text('5 minutes before')),
                DropdownMenuItem(value: 10, child: Text('10 minutes before')),
                DropdownMenuItem(value: 15, child: Text('15 minutes before')),
                DropdownMenuItem(value: 30, child: Text('30 minutes before')),
                DropdownMenuItem(value: 60, child: Text('1 hour before')),
                DropdownMenuItem(value: 120, child: Text('2 hours before')),
              ],
              onChanged: (value) {
                if (value != null) {
                  notificationController.setPreReminderLeadMinutes(value);
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.alarm_outlined),
            title: Text('Exact alarms'),
            subtitle: Text(
              exactAlarmAccess.when(
                data: (granted) => granted
                    ? 'Access granted. Android alarms are available.'
                    : 'Access not granted. Enable in Special access > Alarms & reminders.',
                loading: () => 'Checking alarm access...',
                error: (error, stackTrace) =>
                    'Could not read alarm access state. Try requesting again.',
              ),
            ),
            trailing: FilledButton.tonal(
              onPressed: () async {
                final result = await notificationService
                    .ensureAlarmPermissions();
                ref.invalidate(exactAlarmAccessProvider);
                if (!context.mounted) {
                  return;
                }
                final snackText = result.exactAlarmsGranted
                    ? 'Alarm permission granted.'
                    : 'Exact alarm permission is still disabled in system settings.';
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(snackText)));
              },
              child: const Text('Request now'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 4, left: 16, right: 16),
            child: Text(
              'Note: Exact alarm is a Special App Access on Android, not a regular runtime permission list entry.',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () async {
                    await notificationService.showTestNotification();
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Test notification sent.')),
                    );
                  },
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: const Text('Test Notification'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () async {
                    final ok = await notificationService.triggerTestAlarm();
                    if (!context.mounted) {
                      return;
                    }
                    final message = ok
                        ? 'Test alarm scheduled (about 1 second).'
                        : 'Exact alarm permission is not granted.';
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  },
                  icon: const Icon(Icons.alarm),
                  label: const Text('Test Alarm'),
                ),
              ),
            ],
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Theme mode'),
            subtitle: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {settings.mode},
              onSelectionChanged: (selection) {
                controller.setThemeMode(selection.first);
              },
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Accent palette'),
            subtitle: DropdownButton<AppPalette>(
              value: settings.palette,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: AppPalette.ocean,
                  child: Text('Ocean Teal'),
                ),
                DropdownMenuItem(
                  value: AppPalette.ember,
                  child: Text('Ember Orange'),
                ),
                DropdownMenuItem(
                  value: AppPalette.forest,
                  child: Text('Forest Green'),
                ),
              ],
              onChanged: (palette) {
                if (palette != null) {
                  controller.setPalette(palette);
                }
              },
            ),
          ),
          const Divider(),
          SwitchListTile(
            value: settings.reducedMotion,
            onChanged: (value) => controller.setReducedMotion(value),
            secondary: const Icon(Icons.animation_outlined),
            title: const Text('Reduced motion'),
            subtitle: const Text(
              'Disables celebratory and transition animations.',
            ),
          ),
        ],
      ),
    );
  }
}
