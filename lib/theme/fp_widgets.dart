import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../services/exercise_data.dart';
import 'fp_theme.dart';

// ── GlassCard ─────────────────────────────────────────────────────────────────
// Frosted panel: backdrop blur, hairline border and an optional colour glow.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? glow;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double blur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
    this.glow,
    this.gradient,
    this.onTap,
    this.blur = 14,
  });

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    Widget card = ClipRRect(
      borderRadius: shape,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: shape,
            gradient:
                gradient ??
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.09),
                    Colors.white.withValues(alpha: 0.03),
                  ],
                ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: child,
        ),
      ),
    );
    if (onTap != null) {
      card = Bounce(onTap: onTap!, child: card);
    }
    if (glow == null) return card;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: [
          BoxShadow(
            color: glow!.withValues(alpha: 0.28),
            blurRadius: 28,
            spreadRadius: -6,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: card,
    );
  }
}

// ── Bounce ────────────────────────────────────────────────────────────────────
// Springy press feedback for any tappable widget.
class Bounce extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  const Bounce({super.key, required this.child, this.onTap, this.scale = 0.95});

  @override
  State<Bounce> createState() => _BounceState();
}

class _BounceState extends State<Bounce> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? widget.scale : 1,
          duration: Duration(milliseconds: _down ? 90 : 380),
          curve: _down ? Curves.easeOut : Curves.elasticOut,
          child: widget.child,
        ),
      ),
    );
  }
}

