import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pedometer/pedometer.dart';
import '../services/app_state.dart';
import 'app_colors.dart';
import 'shared_widgets.dart';

class StepCounterScreen extends StatefulWidget {
  const StepCounterScreen({super.key});

  @override
  State<StepCounterScreen> createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ringController;
  StreamSubscription<StepCount>? _stepSub;
  StreamSubscription<PedestrianStatus>? _statusSub;

  int _steps = 0;
  String _status = 'unknown'; // 'walking', 'stopped', 'unknown'
  bool _sensorAvailable = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    // No step sensor in the browser — pedometer has no web implementation
    if (!kIsWeb) _initPedometer();
  }

  void _initPedometer() {
    try {
      _stepSub = Pedometer.stepCountStream.listen(
        (event) {
          if (!mounted) return;
          final appState = context.read<AppState>();
          setState(() => _steps = event.steps);
          appState.updateSteps(event.steps);
        },
        onError: (e) {
          setState(() {
            _sensorAvailable = false;
            _errorMsg = 'Pedometer not available on this device';
          });
        },
      );

      _statusSub = Pedometer.pedestrianStatusStream.listen(
        (event) => setState(() => _status = event.status),
        onError: (_) {},
      );
    } catch (e) {
      setState(() {
        _sensorAvailable = false;
        _errorMsg = 'Pedometer not supported';
      });
    }
  }

  @override
  void dispose() {
    _ringController.dispose();
    _stepSub?.cancel();
    _statusSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Step Counter'),
          backgroundColor: AppColors.background,
        ),
        body: const MobileOnlyNotice(
          icon: Icons.directions_walk_rounded,
          feature: 'Step counting',
        ),
      );
    }

    final appState = context.watch<AppState>();
    final goal = appState.stepGoal;
    final steps = _sensorAvailable ? _steps : appState.todaySteps;
    final progress = (steps / goal).clamp(0.0, 1.0);
    final double caloriesEstimate = steps * 0.04; // ~0.04 cal per step
    final double kmEstimate = steps * 0.0008; // ~0.8m per step

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Step Counter'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: AppColors.textGrey,
            onPressed: () => _showGoalDialog(context, appState),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Walking status ────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _status == 'walking'
                    ? AppColors.sageGreen.withValues(alpha: 0.1)
                    : AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _status == 'walking'
                      ? AppColors.sageGreen
                      : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _status == 'walking'
                        ? Icons.directions_walk
                        : Icons.accessibility_new,
                    color: _status == 'walking'
                        ? AppColors.sageGreen
                        : AppColors.textGrey,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _status == 'walking' ? 'Walking...' : 'Standing still',
                    style: TextStyle(
                      color: _status == 'walking'
                          ? AppColors.sageGreen
                          : AppColors.textGrey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Progress Ring ─────────────────────────
            SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ring painter
                  CustomPaint(
                    size: const Size(240, 240),
                    painter: _RingPainter(
                      progress: progress,
                      trackColor: AppColors.border,
                      progressColor: AppColors.sageGreen,
                    ),
                  ),
                  // Center content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_sensorAvailable)
                        const Icon(
                          Icons.sensors_off,
                          color: AppColors.textGrey,
                          size: 28,
                        ),
                      Text(
                        '$steps',
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Text(
                        'steps',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Goal: $goal',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.sageGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (_errorMsg != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '⚠️ $_errorMsg — showing estimated data',
                  style: const TextStyle(fontSize: 12, color: Colors.orange),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            const SizedBox(height: 32),

            // ── Stats Row ─────────────────────────────
            Row(
              children: [
                _StatBox(
                  icon: Icons.local_fire_department,
                  value: caloriesEstimate.toStringAsFixed(0),
                  label: 'Calories',
                  color: const Color(0xFFE07B54),
                ),
                const SizedBox(width: 12),
                _StatBox(
                  icon: Icons.route_outlined,
                  value: '${kmEstimate.toStringAsFixed(2)} km',
                  label: 'Distance',
                  color: AppColors.sageGreen,
                ),
                const SizedBox(width: 12),
                _StatBox(
                  icon: Icons.percent,
                  value: '${(progress * 100).toStringAsFixed(0)}%',
                  label: 'Goal',
                  color: const Color(0xFF8B7CF6),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Progress bar ──────────────────────────
            Container(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Daily Progress',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        '$steps / $goal',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(
                        progress >= 1.0 ? Colors.green : AppColors.sageGreen,
                      ),
                    ),
                  ),
                  if (progress >= 1.0) ...[
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Goal achieved! 🎉',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Motivational milestones ───────────────
            _MilestoneSection(steps: steps),
          ],
        ),
      ),
    );
  }

  void _showGoalDialog(BuildContext context, AppState appState) {
    final controller = TextEditingController(
      text: appState.stepGoal.toString(),
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Set Step Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Daily step goal',
            hintText: '10000',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.flag_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                appState.setStepGoal(val);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sageGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ── Ring Painter ──────────────────────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 16;
    const strokeWidth = 18.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw track
    canvas.drawCircle(center, radius, trackPaint);

    // Draw progress arc
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

// ── Stat Box ──────────────────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Milestones ────────────────────────────────────────────────────────────────
class _MilestoneSection extends StatelessWidget {
  final int steps;
  const _MilestoneSection({required this.steps});

  @override
  Widget build(BuildContext context) {
    final milestones = [
      {'label': 'First Steps', 'target': 100, 'icon': '👶'},
      {'label': 'Warm Up', 'target': 1000, 'icon': '🚶'},
      {'label': 'Half Way', 'target': 5000, 'icon': '🏃'},
      {'label': 'Goal Reached', 'target': 10000, 'icon': '🏆'},
      {'label': 'Overachiever', 'target': 15000, 'icon': '⭐'},
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Milestones',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ...milestones.map((m) {
            final target = m['target'] as int;
            final reached = steps >= target;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Text(
                    m['icon'] as String,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${m['label']} (${target.toString()} steps)',
                      style: TextStyle(
                        fontSize: 13,
                        color: reached
                            ? AppColors.textDark
                            : AppColors.textGrey,
                        fontWeight: reached
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  Icon(
                    reached
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked,
                    color: reached ? AppColors.sageGreen : AppColors.border,
                    size: 20,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
