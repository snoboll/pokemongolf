import '../data/bogeybeast_battle_stats.dart';
import '../data/type_effectiveness.dart';
import '../data/first_gen_bogeybeasts.dart';
import 'bogeybeast_type.dart';

// ── BattleBogeybeast ────────────────────────────────────────────────────────────

class BattleBogeybeast {
  BattleBogeybeast({
    required this.dexNumber,
    required this.name,
    required this.types,
    required this.hpMax,
    required this.hpCurrent,
    required this.offenseTier,
    required this.defenseTier,
  });

  final int dexNumber;
  final String name;
  final List<BogeybeastType> types;
  final int hpMax;
  int hpCurrent;
  final int offenseTier;
  final int defenseTier;

  bool get isAlive => hpCurrent > 0;
  double get hpPercent => hpCurrent / hpMax;

  String get paddedDexNumber => dexNumber.toString().padLeft(3, '0');
  String get imageUrl =>
      'https://raw.githubusercontent.com/HybridShivam/Bogeybeast/master/assets/images/$paddedDexNumber.png';

  BattleBogeybeast copyWith({int? hpCurrent}) => BattleBogeybeast(
        dexNumber: dexNumber,
        name: name,
        types: types,
        hpMax: hpMax,
        hpCurrent: hpCurrent ?? this.hpCurrent,
        offenseTier: offenseTier,
        defenseTier: defenseTier,
      );

  Map<String, dynamic> toJson() => {
        'dex_number': dexNumber,
        'name': name,
        'types': types.map((t) => _typeToString(t)).toList(),
        'hp_max': hpMax,
        'hp_current': hpCurrent,
        'offense_tier': offenseTier,
        'defense_tier': defenseTier,
      };

  static BattleBogeybeast fromJson(Map<String, dynamic> json) {
    final typeStrings = (json['types'] as List<dynamic>).cast<String>();
    return BattleBogeybeast(
      dexNumber: (json['dex_number'] as num).toInt(),
      name: json['name'] as String,
      types: typeStrings.map(_typeFromString).whereType<BogeybeastType>().toList(),
      hpMax: (json['hp_max'] as num).toInt(),
      hpCurrent: (json['hp_current'] as num).toInt(),
      offenseTier: (json['offense_tier'] as num).toInt(),
      defenseTier: (json['defense_tier'] as num).toInt(),
    );
  }

  /// Create from a dex number using the battle stats lookup.
  static BattleBogeybeast fromDexNumber(int dexNumber) {
    final stats = bogeybeastBattleStats[dexNumber]!;
    final species = firstGenBogeybeast.firstWhere((p) => p.dexNumber == dexNumber);
    final hpMax = battleHpMax(stats.hp);
    return BattleBogeybeast(
      dexNumber: dexNumber,
      name: species.name,
      types: List<BogeybeastType>.unmodifiable(species.types),
      hpMax: hpMax,
      hpCurrent: hpMax,
      offenseTier: stats.offense,
      defenseTier: stats.defense,
    );
  }
}

// ── BattleStatus ─────────────────────────────────────────────────────────────

enum BattleStatus { pending, active, completed }

BattleStatus _statusFromString(String s) => switch (s) {
      'pending'   => BattleStatus.pending,
      'active'    => BattleStatus.active,
      'completed' => BattleStatus.completed,
      _           => BattleStatus.pending,
    };

// ── BattleHoleEvent ───────────────────────────────────────────────────────────

enum BattleHoleResult { challengerWins, opponentWins, tie }

class BattleHoleEvent {
  const BattleHoleEvent({
    required this.hole,
    required this.challengerStrokes,
    required this.opponentStrokes,
    required this.result,
    required this.damage,
    required this.typeMult,
    this.attackerBogeybeastName,
    this.defenderBogeybeastName,
    required this.challengerTeamAfter,
    required this.opponentTeamAfter,
  });

  final int hole;
  final int challengerStrokes;
  final int opponentStrokes;
  final BattleHoleResult result;
  final int damage;
  final double typeMult;
  final String? attackerBogeybeastName;
  final String? defenderBogeybeastName;
  final List<BattleBogeybeast> challengerTeamAfter;
  final List<BattleBogeybeast> opponentTeamAfter;

