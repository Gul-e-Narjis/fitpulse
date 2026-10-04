import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/app_state.dart';
import '../theme/fp_theme.dart';
import '../theme/fp_widgets.dart';

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

    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final labels = days.map((d) => _dayLabels[d.weekday - 1]).toList();

    return Scaffold(
      backgroundColor: FpColors.bg,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text('Progress', style: FpText.h1()),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: GlassCard(
                  padding: const EdgeInsets.all(4),
                  radius: 18,
                  child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      gradient: FpColors.accentGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    labelColor: FpColors.bgDeep,
                    unselectedLabelColor: FpColors.muted,
                    labelStyle: FpText.label(size: 13),
                    tabs: const [
                      Tab(text: 'Minutes', height: 40),
                      Tab(text: 'Calories', height: 40),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMinutesTab(minutes, labels, appState),
                    _buildCaloriesTab(calories, labels, appState),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Minutes Tab ────────────────────────────────────────────────────────────
  Widget _buildMinutesTab(
    List<double> minutes,
    List<String> labels,
    AppState appState,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            _SummaryTile(
              label: 'This week',
              value: appState.weeklyWorkouts,
              unit: 'workouts',
              color: FpColors.tealLight,
            ),
            const SizedBox(width: 12),
            _SummaryTile(
              label: 'Total time',
              value: appState.totalMinutesWorkedOut,
              unit: 'minutes',
              color: FpColors.violet,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _ChartCard(
          title: 'Daily workout minutes',
          values: minutes,
          labels: labels,
          colors: const [FpColors.teal, FpColors.lime],
          emptyMessage: 'Complete workouts to see your progress!',
          minMax: 20,
        ),
        const SizedBox(height: 24),
        _StreakCard(streak: appState.currentStreak),
      ],
    );
  }

  // ── Calories Tab ───────────────────────────────────────────────────────────
  Widget _buildCaloriesTab(
    List<double> calories,
    List<String> labels,
    AppState appState,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            _SummaryTile(
              label: 'Total burned',
              value: appState.totalCaloriesBurned.round(),
              unit: 'calories',
              color: FpColors.coral,
            ),
            const SizedBox(width: 12),
            _SummaryTile(
              label: 'This week',
              value: _weekCalories(appState).round(),
              unit: 'cal this week',
              color: FpColors.amber,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _ChartCard(
          title: 'Calories burned',
          values: calories,
          labels: labels,
          colors: const [FpColors.coral, FpColors.amber],
          emptyMessage: 'Complete workouts to see calorie data!',
          minMax: 100,
        ),
        const SizedBox(height: 24),
        _CategoryBreakdown(history: appState.workoutHistory),
      ],
    );
  }

  double _weekCalories(AppState appState) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return appState.workoutHistory
        .where((s) {
          final d = DateTime.parse(s.date);
          return d.isAfter(weekStart.subtract(const Duration(days: 1)));
        })
        .fold(0.0, (sum, s) => sum + s.caloriesBurned);
  }
}

// ── Gradient line chart card ──────────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  final String title;
  final List<double> values;
  final List<String> labels;
  final List<Color> colors;
  final String emptyMessage;
  final double minMax;

  const _ChartCard({
    required this.title,
    required this.values,
    required this.labels,
    required this.colors,
    required this.emptyMessage,
    required this.minMax,
  });

  @override
  Widget build(BuildContext context) {
    final peak = values.fold(0.0, (a, b) => a > b ? a : b);
    final maxY = (peak * 1.25).clamp(minMax, double.infinity);
    return GlassCard(
      glow: colors.first,
      padding: const EdgeInsets.fromLTRB(16, 18, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: FpText.h3()),
          Text('Last 7 days', style: FpText.muted(size: 12)),
          const SizedBox(height: 18),
          SizedBox(
            height: 210,
            child: values.every((v) => v == 0)
                ? _EmptyChart(message: emptyMessage)
                : TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (context, t, _) =>
                        LineChart(_data(maxY, t), duration: Duration.zero),
                  ),
          ),
        ],
      ),
    );
  }

  LineChartData _data(double maxY, double t) {
    final spots = List.generate(
      values.length,
      (i) => FlSpot(i.toDouble(), values[i] * t),
    );
    return LineChartData(
      minY: 0,
      maxY: maxY,
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (_) => FlLine(
          color: Colors.white.withValues(alpha: 0.06),
          strokeWidth: 1,
          dashArray: [4, 4],
        ),
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => FpColors.surfaceHigh,
          getTooltipItems: (spots) => spots
              .map(
                (s) => LineTooltipItem(
                  values[s.x.toInt()].toStringAsFixed(0),
                  FpText.label(color: FpColors.text, size: 12),
                ),
              )
              .toList(),
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 34,
            interval: maxY / 4,
            getTitlesWidget: (value, _) =>
                Text('${value.toInt()}', style: FpText.label(size: 10)),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, _) {
              final i = value.toInt();
              if (i < 0 || i >= labels.length) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  labels[i],
                  style: FpText.label(
                    size: 11,
                    color: i == labels.length - 1
                        ? FpColors.text
                        : FpColors.muted,
                  ),
                ),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.35,
          preventCurveOverShooting: true,
          gradient: LinearGradient(colors: colors),
          barWidth: 4,
          isStrokeCapRound: true,
          shadow: Shadow(
            color: colors.last.withValues(alpha: 0.5),
            blurRadius: 12,
          ),
          dotData: FlDotData(
            getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
              radius: 4,
              color: FpColors.bg,
              strokeWidth: 2.5,
              strokeColor: colors.last,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.first.withValues(alpha: 0.35),
                colors.last.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Streak Card ───────────────────────────────────────────────────────────────
class _StreakCard extends StatelessWidget {
  final int streak;
  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glow: FpColors.amber,
      gradient: LinearGradient(
        colors: [
          FpColors.amber.withValues(alpha: 0.18),
          FpColors.coral.withValues(alpha: 0.06),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 36))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(end: 1.15, duration: 900.ms),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak day${streak == 1 ? '' : 's'} streak!',
                  style: FpText.h2(),
                ),
                const SizedBox(height: 4),
                Text(
                  streak == 0
                      ? 'Start your streak today!'
                      : 'Keep it up, you\'re doing great!',
                  style: FpText.muted(),
                ),
              ],
            ),
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
        const SectionTitle('By category'),
        const SizedBox(height: 12),
        ...sorted.map((e) {
          final pct = total > 0 ? e.value / total : 0.0;
          final color = FpColors.forCategory(e.key);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(e.key, style: FpText.h3())),
                      Text(
                        '${e.value.toStringAsFixed(0)} cal',
                        style: FpText.label(color: color, size: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: pct),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, _) => LinearProgressIndicator(
                        value: v,
                        minHeight: 7,
                        backgroundColor: Colors.white.withValues(alpha: 0.06),
                        valueColor: AlwaysStoppedAnimation(color),
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

// ── Summary Tile ──────────────────────────────────────────────────────────────
class _SummaryTile extends StatelessWidget {
  final String label;
  final num value;
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
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: FpText.label()),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: CountUp(
                value: value,
                style: FpText.number(size: 28, color: color),
              ),
            ),
            Text(unit, style: FpText.muted(size: 11)),
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
          const Icon(Icons.show_chart_rounded, size: 48, color: FpColors.faint),
          const SizedBox(height: 12),
          Text(message, style: FpText.muted(), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
