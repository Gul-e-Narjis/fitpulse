import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ── WorkoutSession model ──────────────────────────────────────────────────────
class WorkoutSession {
  final String category;
  final String date;
  final int durationMinutes;
  final int exercisesCompleted;
  final double caloriesBurned;
  // Actual active time; older sessions only stored whole minutes
  final int durationSeconds;
  // Ended early from the ✕ button
  final bool partial;
  // Local start time (ISO-8601), used for time-of-day badges
  final String? startedAt;

  WorkoutSession({
    required this.category,
    required this.date,
    required this.durationMinutes,
    required this.exercisesCompleted,
    required this.caloriesBurned,
    int? durationSeconds,
    this.partial = false,
    this.startedAt,
  }) : durationSeconds = durationSeconds ?? durationMinutes * 60;

  Map<String, dynamic> toMap() => {
    'category': category,
    'date': date,
    'durationMinutes': durationMinutes,
    'durationSeconds': durationSeconds,
    'exercisesCompleted': exercisesCompleted,
    'caloriesBurned': caloriesBurned,
    'partial': partial,
    if (startedAt != null) 'startedAt': startedAt,
  };

  static WorkoutSession fromMap(Map<String, dynamic> m) => WorkoutSession(
    category: m['category'] as String,
    date: m['date'] as String,
    durationMinutes: (m['durationMinutes'] as num).toInt(),
    durationSeconds: (m['durationSeconds'] as num?)?.toInt(),
    exercisesCompleted: (m['exercisesCompleted'] as num).toInt(),
    caloriesBurned: (m['caloriesBurned'] as num).toDouble(),
    partial: m['partial'] as bool? ?? false,
    startedAt: m['startedAt'] as String?,
  );
}

// ── PlannedWorkout model ──────────────────────────────────────────────────────
class PlannedWorkout {
  final String id;
  final String category;
  final String day; // 'Monday', 'Tuesday' ...
  final String time; // '07:00 AM'
  bool isFavourite;

  PlannedWorkout({
    required this.id,
    required this.category,
    required this.day,
    required this.time,
    this.isFavourite = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'category': category,
    'day': day,
    'time': time,
    'isFavourite': isFavourite,
  };

  static PlannedWorkout fromMap(Map<String, dynamic> m) => PlannedWorkout(
    id: m['id'] as String,
    category: m['category'] as String,
    day: m['day'] as String,
    time: m['time'] as String,
    isFavourite: m['isFavourite'] as bool? ?? false,
  );
}

// ── BmiRecord model ───────────────────────────────────────────────────────────
class BmiRecord {
  final String date; // ISO-8601
  final double bmi;
  final double weight;
  final double height;

  BmiRecord({
    required this.date,
    required this.bmi,
    required this.weight,
    required this.height,
  });

  Map<String, dynamic> toMap() => {
    'date': date,
    'bmi': bmi,
    'weight': weight,
    'height': height,
  };

  static BmiRecord fromMap(Map<String, dynamic> m) => BmiRecord(
    date: m['date'] as String,
    bmi: (m['bmi'] as num).toDouble(),
    weight: (m['weight'] as num).toDouble(),
    height: (m['height'] as num).toDouble(),
  );
}

// ── AppState ──────────────────────────────────────────────────────────────────
// All user data lives in one Firestore document: users/{uid}.
class AppState extends ChangeNotifier {
  // ── Signed-in user ─────────────────────
  String? _uid;

  // ── User Profile ──────────────────────
  String _userName = _defaultName;
  String _userEmail = '';
  double _userWeight = 70.0;
  double _userHeight = 170.0;
  int _userAge = 25;
  String _fitnessGoal = 'Stay Fit';
  String? _avatarSeed;

  // ── Workout History ────────────────────
  List<WorkoutSession> _workoutHistory = [];

  // ── Workout Planner ────────────────────
  List<PlannedWorkout> _plannedWorkouts = [];

  // ── BMI History ────────────────────────
  List<BmiRecord> _bmiHistory = [];

  // ── Step Counter ───────────────────────
  int _todaySteps = 0;
  int _stepGoal = 10000;

  // ── Notifications ──────────────────────
  bool _notificationsEnabled = true;

  // ── Getters — Profile ──────────────────
  bool get isSignedIn => _uid != null;
  String get userName => _userName;
  String get userEmail => _userEmail;
  double get userWeight => _userWeight;
  double get userHeight => _userHeight;
  int get userAge => _userAge;
  String get fitnessGoal => _fitnessGoal;
  // DiceBear seed; falls back to the user's name
  String get avatarSeed => _avatarSeed ?? _userName;

