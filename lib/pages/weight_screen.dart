import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme/fp_theme.dart';
import '../theme/fp_widgets.dart';

const _weightColor = FpColors.violet;

String _kg(double v) => v.toStringAsFixed(v % 1 == 0 ? 0 : 1);

String _prettyDate(String iso) {
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
  final d = DateTime.parse(iso);
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

// ── Weight progress screen ────────────────────────────────────────────────────
class WeightScreen extends StatelessWidget {
  const WeightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final goal = app.goalWeight;
    final change = app.weightChange;
    final entries = app.weights.reversed.toList();

    return Scaffold(
      backgroundColor: FpColors.bg,
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(child: Text('Weight progress', style: FpText.h1())),
                ],
              ),
              const SizedBox(height: 12),

              // ── Ring + stats ──────────────────────
              GlassCard(
                glow: _weightColor,
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    AnimatedRing(
                      progress: app.weightProgress,
                      size: 128,
                      stroke: 11,
                      colors: const [
                        FpColors.violet,
                        FpColors.tealLight,
                        FpColors.lime,
                      ],
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CountUp(
                            value: app.currentWeight,
                            decimals: app.currentWeight % 1 == 0 ? 0 : 1,
                            style: FpText.number(size: 26),
                          ),
                          Text('kg now', style: FpText.label()),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StatLine(
                            label: change >= 0 ? 'LOST' : 'GAINED',
                            value: '${_kg(change.abs())} kg',
                            color: change >= 0 ? FpColors.lime : FpColors.amber,
                          ),
                          const SizedBox(height: 10),
                          _StatLine(
                            label: 'TO GO',
                            value: goal == null
                                ? '—'
                                : app.weightToGo! < 0.05
                                ? 'Goal reached 🎉'
                                : '${_kg(app.weightToGo!)} kg',
                            color: FpColors.tealLight,
                          ),
                          const SizedBox(height: 10),
                          _StatLine(
                            label: 'START → GOAL',
                            value:
                                '${_kg(app.startWeight)} → ${goal == null ? '?' : _kg(goal)} kg',
                            color: FpColors.muted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: GlowButton(
                      label: 'Log weight',
                      icon: Icons.add_rounded,
                      gradient: const LinearGradient(
                        colors: [FpColors.violet, FpColors.tealLight],
                      ),
                      onTap: () => showWeightSheet(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: GlowButton(
                      label: goal == null ? 'Set goal' : 'Goal',
                      icon: Icons.flag_rounded,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.12),
                          Colors.white.withValues(alpha: 0.06),
                        ],
                      ),
                      textColor: FpColors.text,
                      onTap: () => _showGoalSheet(context, app),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Chart ─────────────────────────────
              const SectionTitle('Weight over time'),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.fromLTRB(12, 18, 18, 10),
                child: SizedBox(
                  height: 210,
                  child: app.weights.isEmpty
                      ? Center(
                          child: Text(
                            'Log your weight to see the trend',
                            style: FpText.muted(),
                          ),
                        )
                      : TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1100),
                          curve: Curves.easeOutCubic,
                          builder: (context, t, _) => LineChart(
                            _chartData(app, t),
                            duration: Duration.zero,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // ── History ───────────────────────────
              SectionTitle(
                'History',
                action: entries.isEmpty ? null : '${entries.length} entries',
              ),
              const SizedBox(height: 12),
              if (entries.isEmpty)
                GlassCard(
                  child: Text(
                    'No entries yet. Your starting weight is ${_kg(app.startWeight)} kg.',
                    style: FpText.muted(),
                  ),
                )
              else
                for (final (i, w) in entries.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _HistoryRow(
                      entry: w,
                      previous: i + 1 < entries.length ? entries[i + 1] : null,
                    ),
                  ).animate().fadeIn(delay: (40 * i).ms).slideX(begin: 0.06),
            ],
          ),
        ),
      ),
    );
  }

  LineChartData _chartData(AppState app, double t) {
    // Start point first, then every logged entry
    final values = [app.startWeight, ...app.weights.map((w) => w.kg)];
    final labels = ['Start', ...app.weights.map((w) => _prettyDate(w.date))];
    final goal = app.goalWeight;
    final all = [...values, ?goal];
    final lo = all.reduce((a, b) => a < b ? a : b) - 2;
    final hi = all.reduce((a, b) => a > b ? a : b) + 2;
    final base = values.first;
    final spots = [
      for (var i = 0; i < values.length; i++)
        FlSpot(i.toDouble(), base + (values[i] - base) * t),
    ];
    return LineChartData(
      minY: lo,
      maxY: hi,
      minX: 0,
      maxX: (values.length - 1).toDouble().clamp(1, double.infinity),
      gridData: FlGridData(
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => FlLine(
          color: Colors.white.withValues(alpha: 0.06),
          dashArray: [4, 4],
        ),
      ),
      borderData: FlBorderData(show: false),
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          if (goal != null)
            HorizontalLine(
              y: goal,
              color: FpColors.lime.withValues(alpha: 0.7),
              strokeWidth: 1.5,
              dashArray: [6, 4],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                style: FpText.label(color: FpColors.lime, size: 10),
                labelResolver: (_) => 'GOAL ${_kg(goal)}',
              ),
            ),
        ],
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => FpColors.surfaceHigh,
          getTooltipItems: (spots) => spots
              .map(
                (s) => LineTooltipItem(
                  '${_kg(values[s.x.toInt()])} kg\n${labels[s.x.toInt()]}',
                  FpText.label(color: FpColors.text, size: 11),
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
            getTitlesWidget: (v, meta) => v == meta.min || v == meta.max
                ? const SizedBox()
                : Text(v.toStringAsFixed(0), style: FpText.label(size: 10)),
          ),
        ),
        bottomTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
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
          preventCurveOverShooting: true,
          barWidth: 4,
          isStrokeCapRound: true,
          gradient: const LinearGradient(
            colors: [FpColors.violet, FpColors.tealLight, FpColors.lime],
          ),
          shadow: Shadow(
            color: _weightColor.withValues(alpha: 0.5),
            blurRadius: 12,
          ),
          dotData: FlDotData(
            getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
              radius: 4,
              color: FpColors.bg,
              strokeWidth: 2.5,
              strokeColor: FpColors.tealLight,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _weightColor.withValues(alpha: 0.30),
                _weightColor.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showGoalSheet(BuildContext context, AppState app) async {
    final value = await _numberSheet(
      context,
      title: 'Goal weight',
      initial: app.goalWeight ?? (app.currentWeight - 3).roundToDouble(),
      withDate: false,
    );
    if (value != null) app.setGoalWeight(value.$1);
  }
}

