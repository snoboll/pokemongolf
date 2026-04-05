import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/encounter_modifiers.dart';
import '../models/golf_course.dart';
import '../models/golf_score.dart';
import '../models/hole_stats.dart';
import '../models/pokemon_species.dart';
import '../models/round_models.dart';
import '../services/catch_service.dart';
import '../services/encounter_service.dart';
import '../services/supabase_service.dart';

class PokemonGolfStore extends ChangeNotifier {
  PokemonGolfStore({
    EncounterService? encounterService,
    CatchService? catchService,
    SupabaseService? supabaseService,
  })  : _encounterService = encounterService ?? EncounterService(),
        _catchService = catchService ?? CatchService(),
        _supabaseService = supabaseService;

  final EncounterService _encounterService;
  final CatchService _catchService;
  final SupabaseService? _supabaseService;

  final Set<int> _caughtDexNumbers = <int>{};
  final List<GolfRoundSummary> _completedRounds = <GolfRoundSummary>[];

  ActiveRound? _activeRound;
  final Set<int> _pendingCatches = <int>{};
  String? _trainerName;
  String? _homeCourseId;
  List<GolfCourse> _catalogCourses = <GolfCourse>[];
  List<GolfCourse> _userCourses = <GolfCourse>[];

  ActiveRound? get activeRound => _activeRound;
  String? get trainerName => _trainerName;
  String? get homeCourseId => _homeCourseId;

  List<GolfCourse> get catalogCourses =>
      List<GolfCourse>.unmodifiable(_catalogCourses);

  List<GolfCourse> get userCourses =>
      List<GolfCourse>.unmodifiable(_userCourses);

  /// Resolves a course id from the Supabase catalog or user-created courses.
  String? courseNameForId(String? id) {
    if (id == null) return null;
    for (final GolfCourse c in _catalogCourses) {
      if (c.id == id) return c.name;
    }
    for (final GolfCourse c in _userCourses) {
      if (c.id == id) return c.name;
    }
    return null;
  }

  void setHomeCourseId(String id) {
    _homeCourseId = id;
    notifyListeners();
  }

  void syncUserCourses(List<GolfCourse> courses) {
    _userCourses = List<GolfCourse>.from(courses);
    notifyListeners();
  }

  UnmodifiableSetView<int> get caughtDexNumbers =>
      UnmodifiableSetView<int>(_caughtDexNumbers);

  List<GolfRoundSummary> get completedRounds =>
      List<GolfRoundSummary>.unmodifiable(_completedRounds);

  bool hasCaught(PokemonSpecies pokemon) {
    return _caughtDexNumbers.contains(pokemon.dexNumber);
  }

  Future<void> loadUserData() async {
    final supa = _supabaseService;
    if (supa == null) return;

    try {
      final results = await Future.wait([
        supa.fetchCaughtDexNumbers(),
        supa.fetchCompletedRounds(),
        supa.fetchTrainerName(),
      ]);

      _caughtDexNumbers
        ..clear()
        ..addAll(results[0] as Set<int>);
      _completedRounds
        ..clear()
        ..addAll(results[1] as List<GolfRoundSummary>);
      _trainerName = results[2] as String?;

      try {
        _catalogCourses = await supa.fetchCatalogCourses();
      } catch (e) {
        debugPrint('Failed to load catalog courses: $e');
        _catalogCourses = <GolfCourse>[];
      }
      try {
        _userCourses = await supa.fetchUserCourses();
      } catch (e) {
        debugPrint('Failed to load user courses: $e');
        _userCourses = <GolfCourse>[];
      }

      try {
        _homeCourseId = await supa.fetchHomeCourseId();
      } catch (_) {}

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load user data: $e');
    }
  }

  Future<void> resetProgress() async {
    final SupabaseService? supa = _supabaseService;
    try {
      if (supa != null) {
        await supa.resetAllProgress();
        // Reload from Supabase so local state matches the DB (and IndexedStack tabs refresh via [notifyListeners]).
        final List<Object?> results = await Future.wait(<Future<Object?>>[
          supa.fetchCaughtDexNumbers(),
          supa.fetchCompletedRounds(),
        ]);
        _caughtDexNumbers
          ..clear()
          ..addAll(results[0]! as Set<int>);
        _completedRounds
          ..clear()
          ..addAll(results[1]! as List<GolfRoundSummary>);
      } else {
        _caughtDexNumbers.clear();
        _completedRounds.clear();
      }
    } catch (e) {
      debugPrint('Failed to reset progress: $e');
      rethrow;
    }
    _pendingCatches.clear();
    _activeRound = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    _caughtDexNumbers.clear();
    _completedRounds.clear();
    _activeRound = null;
    _trainerName = null;
    _homeCourseId = null;
    _catalogCourses = <GolfCourse>[];
    _userCourses = <GolfCourse>[];
    notifyListeners();
    await _supabaseService?.signOut();
  }

  void startRound(int holeCount, {
    List<int>? holePars,
    String? courseName,
    List<({double lat, double lng})?>? greenCoords,
  }) {
    _pendingCatches.clear();
    _activeRound = ActiveRound(
      holeCount: holeCount,
      currentHoleNumber: 1,
      currentEncounter: _encounterService.generateEncounter(),
      completedHoles: const <HoleResult>[],
      holePars: holePars,
      courseName: courseName,
      greenCoords: greenCoords,
    );
    notifyListeners();
  }

  void discardRound() {
    _caughtDexNumbers.removeAll(_pendingCatches);
    _pendingCatches.clear();
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
      courseName: round.courseName,
    );
    _completedRounds.insert(0, summary);
    _commitPendingCatches();
    _activeRound = null;
    notifyListeners();

    _persistRound(summary);

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
      _pendingCatches.add(round.currentEncounter.dexNumber);
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
        courseName: round.courseName,
      );
      _completedRounds.insert(0, summary);
      _commitPendingCatches();
      _activeRound = null;
      notifyListeners();

      _persistRound(summary);

      return HoleResolution(
        holeResult: result,
        roundCompleted: true,
        roundSummary: summary,
      );
    }

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
      holePars: round.holePars,
      courseName: round.courseName,
      greenCoords: round.greenCoords,
    );
    notifyListeners();

    return HoleResolution(
      holeResult: result,
      roundCompleted: false,
      nextHoleNumber: round.currentHoleNumber + 1,
    );
  }

  // ── Private persistence helpers (fire-and-forget) ───────────────────

  void _commitPendingCatches() {
    for (final dex in _pendingCatches) {
      _persistCatch(dex);
    }
    _pendingCatches.clear();
  }

  void _persistCatch(int dexNumber) {
    _supabaseService?.insertCaughtPokemon(dexNumber).catchError((e) {
      debugPrint('Failed to persist catch: $e');
    });
  }

  void _persistRound(GolfRoundSummary summary) {
    _supabaseService?.insertRound(summary).catchError((e) {
      debugPrint('Failed to persist round: $e');
    });
  }
}
