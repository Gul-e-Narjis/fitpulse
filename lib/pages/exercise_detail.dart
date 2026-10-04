import 'package:flutter/material.dart';
import '../services/exercise_data.dart';
import 'app_colors.dart';

class ExerciseDetailPage extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailPage({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final color = ExerciseDataService.getCategoryColor(exercise.category);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
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
                    colors: [color, color.withValues(alpha: 0.6)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(exercise.icon, size: 44, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        exercise.difficulty,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Quick Stats ────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  _StatChip(
                    icon: Icons.timer_outlined,
                    label: 'Duration',
                    value: exercise.duration,
                    color: color,
                  ),
                  const SizedBox(width: 12),
                  _StatChip(
                    icon: Icons.repeat,
                    label: 'Reps',
                    value: exercise.reps,
                    color: AppColors.lightPurple,
                  ),
                ],
              ),
            ),
          ),

          // ── About ──────────────────────────────────
          SliverToBoxAdapter(
            child: _Section(
              title: 'About',
              icon: Icons.info_outline,
              color: color,
              child: Text(
                exercise.description,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
          ),

          // ── Muscles ────────────────────────────────
          SliverToBoxAdapter(
            child: _Section(
              title: 'Muscles Targeted',
              icon: Icons.accessibility_new,
              color: color,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: exercise.musclesTargeted
                    .split(',')
                    .map(
                      (m) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          m.trim(),
                          style: TextStyle(color: color, fontSize: 12),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),

          // ── Equipment ──────────────────────────────
          SliverToBoxAdapter(
            child: _Section(
              title: 'Equipment',
              icon: Icons.fitness_center,
              color: color,
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.sageGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    exercise.equipment,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Instructions ───────────────────────────
          SliverToBoxAdapter(
            child: _Section(
              title: 'How To Do It',
              icon: Icons.format_list_numbered,
              color: color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: exercise.instructions
                    .split('\n')
                    .map(
                      (step) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          step,
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),

          // ── Benefits ───────────────────────────────
          SliverToBoxAdapter(
            child: _Section(
              title: 'Benefits',
              icon: Icons.star_outline,
              color: color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: exercise.benefits
                    .split('\n')
                    .map(
                      (b) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          b,
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }
}

// ── Stat Chip ────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section ──────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _Section({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
