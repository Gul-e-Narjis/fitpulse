import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── FitPulse design tokens ────────────────────────────────────────────────────
// Dark navy base, teal primary, electric lime accent.
class FpColors {
  static const bg = Color(0xFF0B1220);
  static const bgDeep = Color(0xFF070C17);
  static const surface = Color(0xFF121B2E);
  static const surfaceHigh = Color(0xFF1A2540);
  static const teal = Color(0xFF14B8A6);
  static const tealLight = Color(0xFF2DD4BF);
  static const tealDeep = Color(0xFF0F766E);
  static const lime = Color(0xFFA3E635);
  static const violet = Color(0xFF8B5CF6);
  static const amber = Color(0xFFFBBF24);
  static const coral = Color(0xFFFB7185);
  static const sky = Color(0xFF38BDF8);
  static const text = Color(0xFFE8EEF8);
  static const muted = Color(0xFF94A3B8);
  static const faint = Color(0xFF64748B);
  static const border = Color(0x1FFFFFFF);
  static const glass = Color(0x0FFFFFFF);

  static const primaryGradient = LinearGradient(
    colors: [teal, tealLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accentGradient = LinearGradient(
    colors: [tealLight, lime],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Category accent colours tuned for the dark background
  static Color forCategory(String category) {
    switch (category) {
      case 'Cardio':
        return const Color(0xFFFB923C);
      case 'Arm':
        return sky;
      case 'Leg':
        return violet;
      case 'Core':
        return lime;
      case 'Full Body':
        return coral;
      default:
        return teal;
    }
  }
}

// ── Typography: Sora for headings, Inter for body ─────────────────────────────
class FpText {
  static TextStyle display({Color color = FpColors.text, double size = 32}) =>
      GoogleFonts.sora(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.5,
      );

  static TextStyle h1({Color color = FpColors.text}) => GoogleFonts.sora(
    color: color,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );

  static TextStyle h2({Color color = FpColors.text}) => GoogleFonts.sora(
    color: color,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  static TextStyle h3({Color color = FpColors.text}) =>
      GoogleFonts.sora(color: color, fontSize: 16, fontWeight: FontWeight.w600);

  static TextStyle body({Color color = FpColors.text, double size = 14}) =>
      GoogleFonts.inter(color: color, fontSize: size, height: 1.45);

  static TextStyle muted({double size = 13}) =>
      GoogleFonts.inter(color: FpColors.muted, fontSize: size, height: 1.4);

  static TextStyle label({Color color = FpColors.muted, double size = 11}) =>
      GoogleFonts.inter(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      );

  static TextStyle number({Color color = FpColors.text, double size = 22}) =>
      GoogleFonts.sora(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}

// ── Theme ─────────────────────────────────────────────────────────────────────
class FpTheme {
  static ThemeData dark() {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: FpColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: FpColors.teal,
        secondary: FpColors.lime,
        surface: FpColors.surface,
        onPrimary: FpColors.bgDeep,
        onSecondary: FpColors.bgDeep,
        onSurface: FpColors.text,
        error: FpColors.coral,
      ),
      textTheme: GoogleFonts.interTextTheme(
        base.textTheme,
      ).apply(bodyColor: FpColors.text, displayColor: FpColors.text),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: FpColors.text),
        titleTextStyle: FpText.h3(),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: FpColors.surfaceHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: FpText.h2(),
        contentTextStyle: FpText.body(color: FpColors.muted),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: FpColors.surfaceHigh,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: FpColors.surfaceHigh,
        contentTextStyle: FpText.body(),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FpColors.surface,
        hintStyle: FpText.muted(),
        labelStyle: FpText.muted(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: FpColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: FpColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: FpColors.teal, width: 1.6),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? FpColors.lime : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? FpColors.teal.withValues(alpha: 0.5)
              : null,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FpPageTransitionsBuilder(),
          TargetPlatform.iOS: FpPageTransitionsBuilder(),
          TargetPlatform.macOS: FpPageTransitionsBuilder(),
          TargetPlatform.windows: FpPageTransitionsBuilder(),
          TargetPlatform.linux: FpPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FpPageTransitionsBuilder(),
        },
      ),
    );
  }
}

// Fade + slight rise + scale for every pushed route
class FpPageTransitionsBuilder extends PageTransitionsBuilder {
  const FpPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final behind = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curved),
        child: ScaleTransition(
          scale: Tween(begin: 1.0, end: 0.96).animate(behind),
          child: child,
        ),
      ),
    );
  }
}
