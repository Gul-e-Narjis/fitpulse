import 'package:flutter/material.dart';
import '../services/exercise_data.dart';
import 'exercise_detail.dart';
import 'app_colors.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  List<Exercise> _results = [];
  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';

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

  @override
  void initState() {
    super.initState();
    _results = ExerciseDataService.allExercises;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    setState(() {
      _results = ExerciseDataService.allExercises.where((e) {
        final matchesQuery = query.isEmpty ||
            e.name.toLowerCase().contains(query.toLowerCase()) ||
            e.description.toLowerCase().contains(query.toLowerCase()) ||
            e.musclesTargeted.toLowerCase().contains(query.toLowerCase());
        final matchesCategory =
            _selectedCategory == 'All' || e.category == _selectedCategory;
        final matchesDifficulty =
            _selectedDifficulty == 'All' || e.difficulty == _selectedDifficulty;
        return matchesQuery && matchesCategory && matchesDifficulty;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              'Search Exercises',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Search Bar ──────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _search,
                style: const TextStyle(color: AppColors.textDark, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search by name, muscle...',
                  hintStyle: const TextStyle(color: AppColors.textGrey),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textGrey,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.textGrey,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _search('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Category Filter ──────────────────────
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                final color = cat == 'All'
                    ? AppColors.sageGreen
                    : ExerciseDataService.getCategoryColor(cat);

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategory = cat);
                    _search(_searchController.text);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? color : AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? color : AppColors.border,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // ── Difficulty Filter ────────────────────
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _difficulties.length,
              itemBuilder: (context, index) {
                final diff = _difficulties[index];
                final isSelected = _selectedDifficulty == diff;
                final color = diff == 'All'
                    ? AppColors.textGrey
                    : diff == 'Beginner'
                        ? AppColors.sageGreen
                        : diff == 'Intermediate'
                            ? const Color(0xFFE8956D)
                            : Colors.red;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDifficulty = diff);
                    _search(_searchController.text);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? color : AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? color : AppColors.border,
                      ),
                    ),
                    child: Text(
                      diff,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // ── Results Count ────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '${_results.length} exercises found',
              style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
            ),
          ),
          const SizedBox(height: 10),

          // ── Results List ─────────────────────────
          Expanded(
            child: _results.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          color: AppColors.textGrey,
                          size: 48,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No exercises found',
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final exercise = _results[index];
                      final color = ExerciseDataService.getCategoryColor(
                        exercise.category,
                      );

                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ExerciseDetailPage(exercise: exercise),
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  exercise.icon,
                                  color: color,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercise.name,
                                      style: const TextStyle(
                                        color: AppColors.textDark,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            exercise.category,
                                            style: TextStyle(
                                              color: color,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          exercise.duration,
                                          style: const TextStyle(
                                            color: AppColors.textGrey,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _diffColor(
                                    exercise.difficulty,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  exercise.difficulty,
                                  style: TextStyle(
                                    color: _diffColor(exercise.difficulty),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _diffColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return AppColors.sageGreen;
      case 'Intermediate':
        return const Color(0xFFE8956D);
      case 'Advanced':
        return Colors.red;
      default:
        return AppColors.lightPurple;
    }
  }
}
