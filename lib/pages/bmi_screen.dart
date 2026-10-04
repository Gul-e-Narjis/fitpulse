import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/fp_theme.dart';
import '../theme/fp_widgets.dart';

class BMIScreen extends StatefulWidget {
  const BMIScreen({super.key});

  @override
  State<BMIScreen> createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  double? _bmi;
  bool _calculated = false;

  static const _underColor = FpColors.sky;
  static const _normalColor = FpColors.lime;
  static const _overColor = FpColors.amber;
  static const _obeseColor = FpColors.coral;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    _weightController.text = appState.userWeight.toString();
    _heightController.text = appState.userHeight.toString();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _calculate() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (weight == null || height == null || height == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid weight and height!')),
      );
      return;
    }

    final heightM = height / 100;
    setState(() {
      _bmi = weight / (heightM * heightM);
      _calculated = true;
    });

    context.read<AppState>().addBmiRecord(weight: weight, height: height);
  }

  String get _category {
    if (_bmi == null) return '';
    if (_bmi! < 18.5) return 'Underweight';
    if (_bmi! < 25.0) return 'Normal';
    if (_bmi! < 30.0) return 'Overweight';
    return 'Obese';
  }

  Color get _categoryColor {
    if (_bmi == null) return FpColors.teal;
    if (_bmi! < 18.5) return _underColor;
    if (_bmi! < 25.0) return _normalColor;
    if (_bmi! < 30.0) return _overColor;
    return _obeseColor;
  }

  String get _advice {
    if (_bmi == null) return '';
    if (_bmi! < 18.5) {
      return 'You are underweight. Consider eating more nutritious foods and consult a doctor.';
    }
    if (_bmi! < 25.0) {
      return 'Great! You have a healthy weight. Keep up your fitness routine!';
    }
    if (_bmi! < 30.0) {
      return 'You are slightly overweight. Regular exercise and a balanced diet can help.';
    }
    return 'Please consult a healthcare professional for personalized advice.';
  }

  @override
  Widget build(BuildContext context) {
    final bmi = _bmi;
    return Scaffold(
      backgroundColor: FpColors.bg,
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            children: [
              // ── Gauge ───────────────────────────────
              GlassCard(
                glow: _categoryColor,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
                child: Column(
                  children: [
                    _BmiGauge(value: bmi),
                    const SizedBox(height: 4),
                    if (bmi != null) ...[
                      CountUp(
                        value: bmi,
                        decimals: 1,
                        style: FpText.display(size: 44),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: 400.ms,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _categoryColor.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _categoryColor.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          _category,
                          style: FpText.h3(color: _categoryColor),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _advice,
                        textAlign: TextAlign.center,
                        style: FpText.muted(),
                      ),
                    ] else
                      Text(
                        'Enter your details and tap Calculate',
                        style: FpText.muted(),
                      ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06),
              const SizedBox(height: 24),

              // ── Inputs ──────────────────────────────
              const SectionTitle('Your details'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InputField(
                      label: 'Weight',
                      unit: 'kg',
                      controller: _weightController,
                      icon: Icons.monitor_weight_outlined,
                      hint: 'e.g. 65',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InputField(
                      label: 'Height',
                      unit: 'cm',
                      controller: _heightController,
                      icon: Icons.height,
                      hint: 'e.g. 165',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              GlowButton(
                label: 'Calculate BMI',
                icon: Icons.speed_rounded,
                onTap: _calculate,
              ),
              const SizedBox(height: 26),

              // ── Scale ───────────────────────────────
              const SectionTitle('BMI scale'),
              const SizedBox(height: 12),
              _BMIScaleCard(
                label: 'Underweight',
                range: '< 18.5',
                color: _underColor,
                isActive: _calculated && bmi! < 18.5,
              ),
              _BMIScaleCard(
                label: 'Normal',
                range: '18.5 – 24.9',
                color: _normalColor,
                isActive: _calculated && bmi! >= 18.5 && bmi < 25,
              ),
              _BMIScaleCard(
                label: 'Overweight',
                range: '25.0 – 29.9',
                color: _overColor,
                isActive: _calculated && bmi! >= 25 && bmi < 30,
              ),
              _BMIScaleCard(
                label: 'Obese',
                range: '≥ 30.0',
                color: _obeseColor,
                isActive: _calculated && bmi! >= 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Needle gauge (BMI 15 → 40) ────────────────────────────────────────────────
class _BmiGauge extends StatelessWidget {
  final double? value;
  const _BmiGauge({required this.value});

  static const minBmi = 15.0;
  static const maxBmi = 40.0;

  @override
  Widget build(BuildContext context) {
    final target =
        ((value ?? minBmi).clamp(minBmi, maxBmi) - minBmi) / (maxBmi - minBmi);
    return LayoutBuilder(
      builder: (context, c) {
        final width = math.min(c.maxWidth, 300.0);
        return SizedBox(
          width: width,
          height: width * 0.58,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: target),
            duration: const Duration(milliseconds: 1600),
            curve: Curves.elasticOut,
            builder: (context, t, _) =>
                CustomPaint(painter: _GaugePainter(t.clamp(-0.02, 1.02))),
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double t; // 0..1 along the arc
  _GaugePainter(this.t);

  static double _frac(double bmi) =>
      (bmi - _BmiGauge.minBmi) / (_BmiGauge.maxBmi - _BmiGauge.minBmi);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.92);
    final radius = size.width / 2 - 14;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const stroke = 16.0;

    final segments = [
      (0.0, _frac(18.5), FpColors.sky),
      (_frac(18.5), _frac(25), FpColors.lime),
      (_frac(25), _frac(30), FpColors.amber),
      (_frac(30), 1.0, FpColors.coral),
    ];
    for (final (from, to, color) in segments) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = color.withValues(alpha: 0.85);
      canvas.drawArc(
        rect,
        math.pi + math.pi * from + 0.012,
        math.pi * (to - from) - 0.024,
        false,
        paint,
      );
    }

    // Tick labels
    for (final bmi in [18.5, 25.0, 30.0]) {
      final a = math.pi + math.pi * _frac(bmi);
      final p = center + Offset(math.cos(a), math.sin(a)) * (radius - 28);
      final tp = TextPainter(
        text: TextSpan(
          text: bmi.toStringAsFixed(bmi % 1 == 0 ? 0 : 1),
          style: FpText.label(size: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }

    // Needle
    final angle = math.pi + math.pi * t;
    final tip =
        center + Offset(math.cos(angle), math.sin(angle)) * (radius - 4);
    final needle = Paint()
      ..color = FpColors.text
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      tip,
      Paint()
        ..color = FpColors.teal.withValues(alpha: 0.5)
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawLine(center, tip, needle);
    canvas.drawCircle(center, 10, Paint()..color = FpColors.text);
    canvas.drawCircle(center, 5, Paint()..color = FpColors.teal);
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.t != t;
}

class _InputField extends StatelessWidget {
  final String label;
  final String unit;
  final String hint;
  final TextEditingController controller;
  final IconData icon;

  const _InputField({
    required this.label,
    required this.unit,
    required this.hint,
    required this.controller,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: FpText.h3(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: FpColors.tealLight, size: 20),
        suffixText: unit,
        suffixStyle: FpText.label(color: FpColors.lime, size: 12),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
    );
  }
}

class _BMIScaleCard extends StatelessWidget {
  final String label;
  final String range;
  final Color color;
  final bool isActive;

  const _BMIScaleCard({
    required this.label,
    required this.range,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive
            ? color.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? color : FpColors.border,
          width: isActive ? 1.6 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: isActive
                  ? FpText.h3()
                  : FpText.body(color: FpColors.muted),
            ),
          ),
          Text(
            range,
            style: FpText.label(
              color: isActive ? color : FpColors.muted,
              size: 12,
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: 8),
            Icon(Icons.check_circle, color: color, size: 18),
          ],
        ],
      ),
    );
  }
}
