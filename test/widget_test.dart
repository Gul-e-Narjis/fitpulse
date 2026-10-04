import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:fit_pulse/pages/home.dart';
import 'package:fit_pulse/pages/workout_detail.dart';
import 'package:fit_pulse/services/app_state.dart';
import 'package:fit_pulse/services/exercise_data.dart';

void main() {
  testWidgets('Completing a workout updates Home stats and history', (
    tester,
  ) async {
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
    await tester.pumpAndSettle();

    final category = ExerciseDataService.categories.first;
    final count = ExerciseDataService.getByCategory(category).length;
    navKey.currentState!.push(
      MaterialPageRoute(builder: (_) => WorkoutDetailPage(category: category)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Workout'));
    await tester.pumpAndSettle();

    // Skip through every exercise to finish the workout
    for (var i = 0; i < count; i++) {
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
    }

    expect(find.text('🎉 Workout Complete!'), findsOneWidget);
    expect(appState.totalWorkoutsCompleted, 1);
    expect(appState.workoutHistory.first.category, category);

    await tester.tap(find.text('Back to Home'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeContent), findsOneWidget);
    expect(appState.totalMinutesWorkedOut, greaterThan(0));
    expect(
      find.text('${appState.totalMinutesWorkedOut}'),
      findsWidgets,
    );

    // History tab lists the completed workout
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('$category Workout'), findsWidgets);
  });
}
