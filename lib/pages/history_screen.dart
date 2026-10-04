import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/exercise_data.dart';
import 'app_colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final history = appState.workoutHistory;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Workout History',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (history.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _confirmClear(context),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 18,
                    ),
                    label: const Text(
                      'Clear',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Summary Cards ────────────────────────
          if (history.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _SummaryCard(
                    icon: Icons.local_fire_department,
                    value: '${appState.totalWorkoutsCompleted}',
                    label: 'Total\nWorkouts',
                    color: const Color(0xFFE8956D),
                    softColor: AppColors.softOrange,
                  ),
                  const SizedBox(width: 10),
                  _SummaryCard(
                    icon: Icons.timer_outlined,
                    value: '${appState.totalMinutesWorkedOut}',
                    label: 'Total\nMinutes',
                    color: AppColors.lightPurple,
                    softColor: AppColors.softPurple,
                  ),
                  const SizedBox(width: 10),
                  _SummaryCard(
                    icon: Icons.bolt,
                    value: appState.totalCaloriesBurned.toStringAsFixed(0),
                    label: 'Total\nCalories',
                    color: AppColors.sageGreen,
                    softColor: AppColors.softGreen,
                  ),
                  const SizedBox(width: 10),
                  _SummaryCard(
                    icon: Icons.calendar_today,
                    value: '${appState.weeklyWorkouts}',
                    label: 'This\nWeek',
                    color: AppColors.lightPurple,
                    softColor: AppColors.softPurple,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── History List ─────────────────────────
          Expanded(
            child: history.isEmpty
                ? _EmptyState()
                : _HistoryList(history: history),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Clear History?',
          style: TextStyle(color: AppColors.textDark),
        ),
        content: const Text(
          'All workout history will be deleted permanently.',
          style: TextStyle(color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<AppState>().clearHistory();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: AppColors.textGrey,
              size: 44,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Workouts Yet!',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete your first workout\nto see your history here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGrey, fontSize: 14),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final sessions = grouped[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
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
                      color: AppColors.softGreen,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.sageGreen.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      _formatDate(date),
                      style: const TextStyle(
                        color: AppColors.sageGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Divider(color: AppColors.border, thickness: 1),
                  ),
                ],
              ),
            ),
            ...sessions.map((s) => _SessionCard(session: s)),
          ],
        );
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
    final color = ExerciseDataService.getCategoryColor(session.category);
    final icon = ExerciseDataService.getCategoryIcon(session.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${session.category} Workout',
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.fitness_center,
                      label: '${session.exercisesCompleted} exercises',
                      color: color,
                    ),
                    const SizedBox(width: 10),
                    _InfoChip(
                      icon: Icons.timer_outlined,
                      label: '${session.durationMinutes} min',
                      color: AppColors.lightPurple,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                session.date,
                style: const TextStyle(color: AppColors.textGrey, fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(
                '${session.caloriesBurned.toStringAsFixed(0)} cal',
                style: const TextStyle(
                  color: AppColors.sageGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Info Chip ────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
        ),
      ],
    );
  }
}

// ── Summary Card ─────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color softColor;

  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.softColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: softColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
