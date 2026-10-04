import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'app_state.dart';
import 'gamification.dart';

// ── Public profile shown on the leaderboard ───────────────────────────────────
class FriendProfile {
  final String uid;
  final String name;
  final String avatarSeed;
  final int level;
  final int weeklyXp;
  final bool isMe;

  const FriendProfile({
    required this.uid,
    required this.name,
    required this.avatarSeed,
    required this.level,
    required this.weeklyXp,
    required this.isMe,
  });

  static FriendProfile fromDoc(String uid, Map<String, dynamic> d, bool isMe) {
    // Weekly XP from an older week no longer counts
    final sameWeek = d['weekKey'] == Gamification.weekKey();
    return FriendProfile(
      uid: uid,
      name: d['name'] as String? ?? 'Friend',
      avatarSeed: d['avatarSeed'] as String? ?? uid,
      level: (d['level'] as num?)?.toInt() ?? 1,
      weeklyXp: sameWeek ? (d['weeklyXp'] as num?)?.toInt() ?? 0 : 0,
      isMe: isMe,
    );
  }
}

// ── FriendsService ────────────────────────────────────────────────────────────
// Firestore layout (see firestore.rules):
//   inviteCodes/{code}      → { uid }                 readable by signed-in users
//   publicProfiles/{uid}    → { name, avatarSeed, level, xp, weeklyXp, weekKey,
//                               inviteCode, friends[] } readable by owner/friends
class FriendsService {
  static final _db = FirebaseFirestore.instance;
  // No 0/O or 1/I to avoid confusion when typing a code
  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static String _randomCode() {
    final r = Random.secure();
    return List.generate(
      6,
      (_) => _alphabet[r.nextInt(_alphabet.length)],
    ).join();
  }

  // Reserves a unique 6-char code. The rules only allow creating a code
  // document that doesn't exist yet, so a collision fails and we retry.
  static Future<String> claimInviteCode(String uid) async {
    for (var attempt = 0; attempt < 6; attempt++) {
      final code = _randomCode();
      try {
        await _db.collection('inviteCodes').doc(code).set({
          'uid': uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return code;
      } on FirebaseException catch (e) {
        if (e.code != 'permission-denied') rethrow;
      }
    }
    throw StateError('Could not reserve an invite code');
  }

  // Returns an error message, or null on success
  static Future<String?> addFriendByCode(AppState app, String rawCode) async {
    final me = app.uid;
    if (me == null) return 'Please sign in first.';
    final code = rawCode.trim().toUpperCase();
    if (code.length != 6) return 'Invite codes have 6 characters.';
    if (code == app.inviteCode) return 'That\'s your own code 🙂';

    try {
      final snap = await _db.collection('inviteCodes').doc(code).get();
      final friendUid = snap.data()?['uid'] as String?;
      if (friendUid == null) return 'No one found with that code.';
      if (app.friends.contains(friendUid)) return 'You\'re already friends!';

      // Both sides list each other, so each can read the other's card
      final batch = _db.batch()
        ..update(_db.collection('publicProfiles').doc(friendUid), {
          'friends': FieldValue.arrayUnion([me]),
        })
        ..update(_db.collection('publicProfiles').doc(me), {
          'friends': FieldValue.arrayUnion([friendUid]),
        });
      await batch.commit();
      app.setFriends([...app.friends, friendUid]);
      return null;
    } on FirebaseException catch (e) {
      debugPrint('addFriend failed: ${e.code} ${e.message}');
      if (e.code == 'not-found') {
        return 'Your friend needs to open FitPulse once first.';
      }
      return 'Could not add friend (${e.code}).';
    }
  }

  // Me + friends, sorted by this week's XP
  static Future<List<FriendProfile>> loadLeaderboard(AppState app) async {
    final me = app.uid;
    if (me == null) return [];

    // Pick up friends who added me since the app loaded
    final mine = await _db.collection('publicProfiles').doc(me).get();
    final friendIds = List<String>.from(
      mine.data()?['friends'] as List? ?? const [],
    );
    app.setFriends(friendIds);

    final profiles = <FriendProfile>[];
    if (mine.data() != null) {
      profiles.add(FriendProfile.fromDoc(me, mine.data()!, true));
    }
    final results = await Future.wait(
      friendIds.map((id) async {
        try {
          final d = await _db.collection('publicProfiles').doc(id).get();
          return d.data() == null
              ? null
              : FriendProfile.fromDoc(id, d.data()!, false);
        } on FirebaseException catch (e) {
          debugPrint('Could not read friend $id: ${e.code}');
          return null;
        }
      }),
    );
    profiles.addAll(results.whereType<FriendProfile>());
    profiles.sort((a, b) => b.weeklyXp.compareTo(a.weeklyXp));
    return profiles;
  }
}
