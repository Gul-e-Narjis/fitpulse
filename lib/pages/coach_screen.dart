import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../services/coach_service.dart';
import '../theme/fp_theme.dart';
import '../theme/fp_widgets.dart';

class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  late final CoachService _coach = CoachService(context.read<AppState>());
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<CoachMessage> _messages = [];
  bool _loading = true;
  bool _waiting = false; // sent, no reply text yet
  bool _streaming = false;

  static const _suggestions = [
    '📅 Plan my week',
    '⚡ Quick 10-min workout',
    '🏋️ How do I improve my squat?',
    '🥗 What should I eat after training?',
  ];

  @override
  void initState() {
    super.initState();
    _coach.loadHistory().then((h) {
      if (!mounted) return;
      setState(() {
        _messages.addAll(h);
        _loading = false;
      });
      _scrollToEnd(jump: true);
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final end = _scroll.position.maxScrollExtent;
      jump
          ? _scroll.jumpTo(end)
          : _scroll.animateTo(
              end,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
    });
  }

  Future<void> _send(String raw) async {
    // Suggestion chips start with an emoji — drop it before sending
    final text = raw.trim().replaceFirst(RegExp(r'^[^\w\s]+\s*'), '');
    if (text.isEmpty || _waiting || _streaming) return;
    final history = List<CoachMessage>.from(_messages);
    _input.clear();
    setState(() {
      _messages.add(
        CoachMessage(
          role: 'user',
          text: text,
          ts: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      _waiting = true;
    });
    _scrollToEnd();

    try {
      var started = false;
      await for (final partial in _coach.send(text, history)) {
        if (!mounted) return;
        setState(() {
          if (!started) {
            started = true;
            _waiting = false;
            _streaming = true;
            _messages.add(CoachMessage(role: 'model', text: partial, ts: 0));
          } else {
            _messages[_messages.length - 1] = CoachMessage(
              role: 'model',
              text: partial,
              ts: 0,
            );
          }
        });
        _scrollToEnd();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          CoachMessage(
            role: 'model',
            text: '⚠️ ${CoachService.describeError(e)}',
            ts: 0,
          ),
        );
      });
      _scrollToEnd();
    } finally {
      if (mounted) {
        setState(() {
          _waiting = false;
          _streaming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstName = context.watch<AppState>().userName.split(' ')[0];
    return Scaffold(
      backgroundColor: FpColors.bg,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 6),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const _CoachOrb(size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pulse · AI Coach', style: FpText.h3()),
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: FpColors.lime,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _waiting || _streaming ? 'typing…' : 'online',
                                style: FpText.muted(size: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Messages ──────────────────────────
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: FpColors.teal),
                      )
                    : ListView(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        children: [
                          if (_messages.isEmpty) _Welcome(name: firstName),
                          for (final m in _messages) _Bubble(message: m),
                          if (_waiting) const _TypingBubble(),
                        ],
                      ),
              ),

              // ── Suggestions ───────────────────────
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => Bounce(
                    onTap: () => _send(_suggestions[i]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: FpColors.teal.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        _suggestions[i],
                        style: FpText.label(color: FpColors.text, size: 12),
                      ),
                    ),
                  ).animate().fadeIn(delay: (80 * i).ms).slideX(begin: 0.2),
                ),
              ),
              const SizedBox(height: 8),

              // ── Input ─────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                child: GlassCard(
                  radius: 26,
                  padding: const EdgeInsets.fromLTRB(16, 4, 6, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _input,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: _send,
                          style: FpText.body(),
                          decoration: InputDecoration(
                            hintText: 'Ask your coach anything…',
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintStyle: FpText.muted(),
                          ),
                        ),
                      ),
                      Bounce(
                        onTap: () => _send(_input.text),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: FpColors.accentGradient,
                          ),
                          child: const Icon(
                            Icons.arrow_upward_rounded,
                            color: FpColors.bgDeep,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'General fitness guidance only — not medical advice.',
                  style: FpText.muted(size: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pieces ────────────────────────────────────────────────────────────────────
class _CoachOrb extends StatelessWidget {
  final double size;
  const _CoachOrb({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(
          colors: [
            FpColors.teal,
            FpColors.lime,
            FpColors.violet,
            FpColors.teal,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: FpColors.teal.withValues(alpha: 0.5),
            blurRadius: 16,
          ),
        ],
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        color: FpColors.bgDeep,
        size: size * 0.5,
      ),
    ).animate(onPlay: (c) => c.repeat()).rotate(duration: 8.seconds);
  }
}

class _Welcome extends StatelessWidget {
  final String name;
  const _Welcome({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          const _CoachOrb(size: 72),
          const SizedBox(height: 18),
          Text(
            'Hi $name, I\'m Pulse 👋',
            style: FpText.h2(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me about workouts, technique, motivation or building a plan. '
            'I know your goal and recent workouts.',
            style: FpText.muted(size: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
    );
  }
}

class _Bubble extends StatelessWidget {
  final CoachMessage message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.8;
    final bubble = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth.clamp(200, 560)),
      child: isUser
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                gradient: FpColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: Text(
                message.text,
                style: FpText.body(color: FpColors.bgDeep),
              ),
            )
          : GlassCard(
              radius: 20,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text.rich(_formatted(message.text), style: FpText.body()),
            ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: bubble,
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.15);
  }

  // Minimal markdown: **bold** and "* " / "- " bullets
  static TextSpan _formatted(String text) {
    final lines = text
        .split('\n')
        .map((l) {
          final m = RegExp(r'^(\s*)[*-]\s+').firstMatch(l);
          return m == null ? l : '${m.group(1)}• ${l.substring(m.end)}';
        })
        .join('\n');
    final spans = <TextSpan>[];
    final bold = RegExp(r'\*\*(.+?)\*\*');
    var last = 0;
    for (final m in bold.allMatches(lines)) {
      spans.add(TextSpan(text: lines.substring(last, m.start)));
      spans.add(
        TextSpan(
          text: m.group(1),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: FpColors.lime,
          ),
        ),
      );
      last = m.end;
    }
    spans.add(TextSpan(text: lines.substring(last)));
    return TextSpan(children: spans);
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GlassCard(
        radius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: const BoxDecoration(
                    color: FpColors.tealLight,
                    shape: BoxShape.circle,
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                  begin: 3,
                  end: -3,
                  delay: (150 * i).ms,
                  duration: 450.ms,
                  curve: Curves.easeInOut,
                );
          }),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
