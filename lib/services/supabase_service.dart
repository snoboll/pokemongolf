import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/first_gen_pokemon.dart';
import '../models/club.dart';
import '../models/course_leader.dart';
import '../models/golf_score.dart';
import '../models/hole_stats.dart';
import '../models/golf_course.dart';
import '../models/pokemon_species.dart';
import '../models/round_models.dart';

class TrainerProfile {
  const TrainerProfile({
    required this.userId,
    required this.trainerName,
    required this.caughtCount,
    this.homeCourseId,
    this.trainerSprite,
    this.trainerTeam,
  });

  final String userId;
  final String trainerName;
  final int caughtCount;
  final String? homeCourseId;
  final String? trainerSprite;
  final String? trainerTeam;
}

class SupabaseService {
  SupabaseService() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  String? get currentUserId => _client.auth.currentUser?.id;

  // ── Auth ────────────────────────────────────────────────────────────

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  Stream<AuthState> get onAuthStateChange =>
      _client.auth.onAuthStateChange;

  // ── Profiles ────────────────────────────────────────────────────────

  Future<String?> fetchTrainerName() async {
    final uid = currentUserId;
    if (uid == null) return null;

    final List<Map<String, dynamic>> rows = await _client
        .from('profiles')
        .select('trainer_name')
        .eq('user_id', uid)
        .limit(1);

    if (rows.isEmpty) return null;
    return rows.first['trainer_name'] as String;
  }

  Future<void> upsertTrainerName(String name) async {
    await _client.from('profiles').upsert(
      {'trainer_name': name},
      onConflict: 'user_id',
    );
  }

  Future<String?> fetchTrainerSprite() async {
    final uid = currentUserId;
    if (uid == null) return null;

    final List<Map<String, dynamic>> rows = await _client
        .from('profiles')
        .select('trainer_sprite')
        .eq('user_id', uid)
        .limit(1);

    if (rows.isEmpty) return null;
    return rows.first['trainer_sprite'] as String?;
  }

  Future<void> updateTrainerSprite(String? sprite) async {
    await _client.from('profiles').update(
      {'trainer_sprite': sprite},
    ).eq('user_id', currentUserId!);
  }

  Future<({String? team, DateTime? changedAt})> fetchTrainerTeam() async {
    final uid = currentUserId;
    if (uid == null) return (team: null, changedAt: null);

    final List<Map<String, dynamic>> rows = await _client
        .from('profiles')
        .select('trainer_team, team_changed_at')
        .eq('user_id', uid)
        .limit(1);

    if (rows.isEmpty) return (team: null, changedAt: null);
    final raw = rows.first;
    return (
      team: raw['trainer_team'] as String?,
      changedAt: raw['team_changed_at'] != null
          ? DateTime.parse(raw['team_changed_at'] as String)
          : null,
    );
  }

  Future<void> updateTrainerTeam(String? team) async {
    await _client.from('profiles').update(
      {'trainer_team': team, 'team_changed_at': DateTime.now().toUtc().toIso8601String()},
    ).eq('user_id', currentUserId!);
  }

  Future<String?> fetchHomeCourseId() async {
    final uid = currentUserId;
    if (uid == null) return null;

    final List<Map<String, dynamic>> rows = await _client
        .from('profiles')
        .select('home_course_id')
        .eq('user_id', uid)
        .limit(1);

    if (rows.isEmpty) return null;
    return rows.first['home_course_id'] as String?;
  }

  Future<void> setHomeCourse(String courseId) async {
    await _client.from('profiles').update(
      {'home_course_id': courseId},
    ).eq('user_id', currentUserId!);
  }

