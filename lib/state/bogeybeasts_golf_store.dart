import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../data/default_npc_leaders.dart';
import '../models/club.dart';
import '../models/course_leader.dart';
import '../models/encounter_modifiers.dart';
import '../models/golf_course.dart';
import '../models/golf_score.dart';
import '../models/hole_stats.dart';
import '../models/bogeybeast_species.dart';
import '../models/round_models.dart';
import '../services/catch_service.dart';
import '../services/encounter_service.dart';
import '../services/supabase_service.dart';

class BogeybeastGolfStore extends ChangeNotifier {
  BogeybeastGolfStore({
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
  String? _golferName;
  String? _golferSprite;
  String? _golferTeam;
  DateTime? _teamChangedAt;
  double? _hcpOverride;
  String? _homeCourseId;
  List<GolfCourse> _catalogCourses = <GolfCourse>[];
  List<GolfCourse> _userCourses = <GolfCourse>[];
  List<Club> _clubs = <Club>[];
  Map<String, CourseLeader> _courseLeaders = {};
  Map<String, CourseLeader> _defaultLeaders = {};

  ActiveRound? get activeRound => _activeRound;
  String? get golferName => _golferName;
  String? get golferSprite => _golferSprite;
  String? get golferTeam => _golferTeam;
  DateTime? get teamChangedAt => _teamChangedAt;
  String? get homeCourseId => _homeCourseId;

  bool get canChangeTeam {
    if (_teamChangedAt == null) return true;
    return DateTime.now().toUtc().difference(_teamChangedAt!).inDays >= 30;
  }

  int get daysUntilTeamChange {
    if (_teamChangedAt == null) return 0;
    final elapsed = DateTime.now().toUtc().difference(_teamChangedAt!).inDays;
    return (30 - elapsed).clamp(0, 30);
  }

  List<GolfCourse> get catalogCourses =>
      List<GolfCourse>.unmodifiable(_catalogCourses);

  List<GolfCourse> get userCourses =>
      List<GolfCourse>.unmodifiable(_userCourses);

  List<Club> get clubs {
    final sorted = List<Club>.from(_clubs)
      ..sort((a, b) {
        final int? da = a.carryDistance ?? a.totalDistance;
        final int? db = b.carryDistance ?? b.totalDistance;
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return db.compareTo(da);
      });
    return List<Club>.unmodifiable(sorted);
  }

  Map<String, CourseLeader> get courseLeaders =>
      Map<String, CourseLeader>.unmodifiable(_courseLeaders);

  CourseLeader leaderForCourse(String courseId) {
    return _courseLeaders[courseId]
        ?? _defaultLeaders[courseId]
        ?? defaultNpcForCourse(courseId);
  }

  void _rebuildDefaultLeaders() {
    final allIds = <String>{
      ..._catalogCourses.map((c) => c.id),
      ..._userCourses.map((c) => c.id),
    }.toList();
    _defaultLeaders = buildDefaultLeaders(allIds);
  }

  double? get hcpOverride => _hcpOverride;

  double get playerHcp {
    if (_hcpOverride != null) return _hcpOverride!;
    final qualifying = _completedRounds
        .where((r) => r.holes.length >= 9 && !r.isBattle)
        .take(10)
        .toList();
    if (qualifying.isEmpty) return 36.0;

    int totalDiff = 0;
    int totalHoles = 0;
    for (final round in qualifying) {
      for (final hole in round.holes) {
        totalDiff += hole.strokes - hole.par;
        totalHoles += 1;
      }
    }
    final raw = (totalDiff / totalHoles) * 18;
    return (raw * 10).round() / 10.0;
  }

  String get playerHcpDisplay {
    final hcp = playerHcp;
    return hcp == hcp.truncateToDouble()
        ? hcp.toInt().toString()
        : hcp.toStringAsFixed(1);
  }

  void setHcpOverride(double? hcp) {
    _hcpOverride = hcp?.clamp(0.0, 54.0);
    notifyListeners();
    _supabaseService?.updateHcpOverride(_hcpOverride).catchError((e) {
      debugPrint('Failed to save HCP override: $e');
    });
    _supabaseService?.updateHcp(playerHcp.round()).catchError((e) {
      debugPrint('Failed to sync HCP: $e');
    });
  }

  void updateCourseLeader(CourseLeader leader) {
    _courseLeaders = Map<String, CourseLeader>.from(_courseLeaders)
      ..[leader.courseId] = leader;
    notifyListeners();
  }

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

  void setGolferSprite(String? sprite) {
    _golferSprite = sprite;
    notifyListeners();
    _supabaseService?.updateGolferSprite(sprite).catchError((e) {
      debugPrint('Failed to update golfer sprite: $e');
    });
  }

  void setGolferTeam(String? team) {
    if (!canChangeTeam) return;
    _golferTeam = team;
    _teamChangedAt = DateTime.now().toUtc();
    notifyListeners();
    _supabaseService?.updateGolferTeam(team).catchError((e) {
      debugPrint('Failed to update golfer team: $e');
    });
  }

  void setHomeCourseId(String id) {
    _homeCourseId = id;
    notifyListeners();
  }

  void syncUserCourses(List<GolfCourse> courses) {
    _userCourses = List<GolfCourse>.from(courses);
    _rebuildDefaultLeaders();
    notifyListeners();
  }

  UnmodifiableSetView<int> get caughtDexNumbers =>
      UnmodifiableSetView<int>(_caughtDexNumbers);

  List<GolfRoundSummary> get completedRounds =>
      List<GolfRoundSummary>.unmodifiable(_completedRounds);

  Set<int> get seenDexNumbers {
    final Set<int> seen = <int>{};
    for (final GolfRoundSummary round in _completedRounds) {
      for (final hole in round.holes) {
        seen.add(hole.bogeybeast.dexNumber);
      }
    }
    return seen;
  }

  bool hasCaught(BogeybeastSpecies bogeybeast) {
    return _caughtDexNumbers.contains(bogeybeast.dexNumber);
  }

  Future<void> loadUserData() async {
    final supa = _supabaseService;
    if (supa == null) return;

    try {
      final results = await Future.wait([
        supa.fetchCaughtDexNumbers(),
        supa.fetchCompletedRounds(),
        supa.fetchGolferName(),
      ]);

      _caughtDexNumbers
        ..clear()
        ..addAll(results[0] as Set<int>);
      _completedRounds
        ..clear()
        ..addAll(results[1] as List<GolfRoundSummary>);
      _golferName = results[2] as String?;

      try {
        _golferSprite = await supa.fetchGolferSprite();
      } catch (e) {
        debugPrint('Failed to load golfer sprite: $e');
      }

      try {
        final teamData = await supa.fetchGolferTeam();
        _golferTeam = teamData.team;
        _teamChangedAt = teamData.changedAt;
      } catch (e) {
        debugPrint('Failed to load golfer team: $e');
      }

      try {
        _hcpOverride = await supa.fetchHcpOverride();
      } catch (e) {
        debugPrint('Failed to load HCP override: $e');
      }

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

      try {
        _clubs = await supa.fetchClubs();
        if (_clubs.isEmpty) {
          _clubs = await supa.seedDefaultClubs();
        }
      } catch (e) {
        debugPrint('Failed to load clubs: $e');
        if (_clubs.isEmpty) {
          _clubs = List<Club>.from(Club.defaults);
        }
      }

      try {
        _courseLeaders = await supa.fetchCourseLeaders();
      } catch (e) {
        debugPrint('Failed to load course leaders: $e');
      }

      _rebuildDefaultLeaders();
      _syncHcp(supa);

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load user data: $e');
    }
  }

  Future<void> releaseBogeybeast(BogeybeastSpecies bogeybeast) async {
    _caughtDexNumbers.remove(bogeybeast.dexNumber);
    notifyListeners();
    _supabaseService?.releaseBogeybeast(bogeybeast.dexNumber).catchError((e) {
      debugPrint('Failed to release bogeybeast: $e');
    });
  }

  Future<void> evolveBogeybeast(int fromDex, int toDex) async {
    _caughtDexNumbers.remove(fromDex);
    _caughtDexNumbers.add(toDex);
    notifyListeners();
    try {
      await _supabaseService?.releaseBogeybeast(fromDex);
      await _supabaseService?.insertCaughtBogeybeast(toDex);
    } catch (e) {
      debugPrint('Failed to evolve bogeybeast: $e');
    }
  }

  Future<void> deleteRound(GolfRoundSummary round) async {
    _completedRounds.remove(round);
    notifyListeners();
    if (round.id != null) {
      _supabaseService?.deleteRound(round.id!).catchError((e) {
        debugPrint('Failed to delete round: $e');
      });
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
    _golferName = null;
    _golferSprite = null;
    _golferTeam = null;
    _teamChangedAt = null;
    _hcpOverride = null;
    _homeCourseId = null;
    _catalogCourses = <GolfCourse>[];
    _userCourses = <GolfCourse>[];
    _clubs = <Club>[];
    _courseLeaders = {};
    _defaultLeaders = {};
    notifyListeners();
    await _supabaseService?.signOut();
  }

  void startRound(int holeCount, {
    List<int>? holePars,
    String? courseName,
    List<({double lat, double lng})?>? greenCoords,
    int startingHoleNumber = 1,
    List<HoleResult> prefilledHoles = const <HoleResult>[],
  }) {
    _pendingCatches.clear();
    _activeRound = ActiveRound(
      holeCount: holeCount,
      currentHoleNumber: startingHoleNumber,
      currentEncounter: _encounterService.generateEncounter(),
      completedHoles: prefilledHoles,
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
      bogeybeast: round.currentEncounter,
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

    int streak = round.streakBonus;
    if (score.relativeToPar <= -2) {
      streak += 12; // eagle
    } else if (score.relativeToPar == -1) {
      streak += 6; // birdie
    } else if (score.relativeToPar == 0) {
      streak += 3; // par
    } else {
      streak = 0; // bogey or worse resets
    }

    final EncounterModifiers modifiers = EncounterModifiers(
      bunker: stats.bunker,
      water: stats.water,
      rough: stats.rough,
      onePutt: stats.onePutt,
      streakBonus: streak,
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

  // ── Club bag management ─────────────────────────────────────────────

  void addClub(Club club) {
    _clubs.add(club);
    notifyListeners();
    _supabaseService?.insertClub(club, _clubs.length - 1).then((saved) {
      for (int i = 0; i < _clubs.length; i++) {
        if (identical(_clubs[i], club)) {
          _clubs[i] = saved;
          break;
        }
      }
    }).catchError((e) {
      debugPrint('Failed to persist club: $e');
    });
  }

  void updateClub(Club oldClub, Club newClub) {
    final int i = _clubs.indexWhere((c) => identical(c, oldClub));
    if (i == -1) return;
    _clubs[i] = newClub;
    notifyListeners();
    if (newClub.id != null) {
      _supabaseService?.updateClub(newClub).catchError((e) {
        debugPrint('Failed to update club: $e');
      });
    }
  }

  void removeClub(Club club) {
    final bool removed = _clubs.remove(club);
    if (!removed) return;
    notifyListeners();
    if (club.id != null) {
      _supabaseService?.deleteClub(club.id!).catchError((e) {
        debugPrint('Failed to delete club: $e');
      });
    }
  }

  // ── Private persistence helpers (fire-and-forget) ───────────────────

  void _commitPendingCatches() {
    for (final dex in _pendingCatches) {
      _persistCatch(dex);
    }
    _pendingCatches.clear();
  }

  void _persistCatch(int dexNumber) {
    _supabaseService?.insertCaughtBogeybeast(dexNumber).catchError((e) {
      debugPrint('Failed to persist catch: $e');
    });
  }

  void _persistRound(GolfRoundSummary summary) {
    _supabaseService?.insertRound(summary).catchError((e) {
      debugPrint('Failed to persist round: $e');
    });
  }

  void _syncHcp(SupabaseService supa) {
    supa.updateHcp(playerHcp.round()).catchError((e) {
      debugPrint('Failed to sync HCP: $e');
    });
  }

  Future<void> refreshCourseLeaders() async {
    final supa = _supabaseService;
    if (supa == null) return;
    try {
      _courseLeaders = await supa.fetchCourseLeaders();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to refresh course leaders: $e');
    }
  }
}
