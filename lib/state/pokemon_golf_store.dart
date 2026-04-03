import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/encounter_modifiers.dart';
import '../models/golf_score.dart';
import '../models/hole_stats.dart';
import '../models/pokemon_species.dart';
import '../models/round_models.dart';
import '../services/catch_service.dart';
import '../services/encounter_service.dart';

class PokemonGolfStore extends ChangeNotifier {
  PokemonGolfStore({
    EncounterService? encounterService,
    CatchService? catchService,
  })  : _encounterService = encounterService ?? EncounterService(),
        _catchService = catchService ?? CatchService();

  final EncounterService _encounterService;
  final CatchService _catchService;

  final Set<int> _caughtDexNumbers = <int>{};
  final List<GolfRoundSummary> _completedRounds = <GolfRoundSummary>[];

  ActiveRound? _activeRound;

  ActiveRound? get activeRound => _activeRound;

  UnmodifiableSetView<int> get caughtDexNumbers =>
      UnmodifiableSetView<int>(_caughtDexNumbers);

  List<GolfRoundSummary> get completedRounds =>
      List<GolfRoundSummary>.unmodifiable(_completedRounds);

  bool hasCaught(PokemonSpecies pokemon) {
    return _caughtDexNumbers.contains(pokemon.dexNumber);
  }

  void startRound(int holeCount) {
    _activeRound = ActiveRound(
      holeCount: holeCount,
      currentHoleNumber: 1,
      currentEncounter: _encounterService.generateEncounter(),
      completedHoles: const <HoleResult>[],
    );
    notifyListeners();
  }

  void discardRound() {
    _activeRound = null;
    notifyListeners();
  }

  GolfRoundSummary? endRoundEarly() {
    final ActiveRound? round = _activeRound;
    if (round == null || round.completedHoles.isEmpty) {
      _activeRound = null;
      notifyListeners();
      return null;
    }

    final GolfRoundSummary summary = GolfRoundSummary(
      completedAt: DateTime.now(),
      holeCount: round.completedHoles.length,
      holes: round.completedHoles,
    );
    _completedRounds.insert(0, summary);
    _activeRound = null;
    notifyListeners();
    return summary;
  }

  HoleResolution playCurrentHole({
    required int par,
    required int strokes,
    required HoleStats stats,
  }) {
    final ActiveRound round = _activeRound!;
    final GolfScore score = scoreFromStrokes(par, strokes);
    final int chance = _catchService.catchChance(
      rarity: round.currentEncounter.rarity,
      score: score,
    );
    final bool caught = _catchService.rollCatch(chance);

    final HoleResult result = HoleResult(
      holeNumber: round.currentHoleNumber,
      par: par,
      strokes: strokes,
      pokemon: round.currentEncounter,
      score: score,
      catchChance: chance,
      caught: caught,
      stats: stats,
    );

    if (caught) {
      _caughtDexNumbers.add(round.currentEncounter.dexNumber);
    }

    final List<HoleResult> updatedHoles = <HoleResult>[
      ...round.completedHoles,
      result,
    ];

    final bool isFinalHole = round.currentHoleNumber == round.holeCount;
    if (isFinalHole) {
      final GolfRoundSummary summary = GolfRoundSummary(
        completedAt: DateTime.now(),
        holeCount: round.holeCount,
        holes: updatedHoles,
      );
      _completedRounds.insert(0, summary);
      _activeRound = null;
      notifyListeners();

      return HoleResolution(
        holeResult: result,
        roundCompleted: true,
        roundSummary: summary,
      );
    }

    // Build modifiers for the next encounter based on this hole's stats/score
    int streak = round.parOrBetterStreak;
    if (score.relativeToPar <= 0) {
      streak++;
    } else {
      streak = 0;
    }

    final EncounterModifiers modifiers = EncounterModifiers(
      bunker: stats.bunker,
      water: stats.water,
      rough: stats.rough,
      onePutt: stats.onePutt,
      parOrBetterStreak: streak,
    );

    _activeRound = ActiveRound(
      holeCount: round.holeCount,
      currentHoleNumber: round.currentHoleNumber + 1,
      currentEncounter: _encounterService.generateEncounter(modifiers),
      completedHoles: updatedHoles,
    );
    notifyListeners();

    return HoleResolution(
      holeResult: result,
      roundCompleted: false,
      nextHoleNumber: round.currentHoleNumber + 1,
    );
  }
}
