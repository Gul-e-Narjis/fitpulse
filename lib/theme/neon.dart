import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'fp_theme.dart';

// ── Neon HUD style for the intro / auth screens ───────────────────────────────
class Neon {
  static const cyan = Color(0xFF22D3EE);
  static const lime = FpColors.lime;
  static const navy = FpColors.bg;
  static const danger = Color(0xFFFB7185);

  static const ctaGradient = LinearGradient(colors: [cyan, lime]);

  static List<Shadow> glow([Color c = cyan, double r = 18]) => [
    Shadow(color: c.withValues(alpha: 0.9), blurRadius: r * 0.4),
    Shadow(color: c.withValues(alpha: 0.6), blurRadius: r),
  ];

  static TextStyle hud({
    double size = 12,
    Color color = cyan,
    FontWeight weight = FontWeight.w600,
    double spacing = 1.6,
  }) => GoogleFonts.orbitron(
    fontSize: size,
    color: color,
    fontWeight: weight,
    letterSpacing: spacing,
  );
}

// Big glowing "FITPULSE" wordmark with tagline
class NeonLogo extends StatelessWidget {
  final double size;
  final bool tagline;
  const NeonLogo({super.key, this.size = 40, this.tagline = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'FITPULSE',
            style: Neon.hud(
              size: size,
              color: Colors.white,
              weight: FontWeight.w800,
              spacing: size * 0.22,
            ).copyWith(shadows: Neon.glow(Neon.cyan, size * 0.7)),
          ),
        ),
        if (tagline) ...[
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'TRAIN. TRACK. TRANSFORM.',
              style: Neon.hud(
                size: size * 0.28,
                spacing: 3,
              ).copyWith(shadows: Neon.glow(Neon.cyan, 8)),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Ken Burns photo: slow zoom 1.0 → 1.15 with a gentle pan ─────────────────
// Falls back to a dark gradient if the asset can't be loaded.
class KenBurnsImage extends StatefulWidget {
  final String asset;
  final Alignment panFrom;
  final Alignment panTo;
  final Duration duration;

  const KenBurnsImage({
    super.key,
    required this.asset,
    this.panFrom = const Alignment(-0.15, -0.05),
    this.panTo = const Alignment(0.15, 0.05),
    this.duration = const Duration(seconds: 8),
  });

  // Large photos are decoded at this width to keep animation smooth on web
  static ImageProvider provider(String asset) =>
      ResizeImage(AssetImage(asset), width: 1080);

  @override
  State<KenBurnsImage> createState() => _KenBurnsImageState();
}

class _KenBurnsImageState extends State<KenBurnsImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = Image(
      image: KenBurnsImage.provider(widget.asset),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => const NeonFallbackBackground(),
      frameBuilder: (context, child, frame, sync) =>
          sync || frame != null ? child : const NeonFallbackBackground(),
    );
    return ClipRect(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_c.value);
          return Transform.scale(
            scale: 1.0 + 0.15 * t,
            alignment: Alignment.lerp(widget.panFrom, widget.panTo, t)!,
            child: child,
          );
        },
        child: RepaintBoundary(child: image),
      ),
    );
  }
}

class NeonFallbackBackground extends StatelessWidget {
  const NeonFallbackBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0E2A3A), Neon.navy, Color(0xFF050912)],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

// Navy fade at the top and bottom so text over the photo stays readable
class NeonScrim extends StatelessWidget {
  final double topStop;
  final double bottomStart;
  const NeonScrim({super.key, this.topStop = 0.32, this.bottomStart = 0.42});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Neon.navy.withValues(alpha: 0.92),
              Neon.navy.withValues(alpha: 0),
              Neon.navy.withValues(alpha: 0),
              Neon.navy.withValues(alpha: 0.97),
            ],
            stops: [0, topStop, bottomStart, 0.86],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

// ── HUD stat card ─────────────────────────────────────────────────────────────
class HudCard extends StatelessWidget {
  final String label;
  final Widget value;
  final Widget? extra;
  final double width;