  // ── Getters — History ──────────────────
  List<WorkoutSession> get workoutHistory => _workoutHistory;

  int get totalWorkoutsCompleted => _workoutHistory.length;

  int get totalMinutesWorkedOut =>
      (_workoutHistory.fold(0, (total, s) => total + s.durationSeconds) / 60)
          .round();

  double get totalCaloriesBurned =>
      _workoutHistory.fold(0.0, (total, s) => total + s.caloriesBurned);

  int get weeklyWorkouts {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return _workoutHistory.where((s) {
      final date = DateTime.parse(s.date);
      return date.isAfter(weekStart.subtract(const Duration(days: 1)));
    }).length;
  }

  // Consecutive workout days ending today (or yesterday)
  int get currentStreak {
    if (_workoutHistory.isEmpty) return 0;
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final day = now.subtract(Duration(days: i));
      final worked = _workoutHistory.any((s) {
        final d = DateTime.parse(s.date);
        return d.year == day.year && d.month == day.month && d.day == day.day;
      });
      if (worked) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  // Last 7 days calories per day — chart ke liye
  List<double> get last7DaysCalories {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return _workoutHistory
          .where((s) {
            final d = DateTime.parse(s.date);
            return d.year == day.year &&
                d.month == day.month &&
                d.day == day.day;
          })
          .fold(0.0, (total, s) => total + s.caloriesBurned);
    });
  }

