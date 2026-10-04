import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/app_state.dart';
import 'pages/landing.dart';
import 'pages/login.dart';
import 'pages/signup_screen.dart';
import 'pages/home.dart';
import 'pages/workout_detail.dart';
import 'pages/exercise_detail.dart';
import 'pages/search_page.dart';
import 'pages/bmi_screen.dart';
import 'pages/history_screen.dart';
import 'pages/progress_charts.dart';
import 'pages/workout_planner.dart';
import 'pages/step_counter.dart';
import 'pages/notifications_screen.dart';
import 'pages/custom_workout.dart';
import 'services/exercise_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // On web the saved session is restored asynchronously — wait for it
  final user = await FirebaseAuth.instance.authStateChanges().first;
  final appState = AppState();
  var signedIn = false;
  if (user != null) {
    try {
      await appState.loadUser(user);
      signedIn = true;
    } catch (e) {
      debugPrint('Could not restore session: $e');
    }
  }

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: MyApp(initialRoute: signedIn ? '/home' : '/landing'),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitPulse — Fitness Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1E9FA3),
          secondary: Color(0xFFB39DDB),
          surface: Color(0xFFFFFFFF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F8F7),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF4F8F7),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF1A2E2E)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1A2E2E),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/landing': (_) => const LandingPage(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/home': (_) => const Home(),
        '/search': (_) => const SearchPage(),
        '/history': (_) => const HistoryScreen(),
        '/bmi': (_) => const BMIScreen(),
        '/charts': (_) => const ProgressChartsScreen(),
        '/planner': (_) => const WorkoutPlannerScreen(),
        '/steps': (_) => const StepCounterScreen(),
        '/notifications': (_) => const NotificationsScreen(),
        '/custom': (_) => const CustomWorkoutScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/workout_detail') {
          final category = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => WorkoutDetailPage(category: category),
          );
        }
        if (settings.name == '/exercise_detail') {
          final exercise = settings.arguments as Exercise;
          return MaterialPageRoute(
            builder: (_) => ExerciseDetailPage(exercise: exercise),
          );
        }
        return null;
      },
    );
  }
}
