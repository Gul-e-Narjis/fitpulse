import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'app_state.dart';
import 'gamification.dart';

// ── In-app notification ───────────────────────────────────────────────────────
enum NotifType { workout, streak, water, weight, goal, badge, leaderboard }

class AppNotification {
  final String id; // deterministic, e.g. "water-2026-10-04-3", so no duplicates
  final NotifType type;
  final String title;
  final String body;
  final int createdMs;
  final bool read;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdMs,
    this.read = false,
  });

  Map<String, dynamic> toMap() => {
    'type': type.name,
    'title': title,
    'body': body,
    'createdMs': createdMs,
    'read': read,
  };

  static AppNotification fromDoc(String id, Map<String, dynamic> m) =>
      AppNotification(
        id: id,
        type: NotifType.values.firstWhere(
          (t) => t.name == m['type'],
          orElse: () => NotifType.goal,
        ),
        title: m['title'] as String? ?? '',
        body: m['body'] as String? ?? '',
        createdMs: (m['createdMs'] as num?)?.toInt() ?? 0,
        read: m['read'] as bool? ?? false,
      );

  AppNotification copyWith({bool? read}) => AppNotification(
    id: id,
    type: type,
    title: title,
    body: body,
    createdMs: createdMs,
    read: read ?? this.read,
  );

  IconData get icon => switch (type) {
    NotifType.workout => Icons.fitness_center_rounded,
    NotifType.streak => Icons.local_fire_department_rounded,
    NotifType.water => Icons.water_drop_rounded,
    NotifType.weight => Icons.monitor_weight_outlined,
    NotifType.goal => Icons.flag_rounded,
    NotifType.badge => Icons.emoji_events_rounded,
    NotifType.leaderboard => Icons.leaderboard_rounded,
  };

  Color get color => switch (type) {
    NotifType.workout => const Color(0xFF2DD4BF),
    NotifType.streak => const Color(0xFFFB923C),
    NotifType.water => const Color(0xFF22D3EE),
    NotifType.weight => const Color(0xFF8B5CF6),
    NotifType.goal => const Color(0xFFA3E635),
    NotifType.badge => const Color(0xFFFBBF24),
    NotifType.leaderboard => const Color(0xFF38BDF8),
  };
}

// ── NotificationCenter ────────────────────────────────────────────────────────
// Everything happens inside the app — no browser or push notifications.
//   users/{uid}/notifications/{id}   the list (read / unread)
//   users/{uid}/meta/notifications   reminder settings
// Smart notifications are generated when the app opens and re-checked every
// minute while it stays open; new ones also slide in as a banner.
class NotificationCenter extends ChangeNotifier {
  final AppState app;

  NotificationCenter(this.app) {
    app.addListener(_onAppChanged);
    _onAppChanged();
  }

  static const _limit = 50;

  String? _uid;
  bool _ready = false;
  List<AppNotification> _items = [];
  final List<AppNotification> _banners = [];
  Set<String>? _knownBadges;
  Timer? _timer;

  // Reminder settings
  TimeOfDay? _workoutTime = const TimeOfDay(hour: 18, minute: 0);
  bool _waterOn = true;

  List<AppNotification> get items => _items;
  int get unreadCount => _items.where((n) => !n.read).length;
  AppNotification? get currentBanner =>
      _banners.isEmpty ? null : _banners.first;
  TimeOfDay? get workoutTime => _workoutTime;
  bool get waterRemindersOn => _waterOn;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      FirebaseFirestore.instance.collection('users').doc(_uid);
  CollectionReference<Map<String, dynamic>> get _col =>
      _userDoc.collection('notifications');
  DocumentReference<Map<String, dynamic>> get _settingsDoc =>
      _userDoc.collection('meta').doc('notifications');

  // ── Lifecycle ──────────────────────────
  void _onAppChanged() {
    if (app.uid != _uid) {
      _reset();
      _uid = app.uid;
      if (_uid != null) _start();
      return;
    }
    if (!_ready) return;
    _checkNewBadges();
  }

  void _reset() {
    _timer?.cancel();
    _timer = null;
    _ready = false;
    _items = [];
    _banners.clear();
    _knownBadges = null;
    _workoutTime = const TimeOfDay(hour: 18, minute: 0);
    _waterOn = true;
    notifyListeners();
  }

