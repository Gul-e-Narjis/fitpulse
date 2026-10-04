import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/exercise_data.dart';
import '../services/app_state.dart';
import '../services/workout_tracker.dart';
import '../theme/fp_theme.dart';
import '../theme/fp_widgets.dart';
import 'exercise_detail.dart';
import 'share_card_screen.dart';

class WorkoutDetailPage extends StatelessWidget {
  final String category;

  const WorkoutDetailPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final exercises = ExerciseDataService.getByCategory(category);
    final color = FpColors.forCategory(category);
    final duration = ExerciseDataService.getCategoryDuration(category);

    return Scaffold(
      backgroundColor: FpColors.bg,
      body: GradientBackground(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              backgroundColor: FpColors.bg,
              surfaceTintColor: Colors.transparent,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  radius: 14,
                  onTap: () => Navigator.pop(context),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: FpColors.text,
                      size: 18,
                    ),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (exercises.isNotEmpty)
                      ExerciseImage(
                        exercise: exercises.first,
                        animate: true,
                        radius: 0,
                      ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            color.withValues(alpha: 0.25),
                            FpColors.bg.withValues(alpha: 0.55),
                            FpColors.bg,
                          ],
                          stops: const [0, 0.6, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TintIcon(
                            ExerciseDataService.getCategoryIcon(category),
                            color: color,
                            size: 44,
                          ),
                          const SizedBox(height: 10),
                          Text(category, style: FpText.display(size: 30)),
                          const SizedBox(height: 6),
                          Text(
                            '${exercises.length} exercises  •  $duration',
                            style: FpText.muted(),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
                    ),
                  ],
                ),
              ),
            ),

            // ── Start Button ─────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: GlowButton(
                  label: 'Start Workout',
                  icon: Icons.play_arrow_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutSessionPage(
                        category: category,
                        exercises: exercises,
                        color: color,
                      ),
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
                  return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassCard(
                          padding: const EdgeInsets.all(10),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ExerciseDetailPage(exercise: exercise),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 72,
                                height: 72,
                                child: Hero(
                                  tag: 'ex-${exercise.name}',
                                  child: ExerciseImage(
                                    exercise: exercise,
                                    radius: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${index + 1}. ${exercise.name}',
                                      style: FpText.h3(),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 4,
                                      children: [
                                        _Meta(
                                          Icons.timer_outlined,
                                          exercise.duration,
                                        ),
                                        _Meta(Icons.repeat, exercise.reps),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    DifficultyChip(exercise.difficulty),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: FpColors.faint,
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: (50 * index).ms)
                      .slideX(begin: 0.06);
                }, childCount: exercises.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Meta(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: FpColors.muted),
        const SizedBox(width: 4),
        Text(text, style: FpText.muted(size: 12)),
      ],
    );
  }
}

class DifficultyChip extends StatelessWidget {
  final String difficulty;
  const DifficultyChip(this.difficulty, {super.key});

