import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'app_colors.dart';

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
        const SnackBar(
          content: Text('Please enter valid weight and height!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
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
    if (_bmi == null) return AppColors.sageGreen;
    if (_bmi! < 18.5) return Colors.blue;
    if (_bmi! < 25.0) return AppColors.sageGreen;
    if (_bmi! < 30.0) return const Color(0xFFE8956D);
    return Colors.red;
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'BMI Calculator',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info Card ──────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.softGreen,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.sageGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.sageGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'BMI measures body fat based on height and weight. Enter your details below.',
                      style: TextStyle(
                        color: AppColors.sageGreen,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Input Fields ────────────────────────
            const Text(
              'Your Details',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _InputField(
              label: 'Weight',
              unit: 'kg',
              controller: _weightController,
              icon: Icons.monitor_weight_outlined,
              hint: 'e.g. 65',
            ),
            const SizedBox(height: 14),
            _InputField(
              label: 'Height',
              unit: 'cm',
              controller: _heightController,
              icon: Icons.height,
              hint: 'e.g. 165',
            ),
            const SizedBox(height: 28),

            // ── Calculate Button ────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sageGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Calculate BMI',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Result ──────────────────────────────
            if (_calculated && _bmi != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_categoryColor, _categoryColor.withValues(alpha: 0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your BMI',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _bmi!.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _advice,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── BMI Scale ──────────────────────────
              const Text(
                'BMI Scale',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              _BMIScaleCard(
                label: 'Underweight',
                range: '< 18.5',
                color: Colors.blue,
                isActive: _bmi! < 18.5,
              ),
              const SizedBox(height: 8),
              _BMIScaleCard(
                label: 'Normal',
                range: '18.5 - 24.9',
                color: AppColors.sageGreen,
                isActive: _bmi! >= 18.5 && _bmi! < 25,
              ),
              const SizedBox(height: 8),
              _BMIScaleCard(
                label: 'Overweight',
                range: '25.0 - 29.9',
                color: const Color(0xFFE8956D),
                isActive: _bmi! >= 25 && _bmi! < 30,
              ),
              const SizedBox(height: 8),
              _BMIScaleCard(
                label: 'Obese',
                range: '≥ 30.0',
                color: Colors.red,
                isActive: _bmi! >= 30,
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: AppColors.textDark, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textGrey),
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textGrey),
          prefixIcon: Icon(icon, color: AppColors.sageGreen, size: 22),
          suffixText: unit,
          suffixStyle: const TextStyle(
            color: AppColors.sageGreen,
            fontWeight: FontWeight.bold,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.12) : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? color : AppColors.border,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.textDark : AppColors.textGrey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            range,
            style: TextStyle(
              color: isActive ? color : AppColors.textGrey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
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