  // Last 7 days workout minutes per day — bar chart ke liye
  List<double> get last7DaysMinutes {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return _workoutHistory
          .where((s) {
            final d = DateTime.parse(s.date);
            return d.year == day.year &&
                d.month == day.month &&
                d.day == day.day;
          })
          .fold(0.0, (total, s) => total + s.durationMinutes);
    });
  }

  // ── Getters — Planner ──────────────────
  List<PlannedWorkout> get plannedWorkouts => _plannedWorkouts;

  List<PlannedWorkout> get favouritePlans =>
      _plannedWorkouts.where((p) => p.isFavourite).toList();

  List<PlannedWorkout> getWorkoutsForDay(String day) =>
      _plannedWorkouts.where((p) => p.day == day).toList();

  // ── Getters — BMI History ──────────────
  List<BmiRecord> get bmiHistory => _bmiHistory;

  // ── Getters — Steps ────────────────────
  int get todaySteps => _todaySteps;
  int get stepGoal => _stepGoal;
  double get stepProgress => (_todaySteps / _stepGoal).clamp(0.0, 1.0);

  // ── Getters — Notifications ────────────
  bool get notificationsEnabled => _notificationsEnabled;

  // ── BMI ────────────────────────────────
  double get bmi {
    if (_userHeight <= 0) return 0;
    final h = _userHeight / 100;
    return _userWeight / (h * h);
  }

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  Color get bmiColor {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25.0) return Colors.green;
    if (bmi < 30.0) return Colors.orange;
    return Colors.red;
  }

  // ── Session ────────────────────────────
  DocumentReference<Map<String, dynamic>> get _doc =>
      FirebaseFirestore.instance.collection('users').doc(_uid);

  // Load users/{uid}; creates the document on first sign-in.
  // Pass [name] right after sign-up: on web the User object returned by
  // createUser doesn't pick up the displayName set afterwards.
  Future<void> loadUser(User user, {String? name}) async {
    _resetFields();
    _uid = user.uid;
    _userEmail = user.email ?? '';
    final authName = _nonEmpty(name) ?? _nonEmpty(user.displayName);
    if (authName != null) _userName = authName;

    final snap = await _doc.get();
    if (_uid != user.uid) return; // signed out / switched while loading
    final data = snap.data();
    if (data == null) {
      await _save();
    } else {
      _applyData(data);
      // Older documents were created with the placeholder name
      if (_userName == _defaultName && authName != null) {
        _userName = authName;
        await _save();
      }
    }
    notifyListeners();
  }

  static const _defaultName = 'Fitness User';

  static String? _nonEmpty(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  void signOut() {
    _uid = null;
    _resetFields();
    notifyListeners();
  }

  // ── Profile update ─────────────────────
  void updateProfile({
    String? name,
    String? email,
    double? weight,
    double? height,
    int? age,
    String? goal,
  }) {
    if (name != null) _userName = name;
    if (email != null) _userEmail = email;
    if (weight != null) _userWeight = weight;
    if (height != null) _userHeight = height;
    if (age != null) _userAge = age;
    if (goal != null) _fitnessGoal = goal;
    _save();
    notifyListeners();
  }

  void setAvatarSeed(String seed) {
    _avatarSeed = seed;
    _save();
    notifyListeners();
  }

  // ── History ────────────────────────────
  void addWorkoutSession(WorkoutSession session) {
    _workoutHistory.insert(0, session);
    _save();
    notifyListeners();
  }

  void clearHistory() {
    _workoutHistory.clear();
    _save();
    notifyListeners();
  }

  // ── BMI History ────────────────────────
  void addBmiRecord({required double weight, required double height}) {
    final h = height / 100;
    _userWeight = weight;
    _userHeight = height;
    _bmiHistory.insert(
      0,
      BmiRecord(
        date: DateTime.now().toIso8601String(),
        bmi: weight / (h * h),
        weight: weight,
        height: height,
      ),
    );
    _save();
    notifyListeners();
  }

  // ── Planner ────────────────────────────
  void addPlannedWorkout(PlannedWorkout plan) {
    _plannedWorkouts.add(plan);
    _save();
    notifyListeners();
  }

  void removePlannedWorkout(String id) {
    _plannedWorkouts.removeWhere((p) => p.id == id);
    _save();
    notifyListeners();
  }

  void toggleFavourite(String id) {
    final i = _plannedWorkouts.indexWhere((p) => p.id == id);
    if (i != -1) {
      _plannedWorkouts[i].isFavourite = !_plannedWorkouts[i].isFavourite;
      _save();
      notifyListeners();
    }
  }

  // ── Steps ──────────────────────────────
  void updateSteps(int steps) {
    _todaySteps = steps;
    notifyListeners();
  }

  void setStepGoal(int goal) {
    _stepGoal = goal;
    _save();
    notifyListeners();
  }

  // ── Notifications ──────────────────────
  void setNotifications(bool value) {
    _notificationsEnabled = value;
    _save();
    notifyListeners();
  }

  // ── Save ───────────────────────────────
  Future<void> _save() async {
    if (_uid == null) return;
    try {
      await _doc.set({
        'profile': {
          'name': _userName,
          'email': _userEmail,
          'weight': _userWeight,
          'height': _userHeight,
          'age': _userAge,
          'goal': _fitnessGoal,
          if (_avatarSeed != null) 'avatarSeed': _avatarSeed,
        },
        'stepGoal': _stepGoal,
        'notificationsEnabled': _notificationsEnabled,
        'streak': currentStreak,
        'workoutHistory': _workoutHistory.map((s) => s.toMap()).toList(),
        'plannedWorkouts': _plannedWorkouts.map((p) => p.toMap()).toList(),
        'bmiHistory': _bmiHistory.map((b) => b.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore save failed: $e');
    }
  }

  // ── Load helpers ───────────────────────
  void _applyData(Map<String, dynamic> data) {
    final profile = (data['profile'] as Map?)?.cast<String, dynamic>() ?? {};
    _userName = profile['name'] as String? ?? _userName;
    _userEmail = profile['email'] as String? ?? _userEmail;
    _userWeight = (profile['weight'] as num?)?.toDouble() ?? 70.0;
    _userHeight = (profile['height'] as num?)?.toDouble() ?? 170.0;
    _userAge = (profile['age'] as num?)?.toInt() ?? 25;
    _fitnessGoal = profile['goal'] as String? ?? 'Stay Fit';
    _avatarSeed = profile['avatarSeed'] as String?;
    _stepGoal = (data['stepGoal'] as num?)?.toInt() ?? 10000;
    _notificationsEnabled = data['notificationsEnabled'] as bool? ?? true;
    _workoutHistory = _mapList(data['workoutHistory'], WorkoutSession.fromMap);
    _plannedWorkouts = _mapList(
      data['plannedWorkouts'],
      PlannedWorkout.fromMap,
    );
    _bmiHistory = _mapList(data['bmiHistory'], BmiRecord.fromMap);
  }

  static List<T> _mapList<T>(
    Object? raw,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((m) => fromMap(m.cast<String, dynamic>()))
        .toList();
  }

  void _resetFields() {
    _userName = _defaultName;
    _userEmail = '';
    _userWeight = 70.0;
    _userHeight = 170.0;
    _userAge = 25;
    _fitnessGoal = 'Stay Fit';
    _avatarSeed = null;
    _workoutHistory = [];
    _plannedWorkouts = [];
    _bmiHistory = [];
    _todaySteps = 0;
    _stepGoal = 10000;
    _notificationsEnabled = true;
  }
}
