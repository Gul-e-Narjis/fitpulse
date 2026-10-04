import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import '../theme/fp_theme.dart';
import '../theme/fp_widgets.dart';
import '../services/gamification.dart';
import 'bmi_screen.dart';
import 'gamification_widgets.dart';

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

  // DiceBear seeds offered in the picker (first one is the user's own name)
  static const _avatarSeeds = [
    'Felix',
    'Aneka',
    'Zoe',
    'Milo',
    'Luna',
    'Leo',
    'Nova',
    'Kai',
    'Maya',
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile saved! ✓')));
  }

  Future<void> _signOut() async {
    final appState = context.read<AppState>();
    final nav = Navigator.of(context);
    await AuthService.signOut();
    appState.signOut();
    nav.pushNamedAndRemoveUntil('/landing', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final firstName = appState.userName.split(' ')[0];
    final seeds = [appState.userName, ..._avatarSeeds];

    final sections = <Widget>[
      // ── Top bar ─────────────────────────────────
      Row(
        children: [
          Expanded(child: Text('My profile', style: FpText.h1())),
          GlowButton(
            label: _isEditing ? 'Save' : 'Edit',
            icon: _isEditing ? Icons.check_rounded : Icons.edit_rounded,
            expand: false,
            height: 40,
            gradient: _isEditing
                ? FpColors.accentGradient
                : LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.12),
                      Colors.white.withValues(alpha: 0.06),
                    ],
                  ),
            textColor: _isEditing ? FpColors.bgDeep : FpColors.text,
            onTap: () {
              if (_isEditing) {
                _save();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      const SizedBox(height: 18),

      // ── Identity card ───────────────────────────
      GlassCard(
        glow: FpColors.teal,
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
        child: Column(
          children: [
            FpAvatar(
              seed: appState.avatarSeed,
              size: 96,
              fallbackInitial: firstName.isEmpty ? '' : firstName[0],
            ),
            const SizedBox(height: 14),
            Text(
              appState.userName,
              style: FpText.h2(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(appState.userEmail, style: FpText.muted()),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: FpColors.lime.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                appState.fitnessGoal,
                style: FpText.label(color: FpColors.lime, size: 12),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _HeaderStat(
                  value: appState.totalWorkoutsCompleted,
                  label: 'Workouts',
                  color: FpColors.tealLight,
                ),
                _vDivider(),
                _HeaderStat(
                  value: appState.totalMinutesWorkedOut,
                  label: 'Minutes',
                  color: FpColors.sky,
                ),
                _vDivider(),
                _HeaderStat(
                  value: appState.totalCaloriesBurned.round(),
                  label: 'Calories',
                  color: FpColors.coral,
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),

      // ── Level + badges ──────────────────────────
      const LevelCard(),
      const SizedBox(height: 24),
      SectionTitle(
        'Badges',
        action: '${appState.earnedBadgeIds.length}/${Badges.all.length}',
      ),
      const SizedBox(height: 12),
      const BadgesGrid(),
      const SizedBox(height: 24),

      // ── Avatar picker ───────────────────────────
      const SectionTitle('Choose your avatar'),
      const SizedBox(height: 12),
      GlassCard(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            for (var i = 0; i < seeds.length; i++)
              _AvatarOption(
                    seed: seeds[i],
                    selected: seeds[i] == appState.avatarSeed,
                    onTap: () => appState.setAvatarSeed(seeds[i]),
                  )
                  .animate()
                  .fadeIn(delay: (40 * i).ms)
                  .scaleXY(begin: 0.7, curve: Curves.easeOutBack),
          ],
        ),
      ),
      const SizedBox(height: 24),

      // ── BMI card ────────────────────────────────
      GlassCard(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BMIScreen()),
        ),
        child: Row(
          children: [
            AnimatedRing(
              progress: ((appState.bmi - 15) / 25).clamp(0, 1),
              size: 72,
              stroke: 7,
              colors: [appState.bmiColor, FpColors.tealLight],
              child: Text(
                appState.bmi.toStringAsFixed(1),
                style: FpText.number(size: 16),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('YOUR BMI', style: FpText.label()),
                  const SizedBox(height: 2),
                  Text(appState.bmiCategory, style: FpText.h2()),
                  Text(
                    '${appState.userWeight.toStringAsFixed(0)} kg • ${appState.userHeight.toStringAsFixed(0)} cm',
                    style: FpText.muted(size: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: FpColors.faint),
          ],
        ),
      ),
      const SizedBox(height: 24),

      // ── Personal info ───────────────────────────
      const SectionTitle('Personal info'),
      const SizedBox(height: 12),
      _ProfileField(
        label: 'Full name',
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
      const SizedBox(height: 12),

      // ── Fitness goal ────────────────────────────
      const SectionTitle('Fitness goal'),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _goals.map((g) {
          final selected = g == _selectedGoal;
          return Bounce(
            onTap: _isEditing ? () => setState(() => _selectedGoal = g) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: selected ? FpColors.accentGradient : null,
                color: selected ? null : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected ? Colors.transparent : FpColors.border,
                ),
              ),
              child: Text(
                g,
                style: FpText.label(
                  color: selected ? FpColors.bgDeep : FpColors.muted,
                  size: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 28),

      GlowButton(
        label: 'Rebuild my weekly plan',
        icon: Icons.auto_awesome_rounded,
        gradient: LinearGradient(
          colors: [
            FpColors.teal.withValues(alpha: 0.25),
            FpColors.lime.withValues(alpha: 0.10),
          ],
        ),
        textColor: FpColors.text,
        onTap: () => Navigator.pushNamed(context, '/onboarding'),
      ),
      const SizedBox(height: 12),
      // ── Sign out ────────────────────────────────
      GlowButton(
        label: 'Sign out',
        icon: Icons.logout_rounded,
        gradient: LinearGradient(
          colors: [
            FpColors.coral.withValues(alpha: 0.22),
            FpColors.coral.withValues(alpha: 0.12),
          ],
        ),
        textColor: FpColors.coral,
        onTap: _signOut,
      ),
    ];

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
        children: [
          for (var i = 0; i < sections.length; i++)
            sections[i]
                .animate()
                .fadeIn(delay: (30 * (i ~/ 2)).ms, duration: 400.ms)
                .slideY(begin: 0.06),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
    width: 1,
    height: 36,
    color: FpColors.border,
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );
}

// ── Avatar option ─────────────────────────────────────────────────────────────
class _AvatarOption extends StatelessWidget {
  final String seed;
  final bool selected;
  final VoidCallback onTap;

  const _AvatarOption({
    required this.seed,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Bounce(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: selected
              ? const SweepGradient(
                  colors: [FpColors.teal, FpColors.lime, FpColors.teal],
                )
              : null,
          color: selected ? null : Colors.white.withValues(alpha: 0.06),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: FpColors.lime.withValues(alpha: 0.4),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: LayoutBuilder(
          builder: (context, c) =>
              FpAvatar(seed: seed, size: c.maxWidth, ring: false),
        ),
      ),
    );
  }
}

// ── Header Stat ───────────────────────────────────────────────────────────────
class _HeaderStat extends StatelessWidget {
  final num value;
  final String label;
  final Color color;
  const _HeaderStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: CountUp(
            value: value,
            style: FpText.number(size: 20, color: color),
          ),
        ),
        Text(label, style: FpText.label(size: 10)),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        enabled: editing,
        keyboardType: keyboard,
        style: FpText.body(size: 15),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: FpColors.tealLight, size: 20),
          fillColor: editing
              ? FpColors.surfaceHigh
              : Colors.white.withValues(alpha: 0.04),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: FpColors.border),
          ),
        ),
      ),
    );
  }
}
