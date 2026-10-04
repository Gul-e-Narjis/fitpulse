import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:fit_pulse/pages/home.dart';
import 'package:fit_pulse/pages/workout_detail.dart';
import 'package:fit_pulse/services/app_state.dart';
import 'package:fit_pulse/services/exercise_data.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('Only time actually exercised is recorded', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final appState = AppState();
    final navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: MaterialApp(navigatorKey: navKey, home: const Home()),
      ),
    );
    await settle(tester);

    final category = ExerciseDataService.categories.first;
    final exercises = ExerciseDataService.getByCategory(category);
    navKey.currentState!.push(
      MaterialPageRoute(builder: (_) => WorkoutDetailPage(category: category)),
    );
    await settle(tester);
    await tester.tap(find.text('Start Workout'));
    await settle(tester);

    // Do the first two exercises for real, skip the rest
    var expectedSeconds = 0;
    for (var i = 0; i < 2; i++) {
      final secs = ExerciseDataService.durationSeconds(exercises[i]);
      expectedSeconds += secs;
      await tester.tap(find.text('Start'));
      for (var s = 0; s <= secs; s++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await settle(tester);
    }
    for (var i = 2; i < exercises.length; i++) {
      await tester.tap(find.text('Skip'));
      await settle(tester);
    }

    expect(find.text('🎉 Workout Complete!'), findsOneWidget);
    expect(appState.totalWorkoutsCompleted, 1);
    final session = appState.workoutHistory.first;
    expect(session.durationSeconds, expectedSeconds);
    expect(session.exercisesCompleted, 2);
    expect(session.partial, isFalse);

    await tester.tap(find.text('Back to Home'));
    await settle(tester);
    expect(find.byType(HomeContent), findsOneWidget);

    // First workout badge is celebrated once back on Home
    expect(appState.earnedBadgeIds, contains('first_workout'));
    await settle(tester);
    expect(find.text('NEW BADGE UNLOCKED'), findsOneWidget);
    await tester.tap(find.text('Awesome!'));
    await settle(tester);
    expect(appState.pendingBadge, isNull);

    // History tab lists the completed workout
    await tester.tap(find.text('History'));
    await settle(tester);
    expect(find.text('$category Workout'), findsWidgets);
  });
}

// The UI has looping animations, so pumpAndSettle would never finish
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
