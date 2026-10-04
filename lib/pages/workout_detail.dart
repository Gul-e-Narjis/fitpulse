import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/exercise_data.dart';
import '../services/app_state.dart';
import 'exercise_detail.dart';
import 'app_colors.dart';

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
  int _currentIndex = 0;
  int _secondsLeft = 30;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _completed = false;
  // Bumped whenever the timer restarts so only one _tick loop stays alive
  int _tickId = 0;

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  void _resetTimer() {
    final exercise = widget.exercises[_currentIndex];
    final match = RegExp(r'\d+').firstMatch(exercise.duration);
    _secondsLeft = match != null ? int.parse(match.group(0)!) : 30;
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
    while (_isRunning && !_isPaused && _secondsLeft > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || id != _tickId) return;
      if (_isRunning && !_isPaused) {
        setState(() => _secondsLeft--);
      }
    }
    if (_isRunning && _secondsLeft == 0 && mounted) _nextExercise();
  }

  void _pauseResume() {
    setState(() => _isPaused = !_isPaused);
    if (!_isPaused) _tick();
  }

  void _nextExercise() {
    if (_completed) return;
    _tickId++; // stop any running countdown
    if (_currentIndex < widget.exercises.length - 1) {
      setState(() {
        _currentIndex++;
        _isRunning = false;
        _isPaused = false;
        _resetTimer();
      });
    } else {
      _workoutComplete();
    }
  }

  void _workoutComplete() {
    _completed = true;
    _isRunning = false;
    final totalMinutes = widget.exercises.fold<int>(0, (sum, e) {
      final match = RegExp(r'\d+').firstMatch(e.duration);
      return sum + (match != null ? int.parse(match.group(0)!) ~/ 60 + 1 : 1);
    });

    final appState = Provider.of<AppState>(context, listen: false);
    appState.addWorkoutSession(
      WorkoutSession(
        category: widget.category,
        date: DateTime.now().toIso8601String().split('T')[0],
        durationMinutes: totalMinutes,
        exercisesCompleted: widget.exercises.length,
        caloriesBurned: widget.exercises.length * 12.0,
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🎉 Workout Complete!',
          style: TextStyle(
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
              child: const Icon(
                Icons.emoji_events,
                color: AppColors.sageGreen,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${widget.exercises.length} exercises done!\n$totalMinutes minutes  •  ${(widget.exercises.length * 12).toStringAsFixed(0)} cal',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            },
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
    final totalSeconds = () {
      final match = RegExp(r'\d+').firstMatch(exercise.duration);
      return match != null ? int.parse(match.group(0)!) : 30;
    }();
    final progress = _secondsLeft / totalSeconds;

    return Scaffold(
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
          onPressed: () => Navigator.pop(context),
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
                  Icon(Icons.accessibility_new, color: widget.color, size: 20),
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
                    onPressed: _nextExercise,
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
    );
  }
}
