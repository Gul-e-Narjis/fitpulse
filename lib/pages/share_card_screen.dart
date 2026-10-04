import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../services/exercise_data.dart';
import '../services/share_helper.dart' as share;
import '../theme/fp_theme.dart';
import '../theme/fp_widgets.dart';

// ── Share card: workout summary exported as a PNG ─────────────────────────────
class ShareCardScreen extends StatefulWidget {
  final WorkoutSession session;
  const ShareCardScreen({super.key, required this.session});

  @override
  State<ShareCardScreen> createState() => _ShareCardScreenState();
}

class _ShareCardScreenState extends State<ShareCardScreen> {
  final _cardKey = GlobalKey();
  bool _busy = false;

  Future<ui.Image?> _capture() async {
    final boundary =
        _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    return boundary.toImage(pixelRatio: 3);
  }

  Future<void> _export({required bool shareIt}) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final image = await _capture();
      final data = await image?.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('Could not render the card');
      final bytes = data.buffer.asUint8List();
      final name =
          'fitpulse-${widget.session.date}-${widget.session.category.toLowerCase().replaceAll(' ', '-')}.png';
      if (shareIt) {
        final shared = await share.sharePng(
          bytes,
          name,
          'Just finished a ${widget.session.category} workout on FitPulse 💪',
        );
        if (!shared) {
          share.downloadPng(bytes, name);
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Sharing isn\'t available here — image downloaded'),
            ),
          );
        }
      } else {
        share.downloadPng(bytes, name);
        messenger.showSnackBar(const SnackBar(content: Text('Image saved ✓')));
      }
    } catch (e) {
      debugPrint('Share card export failed: $e');
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not create the image')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canShare = share.canShareFiles;
    return Scaffold(
      backgroundColor: FpColors.bg,
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text('Share your workout', style: FpText.h2()),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: _SummaryCard(session: widget.session),
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms).scaleXY(begin: 0.92),
              const SizedBox(height: 24),
              if (canShare) ...[
                GlowButton(
                  label: 'Share',
                  icon: Icons.ios_share_rounded,
                  onTap: _busy ? null : () => _export(shareIt: true),
                ),
                const SizedBox(height: 12),
              ],
              GlowButton(
                label: 'Download PNG',
                icon: Icons.download_rounded,
                gradient: canShare
                    ? LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.12),
                          Colors.white.withValues(alpha: 0.06),
                        ],
                      )
                    : FpColors.accentGradient,
                textColor: canShare ? FpColors.text : FpColors.bgDeep,
                onTap: _busy ? null : () => _export(shareIt: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final WorkoutSession session;
  const _SummaryCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final color = FpColors.forCategory(session.category);
    final minutes = session.durationSeconds / 60;
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              FpColors.bgDeep,
              Color.lerp(FpColors.bg, color, 0.35)!,
              FpColors.tealDeep,
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -60,
              top: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      FpColors.lime.withValues(alpha: 0.30),
                      FpColors.lime.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: FpColors.accentGradient,
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          size: 16,
                          color: FpColors.bgDeep,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('FitPulse', style: FpText.h3()),
                      const Spacer(),
                      Text(session.date, style: FpText.label(size: 11)),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      FpAvatar(seed: app.avatarSeed, size: 54),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.userName,
                              style: FpText.h3(),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Level ${app.level} · ${app.levelName}',
                              style: FpText.label(color: FpColors.lime),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        ExerciseDataService.getCategoryIcon(session.category),
                        color: color,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${session.category} Workout',
                          style: FpText.display(size: 26),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (session.partial)
                    Text(
                      'Ended early — still counts!',
                      style: FpText.muted(size: 12),
                    ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _Stat(
                        value: minutes < 10
                            ? minutes.toStringAsFixed(1)
                            : minutes.round().toString(),
                        label: 'MINUTES',
                        color: FpColors.sky,
                      ),
                      _Stat(
                        value: session.caloriesBurned.round().toString(),
                        label: 'KCAL',
                        color: FpColors.coral,
                      ),
                      _Stat(
                        value: '${session.exercisesCompleted}',
                        label: 'EXERCISES',
                        color: FpColors.tealLight,
                      ),
                      _Stat(
                        value: '${app.currentStreak}🔥',
                        label: 'STREAK',
                        color: FpColors.amber,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _Stat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: FpText.number(size: 22, color: color)),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(label, style: FpText.label(size: 9)),
          ),
        ],
      ),
    );
  }
}
