import 'package:flutter/material.dart';

class Exercise {
  final String name;
  final String category;
  final String duration;
  final String reps;
  final String description;
  final String instructions;
  final String benefits;
  final String difficulty;
  final String musclesTargeted;
  final String equipment;
  final IconData icon;

  const Exercise({
    required this.name,
    required this.category,
    required this.duration,
    required this.reps,
    required this.description,
    required this.instructions,
    required this.benefits,
    required this.difficulty,
    required this.musclesTargeted,
    required this.equipment,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'duration': duration,
      'reps': reps,
      'description': description,
      'instructions': instructions,
      'benefits': benefits,
      'difficulty': difficulty,
      'musclesTargeted': musclesTargeted,
      'equipment': equipment,
      'icon': icon,
    };
  }
}

class ExerciseDataService {
  static final List<Exercise> allExercises = [
    // ── CARDIO ──────────────────────────────────────────
    Exercise(
      name: 'Jumping Jacks',
      category: 'Cardio',
      duration: '30 seconds',
      reps: '30 reps',
      description:
          'A full-body cardiovascular exercise that improves heart health and coordination.',
      instructions:
          '1. Stand with feet together and arms at sides\n2. Jump while spreading legs shoulder-width\n3. Simultaneously raise arms overhead\n4. Jump back to starting position\n5. Repeat at a steady pace',
      benefits:
          '• Improves cardiovascular endurance\n• Burns calories quickly\n• Enhances coordination\n• No equipment needed',
      difficulty: 'Beginner',
      musclesTargeted: 'Full Body, Calves, Shoulders',
      equipment: 'None required',
      icon: Icons.directions_run,
    ),
    Exercise(
      name: 'High Knees',
      category: 'Cardio',
      duration: '45 seconds',
      reps: '40 reps',
      description: 'Running in place while bringing knees up to hip level.',
      instructions:
          '1. Stand tall with feet hip-width apart\n2. Run in place lifting knees to waist level\n3. Pump arms for balance and speed\n4. Land softly on balls of feet\n5. Keep core tight throughout',
      benefits:
          '• Strengthens core muscles\n• Improves running form\n• Boosts heart rate fast\n• Burns belly fat',
      difficulty: 'Beginner',
      musclesTargeted: 'Hip Flexors, Quads, Core, Calves',
      equipment: 'None required',
      icon: Icons.directions_run,
    ),
    Exercise(
      name: 'Burpees',
      category: 'Cardio',
      duration: '60 seconds',
      reps: '10 reps',
      description: 'A full-body exercise combining squat, plank, and jump.',
      instructions:
          '1. Start standing, feet shoulder-width apart\n2. Drop into a squat and place hands on floor\n3. Kick feet back into plank position\n4. Do one push-up (optional)\n5. Jump feet back to squat, then jump up with arms overhead',
      benefits:
          '• Full-body workout in one move\n• Maximum calorie burn\n• Builds strength and endurance\n• Improves explosiveness',
      difficulty: 'Intermediate',
      musclesTargeted: 'Full Body, Chest, Core, Legs',
      equipment: 'None required',
      icon: Icons.fitness_center,
    ),
    Exercise(
      name: 'Mountain Climbers',
      category: 'Cardio',
      duration: '40 seconds',
      reps: '20 reps per side',
      description: 'Dynamic core exercise that also provides cardio benefits.',
      instructions:
          '1. Start in a high plank position\n2. Keep wrists under shoulders\n3. Drive one knee toward chest\n4. Quickly switch legs in running motion\n5. Keep hips level, do not bounce',
      benefits:
          '• Strengthens core deeply\n• Improves cardiovascular fitness\n• Enhances coordination\n• Burns calories efficiently',
      difficulty: 'Intermediate',
      musclesTargeted: 'Core, Shoulders, Hip Flexors, Quads',
      equipment: 'None required',
      icon: Icons.self_improvement,
    ),

    // ── ARM ─────────────────────────────────────────────
    Exercise(
      name: 'Push Ups',
      category: 'Arm',
      duration: '30 seconds',
      reps: '15 reps',
      description:
          'Classic bodyweight exercise for chest, shoulders, and triceps.',
      instructions:
          '1. Start in plank with hands under shoulders\n2. Keep body straight from head to heels\n3. Lower chest until it nearly touches floor\n4. Push back up to starting position\n5. Keep core engaged throughout',
      benefits:
          '• Builds upper body strength\n• Improves core stability\n• No equipment needed\n• Enhances pushing power',
      difficulty: 'Beginner',
      musclesTargeted: 'Chest, Shoulders, Triceps, Core',
      equipment: 'None required',
      icon: Icons.fitness_center,
    ),
    Exercise(
      name: 'Tricep Dips',
      category: 'Arm',
      duration: '45 seconds',
      reps: '12 reps',
      description: 'Targets triceps using body weight and a bench or chair.',
      instructions:
          '1. Sit on edge of a sturdy chair or bench\n2. Place hands beside hips, fingers forward\n3. Slide off the edge, supporting your weight\n4. Lower body by bending elbows to 90 degrees\n5. Push back up to start',
      benefits:
          '• Strengthens triceps effectively\n• Improves arm definition\n• Can be done with a chair\n• Builds elbow stability',
      difficulty: 'Beginner',
      musclesTargeted: 'Triceps, Chest, Shoulders',
      equipment: 'Chair or bench',
      icon: Icons.fitness_center,
    ),
    Exercise(
      name: 'Bicep Curls',
      category: 'Arm',
      duration: '40 seconds',
      reps: '10 reps each arm',
      description: 'Isolation exercise for bicep muscles.',
      instructions:
          '1. Hold weights with palms facing forward\n2. Keep elbows tucked to your sides\n3. Curl weights toward shoulders slowly\n4. Squeeze biceps at the top\n5. Lower back down with control',
      benefits:
          '• Builds bicep strength and size\n• Improves arm definition\n• Strengthens wrist flexors\n• Easy to learn',
      difficulty: 'Beginner',
      musclesTargeted: 'Biceps, Forearms',
      equipment: 'Dumbbells or water bottles',
      icon: Icons.fitness_center,
    ),
    Exercise(
      name: 'Shoulder Press',
      category: 'Arm',
      duration: '35 seconds',
      reps: '12 reps',
      description: 'Compound exercise for shoulder development.',
      instructions:
          '1. Hold weights at shoulder height, palms forward\n2. Sit or stand with back straight\n3. Press weights overhead until arms are extended\n4. Do not lock elbows at the top\n5. Lower back to shoulder level with control',
      benefits:
          '• Builds shoulder strength\n• Improves upper body power\n• Enhances posture\n• Works multiple muscle groups',
      difficulty: 'Intermediate',
      musclesTargeted: 'Deltoids, Triceps, Upper Traps',
      equipment: 'Dumbbells or water bottles',
      icon: Icons.fitness_center,
    ),

    // ── LEG ─────────────────────────────────────────────
    Exercise(
      name: 'Squats',
      category: 'Leg',
      duration: '30 seconds',
      reps: '15 reps',
      description:
          'Fundamental lower body exercise targeting quads, glutes, and hamstrings.',
      instructions:
          '1. Stand with feet shoulder-width apart\n2. Toes pointed slightly outward\n3. Lower hips as if sitting in a chair\n4. Keep chest up and knees over toes\n5. Push through heels to return to start',
      benefits:
          '• Builds leg strength\n• Improves mobility and balance\n• Enhances athletic performance\n• Burns significant calories',
      difficulty: 'Beginner',
      musclesTargeted: 'Quadriceps, Glutes, Hamstrings, Core',
      equipment: 'None required',
      icon: Icons.directions_walk,
    ),
    Exercise(
      name: 'Lunges',
      category: 'Leg',
      duration: '45 seconds',
      reps: '10 reps each leg',
      description:
          'Unilateral exercise that improves balance and leg strength.',
      instructions:
          '1. Stand tall with feet together\n2. Step forward with one leg\n3. Lower hips until both knees are at 90 degrees\n4. Keep front knee above ankle\n5. Push through front heel to return to start',
      benefits:
          '• Improves balance significantly\n• Strengthens each leg independently\n• Enhances coordination\n• Great for glutes',
      difficulty: 'Beginner',
      musclesTargeted: 'Quads, Glutes, Hamstrings, Calves',
      equipment: 'None required',
      icon: Icons.directions_walk,
    ),
    Exercise(
      name: 'Calf Raises',
      category: 'Leg',
      duration: '30 seconds',
      reps: '20 reps',
      description: 'Isolation exercise for calf muscles.',
      instructions:
          '1. Stand near a wall for balance if needed\n2. Place feet hip-width apart\n3. Rise up onto the balls of your feet\n4. Hold at the top for 1 second\n5. Lower back down slowly with control',
      benefits:
          '• Strengthens calf muscles\n• Improves ankle stability\n• Enhances leg definition\n• Helps with running speed',
      difficulty: 'Beginner',
      musclesTargeted: 'Gastrocnemius, Soleus, Ankles',
      equipment: 'None required',
      icon: Icons.directions_walk,
    ),
    Exercise(
      name: 'Glute Bridges',
      category: 'Leg',
      duration: '40 seconds',
      reps: '15 reps',
      description: 'Targets glute muscles and improves hip mobility.',
      instructions:
          '1. Lie on your back with knees bent\n2. Place feet flat on floor hip-width apart\n3. Press through heels and lift hips up\n4. Squeeze glutes hard at the top\n5. Lower back down with control',
      benefits:
          '• Activates glutes effectively\n• Improves hip mobility\n• Helps relieve lower back pain\n• Strengthens hamstrings',
      difficulty: 'Beginner',
      musclesTargeted: 'Glutes, Hamstrings, Lower Back, Core',
      equipment: 'None required',
      icon: Icons.directions_walk,
    ),

    // ── CORE ────────────────────────────────────────────
    Exercise(
      name: 'Plank',
      category: 'Core',
      duration: '30 seconds',
      reps: '3 sets',
      description:
          'Isometric core exercise that strengthens the entire abdominal region.',
      instructions:
          '1. Place forearms on ground, elbows under shoulders\n2. Extend legs back and rise onto toes\n3. Keep body perfectly straight head to heels\n4. Engage your core and squeeze glutes\n5. Hold without letting hips sag or rise',
      benefits:
          '• Strengthens entire core\n• Improves posture dramatically\n• Reduces lower back pain\n• Enhances overall stability',
      difficulty: 'Beginner',
      musclesTargeted: 'Abs, Obliques, Lower Back, Shoulders',
      equipment: 'None required',
      icon: Icons.timer,
    ),
    Exercise(
      name: 'Russian Twists',
      category: 'Core',
      duration: '45 seconds',
      reps: '20 reps',
      description: 'Rotational core exercise targeting obliques.',
      instructions:
          '1. Sit with knees bent, feet slightly off floor\n2. Lean back at 45 degree angle\n3. Clasp hands together in front of chest\n4. Twist torso to the right, then to the left\n5. Keep movements controlled, not rushed',
      benefits:
          '• Strengthens obliques deeply\n• Improves rotational power\n• Enhances balance and stability\n• Great for waist definition',
      difficulty: 'Intermediate',
      musclesTargeted: 'Obliques, Abs, Hip Flexors',
      equipment: 'None required',
      icon: Icons.rotate_right,
    ),
    Exercise(
      name: 'Leg Raises',
      category: 'Core',
      duration: '40 seconds',
      reps: '12 reps',
      description: 'Targets lower abdominal muscles.',
      instructions:
          '1. Lie flat on your back, arms at sides\n2. Keep legs straight and together\n3. Raise legs to 90 degrees slowly\n4. Lower them back without touching floor\n5. Keep lower back pressed into ground',
      benefits:
          '• Strengthens lower abs\n• Improves core stability\n• Enhances hip flexibility\n• Tones the lower belly',
      difficulty: 'Intermediate',
      musclesTargeted: 'Lower Abs, Hip Flexors, Quads',
      equipment: 'None required',
      icon: Icons.arrow_upward,
    ),
    Exercise(
      name: 'Bicycle Crunches',
      category: 'Core',
      duration: '50 seconds',
      reps: '30 reps',
      description: 'Dynamic core exercise that mimics cycling motion.',
      instructions:
          '1. Lie on back, hands behind head\n2. Lift shoulders off the ground\n3. Bring right elbow to left knee\n4. Extend right leg at the same time\n5. Switch sides in a smooth cycling motion',
      benefits:
          '• Works entire core at once\n• Improves coordination\n• Burns calories well\n• Best exercise for abs per research',
      difficulty: 'Beginner',
      musclesTargeted: 'Abs, Obliques, Hip Flexors',
      equipment: 'None required',
      icon: Icons.pedal_bike,
    ),

    // ── FULL BODY ────────────────────────────────────────
    Exercise(
      name: 'Kettlebell Swings',
      category: 'Full Body',
      duration: '45 seconds',
      reps: '15 reps',
      description:
          'Dynamic hip-hinging movement that works the entire posterior chain.',
      instructions:
          '1. Stand with feet shoulder-width apart\n2. Hold weight with both hands\n3. Hinge at hips and swing weight between legs\n4. Drive hips forward explosively\n5. Let weight swing to chest height and repeat',
      benefits:
          '• Builds explosive power\n• Strengthens glutes and hamstrings\n• Improves cardio fitness\n• Burns lots of calories',
      difficulty: 'Intermediate',
      musclesTargeted: 'Glutes, Hamstrings, Core, Shoulders',
      equipment: 'Kettlebell or dumbbell',
      icon: Icons.fitness_center,
    ),
    Exercise(
      name: 'Renegade Rows',
      category: 'Full Body',
      duration: '50 seconds',
      reps: '10 reps per side',
      description: 'Combines plank stability with upper body pulling.',
      instructions:
          '1. Start in high plank with hands on weights\n2. Keep feet wide for stability\n3. Row one weight to your hip\n4. Keep hips square and still\n5. Lower and repeat on other side',
      benefits:
          '• Works core and back together\n• Improves anti-rotation stability\n• Builds arm strength\n• Challenges balance',
      difficulty: 'Advanced',
      musclesTargeted: 'Back, Core, Biceps, Shoulders',
      equipment: 'Two dumbbells',
      icon: Icons.fitness_center,
    ),
    Exercise(
      name: 'Thrusters',
      category: 'Full Body',
      duration: '40 seconds',
      reps: '12 reps',
      description:
          'Combines front squat with overhead press in one fluid movement.',
      instructions:
          '1. Hold weights at shoulder height\n2. Perform a front squat going down\n3. As you stand up, use momentum\n4. Press weights overhead at the top\n5. Lower back to shoulders and repeat',
      benefits:
          '• Full-body coordination exercise\n• Builds leg and shoulder strength\n• Great metabolic conditioning\n• Time-efficient workout',
      difficulty: 'Intermediate',
      musclesTargeted: 'Legs, Shoulders, Core, Triceps',
      equipment: 'Dumbbells or water bottles',
      icon: Icons.fitness_center,
    ),

    // ── ADVANCED EXERCISES ──────────────────────────────────────────────────
    Exercise(
      name: 'Muscle Ups',
      category: 'Full Body',
      duration: '45 seconds',
      reps: '5 reps',
      description:
          'Advanced calisthenics move combining pull-up and dip in one explosive movement.',
      instructions:
          '1. Hang from a bar with overhand grip\n2. Perform explosive pull-up\n3. Transition hands above the bar\n4. Push up to lock out arms\n5. Lower back with control and repeat',
      benefits:
          '• Elite upper body strength\n• Combines pulling and pushing\n• Improves explosive power\n• Great for gymnastic strength',
      difficulty: 'Advanced',
      musclesTargeted: 'Chest, Back, Shoulders, Triceps, Core',
      equipment: 'Pull-up bar',
      icon: Icons.sports_gymnastics,
    ),
    Exercise(
      name: 'Pistol Squat',
      category: 'Leg',
      duration: '40 seconds',
      reps: '8 reps each leg',
      description:
          'Single-leg squat requiring extreme balance, flexibility and leg strength.',
      instructions:
          '1. Stand on one leg\n2. Extend other leg forward\n3. Slowly lower into squat on standing leg\n4. Keep back straight and heel down\n5. Push back up to start position',
      benefits:
          '• Single-leg strength and balance\n• Improves flexibility\n• Corrects muscle imbalances\n• No equipment needed',
      difficulty: 'Advanced',
      musclesTargeted: 'Quads, Glutes, Hamstrings, Calves, Core',
      equipment: 'None required',
      icon: Icons.accessibility_new,
    ),
    Exercise(
      name: 'Planche Push-Up',
      category: 'Arm',
      duration: '40 seconds',
      reps: '6 reps',
      description:
          'Elite calisthenics push-up variation with hands far back, body nearly parallel.',
      instructions:
          '1. Place hands near hips pointing back\n2. Lean forward shifting weight over hands\n3. Lower chest toward floor\n4. Push back up explosively\n5. Keep core completely tight throughout',
      benefits:
          '• Maximum chest and shoulder strength\n• Core stability elite level\n• Gymnastic strength builder\n• Impressive functional movement',
      difficulty: 'Advanced',
      musclesTargeted: 'Chest, Shoulders, Triceps, Core, Wrists',
      equipment: 'None required',
      icon: Icons.fitness_center,
    ),
    Exercise(
      name: 'Dragon Flag',
      category: 'Core',
      duration: '45 seconds',
      reps: '6 reps',
      description:
          'Bruce Lee signature move — full body lowering while keeping body straight.',
      instructions:
          '1. Lie on bench and grip behind head\n2. Raise legs and hips to vertical\n3. Slowly lower entire body as one unit\n4. Stop just before touching bench\n5. Pull back up to vertical position',
      benefits:
          '• Extreme core strength\n• Full posterior chain engagement\n• Signature advanced ab exercise\n• Builds incredible body control',
      difficulty: 'Advanced',
      musclesTargeted: 'Abs, Core, Lower Back, Glutes, Shoulders',
      equipment: 'Bench or sturdy surface',
      icon: Icons.self_improvement,
    ),
    Exercise(
      name: 'Sprint Intervals',
      category: 'Cardio',
      duration: '60 seconds',
      reps: '8 rounds',
      description:
          'High-intensity sprint bursts for maximum cardiovascular and metabolic conditioning.',
      instructions:
          '1. Start at a comfortable jog\n2. Sprint at 90% max effort for 20 seconds\n3. Walk or slow jog for 40 seconds\n4. Repeat for all rounds\n5. Cool down with slow walk after',
      benefits:
          '• Maximum calorie burn\n• Improves VO2 max\n• Burns fat even after workout\n• Builds speed and endurance',
      difficulty: 'Advanced',
      musclesTargeted: 'Full Body, Heart, Lungs',
      equipment: 'Open space or treadmill',
      icon: Icons.directions_run,
    ),
  ];

