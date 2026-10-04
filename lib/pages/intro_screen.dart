import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/fp_theme.dart';
import '../theme/neon.dart';

// ── First-launch intro: 3 swipeable neon HUD slides ──────────────────────────
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  static const seenKey = 'introSeen';

  static Future<bool> hasBeenSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(seenKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

enum _Side { left, right, center }

class _Hud {
  final _Side side;
  final double top; // fraction of screen height
  final Offset target; // fraction of the photo (person)
  final Widget Function(Duration delay) builder;
  const _Hud(this.side, this.top, this.target, this.builder);
}

class _Slide {
  final String asset;
  final String heading;
  final String subtitle;
  final Alignment panFrom;
  final Alignment panTo;
  final List<_Hud> cards;
  const _Slide({
    required this.asset,
    required this.heading,
    required this.subtitle,
    required this.panFrom,
    required this.panTo,
    required this.cards,
  });
}

// Photo aspect ratio (1536 × 2752) — used to map targets onto the screen
const _photoAspect = 1536 / 2752;

// Note: slide2.jpg is the deadlift photo and slide1.jpg the treadmill one
final _slides = <_Slide>[
  _Slide(
    asset: 'assets/images/slide2.jpg',
    heading: 'Train Smarter',
    subtitle: 'Personalized workouts built for your goal',
    panFrom: const Alignment(0.1, -0.1),
    panTo: const Alignment(-0.1, 0.1),
    cards: [
      _Hud(
        _Side.left,
        0.19,
        const Offset(0.58, 0.47),
        (d) => HudCard(
          label: 'HEART RATE',
          value: HudCount(value: 174, unit: 'BPM', delay: d),
          extra: const EcgLine(width: 118, height: 18),
        ),
      ),
      _Hud(
        _Side.right,
        0.40,
        const Offset(0.84, 0.66),
        (d) => HudCard(
          label: 'LOAD',
          value: HudCount(value: 60, unit: 'KG', delay: d),
        ),
      ),
      _Hud(
        _Side.left,
        0.50,
        const Offset(0.41, 0.68),
        (d) => HudCard(
          label: 'REPS',
          value: HudCount(value: 7, suffix: '/12', delay: d),
        ),
      ),
    ],
  ),
  _Slide(
    asset: 'assets/images/slide1.jpg',
    heading: 'Track Every Win',
    subtitle: 'Streaks, XP and badges that keep you going',
    panFrom: const Alignment(-0.15, 0),
    panTo: const Alignment(0.15, 0.05),
    cards: [
      _Hud(
        _Side.right,
        0.19,
        const Offset(0.38, 0.29),
        (d) => HudCard(
          label: 'PACE',
          value: HudCount(value: 12, unit: 'KM/H', delay: d),
        ),
      ),
      _Hud(
        _Side.right,
        0.36,
        const Offset(0.52, 0.39),
        (d) => HudCard(
          label: 'CALORIES',
          value: HudCount(value: 512, unit: 'KCAL', delay: d),
        ),
      ),
      _Hud(
        _Side.right,
        0.53,
        const Offset(0.38, 0.58),
        (d) => HudCard(
          label: 'STREAK',
          value: HudCount(value: 12, unit: 'DAYS 🔥', delay: d),
        ),
      ),
    ],
  ),
  _Slide(
    asset: 'assets/images/slide3.jpg',
    heading: 'Train Together',
    subtitle: 'AI coach and friends leaderboard',
    panFrom: const Alignment(0, -0.15),
    panTo: const Alignment(0, 0.1),
    cards: [
      _Hud(
        _Side.left,
        0.17,
        const Offset(0.51, 0.33),
        (d) => const HudCard(
          label: 'AI COACH',
          value: Row(
            mainAxisSize: MainAxisSize.min,
            children: [NeonDot(), SizedBox(width: 8), Text('ONLINE')],
          ),
        ),
      ),
      _Hud(
        _Side.right,
        0.49,
        const Offset(0.79, 0.37),
        (d) => HudCard(
          label: 'LEVEL',
          value: HudCount(value: 5, delay: d),
        ),
      ),
      _Hud(
        _Side.center,
        0.56,
        const Offset(0.51, 0.36),
        (d) => HudCard(
          label: 'RANK',
          value: HudCount(value: 1, prefix: '#', unit: '🏆', delay: d),
        ),
      ),
    ],
  ),
];

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  final _pager = PageController();
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();
  double _page = 0;
  int _active = 0;
  int _generation = 0; // bump to replay a slide's card animations

  @override
  void initState() {
    super.initState();
    _pager.addListener(() => setState(() => _page = _pager.page ?? 0));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final s in _slides) {
      precacheImage(
        KenBurnsImage.provider(s.asset),
        context,
        onError: (_, _) {},
      );
    }
  }

  @override
  void dispose() {
    _pager.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(IntroScreen.seenKey, true);
    } catch (_) {
      // Storage unavailable (e.g. private mode) — just continue
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/landing');
  }

  void _next() {
    if (_active == _slides.length - 1) {
      _finish();
    } else {
      _pager.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _active == _slides.length - 1;
    return Scaffold(
      backgroundColor: Neon.navy,
      body: LayoutBuilder(
        builder: (context, box) {
          final size = box.biggest;
          return Stack(
            children: [
              // ── Crossfading Ken Burns photos (slow parallax) ──
              // One slot per slide, always present: changing the number of
              // Stack children would remount the PageView and reset it.
              for (var i = 0; i < _slides.length; i++)
                Positioned.fill(
                  key: ValueKey('photo-$i'),
                  child: (1 - (_page - i).abs()) <= 0.01
                      ? const SizedBox.shrink()
                      : Opacity(
                          opacity: (1 - (_page - i).abs()).clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(-(_page - i) * size.width * 0.12, 0),
                            child: Transform.scale(
                              scale: 1.08, // room for the parallax shift
                              child: KenBurnsImage(
                                asset: _slides[i].asset,
                                panFrom: _slides[i].panFrom,
                                panTo: _slides[i].panTo,
                              ),
                            ),
                          ),
                        ),
                ),
              const Positioned.fill(child: NeonScrim()),

              // ── Swipeable foreground: HUD cards + text ──
              Positioned.fill(
                key: const ValueKey('pager'),
                child: PageView.builder(
                  controller: _pager,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() {
                    _active = i;
                    _generation++;
                  }),
                  itemBuilder: (context, i) => _SlideForeground(
                    key: ValueKey('slide-$i'),
                    slide: _slides[i],
                    size: size,
                    offset: _page - i,
                    replayKey: i == _active ? _generation : -1,
                    pulse: _pulse,
                  ),
                ),
              ),

              // ── Fixed chrome: logo, skip, indicator, CTA ──
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
                      child: Row(
                        children: [
                          const Spacer(),
                          AnimatedOpacity(
                            opacity: last ? 0 : 1,
                            duration: const Duration(milliseconds: 250),
                            child: TextButton(
                              onPressed: last ? null : _finish,
                              child: Text(
                                'SKIP',
                                style: Neon.hud(size: 12, spacing: 2.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const IgnorePointer(child: NeonLogo(size: 34))
                        .animate()
                        .fadeIn(duration: 700.ms)
                        .slideY(begin: -0.2, curve: Curves.easeOutCubic),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_slides.length, (i) {
                              final t = (1 - (_page - i).abs()).clamp(0.0, 1.0);
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: 8 + 22 * t,
                                height: 8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Color.lerp(
                                    Colors.white.withValues(alpha: 0.25),
                                    Neon.cyan,
                                    t,
                                  ),
                                  boxShadow: t > 0.5
                                      ? [
                                          BoxShadow(
                                            color: Neon.cyan.withValues(
                                              alpha: 0.6,
                                            ),
                                            blurRadius: 10,
                                          ),
                                        ]
                                      : null,
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 18),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            transitionBuilder: (child, a) => FadeTransition(
                              opacity: a,
                              child: ScaleTransition(scale: a, child: child),
                            ),
                            child: last
                                ? NeonGradientButton(
                                    key: const ValueKey('start'),
                                    label: 'Get Started',
                                    icon: Icons.arrow_forward_rounded,
                                    pulse: true,
                                    onTap: _finish,
                                  )
                                : NeonOutlineButton(
                                    key: const ValueKey('next'),
                                    label: 'Next',
                                    onTap: _next,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── One slide's moving layer ──────────────────────────────────────────────────
class _SlideForeground extends StatelessWidget {
  final _Slide slide;
  final Size size;
  final double offset; // page - index, −1..1
  final int replayKey;
  final Animation<double> pulse;

  const _SlideForeground({
    super.key,
    required this.slide,
    required this.size,
    required this.offset,
    required this.replayKey,
    required this.pulse,
  });

  // Where a fraction of the photo lands on screen with BoxFit.cover
  Offset _photoPoint(Offset f) {
    final screenAspect = size.width / size.height;
    if (screenAspect < _photoAspect) {
      final w = size.height * _photoAspect;
      return Offset((size.width - w) / 2 + f.dx * w, f.dy * size.height);
    }
    final h = size.width / _photoAspect;
    return Offset(f.dx * size.width, (size.height - h) / 2 + f.dy * h);
  }

  @override
  Widget build(BuildContext context) {
    final w = size.width;
    final cardW = math.min(150.0, (w - 48) / 2);
    final placed = <(Rect, _Hud)>[];
    for (final c in slide.cards) {
      final x = switch (c.side) {
        _Side.left => 16.0,
        _Side.right => w - 16 - cardW,
        _Side.center => (w - cardW) / 2,
      };
      placed.add((Rect.fromLTWH(x, c.top * size.height, cardW, 56), c));
    }
    final lines = [
      for (final (r, c) in placed)
        (
          switch (c.side) {
            _Side.left => Offset(r.right, r.top + 22),
            _Side.right => Offset(r.left, r.top + 22),
            _Side.center => Offset(r.center.dx, r.top),
          },
          _photoPoint(c.target),
        ),
    ];

    return Stack(
      children: [
        // HUD layer — moves slower than the page (parallax)
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(offset * w * 0.45, 0),
            child: KeyedSubtree(
              key: ValueKey(replayKey),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1500),
                        curve: const Interval(0.45, 1, curve: Curves.easeOut),
                        builder: (context, t, _) => AnimatedBuilder(
                          animation: pulse,
                          builder: (_, _) => CustomPaint(
                            painter: HudPointerPainter(
                              lines,
                              progress: t,
                              pulse: pulse.value,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  for (final (k, (r, c)) in placed.indexed)
                    Positioned(
                      left: r.left,
                      top: r.top,
                      width: r.width,
                      child: c
                          .builder(Duration(milliseconds: 250 + 220 * k))
                          .animate()
                          .fadeIn(delay: (250 + 220 * k).ms, duration: 400.ms)
                          .scaleXY(
                            begin: 0.6,
                            delay: (250 + 220 * k).ms,
                            duration: 500.ms,
                            curve: Curves.easeOutBack,
                          ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Heading + subtitle — moves faster than the page
        Positioned(
          left: 24,
          right: 24,
          bottom: 150,
          child: SafeArea(
            top: false,
            child: Transform.translate(
              offset: Offset(-offset * w * 0.25, 0),
              child: Opacity(
                opacity: (1 - offset.abs() * 1.4).clamp(0.0, 1.0),
                child: Column(
                  children: [
                    Text(
                      slide.heading,
                      textAlign: TextAlign.center,
                      style: FpText.display(size: 32, color: Colors.white)
                          .copyWith(
                            shadows: [
                              Shadow(
                                color: Neon.cyan.withValues(alpha: 0.45),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      slide.subtitle,
                      textAlign: TextAlign.center,
                      style: FpText.body(
                        color: Colors.white.withValues(alpha: 0.78),
                        size: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
