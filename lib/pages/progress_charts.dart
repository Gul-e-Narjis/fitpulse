import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/app_state.dart';
import 'app_colors.dart';

class ProgressChartsScreen extends StatefulWidget {
  const ProgressChartsScreen({super.key});

  @override
  State<ProgressChartsScreen> createState() => _ProgressChartsScreenState();
}

class _ProgressChartsScreenState extends State<ProgressChartsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final calories = appState.last7DaysCalories;
    final minutes = appState.last7DaysMinutes;

    // Day labels (Mon-Sun real dates)
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final labels = days.map((d) => _dayLabels[d.weekday - 1]).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Progress Charts'),
        backgroundColor: AppColors.background,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.sageGreen,
          unselectedLabelColor: AppColors.textGrey,
          indicatorColor: AppColors.sageGreen,
          tabs: const [
            Tab(text: 'Minutes'),
            Tab(text: 'Calories'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMinutesTab(minutes, labels, appState),
          _buildCaloriesTab(calories, labels, appState),
        ],
      ),
    );
  }

  // ── Minutes Tab ────────────────────────────────────────────────────────────
  Widget _buildMinutesTab(
    List<double> minutes,
    List<String> labels,
    AppState appState,
  ) {
    final maxVal = minutes.isEmpty
        ? 60.0
        : (minutes.reduce((a, b) => a > b ? a : b) + 10).clamp(20.0, 999.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Summary row ───────────────────────────
          Row(
            children: [
              _SummaryTile(
                label: 'This Week',
                value: '${appState.weeklyWorkouts}',
                unit: 'workouts',
                color: AppColors.sageGreen,
              ),
              const SizedBox(width: 12),
              _SummaryTile(
                label: 'Total Time',
                value: '${appState.totalMinutesWorkedOut}',
                unit: 'minutes',
                color: const Color(0xFF8B7CF6),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Bar Chart ─────────────────────────────
          const Text(
            'Daily Workout Minutes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Last 7 days',
            style: TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
          const SizedBox(height: 20),

          Container(
            height: 240,
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: minutes.every((v) => v == 0)
                ? _EmptyChart(
                    message: 'Complete workouts to see your progress!',
                  )
                : BarChart(
                    BarChartData(
                      maxY: maxVal,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxVal / 4,
                        getDrawingHorizontalLine: (value) =>
                            FlLine(color: AppColors.border, strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            interval: maxVal / 4,
                            getTitlesWidget: (value, _) => Text(
                              '${value.toInt()}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              final i = value.toInt();
                              if (i < 0 || i >= labels.length) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  labels[i],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      barGroups: List.generate(
                        7,
                        (i) => BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: minutes[i],
                              color: minutes[i] > 0
                                  ? AppColors.sageGreen
                                  : AppColors.border,
                              width: 22,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 28),

          // ── Streak section ────────────────────────
          _StreakCard(workoutHistory: appState.workoutHistory),
        ],
      ),
    );
  }

  // ── Calories Tab ───────────────────────────────────────────────────────────
  Widget _buildCaloriesTab(
    List<double> calories,
    List<String> labels,
    AppState appState,
  ) {
    final spots = List.generate(7, (i) => FlSpot(i.toDouble(), calories[i]));
    final maxVal = calories.isEmpty
        ? 500.0
        : (calories.reduce((a, b) => a > b ? a : b) + 50).clamp(100.0, 9999.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Summary row ───────────────────────────
          Row(
            children: [
              _SummaryTile(
                label: 'Total Burned',
                value: appState.totalCaloriesBurned.toStringAsFixed(0),
                unit: 'calories',
                color: const Color(0xFFE07B54),
              ),
              const SizedBox(width: 12),
              _SummaryTile(
                label: 'This Week',
                value: _weekCalories(appState).toStringAsFixed(0),
                unit: 'cal this week',
                color: AppColors.sageGreen,
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Line Chart ────────────────────────────
          const Text(
            'Calories Burned',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Last 7 days',
            style: TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
          const SizedBox(height: 20),

          Container(
            height: 240,
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: calories.every((v) => v == 0)
                ? _EmptyChart(message: 'Complete workouts to see calorie data!')
                : LineChart(
                    LineChartData(
                      maxY: maxVal,
                      minY: 0,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxVal / 4,
                        getDrawingHorizontalLine: (_) =>
                            FlLine(color: AppColors.border, strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: maxVal / 4,
                            getTitlesWidget: (value, _) => Text(
                              '${value.toInt()}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              final i = value.toInt();
                              if (i < 0 || i >= labels.length) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  labels[i],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: const Color(0xFFE07B54),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, _, __, ___) =>
                                FlDotCirclePainter(
                              radius: 4,
                              color: Colors.white,
                              strokeWidth: 2.5,
                              strokeColor: const Color(0xFFE07B54),
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFFE07B54).withValues(alpha: 0.12),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          const SizedBox(height: 28),

          // ── Per-category breakdown ────────────────
          _CategoryBreakdown(history: appState.workoutHistory),
        ],
      ),
    );
  }

  double _weekCalories(AppState appState) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return appState.workoutHistory.where((s) {
      final d = DateTime.parse(s.date);
      return d.isAfter(weekStart.subtract(const Duration(days: 1)));
    }).fold(0.0, (sum, s) => sum + s.caloriesBurned);
  }
}

// ── Streak Card ───────────────────────────────────────────────────────────────
class _StreakCard extends StatelessWidget {
  final List<WorkoutSession> workoutHistory;
  const _StreakCard({required this.workoutHistory});

  int get _currentStreak {
    if (workoutHistory.isEmpty) return 0;
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final day = now.subtract(Duration(days: i));
      final worked = workoutHistory.any((s) {
        final d = DateTime.parse(s.date);
        return d.year == day.year && d.month == day.month && d.day == day.day;
      });
      if (worked) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final streak = _currentStreak;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E9FA3), Color(0xFF0D7A7E)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streak Day${streak == 1 ? '' : 's'} Streak!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                streak == 0
                    ? 'Start your streak today!'
                    : 'Keep it up, you\'re doing great!',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Category Breakdown ────────────────────────────────────────────────────────
class _CategoryBreakdown extends StatelessWidget {
  final List<WorkoutSession> history;
  const _CategoryBreakdown({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox();

    final Map<String, double> catCalories = {};
    for (final s in history) {
      catCalories[s.category] =
          (catCalories[s.category] ?? 0) + s.caloriesBurned;
    }
    final sorted = catCalories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = catCalories.values.fold(0.0, (a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'By Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        ...sorted.map((e) {
          final pct = total > 0 ? e.value / total : 0.0;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.key,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '${e.value.toStringAsFixed(0)} cal',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.sageGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.sageGreen,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ── Summary Tile ──────────────────────────────────────────────────────────────
class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              unit,
              style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty chart placeholder ───────────────────────────────────────────────────
class _EmptyChart extends StatelessWidget {
  final String message;
  const _EmptyChart({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bar_chart_rounded,
            size: 48,
            color: AppColors.border,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