  Future<List<TrainerProfile>> fetchAllTrainers() async {
    final List<Map<String, dynamic>> profiles = await _client
        .from('profiles')
        .select('user_id, trainer_name, home_course_id, trainer_sprite, trainer_team')
        .order('created_at');

    if (profiles.isEmpty) return <TrainerProfile>[];

    final List<Map<String, dynamic>> catchCounts = await _client
        .rpc('get_trainer_catch_counts');

    final Map<String, int> countMap = <String, int>{};
    for (final row in catchCounts) {
      countMap[row['user_id'] as String] = (row['catch_count'] as num).toInt();
    }

    return (profiles.map((p) {
      final String uid = p['user_id'] as String;
      return TrainerProfile(
        userId: uid,
        trainerName: p['trainer_name'] as String,
        caughtCount: countMap[uid] ?? 0,
        homeCourseId: p['home_course_id'] as String?,
        trainerSprite: p['trainer_sprite'] as String?,
        trainerTeam: p['trainer_team'] as String?,
      );
    }).toList()
      ..sort((a, b) => b.caughtCount.compareTo(a.caughtCount)));
  }

  Future<Set<int>> fetchTrainerCaughtDexNumbers(String userId) async {
    final List<Map<String, dynamic>> rows = await _client
        .from('caught_pokemon')
        .select('dex_number')
        .eq('user_id', userId);
    return rows.map((r) => (r['dex_number'] as num).toInt()).toSet();
  }

  Future<Map<String, Set<int>>> fetchAllCaughtDexNumbers() async {
    final List<Map<String, dynamic>> rows = await _client
        .from('caught_pokemon')
        .select('user_id, dex_number');

    final Map<String, Set<int>> result = <String, Set<int>>{};
    for (final Map<String, dynamic> row in rows) {
      final String userId = row['user_id'] as String;
      final int dex = (row['dex_number'] as num).toInt();
      (result[userId] ??= <int>{}).add(dex);
    }
    return result;
  }

  // ── Catalog courses (pars, multi-loop parts, green centers) ─────────

  Future<List<GolfCourse>> fetchCatalogCourses() async {
    final List<Map<String, dynamic>> rows = await _client
        .from('catalog_courses')
        .select('id, name, layout, lat, lng')
        .order('sort_order');

    final List<GolfCourse> courses = <GolfCourse>[];
    for (final Map<String, dynamic> row in rows) {
      try {
        final Object? rawLayout = row['layout'];
        final Map<String, dynamic> layout = switch (rawLayout) {
          final Map<String, dynamic> m => m,
          final Map m => Map<String, dynamic>.from(m),
          _ => throw FormatException('catalog_courses.layout must be a JSON object'),
        };
        courses.add(GolfCourse.fromCatalogRow(
          id: row['id'] as String,
          name: row['name'] as String,
          layout: layout,
          lat: (row['lat'] as num?)?.toDouble(),
          lng: (row['lng'] as num?)?.toDouble(),
        ));
      } catch (e, st) {
        debugPrint('Skipping catalog course row ${row['id']}: $e\n$st');
      }
    }
    return courses;
  }

  // ── User Courses ─────────────────────────────────────────────────

  Future<List<GolfCourse>> fetchUserCourses() async {
    final List<Map<String, dynamic>> rows = await _client
        .from('user_courses')
        .select()
        .order('created_at');

    return rows.map((row) {
      final List<dynamic> parsRaw = row['pars'] as List<dynamic>;
      final List<int> pars = parsRaw.map((e) => (e as num).toInt()).toList();

      return GolfCourse(
        id: row['id'] as String,
        name: row['name'] as String,
        loops: <CourseLoop>[
          CourseLoop(
            name: '',
            holes: pars.map((int p) => CourseHole(par: p)).toList(growable: false),
          ),
        ],
      );
    }).toList(growable: false);
  }

  Future<void> insertUserCourse(String name, List<int> pars) async {
    await _client.from('user_courses').insert({
      'name': name,
      'pars': pars,
    });
  }

  // ── Caught Pokemon ──────────────────────────────────────────────────

  Future<Set<int>> fetchCaughtDexNumbers() async {
    final List<Map<String, dynamic>> rows = await _client
        .from('caught_pokemon')
        .select('dex_number')
        .eq('user_id', currentUserId!)
        .order('dex_number');

    return rows.map<int>((row) => row['dex_number'] as int).toSet();
  }