class _StatLine extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatLine({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: FpText.label(size: 10)),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: FpText.number(size: 17, color: color)),
        ),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final WeightEntry entry;
  final WeightEntry? previous;
  const _HistoryRow({required this.entry, this.previous});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final diff = previous == null ? null : entry.kg - previous!.kg;
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: FpColors.coral.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: FpColors.coral),
      ),
      onDismissed: (_) => _delete(context, app),
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
        child: Row(
          children: [
            const TintIcon(
              Icons.monitor_weight_outlined,
              color: _weightColor,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_kg(entry.kg)} kg', style: FpText.h3()),
                  Text(_prettyDate(entry.date), style: FpText.muted(size: 12)),
                ],
              ),
            ),
            if (diff != null && diff.abs() >= 0.05)
              Text(
                '${diff > 0 ? '+' : '−'}${_kg(diff.abs())}',
                style: FpText.label(
                  color: diff > 0 ? FpColors.amber : FpColors.lime,
                  size: 12,
                ),
              ),
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(
                Icons.edit_outlined,
                size: 20,
                color: FpColors.muted,
              ),
              onPressed: () async {
                final v = await _numberSheet(
                  context,
                  title: 'Edit entry',
                  initial: entry.kg,
                  date: DateTime.parse(entry.date),
                );
                if (v != null) app.updateWeight(entry.id, v.$1, v.$2);
              },
            ),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: FpColors.coral,
              ),
              onPressed: () => _delete(context, app),
            ),
          ],
        ),
      ),
    );
  }

  void _delete(BuildContext context, AppState app) {
    final messenger = ScaffoldMessenger.of(context);
    final removed = entry;
    app.deleteWeight(entry.id);
    messenger.showSnackBar(
      SnackBar(
        content: Text('Deleted ${_kg(removed.kg)} kg entry'),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: FpColors.lime,
          onPressed: () =>
              app.addWeight(removed.kg, DateTime.parse(removed.date)),
        ),
      ),
    );
  }
}