  static List<Exercise> getByCategory(String category) {
    return allExercises.where((e) => e.category == category).toList();
  }

  static List<Exercise> search(String query) {
    if (query.isEmpty) return allExercises;
    final q = query.toLowerCase();
    return allExercises
        .where(
          (e) =>
              e.name.toLowerCase().contains(q) ||
              e.category.toLowerCase().contains(q) ||
              e.description.toLowerCase().contains(q) ||
              e.difficulty.toLowerCase().contains(q),
        )
        .toList();
  }

  static List<String> get categories => [
    'Cardio',
    'Arm',
    'Leg',
    'Core',
    'Full Body',
  ];

  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Cardio':
        return Colors.orange;
      case 'Arm':
        return Colors.blue;
      case 'Leg':
        return Colors.purple;
      case 'Core':
        return Colors.green;
      case 'Full Body':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Cardio':
        return Icons.directions_run;
      case 'Arm':
        return Icons.fitness_center;
      case 'Leg':
        return Icons.directions_walk;
      case 'Core':
        return Icons.self_improvement;
      case 'Full Body':
        return Icons.accessibility_new;
      default:
        return Icons.fitness_center;
    }
  }

  // Seconds parsed from strings like '45 seconds'
  static int durationSeconds(Exercise e) {
    final match = RegExp(r'\d+').firstMatch(e.duration);
    return match != null ? int.parse(match.group(0)!) : 30;
  }

  // Approximate MET value per category (Compendium of Physical Activities)
  static double metFor(String category) {
    switch (category) {
      case 'Cardio':
        return 8.0;
      case 'Arm':
        return 5.0;
      case 'Leg':
        return 6.0;
      case 'Core':
        return 4.0;
      case 'Full Body':
        return 8.0;
      default:
        return 5.0;
    }
  }

  // kcal = MET × 3.5 × kg / 200 per minute
  static double caloriesFor(Exercise e, int seconds, double weightKg) =>
      metFor(e.category) * 3.5 * weightKg / 200 * (seconds / 60);

  static String getCategoryDuration(String category) {
    switch (category) {
      case 'Cardio':
        return '30 Minutes';
      case 'Arm':
        return '25 Minutes';
      case 'Leg':
        return '28 Minutes';
      case 'Core':
        return '22 Minutes';
      case 'Full Body':
        return '35 Minutes';
      default:
        return '30 Minutes';
    }
  }
}

