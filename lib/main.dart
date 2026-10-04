import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_check_config.dart';
import 'firebase_options.dart';
import 'theme/fp_theme.dart';
import 'services/app_state.dart';
import 'pages/intro_screen.dart';
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
import 'pages/onboarding_screen.dart';
import 'services/exercise_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _activateAppCheck();

  // On web the saved session is restored asynchronously — wait for it
  final user = await FirebaseAuth.instance.authStateChanges().first;
  final introSeen = user != null || await IntroScreen.hasBeenSeen();
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
      child: MyApp(
        initialRoute: !signedIn
            ? (introSeen ? '/landing' : '/intro')
            : appState.needsOnboarding
            ? '/onboarding'
            : '/home',
      ),
    ),
  );
}

// App Check protects Firebase AI Logic (the coach) from abuse.
// Debug builds (localhost) use a debug token printed in the browser console;
// release builds use reCAPTCHA v3 with the site key in app_check_config.dart.
Future<void> _activateAppCheck() async {
  if (!kIsWeb) return; // FitPulse currently ships for web only
  try {
    if (kDebugMode) {
      await FirebaseAppCheck.instance.activate(providerWeb: WebDebugProvider());
    } else if (recaptchaSiteKey.isNotEmpty) {
      await FirebaseAppCheck.instance.activate(
        providerWeb: ReCaptchaV3Provider(recaptchaSiteKey),
      );
    } else {
      debugPrint('App Check: no reCAPTCHA site key set — AI coach will fail');
    }
  } catch (e) {
    debugPrint('App Check activation failed: $e');
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitPulse — Fitness Tracker',
      debugShowCheckedModeBanner: false,
      theme: FpTheme.dark(),
      initialRoute: initialRoute,
      routes: {
        '/intro': (_) => const IntroScreen(),
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
        '/onboarding': (_) => const OnboardingScreen(),
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