  Future<void> resetAllProgress() async {
    final uid = currentUserId;
    if (uid == null) return;

    final List<Map<String, dynamic>> roundRows = await _client
        .from('rounds')
        .select('id')
        .eq('user_id', uid);

    final List<dynamic> roundIds =
        roundRows.map((Map<String, dynamic> r) => r['id']).toList();

    // PostgREST `in.()` with an empty list is invalid; skip when there are no rounds.
    if (roundIds.isNotEmpty) {
      await _client
          .from('hole_results')
          .delete()
          .inFilter('round_id', roundIds);
    }

    await _client.from('rounds').delete().eq('user_id', uid);
    await _client.from('caught_pokemon').delete().eq('user_id', uid);
  }

  Future<void> releasePokemon(int dexNumber) async {
    await _client
        .from('caught_pokemon')
        .delete()
        .eq('user_id', currentUserId!)
        .eq('dex_number', dexNumber);
  }

  Future<void> insertCaughtPokemon(int dexNumber) async {
    await _client.from('caught_pokemon').upsert(
      {'dex_number': dexNumber},
      onConflict: 'user_id,dex_number',
    );
  }

  // ── Clubs (bag) ────────────────────────────────────────────────────

  Future<List<Club>> fetchClubs() async {
    final List<Map<String, dynamic>> rows = await _client
        .from('clubs')
        .select()
        .order('sort_order');

    return rows.map((Map<String, dynamic> r) => Club(
      id: r['id'] as String,
      name: r['name'] as String,
      carryDistance: r['carry_distance'] as int?,
      totalDistance: r['total_distance'] as int?,
    )).toList();
  }

  Future<List<Club>> seedDefaultClubs() async {
    final List<Club> defaults = Club.defaults;
    final List<Map<String, dynamic>> rows = <Map<String, dynamic>>[];
    for (int i = 0; i < defaults.length; i++) {
      rows.add(<String, dynamic>{
        'name': defaults[i].name,
        'sort_order': i,
      });
    }
    final List<Map<String, dynamic>> inserted =
        await _client.from('clubs').insert(rows).select();

    return inserted.map((Map<String, dynamic> r) => Club(
      id: r['id'] as String,
      name: r['name'] as String,
      carryDistance: r['carry_distance'] as int?,
      totalDistance: r['total_distance'] as int?,
    )).toList();
  }

  Future<Club> insertClub(Club club, int sortOrder) async {
    final Map<String, dynamic> row =
        await _client.from('clubs').insert(<String, dynamic>{
      'name': club.name,
      'carry_distance': club.carryDistance,
      'total_distance': club.totalDistance,
      'sort_order': sortOrder,
    }).select().single();

    return Club(
      id: row['id'] as String,
      name: row['name'] as String,
      carryDistance: row['carry_distance'] as int?,
      totalDistance: row['total_distance'] as int?,
    );
  }

  Future<void> updateClub(Club club) async {
    await _client.from('clubs').update(<String, dynamic>{
      'name': club.name,
      'carry_distance': club.carryDistance,
      'total_distance': club.totalDistance,
    }).eq('id', club.id!);
  }

  Future<void> deleteClub(String clubId) async {
    await _client.from('clubs').delete().eq('id', clubId);
  }

  // ── Rounds ──────────────────────────────────────────────────────────

