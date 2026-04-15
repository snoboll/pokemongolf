import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/battle_models.dart';

class BattleService {
  BattleService() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  String? get currentUserId => _client.auth.currentUser?.id;

  // ── Fetch ─────────────────────────────────────────────────────────────────

  /// Returns all battles where the current user is challenger or opponent,
  /// plus all pending battles (open invites from other golfers).
  Future<List<Battle>> fetchBattles() async {
    final uid = currentUserId;
    if (uid == null) return [];

    final rows = await _client
        .from('battles')
        .select()
        .order('created_at', ascending: false);

    return rows
        .map((r) => Battle.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<Battle> fetchBattle(String battleId) async {
    final row = await _client
        .from('battles')
        .select()
        .eq('id', battleId)
        .single();

    return Battle.fromJson(Map<String, dynamic>.from(row));
  }

  // ── Create ────────────────────────────────────────────────────────────────

  Future<Battle> createBattle({
    required String courseId,
    required String courseName,
    required int holeCount,
    required List<int> coursePars,
    required List<BattleBogeybeast> team,
    required String challengerName,
  }) async {
    final uid = currentUserId!;

    final row = await _client.from('battles').insert({
      'course_id':       courseId,
      'course_name':     courseName,
      'hole_count':      holeCount,
      'course_pars':     coursePars,
      'challenger_id':   uid,
      'challenger_name': challengerName,
      'challenger_team': team.map((p) => p.toJson()).toList(),
      'status':          'pending',
    }).select().single();

    return Battle.fromJson(Map<String, dynamic>.from(row));
  }

  // ── Join ──────────────────────────────────────────────────────────────────

  Future<Battle> joinBattle({
    required String battleId,
    required List<BattleBogeybeast> team,
  }) async {
    final result = await _client.rpc(
      'join_battle',
      params: {
        'p_battle_id': battleId,
        'p_team':      team.map((p) => p.toJson()).toList(),
      },
    );

    return Battle.fromJson(Map<String, dynamic>.from(result as Map));
  }

  // ── Save scorecard ────────────────────────────────────────────────────────

  /// Saves a completed battle as a `round_type='battle'` scorecard in the
  /// `rounds` + `hole_results` tables so it appears in Scorecards history.
  Future<void> insertBattleRound({
    required Battle battle,
    required bool isChallenger,
  }) async {
    final scores = isChallenger ? battle.challengerScores : battle.opponentScores;
    if (scores.isEmpty) return;

    final roundRow = await _client.from('rounds').insert({
      'hole_count':   battle.holeCount,
      'completed_at': (battle.completedAt ?? DateTime.now()).toUtc().toIso8601String(),
      'round_type':   'battle',
      'course_name':  battle.courseName,
    }).select().single();

    final roundId = roundRow['id'] as String;

    String scoreName(int strokes, int par) {
      final d = strokes - par;
      if (d <= -3) return 'albatross';
      return switch (d) {
        -2 => 'eagle',
        -1 => 'birdie',
         0 => 'par',
         1 => 'bogey',
         2 => 'doubleBogey',
         _ => 'tripleOrWorse',
      };
    }

    final holeRows = scores.entries.map((e) {
      final hole    = e.key;
      final strokes = e.value;
      final par     = battle.parForHole(hole);
      return <String, dynamic>{
        'round_id':    roundId,
        'hole_number': hole,
        'par':         par,
        'strokes':     strokes,
        'score':       scoreName(strokes, par),
        'catch_chance': 0,
        'caught':      false,
        'bogeybeast_dex': 0,
        'on_putt':     false,
        'bunker':      false,
        'water':       false,
        'rough':       false,
      };
    }).toList();

    await _client.from('hole_results').insert(holeRows);
  }

  // ── Submit score ──────────────────────────────────────────────────────────

  Future<Battle> submitHoleScore({
    required String battleId,
    required int hole,
    required int strokes,
  }) async {
    final result = await _client.rpc(
      'submit_battle_score',
      params: {
        'p_battle_id': battleId,
        'p_hole':      hole,
        'p_strokes':   strokes,
      },
    );

    return Battle.fromJson(Map<String, dynamic>.from(result as Map));
  }

  // ── Leader challenges ──────────────────────────────────────────────────────

  Future<Battle> createLeaderChallenge({
    required String courseId,
    required String courseName,
    required int holeCount,
    required List<int> coursePars,
    required List<BattleBogeybeast> team,
    required String challengerName,
    required String leaderName,
    required List<BattleBogeybeast> leaderTeam,
    required int leaderHcp,
    String? leaderUserId,
  }) async {
    final uid = currentUserId!;

    final row = await _client.from('battles').insert({
      'course_id':            courseId,
      'course_name':          courseName,
      'hole_count':           holeCount,
      'course_pars':          coursePars,
      'challenger_id':        uid,
      'challenger_name':      challengerName,
      'challenger_team':      team.map((p) => p.toJson()).toList(),
      'opponent_id':          leaderUserId,
      'opponent_name':        leaderName,
      'opponent_team':        leaderTeam.map((p) => p.toJson()).toList(),
      'is_leader_challenge':  true,
      'leader_hcp':           leaderHcp,
      'status':               'active',
    }).select().single();

    return Battle.fromJson(Map<String, dynamic>.from(row));
  }

  Future<Battle> submitLeaderChallengeScore({
    required String battleId,
    required int hole,
    required int strokes,
  }) async {
    final result = await _client.rpc(
      'submit_leader_challenge_score',
      params: {
        'p_battle_id': battleId,
        'p_hole':      hole,
        'p_strokes':   strokes,
      },
    );

    return Battle.fromJson(Map<String, dynamic>.from(result as Map));
  }

  Future<void> claimEvolutionReward(String battleId) async {
    await _client
        .from('battles')
        .update({'evolution_claimed': true})
        .eq('id', battleId);
  }

  Future<Map<String, dynamic>> claimCourseLeadership({
    required String courseId,
    required String battleId,
    required List<BattleBogeybeast> defenderTeam,
  }) async {
    final result = await _client.rpc(
      'claim_course_leadership',
      params: {
        'p_course_id':  courseId,
        'p_battle_id':  battleId,
        'p_team':       defenderTeam.map((p) => p.toJson()).toList(),
      },
    );

    return Map<String, dynamic>.from(result as Map);
  }
}