  const HudCard({
    super.key,
    required this.label,
    required this.value,
    this.extra,
    this.width = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Neon.cyan.withValues(alpha: 0.28),
            blurRadius: 18,
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: CustomPaint(
            foregroundPainter: _CornerBracketsPainter(),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
              decoration: BoxDecoration(
                color: Neon.navy.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Neon.cyan.withValues(alpha: 0.55),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: Neon.hud(size: 8.5, spacing: 1.8)),
                  const SizedBox(height: 4),
                  DefaultTextStyle(
                    style: Neon.hud(
                      size: 17,
                      color: Colors.white,
                      weight: FontWeight.w700,
                      spacing: 0.8,
                    ),
                    child: value,
                  ),
                  if (extra != null) ...[const SizedBox(height: 6), extra!],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CornerBracketsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Neon.cyan
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    const l = 8.0;
    const i = 3.0;
    final w = size.width;
    final h = size.height;
    canvas
      ..drawPath(
        Path()
          ..moveTo(i, i + l)
          ..lineTo(i, i)
          ..lineTo(i + l, i),
        p,
      )
      ..drawPath(
        Path()
          ..moveTo(w - i - l, h - i)
          ..lineTo(w - i, h - i)
          ..lineTo(w - i, h - i - l),
        p,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Number that counts up from zero, with an optional unit
class HudCount extends StatelessWidget {
  final int value;
  final String prefix;
  final String suffix;
  final String unit;
  final Duration delay;

  const HudCount({
    super.key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.unit = '',
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 1400) + delay,
      curve: Interval(
        delay.inMilliseconds / (1400 + delay.inMilliseconds),
        1,
        curve: Curves.easeOutCubic,
      ),
      builder: (context, v, _) => Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$prefix${v.round()}$suffix'),
            if (unit.isNotEmpty)
              TextSpan(
                text: ' $unit',
                style: Neon.hud(size: 9, color: Colors.white70, spacing: 1),
              ),
          ],
        ),
        maxLines: 1,
      ),
    );
  }
}

// ── Pulsing dot (e.g. "● ONLINE") ─────────────────────────────────────────────
class NeonDot extends StatelessWidget {
  final Color color;
  final double size;
  const NeonDot({super.key, this.color = Neon.lime, this.size = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.8), blurRadius: 8),
            ],
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fade(begin: 1, end: 0.35, duration: 800.ms);
  }
}

// ── Animated ECG line ─────────────────────────────────────────────────────────
class EcgLine extends StatefulWidget {
  final double width;
  final double height;
  const EcgLine({super.key, this.width = 110, this.height = 20});

  @override
  State<EcgLine> createState() => _EcgLineState();
}

class _EcgLineState extends State<EcgLine> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) => CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _EcgPainter(_c.value),
        ),
      ),
    );
  }
}

class _EcgPainter extends CustomPainter {
  final double t;
  _EcgPainter(this.t);

  // One heartbeat (x 0..1 → y -1..1)
  static double _beat(double x) {
    if (x < 0.30) return 0;
    if (x < 0.36) return -0.15 * math.sin((x - 0.30) / 0.06 * math.pi);
    if (x < 0.40) return 0;
    if (x < 0.43) return (x - 0.40) / 0.03 * 0.25;
    if (x < 0.47) return 0.25 - (x - 0.43) / 0.04 * 1.25;
    if (x < 0.51) return -1.0 + (x - 0.47) / 0.04 * 1.35;
    if (x < 0.54) return 0.35 - (x - 0.51) / 0.03 * 0.35;
    if (x < 0.62) return 0;
    if (x < 0.74) return -0.28 * math.sin((x - 0.62) / 0.12 * math.pi);
    return 0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height / 2;
    final path = Path();
    const beats = 2;
    for (double px = 0; px <= size.width; px += 1) {
      final x = ((px / size.width) * beats + t) % 1.0;
      final y = mid + _beat(x) * mid * 0.95;
      px == 0 ? path.moveTo(px, y) : path.lineTo(px, y);
    }
    final shader = const LinearGradient(
      colors: [Color(0x0022D3EE), Neon.cyan, Neon.lime],
    ).createShader(Offset.zero & size);
    canvas
      ..drawPath(
        path,
        Paint()
          ..shader = shader
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      )
      ..drawPath(
        path,
        Paint()
          ..shader = shader
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
  }

  @override
  bool shouldRepaint(_EcgPainter old) => old.t != t;
}

// ── Pointer line from a card to a spot on the photo ──────────────────────────
class HudPointerPainter extends CustomPainter {
  final List<(Offset from, Offset to)> lines; // absolute px
  final double progress; // 0..1 draws the lines in
  final double pulse; // 0..1 target ring

