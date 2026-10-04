import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../services/notification_center.dart';
import '../theme/fp_theme.dart';
import '../theme/fp_widgets.dart';

// ── Notification Center (in-app only) ─────────────────────────────────────────
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final center = context.watch<NotificationCenter>();
    final items = center.items;

    return Scaffold(
      backgroundColor: FpColors.bg,
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(child: Text('Notifications', style: FpText.h1())),
                  if (center.unreadCount > 0)
                    TextButton(
                      onPressed: center.markAllRead,
                      child: Text(
                        'Mark all read',
                        style: FpText.label(
                          color: FpColors.tealLight,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const _ReminderSettings(),
              const SizedBox(height: 24),
              SectionTitle(
                'Inbox',
                action: center.unreadCount > 0
                    ? '${center.unreadCount} unread'
                    : null,
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const TintIcon(
                        Icons.notifications_none_rounded,
                        color: FpColors.tealLight,
                        size: 60,
                      ),
                      const SizedBox(height: 12),
                      Text('You\'re all caught up', style: FpText.h3()),
                      const SizedBox(height: 4),
                      Text(
                        'Reminders, badges and streak alerts will show up here.',
                        style: FpText.muted(),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                  child: Text(
                    'Swipe left to delete',
                    style: FpText.muted(size: 11),
                  ),
                ),
                for (final (i, n) in items.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _NotificationTile(notification: n),
                  ).animate().fadeIn(delay: (30 * i).ms).slideX(begin: 0.06),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  const _NotificationTile({required this.notification});

  static String _ago(int ms) {
    final d = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(ms),
    );
    if (d.inMinutes < 1) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    final t = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${t.day}/${t.month}/${t.year}';
  }

  @override
  Widget build(BuildContext context) {
    final center = context.read<NotificationCenter>();
    final n = notification;
    return Dismissible(
      key: ValueKey(n.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => center.delete(n.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: FpColors.coral.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: FpColors.coral),
      ),
      child: GlassCard(
        onTap: () => center.markRead(n.id),
        padding: const EdgeInsets.all(14),
        gradient: n.read
            ? null
            : LinearGradient(
                colors: [
                  n.color.withValues(alpha: 0.16),
                  Colors.white.withValues(alpha: 0.03),
                ],
              ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TintIcon(n.icon, color: n.color, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: FpText.h3().copyWith(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(_ago(n.createdMs), style: FpText.muted(size: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(n.body, style: FpText.muted(size: 13)),
                ],
              ),
            ),
            if (!n.read) ...[
              const SizedBox(width: 8),
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: n.color,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: n.color, blurRadius: 6)],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReminderSettings extends StatelessWidget {
  const _ReminderSettings();

  @override
  Widget build(BuildContext context) {
    final center = context.watch<NotificationCenter>();
    final time = center.workoutTime;
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('REMINDERS', style: FpText.label(color: FpColors.tealLight)),
          const SizedBox(height: 6),
          Row(
            children: [
              const TintIcon(
                Icons.alarm_rounded,
                color: FpColors.tealLight,
                size: 38,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily workout reminder',
                      style: FpText.h3().copyWith(fontSize: 14),
                    ),
                    Text(
                      time == null
                          ? 'Off'
                          : 'Every day at ${time.format(context)}',
                      style: FpText.muted(size: 12),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: time ?? const TimeOfDay(hour: 18, minute: 0),
                  );
                  if (picked != null) center.setWorkoutTime(picked);
                },
                child: Text(
                  time == null ? 'Set' : 'Change',
                  style: FpText.label(color: FpColors.lime, size: 12),
                ),
              ),
              Switch(
                value: time != null,
                onChanged: (on) => center.setWorkoutTime(
                  on ? const TimeOfDay(hour: 18, minute: 0) : null,
                ),
              ),
            ],
          ),
          const Divider(color: FpColors.border, height: 18),
          Row(
            children: [
              const TintIcon(
                Icons.water_drop_rounded,
                color: Color(0xFF22D3EE),
                size: 38,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Water reminders',
                      style: FpText.h3().copyWith(fontSize: 14),
                    ),
                    Text(
                      'Nudges when you\'re behind your daily goal',
                      style: FpText.muted(size: 12),
                    ),
                  ],
                ),
              ),
              Switch(
                value: center.waterRemindersOn,
                onChanged: center.setWaterReminders,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Reminders appear inside the app while it\'s open.',
            style: FpText.muted(size: 11),
          ),
        ],
      ),
    );
  }
}