  static Color colorFor(String d) {
    switch (d) {
      case 'Beginner':
        return FpColors.lime;
      case 'Intermediate':
        return FpColors.amber;
      case 'Advanced':
        return FpColors.coral;
      default:
        return FpColors.violet;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = colorFor(difficulty);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(difficulty, style: FpText.label(color: c, size: 10)),
    );
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
        title: const Text('End workout?'),
        content: Text(
          'You\'ve done ${session.exercisesCompleted} exercise'
          '${session.exercisesCompleted == 1 ? '' : 's'} • '
          '${_formatDuration(session.durationSeconds)} • '
          '${session.caloriesBurned.toStringAsFixed(0)} cal.\n'
          'This will be saved as a partial workout.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Keep going',
              style: FpText.body(color: FpColors.muted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('End & save', style: FpText.h3(color: FpColors.lime)),
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
        title: Text(saved ? '🎉 Workout Complete!' : 'Workout not recorded'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: saved ? FpColors.accentGradient : null,
                color: saved ? null : FpColors.surface,
              ),
              child: Icon(
                saved ? Icons.emoji_events : Icons.timer_off_outlined,
                color: saved ? FpColors.bgDeep : FpColors.muted,
                size: 44,
              ),
            ).animate().scale(curve: Curves.elasticOut, duration: 900.ms),
            const SizedBox(height: 16),
            Text(
              saved
                  ? '${session.exercisesCompleted} exercises done!\n'
                        '${_formatDuration(session.durationSeconds)}  •  '
                        '${session.caloriesBurned.toStringAsFixed(0)} cal'
                  : 'Less than a minute of exercise was done, '
                        'so nothing was saved.',
              textAlign: TextAlign.center,
              style: FpText.body(color: FpColors.muted),
            ),
          ],
        ),
        actions: [
          if (saved)
            TextButton.icon(
              onPressed: () {
                final nav = Navigator.of(context);
                nav.popUntil((route) => route.isFirst);
                nav.push(
                  MaterialPageRoute(
                    builder: (_) => ShareCardScreen(session: session),
                  ),
                );
              },
              icon: const Icon(
                Icons.ios_share_rounded,
                size: 18,
                color: FpColors.tealLight,
              ),
              label: Text('Share', style: FpText.h3(color: FpColors.tealLight)),
            ),
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: Text('Back to Home', style: FpText.h3(color: FpColors.lime)),
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
    final next = _tracker.next;
    final running = _isRunning && !_isPaused;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _requestExit();
      },
      child: Scaffold(
        backgroundColor: FpColors.bg,
        body: GradientBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 720;
                final timerSize = compact ? 150.0 : 190.0;
                return Column(
                  children: [
                    // ── Top bar ─────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            color: FpColors.text,
                            onPressed: _requestExit,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '${_currentIndex + 1} / ${widget.exercises.length}',
                                  style: FpText.label(),
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(
                                      end:
                                          (_currentIndex + 1) /
                                          widget.exercises.length,
                                    ),
                                    duration: 500.ms,
                                    builder: (_, v, _) =>
                                        LinearProgressIndicator(
                                          value: v,
                                          minHeight: 5,
                                          backgroundColor: Colors.white
                                              .withValues(alpha: 0.08),
                                          valueColor:
                                              const AlwaysStoppedAnimation(
                                                FpColors.lime,
                                              ),
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Exercise visual + glass overlay ─
                    Expanded(
                      child:
                          Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ExerciseImage(
                                        key: ValueKey(exercise.name),
                                        exercise: exercise,
                                        animate: true,
                                        radius: 0,
                                      ),
                                      const DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Color(0xCC070C17),
                                            ],
                                            stops: [0.45, 1],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 12,
                                        right: 12,
                                        bottom: 12,
                                        child: _ExerciseOverlay(
                                          exercise: exercise,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .animate(key: ValueKey(_currentIndex))
                              .fadeIn(duration: 350.ms)
                              .scaleXY(begin: 0.96, curve: Curves.easeOutCubic),
                    ),
                    SizedBox(height: compact ? 14 : 22),

                    // ── Glowing timer ───────────────────
                    _PulseTimer(
                      size: timerSize,
                      progress: progress,
                      seconds: _secondsLeft,
                      running: running,
                    ),
                    SizedBox(height: compact ? 12 : 18),

                    // ── Next up ─────────────────────────
                    if (next != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _NextUp(exercise: next),
                      )
                    else
                      Text(
                        'Last exercise — finish strong! 💪',
                        style: FpText.body(color: FpColors.lime),
                      ),
                    SizedBox(height: compact ? 12 : 18),

                    // ── Controls ────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: GlowButton(
                              label: 'Skip',
                              icon: Icons.skip_next_rounded,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.10),
                                  Colors.white.withValues(alpha: 0.06),
                                ],
                              ),
                              textColor: FpColors.text,
                              onTap: _skip,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 2,
                            child: GlowButton(
                              label: !_isRunning
                                  ? 'Start'
                                  : _isPaused
                                  ? 'Resume'
                                  : 'Pause',
                              icon: running
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              onTap: _isRunning ? _pauseResume : _startTimer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseOverlay extends StatelessWidget {
  final Exercise exercise;
  const _ExerciseOverlay({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 20,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.name,
            style: FpText.h1(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(exercise.reps, style: FpText.h3(color: FpColors.lime)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.accessibility_new_rounded,
                size: 15,
                color: FpColors.tealLight,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  exercise.musclesTargeted,
                  style: FpText.muted(size: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NextUp extends StatelessWidget {
  final Exercise exercise;
  const _NextUp({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: ExerciseImage(exercise: exercise, radius: 12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NEXT UP', style: FpText.label(size: 10)),
                Text(
                  exercise.name,
                  style: FpText.h3(),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(exercise.duration, style: FpText.muted(size: 12)),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// Circular countdown with a glow that pulses while running
class _PulseTimer extends StatelessWidget {
  final double size;
  final double progress;
  final int seconds;
  final bool running;

  const _PulseTimer({
    required this.size,
    required this.progress,
    required this.seconds,
    required this.running,
  });

  @override
  Widget build(BuildContext context) {
    Widget glow = Container(
      width: size * 0.82,
      height: size * 0.82,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: FpColors.teal.withValues(alpha: running ? 0.45 : 0.18),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
    );
    if (running) {
      glow = glow
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(begin: 0.92, end: 1.08, duration: 1000.ms);
    }
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          glow,
          AnimatedRing(
            progress: progress,
            size: size,
            stroke: 12,
            duration: const Duration(milliseconds: 900),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$seconds', style: FpText.display(size: size * 0.28)),
                Text('seconds', style: FpText.label()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
