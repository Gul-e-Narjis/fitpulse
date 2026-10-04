import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../services/gamification.dart';
import '../theme/fp_theme.dart';
import '../theme/fp_widgets.dart';

// ── BadgeCelebrator ───────────────────────────────────────────────────────────
// Wrap a screen with this; whenever AppState has a newly earned badge it
// shows a confetti popup, one badge at a time.
class BadgeCelebrator extends StatefulWidget {
  final Widget child;
  const BadgeCelebrator({super.key, required this.child});

  @override
  State<BadgeCelebrator> createState() => _BadgeCelebratorState();
}

class _BadgeCelebratorState extends State<BadgeCelebrator> {
  bool _showing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeShow();
  }

  void _maybeShow() {
    final app = context.watch<AppState>();
    if (app.pendingBadge == null || _showing) return;
    _showing = true;
    _showWhenHomeVisible(app);
  }

  // Badges are usually earned on the workout screen; wait until the user is
  // back on Home with no dialog or page on top before celebrating.
  Future<void> _showWhenHomeVisible(AppState app) async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      if (ModalRoute.of(context)?.isCurrent ?? true) break;
    }
    if (!mounted) return;
    final id = app.pendingBadge;
    final badge = id == null ? null : Badges.byId(id);
    if (badge == null) {
      _showing = false;
      if (id != null) app.consumePendingBadge();
      return;
    }
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'badge',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, _, _) => _BadgePopup(badge: badge),
      transitionBuilder: (_, a, _, child) => ScaleTransition(
        scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: a, child: child),
      ),
    );
    if (!mounted) return;
    _showing = false;
    // Shows the next queued badge, if any, via didChangeDependencies
    app.consumePendingBadge();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>(); // rebuild → didChangeDependencies on new badges
    return widget.child;
  }
}

class _BadgePopup extends StatefulWidget {
  final BadgeDef badge;
  const _BadgePopup({required this.badge});

  @override
  State<_BadgePopup> createState() => _BadgePopupState();
}

class _BadgePopupState extends State<_BadgePopup> {
  late final ConfettiController _confetti = ConfettiController(
    duration: const Duration(seconds: 2),
  )..play();

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.badge;
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 300,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              decoration: BoxDecoration(
                color: FpColors.surfaceHigh,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: b.color.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: b.color.withValues(alpha: 0.35),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'NEW BADGE UNLOCKED',
                    style: FpText.label(color: b.color),
                  ),
                  const SizedBox(height: 16),
                  _BadgeMedal(badge: b, size: 110, unlocked: true)
                      .animate()
                      .scale(curve: Curves.elasticOut, duration: 1200.ms)
                      .then()
                      .shimmer(duration: 1200.ms, color: Colors.white54),
                  const SizedBox(height: 16),
                  Text(
                    b.title,
                    style: FpText.h1(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    b.description,
                    style: FpText.muted(size: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  GlowButton(
                    label: 'Awesome!',
                    height: 46,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirection: math.pi / 2,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 30,
            emissionFrequency: 0.06,
            gravity: 0.25,
            colors: const [
              FpColors.lime,
              FpColors.teal,
              FpColors.tealLight,
              FpColors.amber,
              FpColors.violet,
              FpColors.coral,
            ],
          ),
        ),
      ],
    );
  }
}

// ── Medal ─────────────────────────────────────────────────────────────────────
class _BadgeMedal extends StatelessWidget {
  final BadgeDef badge;
  final double size;
  final bool unlocked;

  const _BadgeMedal({
    required this.badge,
    required this.size,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    final medal = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: unlocked
            ? RadialGradient(
                colors: [
                  badge.color.withValues(alpha: 0.55),
                  badge.color.withValues(alpha: 0.12),
                ],
              )
            : null,
        color: unlocked ? null : Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: unlocked
              ? badge.color.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.10),
          width: 2,
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: badge.color.withValues(alpha: 0.35),
                  blurRadius: size * 0.2,
                ),
              ]
            : null,
      ),
      child: Text(badge.emoji, style: TextStyle(fontSize: size * 0.42)),
    );
    if (unlocked) return medal;
    // Locked badges render greyed out
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        0.2126, 0.7152, 0.0722, 0, 0, //
        0.2126, 0.7152, 0.0722, 0, 0, //
        0.2126, 0.7152, 0.0722, 0, 0, //
        0, 0, 0, 0.35, 0,
      ]),
      child: medal,
    );
  }
}

// ── Level card (XP progress) ──────────────────────────────────────────────────
class LevelCard extends StatelessWidget {
  final bool compact;
  const LevelCard({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final maxed = app.level >= Gamification.levelThresholds.length;
    return GlassCard(
      glow: FpColors.lime,
      padding: EdgeInsets.all(compact ? 14 : 18),
      child: Row(
        children: [
          Container(
            width: compact ? 46 : 56,
            height: compact ? 46 : 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: FpColors.accentGradient,
              boxShadow: [
                BoxShadow(
                  color: FpColors.lime.withValues(alpha: 0.4),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Text(
              '${app.level}',
              style: FpText.number(
                size: compact ? 20 : 24,
                color: FpColors.bgDeep,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Level ${app.level} · ${app.levelName}',
                        style: FpText.h3(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${app.xp} XP',
                      style: FpText.label(color: FpColors.lime, size: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: app.levelProgress),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, _) => Stack(
                      children: [
                        Container(
                          height: 10,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        FractionallySizedBox(
                          widthFactor: v.clamp(0.0, 1.0),
                          child: Container(
                            height: 10,
                            decoration: const BoxDecoration(
                              gradient: FpColors.accentGradient,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  maxed
                      ? 'Max level reached — you\'re a Legend!'
                      : '${app.xpToNextLevel} XP to Level ${app.level + 1} · ${Gamification.levelName(app.level + 1)}',
                  style: FpText.muted(size: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badges grid (locked = grey) ───────────────────────────────────────────────
class BadgesGrid extends StatelessWidget {
  const BadgesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final earned = context.watch<AppState>().earnedBadgeIds;
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 92,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 0.78,
        ),
        itemCount: Badges.all.length,
        itemBuilder: (context, i) {
          final b = Badges.all[i];
          final unlocked = earned.contains(b.id);
          return Tooltip(
            message: '${b.title}: ${b.description}',
            child: Column(
              children: [
                _BadgeMedal(badge: b, size: 54, unlocked: unlocked),
                const SizedBox(height: 6),
                Text(
                  b.title,
                  style: FpText.label(
                    size: 10,
                    color: unlocked ? FpColors.text : FpColors.faint,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ).animate().fadeIn(delay: (40 * i).ms).scaleXY(begin: 0.8);
        },
      ),
    );
  }
}
