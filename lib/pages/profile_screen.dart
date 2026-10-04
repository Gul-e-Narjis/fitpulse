import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_colors.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import 'bmi_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String _selectedGoal = 'Stay Fit';
  bool _isEditing = false;

  final List<String> _goals = [
    'Stay Fit',
    'Lose Weight',
    'Build Muscle',
    'Improve Endurance',
    'Increase Flexibility',
  ];

  @override
  void initState() {
    super.initState();
    final a = context.read<AppState>();
    _nameCtrl.text = a.userName;
    _emailCtrl.text = a.userEmail;
    _weightCtrl.text = a.userWeight.toString();
    _heightCtrl.text = a.userHeight.toString();
    _ageCtrl.text = a.userAge.toString();
    _selectedGoal = a.fitnessGoal;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final a = context.read<AppState>();
    a.updateProfile(
      name: _nameCtrl.text,
      weight: double.tryParse(_weightCtrl.text) ?? a.userWeight,
      height: double.tryParse(_heightCtrl.text) ?? a.userHeight,
      age: int.tryParse(_ageCtrl.text) ?? a.userAge,
      goal: _selectedGoal,
    );
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile saved! ✓'),
        backgroundColor: AppColors.sageGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // ── TEAL HEADER ───────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E9FA3), Color(0xFF0A6B6F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_isEditing) {
                            _save();
                          } else {
                            setState(() => _isEditing = true);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isEditing
                                    ? Icons.check_rounded
                                    : Icons.edit_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isEditing ? 'Save' : 'Edit',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Center(
                          child: appState.userName == 'Fitness User' ||
                                  appState.userName.isEmpty
                              ? const Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 46,
                                )
                              : Text(
                                  appState.userName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      // Fitness badge overlay
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A5F62),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: AppColors.sageGreen,
                              size: 13,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    appState.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
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

                  const SizedBox(height: 20),

                  // ── 3 stats in header ─────────────────
                  Row(
                    children: [
                      _HeaderStat(
                        value: '${appState.totalWorkoutsCompleted}',
                        label: 'Workouts',
                        icon: Icons.fitness_center_rounded,
                        iconColor: const Color(0xFFFFE082),
                      ),
                      _vDivider(),
                      _HeaderStat(
                        value: '${appState.totalMinutesWorkedOut}',
                        label: 'Minutes',
                        icon: Icons.timer_rounded,
                        iconColor: const Color(0xFFB2EBF2),
                      ),
                      _vDivider(),
                      _HeaderStat(
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

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── BMI CARD ──────────────────────────
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BMIScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E9FA3), Color(0xFF0A5F62)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.sageGreen.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your BMI',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                appState.bmi.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  appState.bmiCategory,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Icon(
                                Icons.monitor_weight_outlined,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${appState.userWeight.toStringAsFixed(0)} kg',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${appState.userHeight.toStringAsFixed(0)} cm',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Tap to calculate →',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── PERSONAL INFO ─────────────────────
                  const Text(
                    'Personal Info',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 14),

                  _ProfileField(
                    label: 'Full Name',
                    icon: Icons.person_outline_rounded,
                    controller: _nameCtrl,
                    editing: _isEditing,
                  ),
                  _ProfileField(
                    label: 'Email',
                    icon: Icons.email_outlined,
                    controller: _emailCtrl,
                    editing: false, // login email is owned by Firebase Auth
                    keyboard: TextInputType.emailAddress,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _ProfileField(
                          label: 'Weight (kg)',
                          icon: Icons.monitor_weight_outlined,
                          controller: _weightCtrl,
                          editing: _isEditing,
                          keyboard: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ProfileField(
                          label: 'Height (cm)',
                          icon: Icons.height_rounded,
                          controller: _heightCtrl,
                          editing: _isEditing,
                          keyboard: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  _ProfileField(
                    label: 'Age',
                    icon: Icons.cake_outlined,
                    controller: _ageCtrl,
                    editing: _isEditing,
                    keyboard: TextInputType.number,
                  ),

                  const SizedBox(height: 20),

                  // ── FITNESS GOAL ──────────────────────
                  const Text(
                    'Fitness Goal',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _goals.map((g) {
                      final selected = g == _selectedGoal;
                      return GestureDetector(
                        onTap: _isEditing
                            ? () => setState(() => _selectedGoal = g)
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color:
                                selected ? AppColors.sageGreen : AppColors.card,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: selected
                                  ? AppColors.sageGreen
                                  : AppColors.border,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            g,
                            style: TextStyle(
                              color:
                                  selected ? Colors.white : AppColors.textGrey,
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),

                  // ── LOGOUT ────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final appState = context.read<AppState>();
                        final nav = Navigator.of(context);
                        await AuthService.signOut();
                        appState.signOut();
                        nav.pushNamedAndRemoveUntil('/landing', (r) => false);
                      },
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.redAccent,
                      ),
                      label: const Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 40,
        color: Colors.white.withValues(alpha: 0.25),
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );
}

// ── Header Stat ───────────────────────────────────────────────────────────────
class _HeaderStat extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color iconColor;
  const _HeaderStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style:
                  TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11),
            ),
          ],
        ),
      );
}

// ── Profile Field ─────────────────────────────────────────────────────────────
class _ProfileField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool editing;
  final TextInputType keyboard;

  const _ProfileField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.editing,
    this.keyboard = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              editing ? AppColors.sageGreen.withValues(alpha: 0.5) : AppColors.border,
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: editing,
        keyboardType: keyboard,
        style: const TextStyle(color: AppColors.textDark, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textGrey, fontSize: 13),
          prefixIcon: Icon(icon, color: AppColors.sageGreen, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