// ── free-exercise-db visuals ──────────────────────────────────────────────────
// Closest matching entry in github.com/yuhonas/free-exercise-db for each
// exercise (Burpees, Planche Push-Up and Dragon Flag have no exact match).
const _exerciseDbIds = {
  'Jumping Jacks': 'Star_Jump',
  'High Knees': 'Knee_Tuck_Jump',
  'Burpees': 'Frog_Hops',
  'Mountain Climbers': 'Mountain_Climbers',
  'Push Ups': 'Pushups',
  'Tricep Dips': 'Bench_Dips',
  'Bicep Curls': 'Dumbbell_Bicep_Curl',
  'Shoulder Press': 'Dumbbell_Shoulder_Press',
  'Squats': 'Bodyweight_Squat',
  'Lunges': 'Bodyweight_Walking_Lunge',
  'Calf Raises': 'Standing_Calf_Raises',
  'Glute Bridges': 'Butt_Lift_Bridge',
  'Plank': 'Plank',
  'Russian Twists': 'Russian_Twist',
  'Leg Raises': 'Flat_Bench_Lying_Leg_Raise',
  'Bicycle Crunches': 'Air_Bike',
  'Kettlebell Swings': 'One-Arm_Kettlebell_Swings',
  'Renegade Rows': 'Alternating_Renegade_Row',
  'Thrusters': 'Kettlebell_Thruster',
  'Muscle Ups': 'Muscle_Up',
  'Pistol Squat': 'Kettlebell_Pistol_Squat',
  'Planche Push-Up': 'Decline_Push-Up',
  'Dragon Flag': 'Hanging_Leg_Raise',
  'Sprint Intervals': 'Wind_Sprints',
};

extension ExerciseVisuals on Exercise {
  String? get dbId => _exerciseDbIds[name];

  // frame 0 = start position, 1 = end position
  String? imageUrl(int frame) => dbId == null
      ? null
      : 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/$dbId/$frame.jpg';

  // Up to 4 short "How to do it" steps from the numbered instructions
  List<String> get steps => instructions
      .split('\n')
      .map((l) => l.replaceFirst(RegExp(r'^\s*\d+[.)]\s*'), '').trim())
      .where((l) => l.isNotEmpty)
      .take(4)
      .toList();
}
