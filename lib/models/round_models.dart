import 'golf_score.dart';
import 'hole_stats.dart';
import 'bogeybeast_rarity.dart';
import 'bogeybeast_species.dart';

class HoleResult {
  const HoleResult({
    required this.holeNumber,
    required this.par,
    required this.strokes,
    required this.bogeybeast,
    required this.score,
    required this.catchChance,
    required this.caught,
    required this.stats,
  });

  final int holeNumber;
  final int par;
  final int strokes;
  final BogeybeastSpecies bogeybeast;
  final GolfScore score;
  final int catchChance;
  final bool caught;
  final HoleStats stats;
}

class ActiveRound {
  const ActiveRound({
    required this.holeCount,
    required this.currentHoleNumber,
    required this.currentEncounter,
    required this.completedHoles,
    this.holePars,
    this.courseName,
    this.greenCoords,
  });

  final int holeCount;
  final int currentHoleNumber;
  final BogeybeastSpecies currentEncounter;
  final List<HoleResult> completedHoles;
  final List<int>? holePars;
  final String? courseName;

  /// Per hole, aligned with [holePars]. Null if no green coordinate for that hole.
  final List<({double lat, double lng})?>? greenCoords;

  int? get currentHolePar {
    if (holePars == null || currentHoleNumber > holePars!.length) return null;
    return holePars![currentHoleNumber - 1];
  }

  ({double lat, double lng})? get currentGreenCoord {
    if (greenCoords == null || currentHoleNumber > greenCoords!.length) {
      return null;
    }
    return greenCoords![currentHoleNumber - 1];
  }

  int get caughtCount => completedHoles.where((hole) => hole.caught).length;

  int get scoreToPar => completedHoles.fold<int>(
        0,
        (total, hole) => total + hole.score.relativeToPar,
      );

  int get totalStrokes =>
      completedHoles.fold<int>(0, (t, h) => t + h.strokes);
  int get totalPar => completedHoles.fold<int>(0, (t, h) => t + h.par);

  int get onePuttCount =>
      completedHoles.where((hole) => hole.stats.onePutt).length;

  /// Accumulated streak bonus for the next encounter.
  /// +3 per par, +6 per birdie, +12 per eagle. Resets on bogey or worse.
  int get streakBonus {
    int bonus = 0;
    for (int i = completedHoles.length - 1; i >= 0; i--) {
      final rel = completedHoles[i].score.relativeToPar;
      if (rel <= -2) {
        bonus += 12;
      } else if (rel == -1) {
        bonus += 6;
      } else if (rel == 0) {
        bonus += 3;
      } else {
        break;
      }
    }
    return bonus;
  }

  /// Number of consecutive holes at par or better (for display next to 🔥).
  int get streakCount {
    int count = 0;
    for (int i = completedHoles.length - 1; i >= 0; i--) {
      if (completedHoles[i].score.relativeToPar <= 0) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }
}

class GolfRoundSummary {
  const GolfRoundSummary({
    required this.completedAt,
    required this.holeCount,
    required this.holes,
    this.id,
    this.courseName,
    this.isBattle = false,
  });

  /// Supabase row id — null for locally-created rounds not yet persisted.
  final String? id;
  final DateTime completedAt;
  final int holeCount;
  final List<HoleResult> holes;
  final String? courseName;
  final bool isBattle;

  int get caughtCount => holes.where((hole) => hole.caught).length;

  int get scoreToPar => holes.fold<int>(
        0,
        (total, hole) => total + hole.score.relativeToPar,
      );

  int get totalStrokes => holes.fold<int>(0, (t, h) => t + h.strokes);
  int get totalPar => holes.fold<int>(0, (t, h) => t + h.par);

  int get onePuttCount => holes.where((hole) => hole.stats.onePutt).length;
  int get bunkerCount => holes.where((hole) => hole.stats.bunker).length;
  int get waterCount => holes.where((hole) => hole.stats.water).length;
  int get roughCount => holes.where((hole) => hole.stats.rough).length;

  List<BogeybeastSpecies> get caughtBogeybeast => holes
      .where((hole) => hole.caught)
      .map((hole) => hole.bogeybeast)
      .toList(growable: false);

  BogeybeastRarity? get highestRarityCaught {
    BogeybeastRarity? highest;
    for (final bogeybeast in caughtBogeybeast) {
      if (highest == null || bogeybeast.rarity.index > highest.index) {
        highest = bogeybeast.rarity;
      }
    }

    return highest;
  }
}

class HoleResolution {
  const HoleResolution({
    required this.holeResult,
    required this.roundCompleted,
    this.roundSummary,
    this.nextHoleNumber,
  });

  final HoleResult holeResult;
  final bool roundCompleted;
  final GolfRoundSummary? roundSummary;
  final int? nextHoleNumber;
}
