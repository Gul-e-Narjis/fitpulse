import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme/fp_theme.dart';
import '../theme/fp_widgets.dart';

const _waterBlue = Color(0xFF22D3EE);
const _waterDeep = Color(0xFF0EA5E9);

// ── Water screen ──────────────────────────────────────────────────────────────
class WaterScreen extends StatelessWidget {
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final glasses = app.todayGlasses;
    final goal = app.waterGoalGlasses;
    final ml = glasses * AppState.glassMl;
    final now = DateTime.now();
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

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
                  Text('Hydration', style: FpText.h1()),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: WaveBottle(
                  progress: goal == 0 ? 0 : glasses / goal,
                  width: 170,
                  height: 280,
                ),
              ).animate().fadeIn(duration: 500.ms).scaleXY(begin: 0.9),
              const SizedBox(height: 18),
              Center(
                child: CountUp(
                  value: ml / 1000,
                  decimals: 2,
                  suffix: ' L',
                  style: FpText.display(size: 40, color: _waterBlue),
                ),
              ),
              Center(
                child: Text(
                  '$glasses of $goal glasses • goal ${(app.waterGoalMl / 1000).toStringAsFixed(1)} L',
                  style: FpText.muted(),
                ),
              ),
              if (glasses >= goal && goal > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Center(
                    child:
                        Text(
                          '🎉 Daily goal reached!',
                          style: FpText.h3(color: FpColors.lime),
                        ).animate().scale(
                          curve: Curves.elasticOut,
                          duration: 800.ms,
                        ),
                  ),
                ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: GlowButton(
                      label: '−',
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.10),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                      textColor: FpColors.text,
                      onTap: glasses == 0 ? null : () => app.addWater(-1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: GlowButton(
                      label: 'Add a glass (250 ml)',
                      icon: Icons.water_drop_rounded,
                      gradient: const LinearGradient(
                        colors: [_waterDeep, _waterBlue],
                      ),
                      onTap: () => app.addWater(1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              const SectionTitle('Last 7 days'),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                child: SizedBox(
                  height: 140,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (i) {
                      final day = now.subtract(Duration(days: 6 - i));
                      final g = app.glassesOn(day);
                      final pct = goal == 0 ? 0.0 : (g / goal).clamp(0.0, 1.0);
                      final hit = g >= goal && goal > 0;
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('$g', style: FpText.label(size: 10)),
                            const SizedBox(height: 4),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: pct),
                              duration: Duration(milliseconds: 700 + 80 * i),
                              curve: Curves.easeOutCubic,
                              builder: (_, v, _) => Container(
                                width: 18,
                                height: 8 + 82 * v,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: hit
                                        ? const [FpColors.teal, FpColors.lime]
                                        : const [_waterDeep, _waterBlue],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dayLabels[day.weekday - 1],
                              style: FpText.label(
                                size: 11,
                                color: i == 6 ? FpColors.text : FpColors.muted,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Home card ─────────────────────────────────────────────────────────────────
class WaterCard extends StatelessWidget {
  const WaterCard({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final glasses = app.todayGlasses;
    final goal = app.waterGoalGlasses;
    return GlassCard(
      glow: _waterBlue,
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WaterScreen()),
      ),
      child: Row(
        children: [
          WaveBottle(
            progress: goal == 0 ? 0 : glasses / goal,
            width: 56,
            height: 92,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HYDRATION', style: FpText.label(color: _waterBlue)),
                const SizedBox(height: 4),
                Text('$glasses / $goal glasses', style: FpText.h2()),
                Text(
                  '${(glasses * AppState.glassMl / 1000).toStringAsFixed(2)} L of ${(app.waterGoalMl / 1000).toStringAsFixed(1)} L',
                  style: FpText.muted(size: 12),
                ),
              ],
            ),
          ),
          Bounce(
            onTap: () => app.addWater(1),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [_waterDeep, _waterBlue],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _waterBlue.withValues(alpha: 0.45),
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

// ── WaveBottle ────────────────────────────────────────────────────────────────
// Bottle outline with a moving sine-wave surface; the level animates whenever
// [progress] changes.
class WaveBottle extends StatefulWidget {
  final double progress; // 0..1
  final double width;
  final double height;

  const WaveBottle({
    super.key,
    required this.progress,
    required this.width,
    required this.height,
  });

  @override
  State<WaveBottle> createState() => _WaveBottleState();
}

class _WaveBottleState extends State<WaveBottle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: widget.progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutBack,
      builder: (context, level, _) => AnimatedBuilder(
        animation: _wave,
        builder: (context, _) => CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _BottlePainter(level: level, phase: _wave.value),
        ),
      ),
    );
  }
}

class _BottlePainter extends CustomPainter {
  final double level;
  final double phase;

  _BottlePainter({required this.level, required this.phase});

  Path _bottle(Size s) {
    final w = s.width;
    final h = s.height;
    final neckW = w * 0.38;
    final neckH = h * 0.12;
    final shoulder = h * 0.22;
    final r = w * 0.22;
    final left = (w - neckW) / 2;
    return Path()
      ..moveTo(left, 0)
      ..lineTo(left + neckW, 0)
      ..lineTo(left + neckW, neckH)
      ..quadraticBezierTo(w, neckH, w, shoulder)
      ..lineTo(w, h - r)
      ..quadraticBezierTo(w, h, w - r, h)
      ..lineTo(r, h)
      ..quadraticBezierTo(0, h, 0, h - r)
      ..lineTo(0, shoulder)
      ..quadraticBezierTo(0, neckH, left, neckH)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bottle = _bottle(size);

    // Glass body
    canvas.drawPath(
      bottle,
      Paint()..color = Colors.white.withValues(alpha: 0.06),
    );

    // Water, clipped to the bottle
    canvas.save();
    canvas.clipPath(bottle);
    final top = size.height * (1 - level.clamp(0.0, 1.05));
    final amp = level <= 0 || level >= 1 ? 2.0 : size.height * 0.025;
    for (var layer = 0; layer < 2; layer++) {
      final path = Path()..moveTo(0, size.height);
      final shift = phase * 2 * math.pi + layer * math.pi * 0.7;
      for (double x = 0; x <= size.width; x += 2) {
        final y =
            top +
            math.sin(x / size.width * 2 * math.pi + shift) *
                amp *
                (layer == 0 ? 1 : 0.7);
        path.lineTo(x, y);
      }
      path
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: layer == 0
                ? [_waterBlue.withValues(alpha: 0.85), _waterDeep]
                : [
                    _waterBlue.withValues(alpha: 0.35),
                    _waterDeep.withValues(alpha: 0.5),
                  ],
          ).createShader(Offset.zero & size),
      );
    }
    // Highlight streak
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.14,
          size.height * 0.3,
          size.width * 0.08,
          size.height * 0.5,
        ),
        const Radius.circular(8),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );
    canvas.restore();

    // Outline
    canvas.drawPath(
      bottle,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _waterBlue.withValues(alpha: 0.6),
    );
  }

  @override
  bool shouldRepaint(_BottlePainter old) =>
      old.level != level || old.phase != phase;
}
