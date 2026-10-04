import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/notification_service.dart';
import 'app_colors.dart';
import 'shared_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Reminder list — locally managed in this screen
  final List<_WorkoutReminder> _reminders = [
    _WorkoutReminder(
      id: 1,
      title: 'Morning Workout',
      time: const TimeOfDay(hour: 7, minute: 0),
      days: ['Mon', 'Wed', 'Fri'],
      isEnabled: true,
    ),
    _WorkoutReminder(
      id: 2,
      title: 'Evening Walk',
      time: const TimeOfDay(hour: 18, minute: 30),
      days: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      isEnabled: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Local notifications can't be scheduled from the browser
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Notifications'),
          backgroundColor: AppColors.background,
        ),
        body: const MobileOnlyNotice(
          icon: Icons.notifications_active_rounded,
          feature: 'Workout reminders',
        ),
      );
    }

    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Master toggle ─────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: appState.notificationsEnabled
                    ? AppColors.sageGreen.withValues(alpha: 0.08)
                    : AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: appState.notificationsEnabled
                      ? AppColors.sageGreen.withValues(alpha: 0.3)
                      : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: appState.notificationsEnabled
                          ? AppColors.sageGreen.withValues(alpha: 0.15)
                          : AppColors.border.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      appState.notificationsEnabled
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_off_rounded,
                      color: appState.notificationsEnabled
                          ? AppColors.sageGreen
                          : AppColors.textGrey,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Workout Reminders',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          appState.notificationsEnabled
                              ? 'Reminders are active'
                              : 'All reminders paused',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: appState.notificationsEnabled,
                    activeThumbColor: AppColors.sageGreen,
                    onChanged: (val) {
                      appState.setNotifications(val);
                      if (val) {
                        NotificationService.initialize();
                      } else {
                        NotificationService.cancelAll();
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Reminders list ────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scheduled Reminders',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                TextButton.icon(
                  onPressed: appState.notificationsEnabled
                      ? () => _showAddReminderDialog(context)
                      : null,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.sageGreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (_reminders.isEmpty)
              _EmptyReminders(onAdd: () => _showAddReminderDialog(context))
            else
              Column(
                children: _reminders.map((reminder) {
                  return _ReminderCard(
                    reminder: reminder,
                    masterEnabled: appState.notificationsEnabled,
                    onToggle: (val) {
                      setState(() => reminder.isEnabled = val);
                      if (val && appState.notificationsEnabled) {
                        NotificationService.scheduleReminder(reminder);
                      } else {
                        NotificationService.cancelReminder(reminder.id);
                      }
                    },
                    onDelete: () {
                      setState(() => _reminders.remove(reminder));
                      NotificationService.cancelReminder(reminder.id);
                    },
                    onEdit: () => _showEditReminderDialog(context, reminder),
                  );
                }).toList(),
              ),

            const SizedBox(height: 28),

            // ── Quick reminder presets ─────────────────
            const Text(
              'Quick Add Presets',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _PresetGrid(
              onAdd: (preset) {
                setState(() {
                  _reminders.add(
                    _WorkoutReminder(
                      id: DateTime.now().millisecondsSinceEpoch,
                      title: preset.title,
                      time: preset.time,
                      days: preset.days,
                      isEnabled: appState.notificationsEnabled,
                    ),
                  );
                });
                if (appState.notificationsEnabled) {
                  NotificationService.scheduleReminder(_reminders.last);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${preset.title} reminder added!'),
                    backgroundColor: AppColors.sageGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            // ── Tips ──────────────────────────────────
            _NotificationTips(),
          ],
        ),
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    _showReminderDialog(context, null);
  }

  void _showEditReminderDialog(
    BuildContext context,
    _WorkoutReminder reminder,
  ) {
    _showReminderDialog(context, reminder);
  }

  void _showReminderDialog(BuildContext context, _WorkoutReminder? existing) {
    final titleController = TextEditingController(text: existing?.title ?? '');
    TimeOfDay selectedTime =
        existing?.time ?? const TimeOfDay(hour: 8, minute: 0);
    final List<String> allDays = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    List<String> selectedDays =
        existing?.days.toList() ?? ['Mon', 'Wed', 'Fri'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            24 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                existing == null ? 'New Reminder' : 'Edit Reminder',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Reminder name',
                  hintText: 'e.g. Morning Run',
                  prefixIcon: const Icon(
                    Icons.label_outline,
                    color: AppColors.sageGreen,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final t = await showTimePicker(
                    context: ctx,
                    initialTime: selectedTime,
                  );
                  if (t != null) setModal(() => selectedTime = t);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: AppColors.sageGreen),
                      const SizedBox(width: 12),
                      Text(
                        selectedTime.format(ctx),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Repeat on',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: allDays.map((day) {
                  final isSel = selectedDays.contains(day);
                  return GestureDetector(
                    onTap: () => setModal(() {
                      if (isSel) {
                        selectedDays.remove(day);
                      } else {
                        selectedDays.add(day);
                      }
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSel ? AppColors.sageGreen : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSel ? AppColors.sageGreen : AppColors.border,
                        ),
                      ),
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSel ? Colors.white : AppColors.textGrey,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedDays.isEmpty ||
                          titleController.text.trim().isEmpty
                      ? null
                      : () {
                          final newReminder = _WorkoutReminder(
                            id: existing?.id ??
                                DateTime.now().millisecondsSinceEpoch,
                            title: titleController.text.trim(),
                            time: selectedTime,
                            days: List.from(selectedDays),
                            isEnabled: true,
                          );
                          setState(() {
                            if (existing != null) {
                              final i = _reminders.indexOf(existing);
                              _reminders[i] = newReminder;
                            } else {
                              _reminders.add(newReminder);
                            }
                          });
                          Navigator.pop(ctx);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sageGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    existing == null ? 'Add Reminder' : 'Save Changes',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reminder model ────────────────────────────────────────────────────────────
class _WorkoutReminder {
  final int id;
  final String title;
  final TimeOfDay time;
  final List<String> days;
  bool isEnabled;

  _WorkoutReminder({
    required this.id,
    required this.title,
    required this.time,
    required this.days,
    required this.isEnabled,
  });
}

// ── Reminder Card ─────────────────────────────────────────────────────────────
class _ReminderCard extends StatelessWidget {
  final _WorkoutReminder reminder;
  final bool masterEnabled;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ReminderCard({
    required this.reminder,
    required this.masterEnabled,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = reminder.isEnabled && masterEnabled;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? AppColors.sageGreen.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.sageGreen.withValues(alpha: 0.12)
                      : AppColors.border.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.alarm,
                  color: isActive ? AppColors.sageGreen : AppColors.textGrey,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      _formatTime(context, reminder.time),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            isActive ? AppColors.sageGreen : AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: reminder.isEnabled,
                activeThumbColor: AppColors.sageGreen,
                onChanged: masterEnabled ? onToggle : null,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 4,
                  children: reminder.days.map((d) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.sageGreen.withValues(alpha: 0.1)
                            : AppColors.border.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        d,
                        style: TextStyle(
                          fontSize: 11,
                          color: isActive
                              ? AppColors.sageGreen
                              : AppColors.textGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppColors.textGrey,
                ),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.redAccent,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(BuildContext context, TimeOfDay t) => t.format(context);
}

// ── Preset model ──────────────────────────────────────────────────────────────
class _Preset {
  final String title;
  final TimeOfDay time;
  final List<String> days;
  final IconData icon;
  final Color color;

  const _Preset({
    required this.title,
    required this.time,
    required this.days,
    required this.icon,
    required this.color,
  });
}

// ── Preset Grid ───────────────────────────────────────────────────────────────
class _PresetGrid extends StatelessWidget {
  final void Function(_Preset preset) onAdd;

  const _PresetGrid({required this.onAdd});

  static const List<_Preset> _presets = [
    _Preset(
      title: 'Morning Run',
      time: TimeOfDay(hour: 6, minute: 30),
      days: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      icon: Icons.directions_run,
      color: Color(0xFF1E9FA3),
    ),
    _Preset(
      title: 'Lunch Workout',
      time: TimeOfDay(hour: 13, minute: 0),
      days: ['Mon', 'Wed', 'Fri'],
      icon: Icons.fitness_center,
      color: Color(0xFF8B7CF6),
    ),
    _Preset(
      title: 'Evening Yoga',
      time: TimeOfDay(hour: 19, minute: 0),
      days: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      icon: Icons.self_improvement,
      color: Color(0xFFE07B54),
    ),
    _Preset(
      title: 'Weekend HIIT',
      time: TimeOfDay(hour: 9, minute: 0),
      days: ['Sat', 'Sun'],
      icon: Icons.bolt,
      color: Color(0xFFE8956D),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: _presets.map((preset) {
        return GestureDetector(
          onTap: () => onAdd(preset),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: preset.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: preset.color.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(preset.icon, color: preset.color, size: 22),
                const Spacer(),
                Text(
                  preset.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: preset.color,
                  ),
                ),
                Text(
                  preset.time.format(context),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyReminders extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyReminders({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.notifications_none_rounded,
            size: 48,
            color: AppColors.border,
          ),
          const SizedBox(height: 12),
          const Text(
            'No reminders yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add your first workout reminder',
            style: TextStyle(fontSize: 13, color: AppColors.textGrey),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, color: AppColors.sageGreen),
            label: const Text(
              'Add Reminder',
              style: TextStyle(color: AppColors.sageGreen),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tips ──────────────────────────────────────────────────────────────────────
class _NotificationTips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E9FA3).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E9FA3).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Color(0xFF1E9FA3), size: 18),
              SizedBox(width: 8),
              Text(
                'Tips for staying consistent',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...[
            'Set reminders at times you\'re already free',
            'Mornings work best for most people',
            'Even a 10-min workout is better than none',
          ].map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.textGrey)),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