  HudPointerPainter(this.lines, {this.progress = 1, this.pulse = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Neon.cyan.withValues(alpha: 0.75)
      ..strokeWidth = 1.1;
    for (final (from, to) in lines) {
      final end = Offset.lerp(from, to, progress.clamp(0, 1))!;
      canvas.drawLine(from, end, line);
      canvas.drawCircle(from, 2.2, Paint()..color = Neon.cyan);
      if (progress >= 1) {
        canvas.drawCircle(
          to,
          4,
          Paint()
            ..color = Neon.cyan
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
        canvas.drawCircle(to, 2.5, Paint()..color = Colors.white);
        canvas.drawCircle(
          to,
          5 + 9 * pulse,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = Neon.cyan.withValues(alpha: 0.7 * (1 - pulse)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(HudPointerPainter old) =>
      old.progress != progress || old.pulse != pulse || old.lines != lines;
}

// ── Buttons ───────────────────────────────────────────────────────────────────
class NeonGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool pulse;
  final bool loading;
  final IconData? icon;

  const NeonGradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.pulse = false,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Widget glow = Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Neon.cyan.withValues(alpha: 0.45),
            blurRadius: 24,
            spreadRadius: -2,
          ),
        ],
      ),
    );
    if (pulse) {
      glow = glow
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(begin: 0.96, end: 1.04, duration: 1100.ms)
          .fade(begin: 0.6, end: 1);
    }
    return Opacity(
      opacity: onTap == null && !loading ? 0.5 : 1,
      child: _Pressable(
        onTap: loading ? null : onTap,
        child: Stack(
          children: [
            Positioned.fill(child: glow),
            Container(
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: Neon.ctaGradient,
                borderRadius: BorderRadius.circular(28),
              ),
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Neon.navy,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label.toUpperCase(),
                          style: Neon.hud(
                            size: 14,
                            color: Neon.navy,
                            weight: FontWeight.w800,
                            spacing: 2,
                          ),
                        ),
                        if (icon != null) ...[
                          const SizedBox(width: 8),
                          Icon(icon, color: Neon.navy, size: 20),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class NeonOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const NeonOutlineButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          color: Neon.cyan.withValues(alpha: 0.06),
          border: Border.all(color: Neon.cyan, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: Neon.cyan.withValues(alpha: 0.25),
              blurRadius: 16,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Text(
          label.toUpperCase(),
          style: Neon.hud(
            size: 13,
            color: Neon.cyan,
            weight: FontWeight.w700,
            spacing: 2,
          ).copyWith(shadows: Neon.glow(Neon.cyan, 8)),
        ),
      ),
    );
  }
}

class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _Pressable({required this.child, this.onTap});

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? 0.96 : 1,
          duration: Duration(milliseconds: _down ? 90 : 300),
          curve: _down ? Curves.easeOut : Curves.easeOutBack,
          child: widget.child,
        ),
      ),
    );
  }
}

// ── Glass panel for auth forms ────────────────────────────────────────────────
class NeonGlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const NeonGlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(22, 24, 22, 20),
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Neon.cyan.withValues(alpha: 0.18),
            blurRadius: 40,
            spreadRadius: -10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Neon.navy.withValues(alpha: 0.55),
              border: Border.all(color: Neon.cyan.withValues(alpha: 0.30)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// Inline error banner for auth forms
class NeonErrorBanner extends StatelessWidget {
  final String? message;
  const NeonErrorBanner({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: message == null
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Neon.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Neon.danger.withValues(alpha: 0.6)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Neon.danger,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message!,
                      style: FpText.body(
                        color: const Color(0xFFFECDD3),
                        size: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms).shakeX(hz: 4, amount: 3),
    );
  }
}

// ── Shared layout for the Sign in / Sign up screens ──────────────────────────
class NeonAuthScaffold extends StatelessWidget {
  final String photo;
  final String title;
  final String subtitle;
  final Widget child;

  const NeonAuthScaffold({
    super.key,
    required this.photo,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Neon.navy,
      body: Stack(
        children: [
          Positioned.fill(
            child: KenBurnsImage(
              asset: photo,
              duration: const Duration(seconds: 12),
            ),
          ),
          // Darker than the intro so the form stays readable
          Positioned.fill(
            child: ColoredBox(color: Neon.navy.withValues(alpha: 0.45)),
          ),
          const Positioned.fill(
            child: NeonScrim(topStop: 0.25, bottomStart: 0.25),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                    child: IconButton(
                      tooltip: 'Back',
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child:
                            Column(
                                  children: [
                                    const NeonLogo(size: 26, tagline: false),
                                    const SizedBox(height: 18),
                                    Text(
                                      title,
                                      textAlign: TextAlign.center,
                                      style:
                                          FpText.display(
                                            size: 28,
                                            color: Colors.white,
                                          ).copyWith(
                                            shadows: [
                                              Shadow(
                                                color: Neon.cyan.withValues(
                                                  alpha: 0.4,
                                                ),
                                                blurRadius: 16,
                                              ),
                                            ],
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      subtitle,
                                      textAlign: TextAlign.center,
                                      style: FpText.body(
                                        color: Colors.white.withValues(
                                          alpha: 0.72,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    NeonGlassPanel(child: child),
                                  ],
                                )
                                .animate()
                                .fadeIn(duration: 500.ms)
                                .slideY(
                                  begin: 0.08,
                                  curve: Curves.easeOutCubic,
                                ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