  Future<List<GolfRoundSummary>> fetchCompletedRounds() async {
    final List<Map<String, dynamic>> roundRows = await _client
        .from('rounds')
        .select()
        .order('completed_at', ascending: false);

    final List<GolfRoundSummary> summaries = <GolfRoundSummary>[];

    for (final roundRow in roundRows) {
      final String roundId = roundRow['id'] as String;
      final List<Map<String, dynamic>> holeRows = await _client
          .from('hole_results')
          .select()
          .eq('round_id', roundId)
          .order('hole_number');

      final List<HoleResult> holes = holeRows.map((h) {
        final int dex = h['pokemon_dex'] as int;
        final species = dex == 0
            ? battleSentinelPokemon
            : firstGenPokemon.firstWhere((p) => p.dexNumber == dex);

        return HoleResult(
          holeNumber: h['hole_number'] as int,
          par: h['par'] as int,
          strokes: h['strokes'] as int,
          pokemon: species,
          score: GolfScore.values.firstWhere(
            (s) => s.name == h['score'],
            orElse: () => GolfScore.par,
          ),
          catchChance: h['catch_chance'] as int,
          caught: h['caught'] as bool,
          stats: HoleStats(
            onePutt: h['on_putt'] as bool,
            bunker: h['bunker'] as bool,
            water: h['water'] as bool,
            rough: h['rough'] as bool,
          ),
        );
      }).toList(growable: false);

      summaries.add(GolfRoundSummary(
        id: roundId,
        completedAt: DateTime.parse(roundRow['completed_at'] as String),
        holeCount: roundRow['hole_count'] as int,
        holes: holes,
        courseName: roundRow['course_name'] as String?,
        isBattle: (roundRow['round_type'] as String?) == 'battle',
      ));
    }

    return summaries;
  }

  Future<void> deleteRound(String roundId) async {
    await _client.from('hole_results').delete().eq('round_id', roundId);
    await _client.from('rounds').delete().eq('id', roundId);
  }

  Future<void> insertRound(GolfRoundSummary summary) async {
    final Map<String, dynamic> roundRow =
        await _client.from('rounds').insert({
      'hole_count': summary.holeCount,
      'completed_at': summary.completedAt.toUtc().toIso8601String(),
      if (summary.isBattle) 'round_type': 'battle',
      if (summary.courseName != null) 'course_name': summary.courseName,
    }).select().single();

    final String roundId = roundRow['id'] as String;

    final List<Map<String, dynamic>> holeRows = summary.holes.map((h) {
      return <String, dynamic>{
        'round_id': roundId,
        'hole_number': h.holeNumber,
        'par': h.par,
        'strokes': h.strokes,
        'score': h.score.name,
        'catch_chance': h.catchChance,
        'caught': h.caught,
        'pokemon_dex': h.pokemon.dexNumber,
        'on_putt': h.stats.onePutt,
        'bunker': h.stats.bunker,
        'water': h.stats.water,
        'rough': h.stats.rough,
      };
    }).toList(growable: false);

    await _client.from('hole_results').insert(holeRows);
  }

  // ── Course Leaders ───────────────────────────────────────────────────

  Future<Map<String, CourseLeader>> fetchCourseLeaders() async {
    final List<Map<String, dynamic>> rows =
        await _client.from('course_leaders').select();

    final Map<String, CourseLeader> map = {};
    for (final row in rows) {
      try {
        final leader = CourseLeader.fromJson(row);
        map[leader.courseId] = leader;
      } catch (e) {
        debugPrint('Skipping course_leaders row: $e');
      }
    }
    return map;
  }

  Future<Map<String, int>> fetchGymOwnershipCounts() async {
    final List<Map<String, dynamic>> rows = await _client
        .from('course_leaders')
        .select('user_id')
        .not('user_id', 'is', null);

    final Map<String, int> counts = <String, int>{};
    for (final row in rows) {
      final uid = row['user_id'] as String;
      counts[uid] = (counts[uid] ?? 0) + 1;
    }
    return counts;
  }

  // ── Player HCP ─────────────────────────────────────────────────────

  Future<void> updateHcp(int hcp) async {
    await _client.from('profiles').update(
      {'hcp': hcp},
    ).eq('user_id', currentUserId!);
  }

  Future<double?> fetchHcpOverride() async {
    final uid = currentUserId;
    if (uid == null) return null;

    final List<Map<String, dynamic>> rows = await _client
        .from('profiles')
        .select('hcp_override')
        .eq('user_id', uid)
        .limit(1);

    if (rows.isEmpty) return null;
    final val = rows.first['hcp_override'];
    return val != null ? (val as num).toDouble() : null;
  }

  Future<void> updateHcpOverride(double? hcp) async {
    await _client.from('profiles').update(
      {'hcp_override': hcp},
    ).eq('user_id', currentUserId!);
  }
}
