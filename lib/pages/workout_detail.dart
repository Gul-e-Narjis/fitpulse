import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/exercise_data.dart';
import '../services/app_state.dart';
import 'exercise_detail.dart';
import 'app_colors.dart';
import '../services/workout_tracker.dart';

class WorkoutDetailPage extends StatelessWidget {
  final String category;

  const WorkoutDetailPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final exercises = ExerciseDataService.getByCategory(category);
    final color = ExerciseDataService.getCategoryColor(category);
    final icon = ExerciseDataService.getCategoryIcon(category);
    final duration = ExerciseDataService.getCategoryDuration(category);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(icon, size: 48, color: Colors.white),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${exercises.length} Exercises  •  $duration',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Start Button ─────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkoutSessionPage(
                      category: category,
                      exercises: exercises,
                      color: color,
                    ),
                  ),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 24),
                label: const Text(
                  'Start Workout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),

          // ── Exercise List ────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final exercise = exercises[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExerciseDetailPage(exercise: exercise),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        // Number
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.name,
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    size: 12,
                                    color: AppColors.textGrey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    exercise.duration,
                                    style: const TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.repeat,
                                    size: 12,
                                    color: AppColors.textGrey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    exercise.reps,
                                    style: const TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Difficulty
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _diffColor(
                              exercise.difficulty,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            exercise.difficulty,
                            style: TextStyle(
                              color: _diffColor(exercise.difficulty),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          color: AppColors.textGrey,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: exercises.length),
            ),
          ),
        ],
      ),
    );
  }

  Color _diffColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return AppColors.sageGreen;
      case 'Intermediate':
        return const Color(0xFFE8956D);
      case 'Advanced':
        return Colors.red;
      default:
        return AppColors.lightPurple;
    }
  }
}

// ── Workout Session Page ─────────────────────────────
class WorkoutSessionPage extends StatefulWidget {
  final String category;
  final List<Exercise> exercises;
  final Color color;

  const WorkoutSessionPage({
    super.key,
    required this.category,
    required this.exercises,
    required this.color,
  });

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  late final WorkoutTracker _tracker;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _completed = false;
  // Bumped whenever the timer restarts so only one _tick loop stays alive
  int _tickId = 0;

  int get _currentIndex => _tracker.index;
  int get _secondsLeft => _tracker.secondsLeft;

  @override
  void initState() {
    super.initState();
    _tracker = WorkoutTracker(
      exercises: widget.exercises,
      weightKg: context.read<AppState>().userWeight,
    );
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });
    _tick();
  }

  void _tick() async {
    final id = ++_tickId;
    while (_isRunning && !_isPaused && _tracker.secondsLeft > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || id != _tickId) return;
      if (_isRunning && !_isPaused) {
        setState(_tracker.tick);
      }
    }
    if (_isRunning && _tracker.secondsLeft == 0 && mounted) {
      _advance(skipped: false);
    }
  }

  void _pauseResume() {
    setState(() => _isPaused = !_isPaused);
    if (!_isPaused) _tick();
  }

  void _skip() => _advance(skipped: true);

  void _advance({required bool skipped}) {
    if (_completed) return;
    _tickId++; // stop any running countdown
    final wasLast = _tracker.isLast;
    setState(() {
      skipped ? _tracker.skipCurrent() : _tracker.completeCurrent();
      _isRunning = false;
      _isPaused = false;
    });
    if (wasLast) _workoutComplete();
  }

  // ✕ / back: offer to save what was done if it's at least a minute
  Future<void> _requestExit() async {
    if (_completed) return;
    if (!_tracker.canSavePartial) {
      _tickId++;
      Navigator.pop(context);
      return;
    }
    final wasPaused = _isPaused;
    if (_isRunning) setState(() => _isPaused = true);
    final session = _tracker.buildSession(
      category: widget.category,
      partial: true,
    );
    final end = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'End workout?',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'You\'ve done ${session.exercisesCompleted} exercise'
          '${session.exercisesCompleted == 1 ? '' : 's'} • '
          '${_formatDuration(session.durationSeconds)} • '
          '${session.caloriesBurned.toStringAsFixed(0)} cal.\n'
          'This will be saved as a partial workout.',
          style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Keep going',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'End & save',
              style: TextStyle(
                color: AppColors.sageGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (end == true) {
      _completed = true;
      _tickId++;
      context.read<AppState>().addWorkoutSession(session);
      Navigator.pop(context);
    } else if (_isRunning && !wasPaused) {
      _pauseResume();
    }
  }

  static String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m == 0) return '${s}s';
    return s == 0 ? '$m min' : '$m min ${s}s';
  }

  void _workoutComplete() {
    _completed = true;
    _isRunning = false;
    final session = _tracker.buildSession(category: widget.category);
    final saved = session.durationSeconds >= WorkoutTracker.minSecondsToSave;
    if (saved) context.read<AppState>().addWorkoutSession(session);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          saved ? '🎉 Workout Complete!' : 'Workout not recorded',
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.softGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                saved ? Icons.emoji_events : Icons.timer_off_outlined,
                color: AppColors.sageGreen,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              saved
                  ? '${session.exercisesCompleted} exercises done!\n'
                        '${_formatDuration(session.durationSeconds)}  •  '
                        '${session.caloriesBurned.toStringAsFixed(0)} cal'
                  : 'Less than a minute of exercise was done, '
                        'so nothing was saved.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text(
              'Back to Home',
              style: TextStyle(
                color: AppColors.sageGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercises[_currentIndex];
    final totalSeconds = _tracker.currentTotalSeconds;
    final progress = _secondsLeft / totalSeconds;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _requestExit();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            '${_currentIndex + 1} / ${widget.exercises.length}',
            style: const TextStyle(color: AppColors.textGrey, fontSize: 16),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.textDark),
            onPressed: _requestExit,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / widget.exercises.length,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(widget.color),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 40),

              // Exercise name
              Text(
                exercise.name,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                exercise.reps,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),

              // Timer circle
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(widget.color),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '$_secondsLeft',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'seconds',
                        style: TextStyle(color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Muscles
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.accessibility_new,
                      color: widget.color,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        exercise.musclesTargeted,
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _skip,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textGrey,
                        side: const BorderSide(color: AppColors.border),
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Skip'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isRunning ? _pauseResume : _startTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.color,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 52),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        !_isRunning
                            ? 'Start'
                            : _isPaused
                            ? 'Resume'
                            : 'Pause',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
