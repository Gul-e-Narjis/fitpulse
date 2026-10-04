import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'friends_service.dart';
import 'gamification.dart';

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

// ── WeightEntry model (users/{uid}/weights/{id}) ─────────────────────────────
class WeightEntry {
  final String id;
  final double kg;
  final String date; // yyyy-mm-dd
  final int createdMs;

  const WeightEntry({
    required this.id,
    required this.kg,
    required this.date,
    required this.createdMs,
  });

  Map<String, dynamic> toMap() => {
    'kg': kg,
    'date': date,
    'createdMs': createdMs,
  };

  static WeightEntry fromDoc(String id, Map<String, dynamic> m) => WeightEntry(
    id: id,
    kg: (m['kg'] as num).toDouble(),
    date: m['date'] as String,
    createdMs: (m['createdMs'] as num?)?.toInt() ?? 0,
  );

  WeightEntry copyWith({String? id, double? kg, String? date}) => WeightEntry(
    id: id ?? this.id,
    kg: kg ?? this.kg,
    date: date ?? this.date,
    createdMs: createdMs,
  );
}

// ── AppState ──────────────────────────────────────────────────────────────────
// All private user data lives in one Firestore document: users/{uid}.
// A small public card (name, avatar, level, weekly XP) is mirrored to
// publicProfiles/{uid} so friends can see it on the leaderboard.
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
  String _fitnessLevel = 'Beginner';
  int? _daysPerWeek;
  bool _onboarded = true;

  // ── Workout History ────────────────────
  List<WorkoutSession> _workoutHistory = [];

  // ── Workout Planner ────────────────────
  List<PlannedWorkout> _plannedWorkouts = [];

  // ── BMI History ────────────────────────
  List<BmiRecord> _bmiHistory = [];

  // ── Weight ─────────────────────────────
  List<WeightEntry> _weights = [];
  double? _goalWeight;
  double? _startWeight;

  // ── Water (date → glasses) ─────────────
  Map<String, int> _water = {};

  // ── Gamification ───────────────────────
  Map<String, String> _badges = {}; // badge id → date earned
  final List<String> _pendingBadges = []; // earned, not yet celebrated

  // ── Friends ────────────────────────────
  String? _inviteCode;
  List<String> _friends = [];

  // ── Getters — Profile ──────────────────
  bool get isSignedIn => _uid != null;
  String? get uid => _uid;
  String get userName => _userName;
  String get userEmail => _userEmail;
  double get userWeight => _userWeight;
  double get userHeight => _userHeight;
  int get userAge => _userAge;
  String get fitnessGoal => _fitnessGoal;
  // DiceBear seed; falls back to the user's name
  String get avatarSeed => _avatarSeed ?? _userName;
  String get fitnessLevel => _fitnessLevel;
  int? get daysPerWeek => _daysPerWeek;
  int get weeklyGoal => _daysPerWeek ?? 4;
  bool get needsOnboarding => isSignedIn && !_onboarded;

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
          .fold(0.0, (total, s) => total + s.durationSeconds / 60);
    });
  }

  // ── Getters — Gamification ─────────────
  int get xp => Gamification.totalXp(_workoutHistory);
  int get weeklyXp => Gamification.weeklyXp(_workoutHistory);
  int get level => Gamification.levelFor(xp);
  String get levelName => Gamification.levelName(level);
  double get levelProgress => Gamification.levelProgress(xp);
  int get xpToNextLevel => Gamification.xpToNextLevel(xp);
  Set<String> get earnedBadgeIds => _badges.keys.toSet();
  String? get pendingBadge =>
      _pendingBadges.isEmpty ? null : _pendingBadges.first;

  void consumePendingBadge() {
    if (_pendingBadges.isEmpty) return;
    _pendingBadges.removeAt(0);
    notifyListeners();
  }

  // ── Getters — Water ────────────────────
  static const glassMl = 250;
  // ~35 ml per kg of body weight
  int get waterGoalMl => (_userWeight * 35).round();
  int get waterGoalGlasses => (waterGoalMl / glassMl).ceil();
  int glassesOn(DateTime d) => _water[_dateKey(d)] ?? 0;
  int get todayGlasses => glassesOn(DateTime.now());
  int get waterGoalDays =>
      _water.values.where((g) => g >= waterGoalGlasses).length;

  // ── Getters — Friends ──────────────────
  String? get inviteCode => _inviteCode;
  List<String> get friends => _friends;

  // ── Getters — Planner ──────────────────
  List<PlannedWorkout> get plannedWorkouts => _plannedWorkouts;

  List<PlannedWorkout> get favouritePlans =>
      _plannedWorkouts.where((p) => p.isFavourite).toList();

  List<PlannedWorkout> getWorkoutsForDay(String day) =>
      _plannedWorkouts.where((p) => p.day == day).toList();

  // ── Getters — BMI History ──────────────
  List<BmiRecord> get bmiHistory => _bmiHistory;

  // ── Getters — Weight ───────────────────
  List<WeightEntry> get weights => _weights;
  double? get goalWeight => _goalWeight;
  // Onboarding weight, else the first logged entry, else the profile weight
  double get startWeight =>
      _startWeight ?? (_weights.isNotEmpty ? _weights.first.kg : _userWeight);
  double get currentWeight =>
      _weights.isNotEmpty ? _weights.last.kg : _userWeight;
  // Positive = lost since start, negative = gained
  double get weightChange => startWeight - currentWeight;
  double? get weightToGo =>
      _goalWeight == null ? null : (currentWeight - _goalWeight!).abs();
  // 0..1 progress from start towards the goal (works for losing or gaining)
  double get weightProgress {
    final goal = _goalWeight;
    if (goal == null) return 0;
    final total = startWeight - goal;
    if (total.abs() < 0.05) return 1;
    return ((startWeight - currentWeight) / total).clamp(0.0, 1.0);
  }

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

  DocumentReference<Map<String, dynamic>> get _publicDoc =>
      FirebaseFirestore.instance.collection('publicProfiles').doc(_uid);

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
      // Brand-new account: run onboarding first
      _onboarded = false;
      await _save();
    } else {
      _applyData(data);
      // Badges didn't exist before — award what's already earned quietly
      final hadBadges = data.containsKey('badges');
      _checkBadges(celebrate: hadBadges);
      // Older documents were created with the placeholder name
      if (_userName == _defaultName && authName != null) {
        _userName = authName;
        await _save();
      } else if (!hadBadges) {
        await _save();
      }
    }
    await _loadWeights();
    await _ensurePublicProfile();
    notifyListeners();
  }

  static const _defaultName = 'Fitness User';

  static String? _nonEmpty(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  static String _dateKey(DateTime d) => d.toIso8601String().split('T')[0];

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

  // ── Onboarding ─────────────────────────
  // Saves the answers and replaces any earlier onboarding plan with a fresh
  // weekly plan for the planner and Home.
  void completeOnboarding({
    required String goal,
    required double heightCm,
    required double weightKg,
    required String level,
    required int daysPerWeek,
  }) {
    _fitnessGoal = goal;
    _userHeight = heightCm;
    _userWeight = weightKg;
    _fitnessLevel = level;
    _daysPerWeek = daysPerWeek;
    _startWeight = weightKg;
    _onboarded = true;
    _plannedWorkouts.removeWhere((p) => p.id.startsWith('onb-'));
    _plannedWorkouts.addAll(
      WeeklyPlanner.build(goal: goal, level: level, daysPerWeek: daysPerWeek),
    );
    _save();
    notifyListeners();
  }

  // ── History ────────────────────────────
  void addWorkoutSession(WorkoutSession session) {
    _workoutHistory.insert(0, session);
    _checkBadges();
    _save();
    notifyListeners();
  }

  void clearHistory() {
    _workoutHistory.clear();
    _save();
    notifyListeners();
  }

  // ── Water ──────────────────────────────
  void addWater(int glasses) {
    final key = _dateKey(DateTime.now());
    final next = ((_water[key] ?? 0) + glasses).clamp(0, 30);
    _water[key] = next;
    // Keep the document small: only the last 60 days
    if (_water.length > 60) {
      final keys = _water.keys.toList()..sort();
      for (final k in keys.take(_water.length - 60)) {
        _water.remove(k);
      }
    }
    _checkBadges();
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

  // ── Weight progress ────────────────────
  CollectionReference<Map<String, dynamic>> get _weightsCol =>
      _doc.collection('weights');

  Future<void> _loadWeights() async {
    if (_uid == null) return;
    try {
      final snap = await _weightsCol.orderBy('date').get();
      _weights = snap.docs
          .map((d) => WeightEntry.fromDoc(d.id, d.data()))
          .toList();
      _sortWeights();
      _syncCurrentWeight();
    } catch (e) {
      debugPrint('Weight history load failed: $e');
    }
  }

  void _sortWeights() => _weights.sort((a, b) {
    final byDate = a.date.compareTo(b.date);
    return byDate != 0 ? byDate : a.createdMs.compareTo(b.createdMs);
  });

  // The newest entry becomes the profile weight (BMI, water goal, calories)
  void _syncCurrentWeight() {
    if (_weights.isNotEmpty) _userWeight = _weights.last.kg;
  }

  Future<void> addWeight(double kg, DateTime date) async {
    final entry = WeightEntry(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      kg: kg,
      date: _dateKey(date),
      createdMs: DateTime.now().millisecondsSinceEpoch,
    );
    _startWeight ??= _weights.isEmpty ? _userWeight : _weights.first.kg;
    _weights.add(entry);
    _sortWeights();
    _syncCurrentWeight();
    notifyListeners();
    if (_uid != null) {
      try {
        final ref = await _weightsCol.add(entry.toMap());
        final i = _weights.indexWhere((w) => w.id == entry.id);
        if (i != -1) _weights[i] = entry.copyWith(id: ref.id);
      } catch (e) {
        debugPrint('Weight save failed: $e');
      }
    }
    _save();
  }

  Future<void> updateWeight(String id, double kg, DateTime date) async {
    final i = _weights.indexWhere((w) => w.id == id);
    if (i == -1) return;
    _weights[i] = _weights[i].copyWith(kg: kg, date: _dateKey(date));
    _sortWeights();
    _syncCurrentWeight();
    notifyListeners();
    if (_uid != null && !id.startsWith('local-')) {
      try {
        await _weightsCol
            .doc(id)
            .set(_weights.firstWhere((w) => w.id == id).toMap());
      } catch (e) {
        debugPrint('Weight update failed: $e');
      }
    }
    _save();
  }

  Future<void> deleteWeight(String id) async {
    _weights.removeWhere((w) => w.id == id);
    _syncCurrentWeight();
    notifyListeners();
    if (_uid != null && !id.startsWith('local-')) {
      try {
        await _weightsCol.doc(id).delete();
      } catch (e) {
        debugPrint('Weight delete failed: $e');
      }
    }
    _save();
  }

  void setGoalWeight(double kg) {
    _goalWeight = kg;
    _startWeight ??= startWeight;
    _save();
    notifyListeners();
  }

  // ── Friends ────────────────────────────
  void setFriends(List<String> uids) {
    _friends = uids;
    notifyListeners();
  }

  // ── Badges ─────────────────────────────
  void _checkBadges({bool celebrate = true}) {
    final today = _dateKey(DateTime.now());
    for (final b in Badges.all) {
      if (_badges.containsKey(b.id) || !b.earned(this)) continue;
      _badges[b.id] = today;
      if (celebrate) _pendingBadges.add(b.id);
    }
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
          'level': _fitnessLevel,
          if (_daysPerWeek != null) 'daysPerWeek': _daysPerWeek,
          if (_goalWeight != null) 'goalWeight': _goalWeight,
          if (_startWeight != null) 'startWeight': _startWeight,
          if (_avatarSeed != null) 'avatarSeed': _avatarSeed,
        },
        'onboarded': _onboarded,
        'streak': currentStreak,
        'xp': xp,
        'water': _water,
        'badges': _badges,
        'workoutHistory': _workoutHistory.map((s) => s.toMap()).toList(),
        'plannedWorkouts': _plannedWorkouts.map((p) => p.toMap()).toList(),
        'bmiHistory': _bmiHistory.map((b) => b.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore save failed: $e');
    }
    await _publishPublicProfile();
  }

  // Public card friends can read. Never contains email or health data.
  Future<void> _publishPublicProfile() async {
    if (_uid == null || _inviteCode == null) return;
    try {
      await _publicDoc.set({
        'name': _userName,
        'avatarSeed': avatarSeed,
        'level': level,
        'xp': xp,
        'weeklyXp': weeklyXp,
        'weekKey': Gamification.weekKey(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Public profile save failed: $e');
    }
  }

  // Creates publicProfiles/{uid} with an invite code on first run
  Future<void> _ensurePublicProfile() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final snap = await _publicDoc.get();
      final data = snap.data();
      if (data != null && data['inviteCode'] is String) {
        _inviteCode = data['inviteCode'] as String;
        _friends = List<String>.from(data['friends'] as List? ?? const []);
        await _publishPublicProfile();
        return;
      }
      final code = await FriendsService.claimInviteCode(uid);
      if (_uid != uid) return;
      _inviteCode = code;
      await _publicDoc.set({'inviteCode': code, 'friends': <String>[]});
      await _publishPublicProfile();
    } catch (e) {
      debugPrint('Public profile setup failed: $e');
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
    _fitnessLevel = profile['level'] as String? ?? 'Beginner';
    _daysPerWeek = (profile['daysPerWeek'] as num?)?.toInt();
    _goalWeight = (profile['goalWeight'] as num?)?.toDouble();
    _startWeight = (profile['startWeight'] as num?)?.toDouble();
    // Accounts created before onboarding existed skip it
    _onboarded = data['onboarded'] as bool? ?? true;
    _workoutHistory = _mapList(data['workoutHistory'], WorkoutSession.fromMap);
    _plannedWorkouts = _mapList(
      data['plannedWorkouts'],
      PlannedWorkout.fromMap,
    );
    _bmiHistory = _mapList(data['bmiHistory'], BmiRecord.fromMap);
    _water = ((data['water'] as Map?) ?? const {}).map(
      (k, v) => MapEntry(k as String, (v as num).toInt()),
    );
    _badges = ((data['badges'] as Map?) ?? const {}).map(
      (k, v) => MapEntry(k as String, v.toString()),
    );
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
    _fitnessLevel = 'Beginner';
    _daysPerWeek = null;
    _goalWeight = null;
    _startWeight = null;
    _weights = [];
    _onboarded = true;
    _workoutHistory = [];
    _plannedWorkouts = [];
    _bmiHistory = [];
    _water = {};
    _badges = {};
    _pendingBadges.clear();
    _inviteCode = null;
    _friends = [];
  }
}

// ── Weekly plan generator (used by onboarding) ───────────────────────────────
class WeeklyPlanner {
  static const _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // Spread training days evenly across the week
  static const _schedule = {
    1: [2],
    2: [0, 3],
    3: [0, 2, 4],
    4: [0, 1, 3, 4],
    5: [0, 1, 2, 4, 5],
    6: [0, 1, 2, 3, 4, 5],
    7: [0, 1, 2, 3, 4, 5, 6],
  };

  static List<String> rotationFor(String goal) {
    switch (goal) {
      case 'Lose Weight':
        return ['Cardio', 'Full Body', 'Core', 'Leg', 'Cardio', 'Arm'];
      case 'Build Muscle':
        return ['Arm', 'Leg', 'Full Body', 'Core', 'Arm', 'Leg'];
      case 'Improve Endurance':
        return ['Cardio', 'Leg', 'Full Body', 'Cardio', 'Core', 'Arm'];
      default:
        return ['Full Body', 'Cardio', 'Core', 'Leg', 'Arm', 'Full Body'];
    }
  }

  static List<PlannedWorkout> build({
    required String goal,
    required String level,
    required int daysPerWeek,
  }) {
    final days = _schedule[daysPerWeek.clamp(1, 7)]!;
    final rotation = rotationFor(goal);
    final time = level == 'Advanced' ? '06:30 AM' : '07:00 AM';
    return [
      for (var i = 0; i < days.length; i++)
        PlannedWorkout(
          id: 'onb-${days[i]}',
          category: rotation[i % rotation.length],
          day: _days[days[i]],
          time: time,
        ),
    ];
  }
}
