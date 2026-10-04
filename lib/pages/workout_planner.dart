import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/exercise_data.dart';
import 'app_colors.dart';

class WorkoutPlannerScreen extends StatefulWidget {
  const WorkoutPlannerScreen({super.key});

  @override
  State<WorkoutPlannerScreen> createState() => _WorkoutPlannerScreenState();
}

class _WorkoutPlannerScreenState extends State<WorkoutPlannerScreen> {
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  String _selectedDay = 'Monday';

  @override
  void initState() {
    super.initState();
    // Set current day as default
    final weekday = DateTime.now().weekday; // 1=Mon ... 7=Sun
    _selectedDay = _days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final dayPlans = appState.getWorkoutsForDay(_selectedDay);
    final favourites = appState.favouritePlans;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Workout Planner'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.sageGreen,
            tooltip: 'Add workout',
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Day Selector ──────────────────────────
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _days.length,
                itemBuilder: (context, i) {
                  final day = _days[i];
                  final isSelected = day == _selectedDay;
                  final hasWorkout = appState.getWorkoutsForDay(day).isNotEmpty;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.sageGreen : AppColors.card,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.sageGreen
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            day.substring(0, 3),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          if (hasWorkout) ...[
                            const SizedBox(width: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white70
                                    : AppColors.sageGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // ── Day's workouts ────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDay,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '${dayPlans.length} workout${dayPlans.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            dayPlans.isEmpty
                ? _EmptyDay(onAdd: () => _showAddDialog(context))
                : Column(
                    children: dayPlans.map((plan) {
                      return _PlanCard(
                        plan: plan,
                        onFavourite: () => appState.toggleFavourite(plan.id),
                        onDelete: () => appState.removePlannedWorkout(plan.id),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 28),

            // ── Favourites ────────────────────────────
            if (favourites.isNotEmpty) ...[
              const Text(
                '⭐ Favourites',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: favourites.map((plan) {
                  return _PlanCard(
                    plan: plan,
                    onFavourite: () => appState.toggleFavourite(plan.id),
                    onDelete: () => appState.removePlannedWorkout(plan.id),
                    showDay: true,
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
            ],

            // ── Week overview ─────────────────────────
            const Text(
              'Week Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _WeekOverview(days: _days, appState: appState),
          ],
        ),
      ),

      // ── FAB ───────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.sageGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Workout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ── Add Dialog ─────────────────────────────────────────────────────────────
  void _showAddDialog(BuildContext context) {
    String selectedCategory = ExerciseDataService.categories.first;
    String selectedDay = _selectedDay;
    TimeOfDay selectedTime = const TimeOfDay(hour: 7, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            24 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add Workout to Plan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 20),

              // Category picker
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ExerciseDataService.categories.map((cat) {
                  final isSelected = cat == selectedCategory;
                  final color = ExerciseDataService.getCategoryColor(cat);
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.15)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? color : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? color : AppColors.textGrey,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Day picker
              const Text(
                'Day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedDay,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                items: [
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday',
                  'Sunday',
                ]
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setModalState(() => selectedDay = v!),
              ),

              const SizedBox(height: 20),

              // Time picker
              const Text(
                'Time',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final t = await showTimePicker(
                    context: ctx,
                    initialTime: selectedTime,
                  );
                  if (t != null) {
                    setModalState(() => selectedTime = t);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: AppColors.sageGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        selectedTime.format(ctx),
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Add button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final plan = PlannedWorkout(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      category: selectedCategory,
                      day: selectedDay,
                      time: selectedTime.format(ctx),
                    );
                    context.read<AppState>().addPlannedWorkout(plan);
                    setState(() => _selectedDay = selectedDay);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$selectedCategory added to $selectedDay!',
                        ),
                        backgroundColor: AppColors.sageGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sageGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Add to Plan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

// ── Plan Card ─────────────────────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  final PlannedWorkout plan;
  final VoidCallback onFavourite;
  final VoidCallback onDelete;
  final bool showDay;

  const _PlanCard({
    required this.plan,
    required this.onFavourite,
    required this.onDelete,
    this.showDay = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = ExerciseDataService.getCategoryColor(plan.category);
    final icon = ExerciseDataService.getCategoryIcon(plan.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.category,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  showDay ? '${plan.day}  •  ${plan.time}' : plan.time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              plan.isFavourite ? Icons.star_rounded : Icons.star_border_rounded,
              color: plan.isFavourite
                  ? const Color(0xFFFFB800)
                  : AppColors.textGrey,
            ),
            onPressed: onFavourite,
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
              size: 20,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ── Empty Day ─────────────────────────────────────────────────────────────────
class _EmptyDay extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyDay({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_available_rounded,
            size: 48,
            color: AppColors.border,
          ),
          const SizedBox(height: 12),
          const Text(
            'No workouts planned',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add a workout to this day',
            style: TextStyle(fontSize: 13, color: AppColors.textGrey),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, color: AppColors.sageGreen),
            label: const Text(
              'Add Workout',
              style: TextStyle(color: AppColors.sageGreen),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Week Overview ─────────────────────────────────────────────────────────────
class _WeekOverview extends StatelessWidget {
  final List<String> days;
  final AppState appState;

  const _WeekOverview({required this.days, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: days.map((day) {
          final plans = appState.getWorkoutsForDay(day);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    day.substring(0, 3),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Expanded(
                  child: plans.isEmpty
                      ? const Text(
                          'Rest day',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        )
                      : Wrap(
                          spacing: 6,
                          children: plans.map((p) {
                            final color = ExerciseDataService.getCategoryColor(
                              p.category,
                            );
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                p.category,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
