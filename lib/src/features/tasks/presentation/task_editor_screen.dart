import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_shit_done/src/database/models/task.dart';
import 'package:get_shit_done/src/database/providers/task_providers.dart';
import 'package:get_shit_done/src/features/notifications/notification_providers.dart';
import 'package:isar/isar.dart';

class TaskEditorScreen extends ConsumerStatefulWidget {
  const TaskEditorScreen({super.key, this.initialTask, this.taskId});

  final Task? initialTask;
  final int? taskId;

  @override
  ConsumerState<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends ConsumerState<TaskEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late final TextEditingController _customRepeatController;

  DateTime? _selectedDueDate;
  int _priority = 1;
  bool _useAlarm = false;
  int _repeatType = TaskRepeat.none;
  int _repeatIntervalDays = 1;
  bool _isSaving = false;

  Task? _loadedTask;
  bool _isLoadingTask = false;

  Task? get _effectiveTask => widget.initialTask ?? _loadedTask;

  bool get _isEditMode => _effectiveTask != null;

  @override
  void initState() {
    super.initState();
    final initialTask = widget.initialTask;
    _titleController = TextEditingController(text: initialTask?.title ?? '');
    _notesController = TextEditingController(
      text: initialTask?.description ?? '',
    );
    _customRepeatController = TextEditingController();
    _selectedDueDate = initialTask?.dueDate;
    _priority = initialTask?.priority ?? 1;
    _useAlarm = initialTask?.useAlarm ?? false;
    _repeatType = initialTask?.repeatType ?? TaskRepeat.none;
    _repeatIntervalDays = initialTask?.repeatIntervalDays ?? 1;
    _customRepeatController.text = '$_repeatIntervalDays';

    if (initialTask == null && widget.taskId != null) {
      _loadTaskById(widget.taskId!);
    }
  }

  Future<void> _loadTaskById(int taskId) async {
    setState(() {
      _isLoadingTask = true;
    });

    final repository = ref.read(taskRepositoryProvider);
    final task = await repository.getTaskById(taskId);
    if (!mounted) {
      return;
    }

    if (task != null) {
      _loadedTask = task;
      _titleController.text = task.title;
      _notesController.text = task.description ?? '';
      _selectedDueDate = task.dueDate;
      _priority = task.priority;
      _useAlarm = task.useAlarm;
      _repeatType = task.repeatType;
      _repeatIntervalDays = task.repeatIntervalDays;
      _customRepeatController.text = '$_repeatIntervalDays';
    }

    setState(() {
      _isLoadingTask = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _customRepeatController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initial = _selectedDueDate ?? now;

    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDate: initial,
    );

    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );

    if (time == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDueDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _clearDueDate() {
    setState(() {
      _selectedDueDate = null;
    });
  }

  Future<void> _handleUseAlarmChanged(bool value) async {
    if (!value) {
      setState(() {
        _useAlarm = false;
      });
      return;
    }

    final notifications = ref.read(notificationServiceProvider);
    final permissionResult = await notifications.ensureAlarmPermissions();

    if (!mounted) {
      return;
    }

    if (!permissionResult.exactAlarmsGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Exact alarm permission is not granted. Enable it in system settings to use Android alarm.',
          ),
        ),
      );
      setState(() {
        _useAlarm = false;
      });
      return;
    }

    if (!permissionResult.notificationsGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notification permission is not granted. Alarm may ring but notifications can be hidden.',
          ),
        ),
      );
    }

    setState(() {
      _useAlarm = true;
    });
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final notes = _notesController.text.trim();
    final existingTask = _effectiveTask;
    final customDays = int.tryParse(_customRepeatController.text.trim());
    final intervalDays = _repeatType == TaskRepeat.custom
        ? (customDays != null && customDays > 0 ? customDays : 1)
        : _repeatType == TaskRepeat.weekly
        ? 7
        : 1;
    final task = Task(
      id: existingTask?.id ?? Isar.autoIncrement,
      title: title,
      description: notes.isEmpty ? null : notes,
      dueDate: _selectedDueDate,
      priority: _priority,
      useAlarm: _useAlarm,
      repeatType: _repeatType,
      repeatIntervalDays: intervalDays,
      isCompleted: existingTask?.isCompleted ?? false,
      completedAt: existingTask?.completedAt,
      categoryId: existingTask?.categoryId,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(taskActionsProvider).upsertTask(task);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save task: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatDueDate(DateTime? dateTime) {
    if (dateTime == null) {
      return 'No deadline';
    }
    final date =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Task' : 'Add Task')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: _isLoadingTask
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      minLines: 3,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.schedule),
                        title: const Text('Deadline'),
                        subtitle: Text(_formatDueDate(_selectedDueDate)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_selectedDueDate != null)
                              IconButton(
                                onPressed: _clearDueDate,
                                icon: const Icon(Icons.clear),
                                tooltip: 'Clear deadline',
                              ),
                            IconButton(
                              onPressed: _pickDateTime,
                              icon: const Icon(Icons.edit_calendar),
                              tooltip: 'Pick date and time',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Priority',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment<int>(
                          value: 1,
                          label: Text('Low'),
                          icon: Icon(Icons.keyboard_arrow_down),
                        ),
                        ButtonSegment<int>(
                          value: 2,
                          label: Text('Medium'),
                          icon: Icon(Icons.drag_handle),
                        ),
                        ButtonSegment<int>(
                          value: 3,
                          label: Text('High'),
                          icon: Icon(Icons.priority_high),
                        ),
                      ],
                      selected: {_priority},
                      onSelectionChanged: (values) {
                        setState(() {
                          _priority = values.first;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile(
                      value: _useAlarm,
                      onChanged: _handleUseAlarmChanged,
                      secondary: const Icon(Icons.alarm),
                      title: const Text('Use Android alarm'),
                      subtitle: const Text(
                        'Triggers an exact alarm at due time (requires exact alarm permission).',
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Repeat',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: _repeatType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Repeat cadence',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: TaskRepeat.none,
                          child: Text('No Repeat'),
                        ),
                        DropdownMenuItem(
                          value: TaskRepeat.daily,
                          child: Text('Daily'),
                        ),
                        DropdownMenuItem(
                          value: TaskRepeat.weekly,
                          child: Text('Weekly'),
                        ),
                        DropdownMenuItem(
                          value: TaskRepeat.monthly,
                          child: Text('Monthly'),
                        ),
                        DropdownMenuItem(
                          value: TaskRepeat.custom,
                          child: Text('Custom interval'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _repeatType = value;
                          if (value == TaskRepeat.weekly) {
                            _customRepeatController.text = '7';
                          }
                          if (value != TaskRepeat.custom &&
                              value != TaskRepeat.weekly) {
                            _customRepeatController.text = '1';
                          }
                        });
                      },
                    ),
                    if (_repeatType == TaskRepeat.custom)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: TextFormField(
                          controller: _customRepeatController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Repeat every (days)',
                          ),
                          validator: (value) {
                            if (_repeatType != TaskRepeat.custom) {
                              return null;
                            }
                            final parsed = int.tryParse((value ?? '').trim());
                            if (parsed == null || parsed <= 0) {
                              return 'Enter a positive number of days';
                            }
                            return null;
                          },
                        ),
                      ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _saveTask,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isEditMode ? 'Save Changes' : 'Create Task'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
