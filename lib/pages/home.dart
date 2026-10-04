import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/exercise_data.dart';
import '../services/notification_center.dart';
import '../theme/fp_theme.dart';
import '../theme/fp_widgets.dart';
import 'search_page.dart';
import 'workout_detail.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import 'progress_charts.dart';
import 'workout_planner.dart';
import 'notifications_screen.dart';
import 'custom_workout.dart';
import 'coach_screen.dart';
import 'gamification_widgets.dart';
import 'leaderboard_screen.dart';
import 'water_screen.dart';
import 'weight_screen.dart';

// ── Home Wrapper ─────────────────────────────────────────────────────────────
class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  static const _items = [
    GlassNavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
    GlassNavItem(Icons.search_outlined, Icons.search_rounded, 'Explore'),
    GlassNavItem(Icons.history_outlined, Icons.history_rounded, 'History'),
    GlassNavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  void _goTo(int i) => setState(() => _currentIndex = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeContent(onOpenProfile: () => _goTo(3)),
      const SearchPage(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      backgroundColor: FpColors.bg,
      extendBody: true,
      body: BadgeCelebrator(
        child: GradientBackground(
          child: IndexedStack(index: _currentIndex, children: pages),
        ),
      ),
      bottomNavigationBar: GlassBottomNav(
        index: _currentIndex,
        items: _items,
        onTap: _goTo,
      ),
    );
  }
}

// ── Home Content ─────────────────────────────────────────────────────────────
class HomeContent extends StatelessWidget {
  final VoidCallback? onOpenProfile;
  const HomeContent({super.key, this.onOpenProfile});