  static BattleHoleEvent fromJson(Map<String, dynamic> json) {
    final resultStr = json['result'] as String;
    final result = switch (resultStr) {
      'challenger_wins' => BattleHoleResult.challengerWins,
      'opponent_wins'   => BattleHoleResult.opponentWins,
      _                 => BattleHoleResult.tie,
    };

    List<BattleBogeybeast> parseTeam(dynamic raw) {
      if (raw == null) return [];
      return (raw as List<dynamic>)
          .map((e) => BattleBogeybeast.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return BattleHoleEvent(
      hole: (json['hole'] as num).toInt(),
      challengerStrokes: (json['c_strokes'] as num).toInt(),
      opponentStrokes: (json['o_strokes'] as num).toInt(),
      result: result,
      damage: (json['damage'] as num).toInt(),
      typeMult: (json['type_mult'] as num).toDouble(),
      attackerBogeybeastName: json['attacker_bogeybeast'] as String?,
      defenderBogeybeastName: json['defender_bogeybeast'] as String?,
      challengerTeamAfter: parseTeam(json['c_team_after']),
      opponentTeamAfter: parseTeam(json['o_team_after']),
    );
  }
}

// ── Battle ────────────────────────────────────────────────────────────────────

class Battle {
  const Battle({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.holeCount,
    required this.coursePars,
    required this.status,
    required this.challengerId,
    required this.challengerName,
    this.opponentId,
    this.opponentName,
    this.challengerTeam,
    this.opponentTeam,
    required this.challengerScores,
    required this.opponentScores,
    required this.holeLog,
    this.winnerId,
    required this.createdAt,
    this.completedAt,
    this.isLeaderChallenge = false,
    this.leaderHcp,
  });

  final String id;
  final String courseId;
  final String courseName;
  final int holeCount;
  final List<int> coursePars;
  final BattleStatus status;
  final String challengerId;
  final String challengerName;
  final String? opponentId;
  final String? opponentName;
  final List<BattleBogeybeast>? challengerTeam;
  final List<BattleBogeybeast>? opponentTeam;
  final Map<int, int> challengerScores; // hole -> strokes
  final Map<int, int> opponentScores;
  final List<BattleHoleEvent> holeLog;
  final String? winnerId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isLeaderChallenge;
  final int? leaderHcp;

  bool get isCompleted => status == BattleStatus.completed;
  bool get isPending    => status == BattleStatus.pending;
  bool get isActive     => status == BattleStatus.active;

  /// The par for the given 1-indexed hole number, or 4 if not available.
  int parForHole(int holeNumber) {
    final idx = holeNumber - 1;
    if (idx < 0 || idx >= coursePars.length) return 4;
    return coursePars[idx];
  }

  /// Next unsubmitted hole number for the given player.
  int myNextHole(bool isChallenger) {
    final scores = isChallenger ? challengerScores : opponentScores;
    return scores.length + 1;
  }

  /// Number of resolved holes (both players submitted).
  int get resolvedHoles => holeLog.length;

  /// Whether the given player is waiting for the opponent on the current hole.
  bool isWaiting(bool isChallenger) {
    final myNext = myNextHole(isChallenger);
    return myNext > resolvedHoles + 1;
  }

  /// Latest snapshot of each team (from last hole log entry, or initial team).
  List<BattleBogeybeast> get currentChallengerTeam =>
      holeLog.isNotEmpty ? holeLog.last.challengerTeamAfter : (challengerTeam ?? []);

  List<BattleBogeybeast> get currentOpponentTeam =>
      holeLog.isNotEmpty ? holeLog.last.opponentTeamAfter : (opponentTeam ?? []);

  static Battle fromJson(Map<String, dynamic> json) {
    Map<int, int> parseScores(dynamic raw) {
      if (raw == null) return {};
      return (raw as Map).map(
        (k, v) => MapEntry(int.parse(k.toString()), (v as num).toInt()),
      );
    }

    List<BattleBogeybeast>? parseTeam(dynamic raw) {
      if (raw == null) return null;
      return (raw as List<dynamic>)
          .map((e) => BattleBogeybeast.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    List<BattleHoleEvent> parseLog(dynamic raw) {
      if (raw == null) return [];
      return (raw as List<dynamic>)
          .map((e) => BattleHoleEvent.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    List<int> parsePars(dynamic raw) {
      if (raw == null) return [];
      return (raw as List<dynamic>).map((e) => (e as num).toInt()).toList();
    }

    return Battle(
      id:               json['id'] as String,
      courseId:         json['course_id'] as String,
      courseName:       json['course_name'] as String? ?? '',
      holeCount:        (json['hole_count'] as num).toInt(),
      coursePars:       parsePars(json['course_pars']),
      status:           _statusFromString(json['status'] as String),
      challengerId:     json['challenger_id'] as String,
      challengerName:   json['challenger_name'] as String? ?? 'Challenger',
      opponentId:       json['opponent_id'] as String?,
      opponentName:     json['opponent_name'] as String?,
      challengerTeam:   parseTeam(json['challenger_team']),
      opponentTeam:     parseTeam(json['opponent_team']),
      challengerScores: parseScores(json['challenger_scores']),
      opponentScores:   parseScores(json['opponent_scores']),
      holeLog:          parseLog(json['hole_log']),
      winnerId:         json['winner_id'] as String?,
      createdAt:        DateTime.parse(json['created_at'] as String),
      completedAt:      json['completed_at'] != null
                          ? DateTime.parse(json['completed_at'] as String)
                          : null,
      isLeaderChallenge: json['is_leader_challenge'] as bool? ?? false,
      leaderHcp:         (json['leader_hcp'] as num?)?.toInt(),
    );
  }
}

// ── Type string helpers ───────────────────────────────────────────────────────

String _typeToString(BogeybeastType t) {
  return switch (t) {
    BogeybeastType.normal   => 'Normal',
    BogeybeastType.fire     => 'Fire',
    BogeybeastType.water    => 'Water',
    BogeybeastType.grass    => 'Grass',
    BogeybeastType.electric => 'Electric',
    BogeybeastType.ice      => 'Ice',
    BogeybeastType.fighting => 'Fighting',
    BogeybeastType.poison   => 'Poison',
    BogeybeastType.ground   => 'Ground',
    BogeybeastType.flying   => 'Flying',
    BogeybeastType.psychic  => 'Psychic',
    BogeybeastType.bug      => 'Bug',
    BogeybeastType.rock     => 'Rock',
    BogeybeastType.ghost    => 'Ghost',
    BogeybeastType.dragon   => 'Dragon',
    BogeybeastType.fairy    => 'Fairy',
  };
}

BogeybeastType? _typeFromString(String s) => switch (s) {
      'Normal'   => BogeybeastType.normal,
      'Fire'     => BogeybeastType.fire,
      'Water'    => BogeybeastType.water,
      'Grass'    => BogeybeastType.grass,
      'Electric' => BogeybeastType.electric,
      'Ice'      => BogeybeastType.ice,
      'Fighting' => BogeybeastType.fighting,
      'Poison'   => BogeybeastType.poison,
      'Ground'   => BogeybeastType.ground,
      'Flying'   => BogeybeastType.flying,
      'Psychic'  => BogeybeastType.psychic,
      'Bug'      => BogeybeastType.bug,
      'Rock'     => BogeybeastType.rock,
      'Ghost'    => BogeybeastType.ghost,
      'Dragon'   => BogeybeastType.dragon,
      'Fairy'    => BogeybeastType.fairy,
      _          => null,
    };

/// Compute damage for a hole result. Used in Dart for preview only;
/// authoritative calculation is in the SQL RPC.
int computeDamage({
  required BattleBogeybeast attacker,
  required BattleBogeybeast defender,
  required int scoreDiff,
}) {
  final rawDmg = (attacker.offenseTier - (defender.defenseTier / 2)).ceil();
  final clamped = rawDmg < 1 ? 1 : rawDmg;
  final scoreBonus = scoreDiff * 10;
  final mult = typeMultiplier(
    attackerTypes: attacker.types,
    defenderTypes: defender.types,
  );
  return ((clamped + scoreBonus) * mult).round().clamp(1, 9999);
}
