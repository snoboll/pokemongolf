import 'golf_score.dart';
import 'hole_stats.dart';
import 'pokemon_rarity.dart';
import 'pokemon_species.dart';

class HoleResult {
  const HoleResult({
    required this.holeNumber,
    required this.par,
    required this.strokes,
    required this.pokemon,
    required this.score,
    required this.catchChance,
    required this.caught,
    required this.stats,
  });

  final int holeNumber;
  final int par;
  final int strokes;
  final PokemonSpecies pokemon;
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
  final PokemonSpecies currentEncounter;
  final List<HoleResult> completedHoles;
  final List<int>? holePars;
  final String? courseName;
  final List<({double lat, double lng})>? greenCoords;

  int? get currentHolePar {
    if (holePars == null || currentHoleNumber > holePars!.length) return null;
    return holePars![currentHoleNumber - 1];
  }

  ({double lat, double lng})? get currentGreenCoord {
    if (greenCoords == null || currentHoleNumber > greenCoords!.length) return null;
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

  int get parOrBetterStreak {
    int streak = 0;
    for (int i = completedHoles.length - 1; i >= 0; i--) {
      if (completedHoles[i].score.relativeToPar <= 0) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}

class GolfRoundSummary {
  const GolfRoundSummary({
    required this.completedAt,
    required this.holeCount,
    required this.holes,
    this.courseName,
  });

  final DateTime completedAt;
  final int holeCount;
  final List<HoleResult> holes;
  final String? courseName;

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

  List<PokemonSpecies> get caughtPokemon => holes
      .where((hole) => hole.caught)
      .map((hole) => hole.pokemon)
      .toList(growable: false);

  PokemonRarity? get highestRarityCaught {
    PokemonRarity? highest;
    for (final pokemon in caughtPokemon) {
      if (highest == null || pokemon.rarity.index > highest.index) {
        highest = pokemon.rarity;
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
