import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_colors.dart';
import '../services/app_state.dart';
import '../services/exercise_data.dart';
import 'search_page.dart';
import 'workout_detail.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import 'progress_charts.dart';
import 'workout_planner.dart';
import 'step_counter.dart';
import 'notifications_screen.dart';
import 'custom_workout.dart';

// ── Home Wrapper ─────────────────────────────────────────────────────────────
class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeContent(),
    SearchPage(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.sageGreen,
          unselectedItemColor: AppColors.textGrey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search_rounded),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Home Content ─────────────────────────────────────────────────────────────
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TOP HEADER ────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E9FA3), Color(0xFF0A6B6F)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_greeting()}  👋',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            appState.userName.split(' ')[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              appState.fitnessGoal,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationsScreen(),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_active_rounded,
                                color: Color(0xFFFFD54F),
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.22),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child:
                                  appState.userName == 'Fitness User' ||
                                      appState.userName.isEmpty
                                  ? const Icon(
                                      Icons.person_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    )
                                  : Center(
                                      child: Text(
                                        appState.userName[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── 3 Stat Cards ──────────────────────
                  Row(
                    children: [
                      _StatCard(
                        value: '${appState.totalWorkoutsCompleted}',
                        label: 'Workouts',
                        icon: Icons.fitness_center_rounded,
                        iconColor: const Color(0xFFFFE082),
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        value: '${appState.totalMinutesWorkedOut}',
                        label: 'Minutes',
                        icon: Icons.timer_rounded,
                        iconColor: const Color(0xFFB2EBF2),
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        value: appState.totalCaloriesBurned.toStringAsFixed(0),
                        label: 'Calories',
                        icon: Icons.local_fire_department_rounded,
                        iconColor: const Color(0xFFFFCCBC),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── QUICK ACCESS ──────────────────────
                  const Text(
                    'Quick Access',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _QuickTool(
                        icon: Icons.bar_chart_rounded,
                        label: 'Progress',
                        color: const Color(0xFF1E9FA3),
                        bgColor: AppColors.softBlue,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProgressChartsScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _QuickTool(
                        icon: Icons.calendar_month_rounded,
                        label: 'Planner',
                        color: const Color(0xFF8B7CF6),
                        bgColor: AppColors.softPurple,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WorkoutPlannerScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _QuickTool(
                        icon: Icons.directions_walk_rounded,
                        label: 'Steps',
                        color: const Color(0xFF43A047),
                        bgColor: AppColors.softGreen,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StepCounterScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _QuickTool(
                        icon: Icons.calculate_outlined,
                        label: 'BMI',
                        color: const Color(0xFFE07B54),
                        bgColor: AppColors.softOrange,
                        onTap: () => Navigator.pushNamed(context, '/bmi'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _QuickTool(
                        icon: Icons.tune_rounded,
                        label: 'Custom',
                        color: const Color(0xFF00897B),
                        bgColor: const Color(0xFFE0F2F1),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CustomWorkoutScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _QuickTool(
                        icon: Icons.notifications_outlined,
                        label: 'Reminders',
                        color: const Color(0xFF7B61FF),
                        bgColor: AppColors.softPurple,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: SizedBox()),
                      const SizedBox(width: 12),
                      const Expanded(child: SizedBox()),
                    ],
                  ),

                  const SizedBox(height: 26),

                  // ── STREAK BANNER ─────────────────────
                  _WeeklyStreakBanner(appState: appState),

                  const SizedBox(height: 26),

                  // ── TODAY'S PLAN ──────────────────────
                  _TodaysPlan(appState: appState),

                  const SizedBox(height: 26),

                  // ── WORKOUT CATEGORIES ────────────────
                  const Text(
                    'Workout Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: ExerciseDataService.categories.length,
                      itemBuilder: (context, i) {
                        final cat = ExerciseDataService.categories[i];
                        final color = ExerciseDataService.getCategoryColor(cat);
                        final icon = ExerciseDataService.getCategoryIcon(cat);
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WorkoutDetailPage(category: cat),
                            ),
                          ),
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: color.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(icon, color: color, size: 26),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  cat,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ── RECENT WORKOUTS ───────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Workouts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      if (appState.workoutHistory.isNotEmpty)
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/history'),
                          child: const Text(
                            'See all',
                            style: TextStyle(
                              color: AppColors.sageGreen,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  appState.workoutHistory.isEmpty
                      ? _EmptyWorkouts()
                      : Column(
                          children: appState.workoutHistory
                              .take(3)
                              .map((s) => _RecentWorkoutCard(session: s))
                              .toList(),
                        ),

                  const SizedBox(height: 26),

                  // ── MOTIVATION ────────────────────────
                  _MotivationCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat Card (improved visibility) ──────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.65), width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Tool ────────────────────────────────────────────────────────────────
class _QuickTool extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _QuickTool({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Weekly Streak Banner ──────────────────────────────────────────────────────
class _WeeklyStreakBanner extends StatelessWidget {
  final AppState appState;
  const _WeeklyStreakBanner({required this.appState});

  int get _streak {
    if (appState.workoutHistory.isEmpty) return 0;
    int s = 0;
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final day = now.subtract(Duration(days: i));
      final worked = appState.workoutHistory.any((w) {
        final d = DateTime.parse(w.date);
        return d.year == day.year && d.month == day.month && d.day == day.day;
      });
      if (worked) {
        s++;
      } else if (i > 0) {
        break;
      }
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final streak = _streak;
    final weekly = appState.weeklyWorkouts;
    final now = DateTime.now();
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E9FA3), Color(0xFF0A6B6F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E9FA3).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Text(
                          streak == 0
                              ? 'Start Your Streak!'
                              : '$streak Day${streak == 1 ? '' : 's'} Streak!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$weekly workout${weekly == 1 ? '' : 's'} this week  •  Keep going! 💪',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 46,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── 7-day indicator with labels ───────────
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
                  // Day label
                  Text(
                    dayLabels[day.weekday - 1],
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Circle
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: worked
                          ? Colors.white
                          : isToday
                          ? Colors.white.withValues(alpha: 0.35)
                          : Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: isToday && !worked
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                    child: worked
                        ? const Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: Color(0xFF1E9FA3),
                          )
                        : isToday
                        ? const Icon(
                            Icons.radio_button_unchecked,
                            size: 18,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(height: 4),
                  // Date number
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 10,
                    ),
                  ),
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
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final today = days[DateTime.now().weekday - 1];
    final plans = appState.getWorkoutsForDay(today);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Plan — $today",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WorkoutPlannerScreen()),
              ),
              child: const Text(
                'Edit',
                style: TextStyle(
                  color: AppColors.sageGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        plans.isEmpty
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.event_available_outlined,
                        color: AppColors.sageGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rest Day 😴',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'No workouts planned — enjoy the rest!',
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Column(
                children: plans.map((plan) {
                  final color = ExerciseDataService.getCategoryColor(
                    plan.category,
                  );
                  final icon = ExerciseDataService.getCategoryIcon(
                    plan.category,
                  );
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, color: color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan.category,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                plan.time,
                                style: const TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  WorkoutDetailPage(category: plan.category),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.sageGreen,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Start',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }
}

// ── Recent Workout Card ───────────────────────────────────────────────────────
class _RecentWorkoutCard extends StatelessWidget {
  final WorkoutSession session;
  const _RecentWorkoutCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final color = ExerciseDataService.getCategoryColor(session.category);
    final icon = ExerciseDataService.getCategoryIcon(session.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
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
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontSize: 14,
                  ),
                ),
                Text(
                  session.date.substring(0, 10),
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${session.durationMinutes} min',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '${session.caloriesBurned.toStringAsFixed(0)} cal',
                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Empty Workouts ────────────────────────────────────────────────────────────
class _EmptyWorkouts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              size: 40,
              color: AppColors.sageGreen,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No workouts yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Complete a workout to see your history here!',
            style: TextStyle(fontSize: 13, color: AppColors.textGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WorkoutDetailPage(
                  category: ExerciseDataService.categories.first,
                ),
              ),
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text('Start a Workout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sageGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Motivation Card ───────────────────────────────────────────────────────────
class _MotivationCard extends StatelessWidget {
  final List<Map<String, String>> _quotes = const [
    {
      'q': 'Push yourself, because no one else is going to do it for you.',
      'a': 'Unknown',
    },
    {
      'q': 'The only bad workout is the one that didn\'t happen.',
      'a': 'Unknown',
    },
    {
      'q':
          'Your body can stand almost anything. It\'s your mind you have to convince.',
      'a': 'Unknown',
    },
    {'q': 'Success starts with self-discipline.', 'a': 'Unknown'},
    {'q': 'Don\'t wish for it. Work for it.', 'a': 'Unknown'},
  ];

  @override
  Widget build(BuildContext context) {
    final q = _quotes[DateTime.now().day % _quotes.length];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.softPurple,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB39DDB).withValues(alpha: 0.3)),
      ),
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
                  q['q']!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4527A0),
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '— Daily Motivation',
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF4527A0).withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
