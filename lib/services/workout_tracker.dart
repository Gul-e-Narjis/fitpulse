import 'app_state.dart';
import 'exercise_data.dart';

// ── WorkoutTracker ────────────────────────────────────────────────────────────
// Keeps the numbers for one workout session based on time actually spent.
// Skipped exercises contribute nothing; an exercise counts once its countdown
// reaches zero. Ending early (✕) also counts the exercise in progress.
class WorkoutTracker {
  // Sessions shorter than this are not saved
  static const minSecondsToSave = 60;

  final List<Exercise> exercises;
  final double weightKg;
  final DateTime startedAt = DateTime.now();

  int index = 0;
  late int secondsLeft;
  int _elapsedOnCurrent = 0;
  int _doneSeconds = 0;
  int _doneExercises = 0;
  double _doneCalories = 0;

  WorkoutTracker({required this.exercises, required this.weightKg}) {
    secondsLeft = ExerciseDataService.durationSeconds(current);
  }

  Exercise get current => exercises[index];
  Exercise? get next => isLast ? null : exercises[index + 1];
  bool get isLast => index == exercises.length - 1;
  int get currentTotalSeconds => ExerciseDataService.durationSeconds(current);

  int get completedExercises => _doneExercises;
  int get completedSeconds => _doneSeconds;

  // Completed time plus whatever has been done on the current exercise
  int get activeSeconds => _doneSeconds + _elapsedOnCurrent;

  bool get canSavePartial => activeSeconds >= minSecondsToSave;

  // One second of active exercise
  void tick() {
    if (secondsLeft <= 0) return;
    secondsLeft--;
    _elapsedOnCurrent++;
  }

  // Countdown reached zero — credit the time and move on
  void completeCurrent() {
    _credit(current, _elapsedOnCurrent);
    _moveNext();
  }

  // Skip throws away any time spent on the current exercise
  void skipCurrent() => _moveNext();

  void _credit(Exercise e, int seconds) {
    if (seconds <= 0) return;
    _doneSeconds += seconds;
    _doneExercises++;
    _doneCalories += ExerciseDataService.caloriesFor(e, seconds, weightKg);
  }

  void _moveNext() {
    _elapsedOnCurrent = 0;
    if (!isLast) {
      index++;
      secondsLeft = currentTotalSeconds;
    } else {
      secondsLeft = 0;
    }
  }

  // Builds the session to save. For an early exit the exercise in progress
  // is credited too, since that time was really spent.
  WorkoutSession buildSession({
    required String category,
    bool partial = false,
  }) {
    var seconds = _doneSeconds;
    var count = _doneExercises;
    var calories = _doneCalories;
    if (partial && _elapsedOnCurrent > 0) {
      seconds += _elapsedOnCurrent;
      count++;
      calories += ExerciseDataService.caloriesFor(
        current,
        _elapsedOnCurrent,
        weightKg,
      );
    }
    return WorkoutSession(
      category: category.trim().isEmpty ? 'Custom' : category.trim(),
      date: _dateKey(startedAt),
      durationMinutes: (seconds / 60).round(),
      durationSeconds: seconds,
      exercisesCompleted: count,
      caloriesBurned: double.parse(calories.toStringAsFixed(1)),
      partial: partial,
      startedAt: startedAt.toIso8601String(),
    );
  }

  static String _dateKey(DateTime d) => d.toIso8601String().split('T')[0];
}
