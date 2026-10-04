import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../services/exercise_data.dart';
import 'workout_detail.dart';

class CustomWorkoutScreen extends StatefulWidget {
  const CustomWorkoutScreen({super.key});
  @override
  State<CustomWorkoutScreen> createState() => _CustomWorkoutScreenState();
}

class _CustomWorkoutScreenState extends State<CustomWorkoutScreen> {
  final _nameCtrl = TextEditingController(text: 'My Custom Workout');
  final List<Exercise> _selected = [];
  String _filterCategory = 'All';
  String _filterDifficulty = 'All';

  final List<String> _categories = [
    'All',
    'Cardio',
    'Arm',
    'Leg',
    'Core',
    'Full Body',
  ];
  final List<String> _difficulties = [
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  List<Exercise> get _filtered {
    return ExerciseDataService.allExercises.where((e) {
      final catOk = _filterCategory == 'All' || e.category == _filterCategory;
      final diffOk =
          _filterDifficulty == 'All' || e.difficulty == _filterDifficulty;
      return catOk && diffOk;
    }).toList();
  }

  int get _totalDuration {
    return _selected.fold(0, (sum, e) {
      final match = RegExp(r'(\d+)').firstMatch(e.duration);
      return sum + (match != null ? int.parse(match.group(0)!) : 30);
    });
  }

  double get _totalCalories => _selected.length * 12.0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Custom Workout'),
        backgroundColor: AppColors.background,
        actions: [
          if (_selected.isNotEmpty)
            TextButton.icon(
              onPressed: _startWorkout,
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
              label: const Text(
                'Start',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.sageGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Selected summary bar ─────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _selected.isEmpty ? 0 : null,
            child: _selected.isEmpty
                ? const SizedBox()
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.sageGreen,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Workout name
                        TextField(
                          controller: _nameCtrl,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Workout name...',
                            hintStyle: TextStyle(color: Colors.white60),
                            border: InputBorder.none,
                            isDense: true,
                            prefixIcon: Icon(
                              Icons.edit_rounded,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _SummaryChip(
                              icon: Icons.fitness_center_rounded,
                              label: '${_selected.length} exercises',
                            ),
                            const SizedBox(width: 10),
                            _SummaryChip(
                              icon: Icons.timer_rounded,
                              label: '~$_totalDuration sec',
                            ),
                            const SizedBox(width: 10),
                            _SummaryChip(
                              icon: Icons.local_fire_department_rounded,
                              label:
                                  '~${_totalCalories.toStringAsFixed(0)} cal',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Filters ─────────────────────────────
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (_, i) {
                        final cat = _categories[i];
                        final sel = cat == _filterCategory;
                        return GestureDetector(
                          onTap: () => setState(() => _filterCategory = cat),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: sel ? AppColors.sageGreen : AppColors.card,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: sel
                                    ? AppColors.sageGreen
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: sel ? Colors.white : AppColors.textGrey,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Difficulty',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    runSpacing: 8,
                    children: _difficulties.map((d) {
                      final sel = d == _filterDifficulty;
                      Color dColor = d == 'Beginner'
                          ? Colors.green
                          : d == 'Intermediate'
                          ? Colors.orange
                          : d == 'Advanced'
                          ? Colors.red
                          : AppColors.textGrey;
                      return GestureDetector(
                        onTap: () => setState(() => _filterDifficulty = d),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: sel
                                ? dColor.withValues(alpha: 0.15)
                                : AppColors.card,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: sel ? dColor : AppColors.border,
                              width: sel ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            d,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: sel ? dColor : AppColors.textGrey,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    '${_filtered.length} Exercises',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Exercise List ─────────────────────
                  ..._filtered.map((ex) {
                    final isSelected = _selected.contains(ex);
                    final color = ExerciseDataService.getCategoryColor(
                      ex.category,
                    );
                    final diffColor = ex.difficulty == 'Beginner'
                        ? Colors.green
                        : ex.difficulty == 'Intermediate'
                        ? Colors.orange
                        : Colors.red;

                    return GestureDetector(
                      onTap: () => setState(() {
                        if (isSelected) {
                          _selected.remove(ex);
                        } else {
                          _selected.add(ex);
                        }
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.sageGreen.withValues(alpha: 0.08)
                              : AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.sageGreen
                                : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(ex.icon, color: color, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ex.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    runSpacing: 4,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: diffColor.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          ex.difficulty,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: diffColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        ex.duration,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textGrey,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '• ${ex.reps}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.sageGreen
                                    : AppColors.background,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.sageGreen
                                      : AppColors.border,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _selected.isEmpty
          ? null
          : Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                12 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border(top: BorderSide(color: AppColors.border)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _startWorkout,
                icon: const Icon(Icons.play_arrow_rounded, size: 22),
                label: Text(
                  'Start ${_selected.length} Exercise${_selected.length == 1 ? '' : 's'}  →',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sageGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
    );
  }

  void _startWorkout() {
    if (_selected.isEmpty) return;
    final color = ExerciseDataService.getCategoryColor(
      _selected.first.category,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutSessionPage(
          category: _nameCtrl.text,
          exercises: _selected,
          color: color,
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SummaryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: Colors.white70, size: 14),
      const SizedBox(width: 4),
      Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
