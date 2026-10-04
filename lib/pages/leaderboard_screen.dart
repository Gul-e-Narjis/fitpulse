import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../services/friends_service.dart';
import '../services/gamification.dart';
import '../theme/fp_theme.dart';
import '../theme/fp_widgets.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _code = TextEditingController();
  List<FriendProfile>? _board;
  String? _error;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final board = await FriendsService.loadLeaderboard(
        context.read<AppState>(),
      );
      if (!mounted) return;
      setState(() {
        _board = board;
        _error = null;
      });
    } catch (e) {
      debugPrint('Leaderboard load failed: $e');
      if (mounted) {
        setState(() {
          _board = [];
          _error = 'Could not load the leaderboard. Pull down to retry.';
        });
      }
    }
  }

  Future<void> _addFriend() async {
    if (_adding) return;
    final app = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _adding = true);
    final error = await FriendsService.addFriendByCode(app, _code.text);
    if (!mounted) return;
    setState(() => _adding = false);
    if (error == null) {
      _code.clear();
      FocusScope.of(context).unfocus();
      messenger.showSnackBar(const SnackBar(content: Text('Friend added! 🎉')));
      _load();
    } else {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final board = _board;
    final top = board == null ? <FriendProfile>[] : board.take(3).toList();
    final rest = board == null ? <FriendProfile>[] : board.skip(3).toList();

    return Scaffold(
      backgroundColor: FpColors.bg,
      body: GradientBackground(
        child: SafeArea(
          child: RefreshIndicator(
            color: FpColors.lime,
            backgroundColor: FpColors.surfaceHigh,
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(child: Text('Leaderboard', style: FpText.h1())),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: FpColors.lime.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'THIS WEEK',
                        style: FpText.label(color: FpColors.lime, size: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Podium ───────────────────────────
                if (board == null)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(color: FpColors.teal),
                    ),
                  )
                else if (top.isNotEmpty)
                  _Podium(top: top),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _error!,
                      style: FpText.muted(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (board != null && board.length <= 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Add friends with their invite code to compete on weekly XP!',
                      style: FpText.muted(size: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 16),

                // ── Rest of the list ─────────────────
                for (final (i, f) in rest.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _Row(rank: i + 4, profile: f),
                  ).animate().fadeIn(delay: (70 * i).ms).slideX(begin: 0.1),

                const SizedBox(height: 18),

                // ── My code ──────────────────────────
                const SectionTitle('Your invite code'),
                const SizedBox(height: 12),
                GlassCard(
                  glow: FpColors.teal,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          app.inviteCode ?? '······',
                          style: FpText.display(
                            size: 30,
                            color: FpColors.lime,
                          ).copyWith(letterSpacing: 6),
                        ),
                      ),
                      Bounce(
                        onTap: app.inviteCode == null
                            ? null
                            : () {
                                Clipboard.setData(
                                  ClipboardData(text: app.inviteCode!),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Code copied')),
                                );
                              },
                        child: const TintIcon(
                          Icons.copy_rounded,
                          color: FpColors.tealLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Share it with friends. They enter it below to join your board.',
                  style: FpText.muted(size: 12),
                ),
                const SizedBox(height: 22),

                // ── Add friend ───────────────────────
                const SectionTitle('Add a friend'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _code,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 6,
                        style: FpText.h3().copyWith(letterSpacing: 4),
                        onSubmitted: (_) => _addFriend(),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp('[A-Za-z0-9]'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          hintText: 'ABC123',
                          counterText: '',
                          prefixIcon: Icon(
                            Icons.person_add_alt_1_rounded,
                            color: FpColors.tealLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GlowButton(
                      label: _adding ? '…' : 'Add',
                      expand: false,
                      height: 52,
                      onTap: _adding ? null : _addFriend,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Podium: 2nd · 1st · 3rd, rising up ────────────────────────────────────────
class _Podium extends StatelessWidget {
  final List<FriendProfile> top;
  const _Podium({required this.top});

  @override
  Widget build(BuildContext context) {
    // Display order: 2nd, 1st, 3rd
    final slots = <(int, FriendProfile)>[
      if (top.length > 1) (2, top[1]),
      (1, top[0]),
      if (top.length > 2) (3, top[2]),
    ];
    return SizedBox(
      height: 270,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final (rank, p) in slots)
            Expanded(
              child: _PodiumSlot(rank: rank, profile: p),
            ),
        ],
      ),
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  final int rank;
  final FriendProfile profile;
  const _PodiumSlot({required this.rank, required this.profile});

  static const _heights = {1: 130.0, 2: 96.0, 3: 72.0};
  static const _colors = {
    1: FpColors.amber,
    2: Color(0xFFCBD5E1),
    3: Color(0xFFFB923C),
  };
  static const _medals = {1: '🥇', 2: '🥈', 3: '🥉'};

  @override
  Widget build(BuildContext context) {
    final color = _colors[rank]!;
    final delay = {1: 500, 2: 250, 3: 0}[rank]!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (rank == 1)
            const Text('👑', style: TextStyle(fontSize: 26))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: -4, duration: 900.ms),
          FpAvatar(seed: profile.avatarSeed, size: rank == 1 ? 64 : 50)
              .animate()
              .fadeIn(delay: (delay + 300).ms)
              .scaleXY(begin: 0.4, curve: Curves.easeOutBack),
          const SizedBox(height: 6),
          Text(
            profile.isMe ? 'You' : profile.name.split(' ')[0],
            style: FpText.h3().copyWith(fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${profile.weeklyXp} XP',
            style: FpText.label(color: color, size: 11),
          ),
          const SizedBox(height: 6),
          Container(
                height: _heights[rank],
                width: double.infinity,
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withValues(alpha: 0.45),
                      color.withValues(alpha: 0.08),
                    ],
                  ),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
                child: Text(
                  _medals[rank]!,
                  style: const TextStyle(fontSize: 26),
                ),
              )
              .animate()
              .slideY(
                begin: 1,
                delay: delay.ms,
                duration: 600.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(delay: delay.ms),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final int rank;
  final FriendProfile profile;
  const _Row({required this.rank, required this.profile});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      gradient: profile.isMe
          ? LinearGradient(
              colors: [
                FpColors.teal.withValues(alpha: 0.22),
                FpColors.lime.withValues(alpha: 0.06),
              ],
            )
          : null,
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('$rank', style: FpText.h3(color: FpColors.muted)),
          ),
          FpAvatar(seed: profile.avatarSeed, size: 40, ring: false),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.isMe ? '${profile.name} (you)' : profile.name,
                  style: FpText.h3(),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Lv ${profile.level} · ${Gamification.levelName(profile.level)}',
                  style: FpText.muted(size: 12),
                ),
              ],
            ),
          ),
          Text(
            '${profile.weeklyXp} XP',
            style: FpText.number(size: 15, color: FpColors.lime),
          ),
        ],
      ),
    );
  }
}