// ── Bottom sheets ─────────────────────────────────────────────────────────────
Future<void> showWeightSheet(BuildContext context) async {
  final app = context.read<AppState>();
  final v = await _numberSheet(
    context,
    title: 'Log weight',
    initial: app.currentWeight,
    date: DateTime.now(),
  );
  if (v != null) app.addWeight(v.$1, v.$2);
}

Future<(double, DateTime)?> _numberSheet(
  BuildContext context, {
  required String title,
  required double initial,
  DateTime? date,
  bool withDate = true,
}) {
  return showModalBottomSheet<(double, DateTime)>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _NumberSheet(
      title: title,
      initial: initial,
      date: date ?? DateTime.now(),
      withDate: withDate,
    ),
  );
}

class _NumberSheet extends StatefulWidget {
  final String title;
  final double initial;
  final DateTime date;
  final bool withDate;
  const _NumberSheet({
    required this.title,
    required this.initial,
    required this.date,
    required this.withDate,
  });

  @override
  State<_NumberSheet> createState() => _NumberSheetState();
}

class _NumberSheetState extends State<_NumberSheet> {
  late final _ctrl = TextEditingController(text: _kg(widget.initial));
  late DateTime _date = widget.date;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final v = double.tryParse(_ctrl.text.replaceAll(',', '.'));
    if (v == null || v < 20 || v > 400) {
      setState(() => _error = 'Enter a weight between 20 and 400 kg');
      return;
    }
    Navigator.pop(context, (double.parse(v.toStringAsFixed(1)), _date));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: FpColors.surfaceHigh,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(widget.title, style: FpText.h2()),
              const SizedBox(height: 16),
              TextField(
                controller: _ctrl,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                style: FpText.number(size: 24),
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  suffixText: 'kg',
                  errorText: _error,
                  prefixIcon: const Icon(
                    Icons.monitor_weight_outlined,
                    color: _weightColor,
                  ),
                ),
              ),
              if (widget.withDate) ...[
                const SizedBox(height: 12),
                GlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_rounded,
                        color: FpColors.tealLight,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _prettyDate(_date.toIso8601String().split('T')[0]),
                          style: FpText.body(),
                        ),
                      ),
                      Text(
                        'Change',
                        style: FpText.label(color: FpColors.tealLight),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              GlowButton(
                label: 'Save',
                icon: Icons.check_rounded,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Home card ─────────────────────────────────────────────────────────────────
class WeightCard extends StatelessWidget {
  const WeightCard({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final goal = app.goalWeight;
    return GlassCard(
      glow: _weightColor,
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WeightScreen()),
      ),
      child: Row(
        children: [
          AnimatedRing(
            progress: app.weightProgress,
            size: 64,
            stroke: 6,
            colors: const [FpColors.violet, FpColors.tealLight],
            child: const Icon(
              Icons.monitor_weight_outlined,
              color: _weightColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('WEIGHT', style: FpText.label(color: _weightColor)),
                const SizedBox(height: 2),
                Text('${_kg(app.currentWeight)} kg', style: FpText.h2()),
                Text(
                  goal == null
                      ? 'Tap to set a goal'
                      : app.weightToGo! < 0.05
                      ? 'Goal reached 🎉'
                      : '${_kg(app.weightToGo!)} kg to go',
                  style: FpText.muted(size: 12),
                ),
              ],
            ),
          ),
          Bounce(
            onTap: () => showWeightSheet(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [FpColors.violet, FpColors.tealLight],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _weightColor.withValues(alpha: 0.45),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded, color: FpColors.bgDeep),
            ),
          ),
        ],
      ),
    );
  }
}
