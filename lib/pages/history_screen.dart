import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/exercise_data.dart';
import '../theme/fp_theme.dart';
import '../theme/fp_widgets.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final history = appState.workoutHistory;
    // Opened via '/history' (See all) rather than as a Home tab
    final standalone = ModalRoute.of(context)?.canPop ?? false;

    final content = SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(standalone ? 8 : 20, 18, 12, 0),
            child: Row(
              children: [
                if (standalone)
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                Expanded(child: Text('Workout history', style: FpText.h1())),
                if (history.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _confirmClear(context),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: FpColors.coral,
                      size: 18,
                    ),
                    label: Text(
                      'Clear',
                      style: FpText.label(color: FpColors.coral, size: 13),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Summary ─────────────────────────────
          if (history.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _SummaryCard(
                    value: appState.totalWorkoutsCompleted,
                    label: 'Workouts',
                    color: FpColors.tealLight,
                  ),
                  const SizedBox(width: 8),
                  _SummaryCard(
                    value: appState.totalMinutesWorkedOut,
                    label: 'Minutes',
                    color: FpColors.sky,
                  ),
                  const SizedBox(width: 8),
                  _SummaryCard(
                    value: appState.totalCaloriesBurned.round(),
                    label: 'Calories',
                    color: FpColors.coral,
                  ),
                  const SizedBox(width: 8),
                  _SummaryCard(
                    value: appState.weeklyWorkouts,
                    label: 'This week',
                    color: FpColors.lime,
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
            ),
            const SizedBox(height: 12),
          ],

          // ── History List ─────────────────────────
          Expanded(
            child: history.isEmpty
                ? const _EmptyState()
                : _HistoryList(history: history),
          ),
        ],
      ),
    );

    if (!standalone) return content;
    return Scaffold(
      backgroundColor: FpColors.bg,
      body: GradientBackground(child: content),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('All workout history will be deleted permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: FpText.body(color: FpColors.muted)),
          ),
          TextButton(
            onPressed: () {
              context.read<AppState>().clearHistory();
              Navigator.pop(dialogContext);
            },
            child: Text('Clear', style: FpText.h3(color: FpColors.coral)),
          ),
        ],
      ),
    );
  }
}

// ── Summary card ─────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final num value;
  final String label;
  final Color color;

  const _SummaryCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        radius: 18,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: CountUp(
                value: value,
                style: FpText.number(size: 18, color: color),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label, style: FpText.label(size: 10)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TintIcon(
              Icons.fitness_center_rounded,
              color: FpColors.tealLight,
              size: 84,
            ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms),
            const SizedBox(height: 20),
            Text('No workouts yet!', style: FpText.h2()),
            const SizedBox(height: 8),
            Text(
              'Complete your first workout\nto see your history here.',
              textAlign: TextAlign.center,
              style: FpText.muted(size: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ── History List ─────────────────────────────────────
class _HistoryList extends StatelessWidget {
  final List<WorkoutSession> history;

  const _HistoryList({required this.history});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<WorkoutSession>> grouped = {};
    for (final session in history) {
      grouped.putIfAbsent(session.date, () => []).add(session);
    }
    final dates = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final sessions = grouped[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: FpColors.teal.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: FpColors.teal.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      _formatDate(date),
                      style: FpText.label(color: FpColors.tealLight, size: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Container(height: 1, color: FpColors.border)),
                ],
              ),
            ),
            ...sessions.map((s) => _SessionCard(session: s)),
          ],
        ).animate().fadeIn(delay: (60 * index).ms).slideY(begin: 0.06);
      },
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sessionDate = DateTime(date.year, date.month, date.day);

    if (sessionDate == today) return 'Today';
    if (sessionDate == yesterday) return 'Yesterday';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// ── Session Card ─────────────────────────────────────
class _SessionCard extends StatelessWidget {
  final WorkoutSession session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final color = FpColors.forCategory(session.category);
    final icon = ExerciseDataService.getCategoryIcon(session.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            TintIcon(icon, color: color, size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${session.category} Workout',
                          style: FpText.h3(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (session.partial) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: FpColors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'PARTIAL',
                            style: FpText.label(color: FpColors.amber, size: 9),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _Chip(
                        icon: Icons.fitness_center,
                        label: '${session.exercisesCompleted} exercises',
                      ),
                      _Chip(
                        icon: Icons.timer_outlined,
                        label: '${session.durationMinutes} min',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  session.caloriesBurned.toStringAsFixed(0),
                  style: FpText.number(size: 18, color: FpColors.coral),
                ),
                Text('cal', style: FpText.label(size: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: FpColors.muted),
          const SizedBox(width: 4),
          Text(label, style: FpText.muted(size: 11)),
        ],
      ),
    );
  }
}
