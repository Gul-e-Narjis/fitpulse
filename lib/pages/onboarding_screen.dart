import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../services/exercise_data.dart';
import '../theme/fp_theme.dart';
import '../theme/fp_widgets.dart';

// ── Smart onboarding: 4 quick steps → personalised weekly plan ───────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pager = PageController();
  int _step = 0;
  bool _showPlan = false;

  String _goal = 'Stay Fit';
  late double _height;
  late double _weight;
  String _level = 'Beginner';
  int _days = 3;

  static const _goals = [
    ('Lose Weight', '🔥', 'Burn fat with cardio-heavy weeks'),
    ('Build Muscle', '💪', 'Strength focus for arms and legs'),
    ('Stay Fit', '⚡', 'A balanced mix of everything'),
    ('Improve Endurance', '🏃', 'Go longer with stamina training'),
  ];

  static const _levels = [
    ('Beginner', '🌱', 'New to training or getting back into it'),
    ('Intermediate', '🌿', 'I work out fairly regularly'),
    ('Advanced', '🌳', 'Training is part of my routine'),
  ];

  @override
  void initState() {
    super.initState();
    final a = context.read<AppState>();
    _height = a.userHeight.clamp(120, 220).toDouble();
    _weight = a.userWeight.clamp(30, 200).toDouble();
    if (_goals.any((g) => g.$1 == a.fitnessGoal)) _goal = a.fitnessGoal;
  }

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 3) {
      setState(() => _step++);
      _pager.animateToPage(
        _step,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.read<AppState>().completeOnboarding(
        goal: _goal,
        heightCm: _height.roundToDouble(),
        weightKg: _weight.roundToDouble(),
        level: _level,
        daysPerWeek: _days,
      );
      setState(() => _showPlan = true);
    }
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step--);
    _pager.animateToPage(
      _step,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FpColors.bg,
      body: GradientBackground(
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _showPlan ? const _PlanReady() : _questions(),
          ),
        ),
      ),
    );
  }

  Widget _questions() {
    return Column(
      key: const ValueKey('questions'),
      children: [
        // ── Progress ────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 20, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: _step == 0 ? null : _back,
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: _step == 0 ? Colors.transparent : FpColors.text,
                ),
              ),
              Expanded(
                child: Row(
                  children: List.generate(4, (i) {
                    return Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: i <= _step ? FpColors.accentGradient : null,
                          color: i <= _step
                              ? null
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Text('${_step + 1}/4', style: FpText.label()),
            ],
          ),
        ),
        Expanded(
          child: PageView(
            controller: _pager,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _StepPage(
                title: 'What\'s your main goal?',
                subtitle: 'We\'ll shape your weekly plan around it.',
                child: Column(
                  children: [
                    for (final g in _goals)
                      _OptionCard(
                        emoji: g.$2,
                        title: g.$1,
                        subtitle: g.$3,
                        selected: _goal == g.$1,
                        onTap: () => setState(() => _goal = g.$1),
                      ),
                  ],
                ),
              ),
              _StepPage(
                title: 'Your body stats',
                subtitle: 'Used for calories, BMI and your water goal.',
                child: Column(
                  children: [
                    _SliderCard(
                      label: 'Height',
                      unit: 'cm',
                      value: _height,
                      min: 120,
                      max: 220,
                      icon: Icons.height_rounded,
                      onChanged: (v) => setState(() => _height = v),
                    ),
                    const SizedBox(height: 14),
                    _SliderCard(
                      label: 'Weight',
                      unit: 'kg',
                      value: _weight,
                      min: 30,
                      max: 200,
                      icon: Icons.monitor_weight_outlined,
                      onChanged: (v) => setState(() => _weight = v),
                    ),
                  ],
                ),
              ),
              _StepPage(
                title: 'Your fitness level',
                subtitle: 'Be honest — we\'ll adjust as you progress.',
                child: Column(
                  children: [
                    for (final l in _levels)
                      _OptionCard(
                        emoji: l.$2,
                        title: l.$1,
                        subtitle: l.$3,
                        selected: _level == l.$1,
                        onTap: () => setState(() => _level = l.$1),
                      ),
                  ],
                ),
              ),
              _StepPage(
                title: 'Days per week',
                subtitle: 'How many days can you train?',
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        '$_days',
                        style: FpText.display(size: 64, color: FpColors.lime),
                      ),
                      Text(
                        _days == 1 ? 'day per week' : 'days per week',
                        style: FpText.muted(),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          for (var d = 2; d <= 6; d++)
                            Bounce(
                              onTap: () => setState(() => _days = d),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: _days == d
                                      ? FpColors.accentGradient
                                      : null,
                                  color: _days == d
                                      ? null
                                      : Colors.white.withValues(alpha: 0.06),
                                ),
                                child: Text(
                                  '$d',
                                  style: FpText.h3(
                                    color: _days == d
                                        ? FpColors.bgDeep
                                        : FpColors.text,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: GlowButton(
            label: _step < 3 ? 'Continue' : 'Build my plan',
            icon: _step < 3
                ? Icons.arrow_forward_rounded
                : Icons.auto_awesome_rounded,
            onTap: _next,
          ),
        ),
      ],
    );
  }
}

class _StepPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _StepPage({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      children: [
        Text(
          title,
          style: FpText.display(size: 28),
        ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: FpText.muted(size: 14),
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
        const SizedBox(height: 24),
        child
            .animate()
            .fadeIn(delay: 180.ms, duration: 450.ms)
            .slideY(begin: 0.08, curve: Curves.easeOutCubic),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Bounce(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: selected
                ? LinearGradient(
                    colors: [
                      FpColors.teal.withValues(alpha: 0.30),
                      FpColors.lime.withValues(alpha: 0.10),
                    ],
                  )
                : null,
            color: selected ? null : Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: selected ? FpColors.lime : FpColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: FpText.h3()),
                    Text(subtitle, style: FpText.muted(size: 12)),
                  ],
                ),
              ),
              AnimatedScale(
                scale: selected ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: FpColors.lime,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderCard extends StatelessWidget {
  final String label;
  final String unit;
  final double value;
  final double min;
  final double max;
  final IconData icon;
  final ValueChanged<double> onChanged;

  const _SliderCard({
    required this.label,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              TintIcon(icon, color: FpColors.tealLight, size: 38),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: FpText.h3())),
              Text(
                value.round().toString(),
                style: FpText.number(size: 26, color: FpColors.lime),
              ),
              const SizedBox(width: 4),
              Text(unit, style: FpText.muted()),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: FpColors.teal,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
              thumbColor: FpColors.lime,
              overlayColor: FpColors.lime.withValues(alpha: 0.15),
              trackHeight: 6,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Plan summary after the last step ──────────────────────────────────────────
class _PlanReady extends StatelessWidget {
  const _PlanReady();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final plan = app.plannedWorkouts.where((p) => p.id.startsWith('onb-'));
    return ListView(
      key: const ValueKey('plan'),
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      children: [
        const Center(
          child: Text('🎯', style: TextStyle(fontSize: 56)),
        ).animate().scale(curve: Curves.elasticOut, duration: 900.ms),
        const SizedBox(height: 12),
        Text(
          'Your plan is ready!',
          style: FpText.display(size: 28),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          '${app.fitnessGoal} • ${app.fitnessLevel} • ${app.weeklyGoal} days/week',
          style: FpText.muted(size: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        for (final (i, p) in plan.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  TintIcon(
                    ExerciseDataService.getCategoryIcon(p.category),
                    color: FpColors.forCategory(p.category),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.day, style: FpText.h3()),
                        Text(
                          '${p.category} • ${p.time}',
                          style: FpText.muted(size: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (120 * i + 300).ms).slideX(begin: 0.1),
        const SizedBox(height: 16),
        GlowButton(
          label: 'Let\'s go',
          icon: Icons.rocket_launch_rounded,
          onTap: () =>
              Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
        ),
        const SizedBox(height: 8),
        Text(
          'You can change this any time in the Planner.',
          style: FpText.muted(size: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