  static const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _push(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final firstName = appState.userName.split(' ')[0];

    final sections = <Widget>[
      // ── Header ──────────────────────────────────
      Row(
        children: [
          Bounce(
            onTap: onOpenProfile,
            child: FpAvatar(
              seed: appState.avatarSeed,
              size: 52,
              fallbackInitial: firstName.isEmpty ? '' : firstName[0],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting()}, $firstName 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FpText.h2(),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: FpColors.lime,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        appState.fitnessGoal,
                        overflow: TextOverflow.ellipsis,
                        style: FpText.muted(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _BellButton(onTap: () => _push(context, const NotificationsScreen())),
        ],
      ),
      const SizedBox(height: 22),

      // ── Activity ring + streak ──────────────────
      _ActivityCard(appState: appState),
      const SizedBox(height: 14),

      // ── Stat cards ──────────────────────────────
      Row(
        children: [
          Expanded(
            child: _StatCard(
              value: appState.totalWorkoutsCompleted,
              label: 'Workouts',
              icon: Icons.fitness_center_rounded,
              color: FpColors.tealLight,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              value: appState.totalMinutesWorkedOut,
              label: 'Minutes',
              icon: Icons.timer_rounded,
              color: FpColors.sky,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              value: appState.totalCaloriesBurned.round(),
              label: 'Calories',
              icon: Icons.local_fire_department_rounded,
              color: FpColors.coral,
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),

      // ── Level / XP ──────────────────────────────
      const LevelCard(compact: true),
      const SizedBox(height: 26),

      // ── Today's workout hero ────────────────────
      const SectionTitle("Today's workout"),
      const SizedBox(height: 12),
      _TodayHero(appState: appState),
      const SizedBox(height: 18),

      // ── AI coach ────────────────────────────────
      _CoachBanner(onTap: () => _push(context, const CoachScreen())),
      const SizedBox(height: 14),

      // ── Water ───────────────────────────────────
      const WaterCard(),
      const SizedBox(height: 14),
      const WeightCard(),
      const SizedBox(height: 26),

      // ── Quick access ────────────────────────────
      const SectionTitle('Quick access'),
      const SizedBox(height: 12),
      _QuickGrid(
        tools: [
          _QuickToolData(
            Icons.auto_awesome_rounded,
            'AI Coach',
            FpColors.lime,
            () => _push(context, const CoachScreen()),
          ),
          _QuickToolData(
            Icons.water_drop_rounded,
            'Water',
            const Color(0xFF22D3EE),
            () => _push(context, const WaterScreen()),
          ),
          _QuickToolData(
            Icons.emoji_events_rounded,
            'Friends',
            FpColors.amber,
            () => _push(context, const LeaderboardScreen()),
          ),
          _QuickToolData(
            Icons.insights_rounded,
            'Progress',
            FpColors.tealLight,
            () => _push(context, const ProgressChartsScreen()),
          ),
          _QuickToolData(
            Icons.calendar_month_rounded,
            'Planner',
            FpColors.violet,
            () => _push(context, const WorkoutPlannerScreen()),
          ),
          _QuickToolData(
            Icons.monitor_weight_outlined,
            'Weight',
            FpColors.violet,
            () => _push(context, const WeightScreen()),
          ),
          _QuickToolData(
            Icons.speed_rounded,
            'BMI',
            FpColors.amber,
            () => Navigator.pushNamed(context, '/bmi'),
          ),
          _QuickToolData(
            Icons.tune_rounded,
            'Custom',
            FpColors.sky,
            () => _push(context, const CustomWorkoutScreen()),
          ),
          _QuickToolData(
            Icons.alarm_rounded,
            'Reminders',
            FpColors.coral,
            () => _push(context, const NotificationsScreen()),
          ),
        ],
      ),
      const SizedBox(height: 26),

      // ── This week ───────────────────────────────
      _WeekStrip(appState: appState),
      const SizedBox(height: 26),

      // ── Today's plan ────────────────────────────
      _TodaysPlan(appState: appState),
      const SizedBox(height: 26),

      // ── Categories ──────────────────────────────
      const SectionTitle('Workout categories'),
      const SizedBox(height: 12),
      SizedBox(
        height: 128,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          itemCount: ExerciseDataService.categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, i) {
            final cat = ExerciseDataService.categories[i];
            return _CategoryTile(
              category: cat,
              onTap: () => _push(context, WorkoutDetailPage(category: cat)),
            );
          },
        ),
      ),
      const SizedBox(height: 26),

      // ── Recent workouts ─────────────────────────
      SectionTitle(
        'Recent workouts',
        action: appState.workoutHistory.isNotEmpty ? 'See all' : null,
        onAction: () => Navigator.pushNamed(context, '/history'),
      ),
      const SizedBox(height: 12),
      if (appState.workoutHistory.isEmpty)
        const _EmptyWorkouts()
      else
        ...appState.workoutHistory
            .take(3)
            .map((s) => _RecentWorkoutCard(session: s)),
      const SizedBox(height: 26),

      // ── Motivation ──────────────────────────────
      const _MotivationCard(),
    ];

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
        children: [
          for (var i = 0; i < sections.length; i++)
            sections[i]
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: 40 * (i ~/ 2)),
                  duration: 450.ms,
                )
                .slideY(begin: 0.08, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }
}

// ── Activity Card ─────────────────────────────────────────────────────────────
class _ActivityCard extends StatelessWidget {
  final AppState appState;
  const _ActivityCard({required this.appState});

  @override
  Widget build(BuildContext context) {
    final weeklyGoal = appState.weeklyGoal;
    final weekly = appState.weeklyWorkouts;
    final streak = appState.currentStreak;
    final todayMinutes = appState.last7DaysMinutes.last;
    return GlassCard(
      glow: FpColors.teal,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          AnimatedRing(
            progress: weekly / weeklyGoal,
            size: 118,
            stroke: 11,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CountUp(value: weekly, style: FpText.number(size: 28)),
                Text('of $weeklyGoal', style: FpText.label()),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THIS WEEK',
                  style: FpText.label(color: FpColors.tealLight),
                ),
                const SizedBox(height: 4),
                Text(
                  weekly >= weeklyGoal
                      ? 'Weekly goal smashed!'
                      : '${weeklyGoal - weekly} more to hit your goal',
                  style: FpText.h3(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 22))
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(end: 1.18, duration: 900.ms),
                    const SizedBox(width: 6),
                    CountUp(
                      value: streak,
                      style: FpText.number(size: 20, color: FpColors.amber),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'day streak',
                        style: FpText.muted(size: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${todayMinutes.round()} min active today',
                  style: FpText.muted(size: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final num value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TintIcon(icon, color: color, size: 34),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: CountUp(value: value, style: FpText.number(size: 22)),
          ),
          Text(label, style: FpText.label(), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ── Today's hero (3D tilt) ────────────────────────────────────────────────────
class _TodayHero extends StatelessWidget {
  final AppState appState;
  const _TodayHero({required this.appState});

  @override
  Widget build(BuildContext context) {
    final today = HomeContent.weekdays[DateTime.now().weekday - 1];
    final plans = appState.getWorkoutsForDay(today);
    final categories = ExerciseDataService.categories;
    final category = plans.isNotEmpty
        ? plans.first.category
        : categories[DateTime.now().weekday % categories.length];
    final exercises = ExerciseDataService.getByCategory(category);
    final color = FpColors.forCategory(category);

    void open() => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WorkoutDetailPage(category: category)),
    );

    return TiltCard(
      onTap: open,
      child: Container(
        height: 212,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.55),
              FpColors.tealDeep.withValues(alpha: 0.65),
              FpColors.surface,
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.30),
              blurRadius: 30,
              spreadRadius: -8,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            children: [
              if (exercises.isNotEmpty)
                Positioned(
                  right: -10,
                  top: 0,
                  bottom: 0,
                  width: 170,
                  child: ShaderMask(
                    shaderCallback: (r) => const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.transparent, Colors.black],
                      stops: [0, 0.45],
                    ).createShader(r),
                    blendMode: BlendMode.dstIn,
                    child: Opacity(
                      opacity: 0.85,
                      child: ExerciseImage(
                        exercise: exercises.first,
                        animate: true,
                        radius: 0,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        plans.isNotEmpty
                            ? 'PLANNED • ${plans.first.time}'
                            : 'SUGGESTED',
                        style: FpText.label(color: FpColors.lime, size: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 190,
                      child: Text(
                        '$category Blast',
                        style: FpText.display(size: 24),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${exercises.length} exercises • ${ExerciseDataService.getCategoryDuration(category)}',
                      style: FpText.body(
                        color: FpColors.text.withValues(alpha: 0.75),
                        size: 12,
                      ),
                    ),
                    const Spacer(),
                    GlowButton(
                      label: 'Start',
                      icon: Icons.play_arrow_rounded,
                      expand: false,
                      height: 42,
                      onTap: open,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quick access grid ─────────────────────────────────────────────────────────
class _QuickToolData {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickToolData(this.icon, this.label, this.color, this.onTap);
}

class _QuickGrid extends StatelessWidget {
  final List<_QuickToolData> tools;
  const _QuickGrid({required this.tools});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.15,
      padding: EdgeInsets.zero,
      children: [
        for (var i = 0; i < tools.length; i++)
          GlassCard(
                radius: 20,
                padding: const EdgeInsets.all(8),
                onTap: tools[i].onTap,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TintIcon(tools[i].icon, color: tools[i].color, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      tools[i].label,
                      style: FpText.label(color: FpColors.text, size: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: (60 * i).ms)
              .scaleXY(begin: 0.85, curve: Curves.easeOutBack),
      ],
    );
  }
}

// ── Week strip ────────────────────────────────────────────────────────────────
class _WeekStrip extends StatelessWidget {
  final AppState appState;
  const _WeekStrip({required this.appState});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final weekly = appState.weeklyWorkouts;
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Last 7 days', style: FpText.h3())),
              Text(
                '$weekly workout${weekly == 1 ? '' : 's'} this week',
                style: FpText.muted(size: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final day = now.subtract(Duration(days: 6 - i));
              final isToday = i == 6;
              final worked = appState.workoutHistory.any((w) {
                final d = DateTime.parse(w.date);
                return d.year == day.year &&
                    d.month == day.month &&
                    d.day == day.day;
              });
              return Column(
                children: [
                  Text(
                    dayLabels[day.weekday - 1],
                    style: FpText.label(size: 10),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: 400.ms,
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: worked ? FpColors.accentGradient : null,
                      color: worked
                          ? null
                          : Colors.white.withValues(
                              alpha: isToday ? 0.10 : 0.05,
                            ),
                      border: isToday && !worked
                          ? Border.all(color: FpColors.tealLight, width: 1.5)
                          : null,
                      boxShadow: worked
                          ? [
                              BoxShadow(
                                color: FpColors.lime.withValues(alpha: 0.35),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: worked
                        ? const Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: FpColors.bgDeep,
                          )
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text('${day.day}', style: FpText.muted(size: 10)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Today's Plan ──────────────────────────────────────────────────────────────
class _TodaysPlan extends StatelessWidget {
  final AppState appState;
  const _TodaysPlan({required this.appState});

  @override
  Widget build(BuildContext context) {
    final today = HomeContent.weekdays[DateTime.now().weekday - 1];
    final plans = appState.getWorkoutsForDay(today);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          "Today's plan — $today",
          action: 'Edit',
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WorkoutPlannerScreen()),
          ),
        ),
        const SizedBox(height: 12),
        if (plans.isEmpty)
          GlassCard(
            child: Row(
              children: [
                const TintIcon(
                  Icons.event_available_outlined,
                  color: FpColors.tealLight,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rest day 😴', style: FpText.h3()),
                      Text(
                        'No workouts planned — enjoy the rest!',
                        style: FpText.muted(size: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          ...plans.map((plan) {
            final color = FpColors.forCategory(plan.category);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    TintIcon(
                      ExerciseDataService.getCategoryIcon(plan.category),
                      color: color,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plan.category, style: FpText.h3()),
                          Text(plan.time, style: FpText.muted(size: 12)),
                        ],
                      ),
                    ),
                    GlowButton(
                      label: 'Start',
                      expand: false,
                      height: 38,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              WorkoutDetailPage(category: plan.category),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

// ── Category tile ─────────────────────────────────────────────────────────────
class _CategoryTile extends StatelessWidget {
  final String category;
  final VoidCallback onTap;
  const _CategoryTile({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = FpColors.forCategory(category);
    final first = ExerciseDataService.getByCategory(category).firstOrNull;
    return Bounce(
      onTap: onTap,
      child: Container(
        width: 112,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (first != null) ExerciseImage(exercise: first, radius: 0),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withValues(alpha: 0.15),
                      FpColors.bgDeep.withValues(alpha: 0.92),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      ExerciseDataService.getCategoryIcon(category),
                      color: color,
                      size: 22,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category,
                      style: FpText.h3().copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Recent Workout Card ───────────────────────────────────────────────────────
class _RecentWorkoutCard extends StatelessWidget {
  final WorkoutSession session;
  const _RecentWorkoutCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final color = FpColors.forCategory(session.category);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            TintIcon(
              ExerciseDataService.getCategoryIcon(session.category),
              color: color,
              size: 46,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${session.category} Workout',
                    style: FpText.h3(),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    session.partial
                        ? '${session.date.substring(0, 10)} • partial'
                        : session.date.substring(0, 10),
                    style: FpText.muted(size: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${session.durationMinutes} min',
                  style: FpText.number(size: 14),
                ),
                Text(
                  '${session.caloriesBurned.toStringAsFixed(0)} cal',
                  style: FpText.muted(size: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty Workouts ────────────────────────────────────────────────────────────
class _EmptyWorkouts extends StatelessWidget {
  const _EmptyWorkouts();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const TintIcon(
            Icons.fitness_center_rounded,
            color: FpColors.tealLight,
            size: 64,
          ),
          const SizedBox(height: 14),
          Text('No workouts yet', style: FpText.h3()),
          const SizedBox(height: 6),
          Text(
            'Complete a workout to see your history here!',
            style: FpText.muted(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GlowButton(
            label: 'Start a workout',
            icon: Icons.play_arrow_rounded,
            expand: false,
            height: 44,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WorkoutDetailPage(
                  category: ExerciseDataService.categories.first,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Motivation Card ───────────────────────────────────────────────────────────
class _MotivationCard extends StatelessWidget {
  const _MotivationCard();

  static const _quotes = [
    'Push yourself, because no one else is going to do it for you.',
    'The only bad workout is the one that didn\'t happen.',
    'Your body can stand almost anything. It\'s your mind you have to convince.',
    'Success starts with self-discipline.',
    'Don\'t wish for it. Work for it.',
  ];

  @override
  Widget build(BuildContext context) {
    final q = _quotes[DateTime.now().day % _quotes.length];
    return GlassCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          FpColors.violet.withValues(alpha: 0.20),
          FpColors.teal.withValues(alpha: 0.08),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💬', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q,
                  style: FpText.body(size: 14).copyWith(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '— Daily motivation',
                  style: FpText.label(color: FpColors.violet),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── AI coach banner ───────────────────────────────────────────────────────────
class _CoachBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _CoachBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      glow: FpColors.violet,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          FpColors.violet.withValues(alpha: 0.28),
          FpColors.teal.withValues(alpha: 0.10),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  FpColors.teal,
                  FpColors.lime,
                  FpColors.violet,
                  FpColors.teal,
                ],
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: FpColors.bgDeep,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ask Pulse, your AI coach', style: FpText.h3()),
                Text(
                  'Plans, form tips and motivation — tailored to you',
                  style: FpText.muted(size: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: FpColors.muted),
        ],
      ),
    );
  }
}

// ── Bell with unread count ────────────────────────────────────────────────────
class _BellButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BellButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotificationCenter>().unreadCount;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(11),
          radius: 16,
          onTap: onTap,
          child: Icon(
            unread > 0
                ? Icons.notifications_active_rounded
                : Icons.notifications_none_rounded,
            color: FpColors.text,
            size: 22,
          ),
        ),
        if (unread > 0)
          Positioned(
            right: -4,
            top: -4,
            child:
                IgnorePointer(
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 20),
                        height: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [FpColors.coral, FpColors.amber],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: FpColors.bg, width: 2),
                        ),
                        child: Text(
                          unread > 9 ? '9+' : '$unread',
                          style: FpText.label(color: Colors.white, size: 10),
                        ),
                      ),
                    )
                    .animate(key: ValueKey(unread))
                    .scaleXY(
                      begin: 0.4,
                      curve: Curves.elasticOut,
                      duration: 700.ms,
                    ),
          ),
      ],
    );
  }
}