// ── GlowButton ────────────────────────────────────────────────────────────────
class GlowButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Gradient gradient;
  final Color textColor;
  final double height;
  final bool expand;

  const GlowButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.gradient = FpColors.accentGradient,
    this.textColor = FpColors.bgDeep,
    this.height = 54,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Bounce(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: height,
          width: expand ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.last.withValues(alpha: 0.35),
                blurRadius: 22,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: textColor, size: 22),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: FpText.h3(color: textColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── TiltCard ──────────────────────────────────────────────────────────────────
// 3D perspective tilt that follows the pointer on hover, or the finger on drag.
class TiltCard extends StatefulWidget {
  final Widget child;
  final double maxTilt;
  final VoidCallback? onTap;

  const TiltCard({
    super.key,
    required this.child,
    this.maxTilt = 0.14,
    this.onTap,
  });

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> {
  Offset _tilt = Offset.zero; // x,y in -1..1

  void _update(Offset local, Size size) {
    final dx = (local.dx / size.width) * 2 - 1;
    final dy = (local.dy / size.height) * 2 - 1;
    setState(() => _tilt = Offset(dx.clamp(-1, 1), dy.clamp(-1, 1)));
  }

  void _reset() => setState(() => _tilt = Offset.zero);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          constraints.maxWidth,
          constraints.maxHeight.isFinite ? constraints.maxHeight : 200,
        );
        return MouseRegion(
          cursor: widget.onTap != null
              ? SystemMouseCursors.click
              : MouseCursor.defer,
          onHover: (e) => _update(e.localPosition, context.size ?? size),
          onExit: (_) => _reset(),
          child: GestureDetector(
            onTap: widget.onTap,
            onPanDown: (d) => _update(d.localPosition, context.size ?? size),
            onPanUpdate: (d) => _update(d.localPosition, context.size ?? size),
            onPanEnd: (_) => _reset(),
            onPanCancel: _reset,
            child: TweenAnimationBuilder<Offset>(
              tween: Tween(end: _tilt),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              builder: (context, t, child) {
                final m = Matrix4.identity()
                  ..setEntry(3, 2, 0.0015)
                  ..rotateX(-t.dy * widget.maxTilt)
                  ..rotateY(t.dx * widget.maxTilt);
                return Transform(
                  alignment: Alignment.center,
                  transform: m,
                  child: Stack(
                    children: [
                      child!,
                      // Moving specular highlight
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              gradient: RadialGradient(
                                center: Alignment(t.dx, t.dy),
                                radius: 1.1,
                                colors: [
                                  Colors.white.withValues(
                                    alpha: 0.10 * t.distance.clamp(0, 1),
                                  ),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

// ── GradientBackground ────────────────────────────────────────────────────────
// Navy canvas with slowly drifting colour blobs.
class GradientBackground extends StatefulWidget {
  final Widget child;
  final bool animate;

  const GradientBackground({
    super.key,
    required this.child,
    this.animate = true,
  });

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: FpColors.bg)),
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final t = _c.value * 2 * math.pi;
                return Stack(
                  children: [
                    _blob(
                      Alignment(
                        -0.9 + 0.25 * math.sin(t),
                        -0.85 + 0.15 * math.cos(t),
                      ),
                      FpColors.teal,
                      420,
                    ),
                    _blob(
                      Alignment(
                        0.95 + 0.2 * math.cos(t),
                        -0.2 + 0.25 * math.sin(t),
                      ),
                      FpColors.violet,
                      360,
                    ),
                    _blob(
                      Alignment(
                        -0.4 + 0.3 * math.cos(t + 1),
                        1.0 + 0.1 * math.sin(t),
                      ),
                      FpColors.lime,
                      320,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        Positioned.fill(child: widget.child),
      ],
    );
  }

  Widget _blob(Alignment a, Color c, double size) => Align(
    alignment: a,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [c.withValues(alpha: 0.22), c.withValues(alpha: 0)],
        ),
      ),
    ),
  );
}

// ── AnimatedRing ──────────────────────────────────────────────────────────────
// Gradient progress ring that fills up when it appears or its value changes.
class AnimatedRing extends StatelessWidget {
  final double progress; // 0..1
  final double size;
  final double stroke;
  final List<Color> colors;
  final Widget? child;
  final Duration duration;

  const AnimatedRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.stroke = 12,
    this.colors = const [FpColors.teal, FpColors.tealLight, FpColors.lime],
    this.child,
    this.duration = const Duration(milliseconds: 1400),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0, 1)),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(value, stroke, colors),
          child: Center(child: child),
        ),
      ),
      child: child,
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final double stroke;
  final List<Color> colors;

  _RingPainter(this.value, this.stroke, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2 + 4);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = Colors.white.withValues(alpha: 0.07);
    canvas.drawArc(arcRect, 0, 2 * math.pi, false, track);
    if (value <= 0) return;

    final sweep = 2 * math.pi * value;
    final shader = SweepGradient(
      startAngle: 0,
      endAngle: 2 * math.pi,
      colors: [...colors, colors.first],
      transform: const GradientRotation(-math.pi / 2),
    ).createShader(arcRect);

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke + 6
      ..strokeCap = StrokeCap.round
      ..shader = shader
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = shader;
    canvas.drawArc(arcRect, -math.pi / 2, sweep, false, glow);
    canvas.drawArc(arcRect, -math.pi / 2, sweep, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.stroke != stroke;
}

// ── CountUp ───────────────────────────────────────────────────────────────────
class CountUp extends StatelessWidget {
  final num value;
  final TextStyle style;
  final int decimals;
  final String suffix;
  final Duration duration;

  const CountUp({
    super.key,
    required this.value,
    required this.style,
    this.decimals = 0,
    this.suffix = '',
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) =>
          Text('${v.toStringAsFixed(decimals)}$suffix', style: style),
    );
  }
}

// ── GlassBottomNav ────────────────────────────────────────────────────────────
class GlassNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const GlassNavItem(this.icon, this.activeIcon, this.label);
}

class GlassBottomNav extends StatelessWidget {
  final int index;
  final List<GlassNavItem> items;
  final ValueChanged<int> onTap;

  const GlassBottomNav({
    super.key,
    required this.index,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 66,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: FpColors.surface.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Row(
                    children: List.generate(items.length, (i) {
                      final item = items[i];
                      final selected = i == index;
                      return Expanded(
                        child: Bounce(
                          onTap: () => onTap(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: selected
                                  ? LinearGradient(
                                      colors: [
                                        FpColors.teal.withValues(alpha: 0.28),
                                        FpColors.lime.withValues(alpha: 0.14),
                                      ],
                                    )
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  selected ? item.activeIcon : item.icon,
                                  size: 22,
                                  color: selected
                                      ? FpColors.lime
                                      : FpColors.muted,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: FpText.label(
                                    size: 10,
                                    color: selected
                                        ? FpColors.text
                                        : FpColors.faint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── FpAvatar ──────────────────────────────────────────────────────────────────
// DiceBear "adventurer" avatar inside an animated gradient ring.
class FpAvatar extends StatelessWidget {
  final String seed;
  final double size;
  final String fallbackInitial;
  final bool ring;

  const FpAvatar({
    super.key,
    required this.seed,
    this.size = 56,
    this.fallbackInitial = '',
    this.ring = true,
  });

  static String urlFor(String seed) =>
      'https://api.dicebear.com/9.x/adventurer/png?seed=${Uri.encodeComponent(seed)}&size=256';

  @override
  Widget build(BuildContext context) {
    final inner = ClipOval(
      child: Container(
        color: FpColors.surfaceHigh,
        child: Image.network(
          urlFor(seed),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Center(
            child: Text(
              fallbackInitial.isEmpty ? '🙂' : fallbackInitial,
              style: FpText.h2(color: FpColors.tealLight),
            ),
          ),
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: FpColors.teal,
                    ),
                  ),
                ),
        ),
      ),
    );
    if (!ring) return SizedBox(width: size, height: size, child: inner);
    return Container(
      width: size + 8,
      height: size + 8,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(
          colors: [
            FpColors.teal,
            FpColors.lime,
            FpColors.tealLight,
            FpColors.teal,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: FpColors.teal.withValues(alpha: 0.45),
            blurRadius: 18,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: FpColors.bg,
        ),
        child: inner,
      ),
    );
  }
}

// ── ExerciseImage ─────────────────────────────────────────────────────────────
// Shows the two free-exercise-db frames; when [animate] is on they alternate
// every ~0.8s so the movement reads like a short animation.
class ExerciseImage extends StatefulWidget {
  final Exercise exercise;
  final bool animate;
  final BoxFit fit;
  final double radius;

  const ExerciseImage({
    super.key,
    required this.exercise,
    this.animate = false,
    this.fit = BoxFit.cover,
    this.radius = 16,
  });

  @override
  State<ExerciseImage> createState() => _ExerciseImageState();
}

class _ExerciseImageState extends State<ExerciseImage> {
  Timer? _timer;
  int _frame = 0;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(ExerciseImage old) {
    super.didUpdateWidget(old);
    if (old.exercise.name != widget.exercise.name) {
      _frame = 0;
      _failed = false;
    }
    if (old.animate != widget.animate) _syncTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final second = widget.exercise.imageUrl(1);
    if (widget.animate && second != null) {
      precacheImage(NetworkImage(second), context, onError: (_, _) {});
    }
  }

  void _syncTimer() {
    _timer?.cancel();
    if (!widget.animate) return;
    _timer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (mounted && !_failed) setState(() => _frame = 1 - _frame);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.exercise.imageUrl(_frame);
    final placeholder = _Placeholder(exercise: widget.exercise);
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: url == null || _failed
          ? placeholder
          : Stack(
              fit: StackFit.expand,
              children: [
                placeholder,
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Image.network(
                    url,
                    key: ValueKey(url),
                    fit: widget.fit,
                    gaplessPlayback: true,
                    errorBuilder: (_, _, _) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && !_failed) {
                          setState(() => _failed = true);
                        }
                      });
                      return placeholder;
                    },
                    frameBuilder: (context, child, frame, sync) =>
                        frame == null && !sync ? const SizedBox() : child,
                  ),
                ),
              ],
            ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final Exercise exercise;
  const _Placeholder({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final c = FpColors.forCategory(exercise.category);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.withValues(alpha: 0.55), FpColors.surface],
        ),
      ),
      child: Center(
        child: Icon(
          exercise.icon,
          color: Colors.white.withValues(alpha: 0.8),
          size: 36,
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionTitle(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: FpText.h2(),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (action != null)
          Bounce(
            onTap: onAction,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Text(
                action!,
                style: FpText.label(color: FpColors.tealLight, size: 13),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Icon in a soft tinted square ──────────────────────────────────────────────
class TintIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const TintIcon(this.icon, {super.key, required this.color, this.size = 42});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.30),
            color.withValues(alpha: 0.10),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}