  Future<void> _start() async {
    final uid = _uid;
    try {
      final settings = await _settingsDoc.get();
      final s = settings.data();
      if (s != null) {
        final t = s['workoutTime'] as String?;
        _workoutTime = t == null ? null : _parseTime(t);
        _waterOn = s['waterOn'] as bool? ?? true;
      }
      final snap = await _col
          .orderBy('createdMs', descending: true)
          .limit(_limit)
          .get();
      if (_uid != uid) return;
      _items = snap.docs
          .map((d) => AppNotification.fromDoc(d.id, d.data()))
          .toList();
    } catch (e) {
      debugPrint('Notifications load failed: $e');
    }
    if (_uid != uid) return;
    _ready = true;
    _knownBadges = app.earnedBadgeIds;
    notifyListeners();
    // Let the first screen settle before the first banner appears
    Future.delayed(const Duration(seconds: 2), evaluate);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => evaluate());
  }

  @override
  void dispose() {
    _timer?.cancel();
    app.removeListener(_onAppChanged);
    super.dispose();
  }

  // ── Actions ────────────────────────────
  Future<void> markAllRead() async {
    final unread = _items.where((n) => !n.read).toList();
    if (unread.isEmpty) return;
    _items = [for (final n in _items) n.copyWith(read: true)];
    notifyListeners();
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final n in unread) {
        batch.update(_col.doc(n.id), {'read': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Mark all read failed: $e');
    }
  }

  Future<void> markRead(String id) async {
    final i = _items.indexWhere((n) => n.id == id);
    if (i == -1 || _items[i].read) return;
    _items[i] = _items[i].copyWith(read: true);
    notifyListeners();
    try {
      await _col.doc(id).update({'read': true});
    } catch (e) {
      debugPrint('Mark read failed: $e');
    }
  }

  Future<void> delete(String id) async {
    _items.removeWhere((n) => n.id == id);
    _banners.removeWhere((n) => n.id == id);
    notifyListeners();
    try {
      await _col.doc(id).delete();
    } catch (e) {
      debugPrint('Delete notification failed: $e');
    }
  }

  void dismissBanner() {
    if (_banners.isEmpty) return;
    _banners.removeAt(0);
    notifyListeners();
  }

  Future<void> setWorkoutTime(TimeOfDay? time) async {
    _workoutTime = time;
    notifyListeners();
    await _saveSettings();
    evaluate();
  }

  Future<void> setWaterReminders(bool on) async {
    _waterOn = on;
    notifyListeners();
    await _saveSettings();
    evaluate();
  }

  Future<void> _saveSettings() async {
    if (_uid == null) return;
    try {
      await _settingsDoc.set({
        'workoutTime': _workoutTime == null ? null : _formatTime(_workoutTime!),
        'waterOn': _waterOn,
      });
    } catch (e) {
      debugPrint('Reminder settings save failed: $e');
    }
  }

  // ── Smart rules ────────────────────────
  void evaluate() {
    if (!_ready || _uid == null) return;
    final now = DateTime.now();
    final today = _dateKey(now);
    final week = Gamification.weekKey(now);
    final workedToday = app.workoutHistory.any((s) => s.date == today);
    final streak = app.currentStreak;
    final minutesNow = now.hour * 60 + now.minute;

    // Daily workout reminder at the chosen time
    final wt = _workoutTime;
    if (wt != null && !workedToday && minutesNow >= wt.hour * 60 + wt.minute) {
      final plan = app.getWorkoutsForDay(_weekday(now));
      _add(
        'workout-$today',
        NotifType.workout,
        'Time to train 💪',
        plan.isNotEmpty
            ? 'Your ${plan.first.category} workout is planned for today.'
            : 'A quick session keeps you on track. Let\'s go!',
      );
    }

    // Streak at risk
    if (streak > 0 && !workedToday && now.hour >= 12) {
      _add(
        'streak-$today',
        NotifType.streak,
        'Your streak is at risk 🔥',
        'No workout yet today — your $streak-day streak will break at midnight!',
      );
    }

    // Water: a nudge per 3-hour slot when behind the day's pace
    final goal = app.waterGoalGlasses;
    if (_waterOn && goal > 0 && now.hour >= 10 && now.hour < 22) {
      final expected = (goal * ((now.hour - 8) / 12)).clamp(1, goal).floor();
      if (app.todayGlasses < expected) {
        _add(
          'water-$today-${now.hour ~/ 3}',
          NotifType.water,
          'Hydration check 💧',
          'You\'ve had ${app.todayGlasses} of $goal glasses today. Time for a glass of water!',
        );
      }
    }

    // Weight log reminder: nothing logged in the last 7 days
    final last = app.weights.isEmpty
        ? null
        : DateTime.parse(app.weights.last.date);
    if (last == null || now.difference(last).inDays >= 7) {
      _add(
        'weight-$week',
        NotifType.weight,
        'Log your weight ⚖️',
        last == null
            ? 'Add your first weigh-in to start tracking progress.'
            : 'It\'s been a week since your last weigh-in.',
      );
    }

    // Weekly goal reached
    if (app.weeklyWorkouts >= app.weeklyGoal) {
      _add(
        'goal-$week',
        NotifType.goal,
        'Weekly goal smashed! 🎯',
        'You hit ${app.weeklyGoal} workouts this week. Amazing consistency!',
      );
    }

    // New leaderboard week
    if (app.friends.isNotEmpty) {
      _add(
        'leaderboard-$week',
        NotifType.leaderboard,
        'New leaderboard week 🏆',
        'Scores reset — you have ${app.weeklyXp} XP so far. Climb to #1!',
      );
    }
  }

  void _checkNewBadges() {
    final known = _knownBadges;
    if (known == null) return;
    final earned = app.earnedBadgeIds;
    for (final id in earned.difference(known)) {
      final b = Badges.byId(id);
      if (b == null) continue;
      _add(
        'badge-$id',
        NotifType.badge,
        'New badge: ${b.title} ${b.emoji}',
        b.description,
        banner: false, // the confetti popup already celebrates it
      );
    }
    _knownBadges = earned;
  }

  void _add(
    String id,
    NotifType type,
    String title,
    String body, {
    bool banner = true,
  }) {
    if (_items.any((n) => n.id == id)) return;
    final n = AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      createdMs: DateTime.now().millisecondsSinceEpoch,
    );
    _items.insert(0, n);
    if (_items.length > _limit) _items.removeLast();
    if (banner) _banners.add(n);
    notifyListeners();
    _col.doc(id).set(n.toMap()).catchError((Object e) {
      debugPrint('Notification save failed: $e');
    });
  }

  // ── Helpers ────────────────────────────
  static String _dateKey(DateTime d) => d.toIso8601String().split('T')[0];

  static String _weekday(DateTime d) => const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][d.weekday - 1];

  static String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static TimeOfDay? _parseTime(String s) {
    final p = s.split(':');
    if (p.length != 2) return null;
    final h = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }
}
