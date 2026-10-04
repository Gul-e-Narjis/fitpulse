import 'package:flutter/material.dart';

import 'app_state.dart';

// ── XP & levels ───────────────────────────────────────────────────────────────
// XP is derived from workout history, so partial workouts earn proportionally
// and old workouts count too.
class Gamification {
  static const xpPerMinute = 10;
  static const xpPerExercise = 5;

  static int xpForSession(WorkoutSession s) =>
      (s.durationSeconds / 60 * xpPerMinute).round() +
      s.exercisesCompleted * xpPerExercise;

  static int totalXp(List<WorkoutSession> history) =>
      history.fold(0, (sum, s) => sum + xpForSession(s));

  // Monday 00:00 of the week containing [d]; used as the leaderboard week key
  static String weekKey([DateTime? d]) {
    final now = d ?? DateTime.now();
    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    return monday.toIso8601String().split('T')[0];
  }

  static int weeklyXp(List<WorkoutSession> history) {
    final key = weekKey();
    return history
        .where((s) => weekKey(DateTime.parse(s.date)) == key)
        .fold(0, (sum, s) => sum + xpForSession(s));
  }

  static const levelNames = [
    'Beginner',
    'Novice',
    'Mover',
    'Active',
    'Athlete',
    'Strong',
    'Elite',
    'Champion',
    'Master',
    'Legend',
  ];

  // XP needed to reach each level (index 0 = level 1)
  static const levelThresholds = [
    0,
    100,
    250,
    500,
    850,
    1300,
    1900,
    2700,
    3700,
    5000,
  ];

  static int levelFor(int xp) {
    var level = 1;
    for (var i = 0; i < levelThresholds.length; i++) {
      if (xp >= levelThresholds[i]) level = i + 1;
    }
    return level;
  }

  static String levelName(int level) => levelNames[(level - 1).clamp(0, 9)];

  // 0..1 progress towards the next level (1.0 at max level)
  static double levelProgress(int xp) {
    final level = levelFor(xp);
    if (level >= levelThresholds.length) return 1;
    final from = levelThresholds[level - 1];
    final to = levelThresholds[level];
    return (xp - from) / (to - from);
  }

  static int xpToNextLevel(int xp) {
    final level = levelFor(xp);
    if (level >= levelThresholds.length) return 0;
    return levelThresholds[level] - xp;
  }
}

// ── Badges ────────────────────────────────────────────────────────────────────
class BadgeDef {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final Color color;
  final bool Function(AppState s) earned;

  const BadgeDef({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
    required this.earned,
  });
}

class Badges {
  static final all = <BadgeDef>[
    BadgeDef(
      id: 'first_workout',
      title: 'First Workout',
      description: 'Complete your first workout',
      emoji: '🏁',
      color: const Color(0xFF2DD4BF),
      earned: (s) => s.workoutHistory.isNotEmpty,
    ),
    BadgeDef(
      id: 'streak_3',
      title: 'On Fire',
      description: 'Work out 3 days in a row',
      emoji: '🔥',
      color: const Color(0xFFFB923C),
      earned: (s) => s.currentStreak >= 3,
    ),
    BadgeDef(
      id: 'streak_7',
      title: 'Week Warrior',
      description: 'Keep a 7-day streak',
      emoji: '⚡',
      color: const Color(0xFFFBBF24),
      earned: (s) => s.currentStreak >= 7,
    ),
    BadgeDef(
      id: 'streak_30',
      title: 'Unstoppable',
      description: 'Keep a 30-day streak',
      emoji: '🏆',
      color: const Color(0xFFA3E635),
      earned: (s) => s.currentStreak >= 30,
    ),
    BadgeDef(
      id: 'workouts_10',
      title: 'Getting Serious',
      description: 'Complete 10 workouts',
      emoji: '💪',
      color: const Color(0xFF38BDF8),
      earned: (s) => s.totalWorkoutsCompleted >= 10,
    ),
    BadgeDef(
      id: 'workouts_50',
      title: 'Half Century',
      description: 'Complete 50 workouts',
      emoji: '🎖️',
      color: const Color(0xFF8B5CF6),
      earned: (s) => s.totalWorkoutsCompleted >= 50,
    ),
    BadgeDef(
      id: 'early_bird',
      title: 'Early Bird',
      description: 'Start a workout before 8 AM',
      emoji: '🌅',
      color: const Color(0xFFFDE047),
      earned: (s) => s.workoutHistory.any((w) {
        final t = w.startedAt == null ? null : DateTime.tryParse(w.startedAt!);
        return t != null && t.hour < 8;
      }),
    ),
    BadgeDef(
      id: 'hydration_hero',
      title: 'Hydration Hero',
      description: 'Hit your water goal on 3 days',
      emoji: '💧',
      color: const Color(0xFF22D3EE),
      earned: (s) => s.waterGoalDays >= 3,
    ),
    BadgeDef(
      id: 'marathoner',
      title: 'Marathoner',
      description: 'Exercise for 300 minutes in total',
      emoji: '⏱️',
      color: const Color(0xFFFB7185),
      earned: (s) => s.totalMinutesWorkedOut >= 300,
    ),
    BadgeDef(
      id: 'level_5',
      title: 'Athlete',
      description: 'Reach level 5',
      emoji: '🚀',
      color: const Color(0xFF14B8A6),
      earned: (s) => s.level >= 5,
    ),
  ];

  static BadgeDef? byId(String id) {
    for (final b in all) {
      if (b.id == id) return b;
    }
    return null;
  }
}
