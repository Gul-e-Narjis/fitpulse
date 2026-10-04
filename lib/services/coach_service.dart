import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import 'app_state.dart';

class CoachMessage {
  final String role; // 'user' or 'model'
  final String text;
  final int ts;

  const CoachMessage({
    required this.role,
    required this.text,
    required this.ts,
  });

  bool get isUser => role == 'user';
}

// ── CoachService ──────────────────────────────────────────────────────────────
// Gemini via Firebase AI Logic (Gemini Developer API, free tier).
// Conversation is stored in users/{uid}/coachChats.
class CoachService {
  static const modelName = 'gemini-2.5-flash';
  static const _historyLimit = 40;

  final AppState app;
  ChatSession? _chat;

  CoachService(this.app);

  CollectionReference<Map<String, dynamic>> get _chats => FirebaseFirestore
      .instance
      .collection('users')
      .doc(app.uid)
      .collection('coachChats');

  Future<List<CoachMessage>> loadHistory() async {
    if (app.uid == null) return [];
    try {
      final snap = await _chats
          .orderBy('ts', descending: true)
          .limit(_historyLimit)
          .get();
      return snap.docs
          .map((d) => d.data())
          .map(
            (m) => CoachMessage(
              role: m['role'] as String? ?? 'model',
              text: m['text'] as String? ?? '',
              ts: (m['ts'] as num?)?.toInt() ?? 0,
            ),
          )
          .toList()
          .reversed
          .toList();
    } catch (e) {
      debugPrint('Coach history load failed: $e');
      return [];
    }
  }

  Future<void> _store(CoachMessage m) async {
    if (app.uid == null) return;
    try {
      await _chats.add({
        'role': m.role,
        'text': m.text,
        'ts': m.ts,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Coach message save failed: $e');
    }
  }

  void _startChat(List<CoachMessage> history) {
    final model = FirebaseAI.googleAI().generativeModel(
      model: modelName,
      systemInstruction: Content.system(_systemPrompt()),
      generationConfig: GenerationConfig(temperature: 0.7),
    );
    _chat = model.startChat(
      history: [
        for (final m in history.where((m) => m.text.isNotEmpty))
          m.isUser ? Content.text(m.text) : Content.model([TextPart(m.text)]),
      ],
    );
  }

  // Streams the reply text as it grows. Saves both messages when done.
  Stream<String> send(String text, List<CoachMessage> history) async* {
    if (_chat == null) _startChat(history);
    await _store(
      CoachMessage(
        role: 'user',
        text: text,
        ts: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    final buffer = StringBuffer();
    await for (final chunk in _chat!.sendMessageStream(Content.text(text))) {
      final part = chunk.text;
      if (part == null || part.isEmpty) continue;
      buffer.write(part);
      yield buffer.toString();
    }
    await _store(
      CoachMessage(
        role: 'model',
        text: buffer.toString(),
        ts: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  String _systemPrompt() {
    final recent = app.workoutHistory
        .take(5)
        .map(
          (s) =>
              '- ${s.date}: ${s.category}, ${(s.durationSeconds / 60).toStringAsFixed(0)} min, '
              '${s.exercisesCompleted} exercises, ${s.caloriesBurned.toStringAsFixed(0)} kcal'
              '${s.partial ? ' (ended early)' : ''}',
        )
        .join('\n');
    return '''
You are "Pulse", the friendly AI fitness coach inside the FitPulse app.

About the user:
- Name: ${app.userName}
- Goal: ${app.fitnessGoal}
- Fitness level: ${app.fitnessLevel}
- Age: ${app.userAge}, weight: ${app.userWeight.toStringAsFixed(0)} kg, height: ${app.userHeight.toStringAsFixed(0)} cm
- Plans to train ${app.weeklyGoal} days per week
- Current streak: ${app.currentStreak} days, level ${app.level} (${app.levelName}), ${app.totalWorkoutsCompleted} workouts so far
- Recent workouts:
${recent.isEmpty ? '- none yet' : recent}

The app has these workout categories: Cardio, Arm, Leg, Core, Full Body.

How to respond:
- Be encouraging, practical and concise (under ~180 words unless asked for a full plan).
- Use short paragraphs or bullet lists. Tailor advice to the user's goal and level.
- You give general fitness, exercise-technique, habit and general healthy-eating guidance only.
- Never give medical advice: do not diagnose, treat, or advise on injuries, pain, illnesses, medications, pregnancy or eating disorders. For those, kindly say you can't help with medical questions and suggest seeing a doctor or qualified professional.
- If the user mentions chest pain, dizziness, fainting or severe pain, tell them to stop exercising and seek medical help.
''';
  }

  // Friendly text for errors such as Firebase AI Logic not being enabled
  static String describeError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('api has not been used') ||
        msg.contains('not enabled') ||
        msg.contains('permission') ||
        msg.contains('403')) {
      return 'The AI coach isn\'t switched on yet. Enable Firebase AI Logic '
          '(Gemini Developer API) in the Firebase console and try again.';
    }
    if (msg.contains('quota') || msg.contains('429')) {
      return 'The coach is a little busy right now (free quota reached). '
          'Please try again in a minute.';
    }
    if (msg.contains('network') || msg.contains('failed to fetch')) {
      return 'No connection. Check your internet and try again.';
    }
    return 'Sorry, something went wrong. Please try again.';
  }
}
