import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/fp_theme.dart';
import '../theme/neon.dart';

// ── Auth entry: Create account / Sign in / Guest ─────────────────────────────
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const _photo = 'assets/images/slide3.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Neon.navy,
      body: Stack(
        children: [
          const Positioned.fill(
            child: KenBurnsImage(
              asset: _photo,
              panFrom: Alignment(0, -0.2),
              panTo: Alignment(0, 0.1),
              duration: Duration(seconds: 10),
            ),
          ),
          const Positioned.fill(
            child: NeonScrim(topStop: 0.30, bottomStart: 0.30),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, box) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: box.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                      child: Column(
                        children: [
                          const NeonLogo(size: 38)
                              .animate()
                              .fadeIn(duration: 700.ms)
                              .slideY(begin: -0.2, curve: Curves.easeOutCubic),
                          const SizedBox(height: 28),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: _CoachHud(),
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(height: 24),
                          _AuthPanel()
                              .animate()
                              .fadeIn(delay: 300.ms, duration: 600.ms)
                              .slideY(begin: 0.15, curve: Curves.easeOutCubic),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachHud extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HudCard(
              label: 'AI COACH',
              width: 148,
              value: Row(
                mainAxisSize: MainAxisSize.min,
                children: [NeonDot(), SizedBox(width: 8), Text('ONLINE')],
              ),
            ),
            // Short pointer towards the high-five
            Container(
              width: 46,
              height: 1.2,
              color: Neon.cyan.withValues(alpha: 0.75),
            ),
            const NeonDot(color: Neon.cyan, size: 7),
          ],
        )
        .animate()
        .fadeIn(delay: 500.ms, duration: 500.ms)
        .scaleXY(
          begin: 0.7,
          delay: 500.ms,
          curve: Curves.easeOutBack,
          alignment: Alignment.centerLeft,
        );
  }
}

class _AuthPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NeonGlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your AI-powered fitness journey starts here',
            textAlign: TextAlign.center,
            style: FpText.h3(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'Workouts, streaks, badges and a coach that knows you.',
            textAlign: TextAlign.center,
            style: FpText.body(
              color: Colors.white.withValues(alpha: 0.7),
              size: 13,
            ),
          ),
          const SizedBox(height: 20),
          NeonGradientButton(
            label: 'Create Account',
            onTap: () => Navigator.pushNamed(context, '/signup'),
          ),
          const SizedBox(height: 12),
          NeonOutlineButton(
            label: 'Sign In',
            onTap: () => Navigator.pushNamed(context, '/login'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (r) => false,
            ),
            icon: Icon(
              Icons.person_outline_rounded,
              size: 16,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            label: Text(
              'Continue as Guest',
              style: FpText.body(
                color: Colors.white.withValues(alpha: 0.7),
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
