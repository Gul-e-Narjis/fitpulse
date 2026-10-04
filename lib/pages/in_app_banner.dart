import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/notification_center.dart';
import '../theme/fp_theme.dart';

// ── Glass banner that slides down from the top for new notifications ────────
// Placed above the Navigator (MaterialApp.builder) so it shows on any screen.
class InAppBannerHost extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  final String notificationsRoute;

  const InAppBannerHost({
    super.key,
    required this.child,
    required this.navigatorKey,
    this.notificationsRoute = '/notifications',
  });

  @override
  State<InAppBannerHost> createState() => _InAppBannerHostState();
}

class _InAppBannerHostState extends State<InAppBannerHost> {
  AppNotification? _shown;
  bool _visible = false;
  Timer? _hideTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = context.watch<NotificationCenter>().currentBanner;
    if (next != null && next.id != _shown?.id) _show(next);
  }

  void _show(AppNotification n) {
    _hideTimer?.cancel();
    setState(() {
      _shown = n;
      _visible = true;
    });
    _hideTimer = Timer(const Duration(milliseconds: 4500), _hide);
  }

  void _hide() {
    if (!mounted || !_visible) return;
    setState(() => _visible = false);
    // Let the slide-out finish, then show the next queued banner (if any)
    Future.delayed(const Duration(milliseconds: 380), () {
      if (mounted) context.read<NotificationCenter>().dismissBanner();
    });
  }

  void _open() {
    final n = _shown;
    _hide();
    if (n == null) return;
    context.read<NotificationCenter>().markRead(n.id);
    widget.navigatorKey.currentState?.pushNamed(widget.notificationsRoute);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = _shown;
    return Stack(
      children: [
        widget.child,
        if (n != null)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SafeArea(
              bottom: false,
              child: AnimatedSlide(
                offset: _visible ? Offset.zero : const Offset(0, -1.4),
                duration: const Duration(milliseconds: 380),
                curve: _visible ? Curves.easeOutBack : Curves.easeIn,
                child: AnimatedOpacity(
                  opacity: _visible ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                        child: GestureDetector(
                          onTap: _open,
                          onVerticalDragEnd: (d) {
                            if ((d.primaryVelocity ?? 0) < 0) _hide();
                          },
                          child: _BannerCard(notification: n, onClose: _hide),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onClose;
  const _BannerCard({required this.notification, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final n = notification;
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
            BoxShadow(color: n.color.withValues(alpha: 0.25), blurRadius: 24),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: FpColors.surfaceHigh.withValues(alpha: 0.78),
                border: Border.all(color: n.color.withValues(alpha: 0.45)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: n.color.withValues(alpha: 0.18),
                    ),
                    child: Icon(n.icon, color: n.color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.title,
                          style: FpText.h3().copyWith(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          n.body,
                          style: FpText.muted(size: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Dismiss',
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: FpColors.muted,
                    ),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
