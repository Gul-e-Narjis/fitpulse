import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/exercise_data.dart';
import '../theme/fp_theme.dart';
import '../theme/fp_widgets.dart';
import 'workout_detail.dart';

class ExerciseDetailPage extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailPage({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final color = FpColors.forCategory(exercise.category);
    final steps = exercise.steps;
    final benefits = exercise.benefits
        .split('\n')
        .map((b) => b.replaceFirst(RegExp(r'^[•\-\s]+'), '').trim())
        .where((b) => b.isNotEmpty)
        .toList();

    final sections = <Widget>[
      // ── Title + chips ───────────────────────────
      Text(exercise.name, style: FpText.display(size: 28)),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          DifficultyChip(exercise.difficulty),
          _Chip(Icons.category_outlined, exercise.category, color),
        ],
      ),
      const SizedBox(height: 18),
      Row(
        children: [
          Expanded(
            child: _StatTile(
              icon: Icons.timer_outlined,
              label: 'Duration',
              value: exercise.duration,
              color: FpColors.sky,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatTile(
              icon: Icons.repeat_rounded,
              label: 'Reps',
              value: exercise.reps,
              color: FpColors.lime,
            ),
          ),
        ],
      ),
      const SizedBox(height: 22),

      // ── How to do it ────────────────────────────
      const SectionTitle('How to do it'),
      const SizedBox(height: 12),
      GlassCard(
        child: Column(
          children: [
            for (var i = 0; i < steps.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i == steps.length - 1 ? 0 : 14,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: FpColors.accentGradient,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: FpText.label(color: FpColors.bgDeep, size: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(steps[i], style: FpText.body()),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 22),

      // ── About ───────────────────────────────────
      const SectionTitle('About'),
      const SizedBox(height: 12),
      GlassCard(
        child: Text(
          exercise.description,
          style: FpText.body(color: FpColors.muted),
        ),
      ),
      const SizedBox(height: 22),

      // ── Muscles + equipment ─────────────────────
      const SectionTitle('Muscles targeted'),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: exercise.musclesTargeted
            .split(',')
            .map((m) => _Chip(Icons.bolt_rounded, m.trim(), FpColors.tealLight))
            .toList(),
      ),
      const SizedBox(height: 22),
      const SectionTitle('Equipment'),
      const SizedBox(height: 12),
      GlassCard(
        child: Row(
          children: [
            const TintIcon(
              Icons.fitness_center_rounded,
              color: FpColors.violet,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(exercise.equipment, style: FpText.body())),
          ],
        ),
      ),
      const SizedBox(height: 22),

      // ── Benefits ────────────────────────────────
      const SectionTitle('Benefits'),
      const SizedBox(height: 12),
      GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final b in benefits)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: FpColors.lime,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(b, style: FpText.body())),
                  ],
                ),
              ),
          ],
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: FpColors.bg,
      body: GradientBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 320,
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
                    Hero(
                      tag: 'ex-${exercise.name}',
                      child: ExerciseImage(
                        exercise: exercise,
                        animate: true,
                        radius: 0,
                      ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, FpColors.bg],
                          stops: [0.55, 1],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  for (var i = 0; i < sections.length; i++)
                    sections[i]
                        .animate()
                        .fadeIn(delay: (25 * i).ms, duration: 400.ms)
                        .slideY(begin: 0.08),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _Chip(this.icon, this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(text, style: FpText.label(color: color, size: 12)),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          TintIcon(icon, color: color, size: 38),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: FpText.label()),
                Text(
                  value,
                  style: FpText.h3(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
