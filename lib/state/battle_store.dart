import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/battle_models.dart';
import '../services/battle_service.dart';

class BattleStore extends ChangeNotifier {
  BattleStore({required BattleService service}) : _service = service;

  final BattleService _service;

  List<Battle> _battles = [];
  Battle? _watchedBattle;
  RealtimeChannel? _realtimeChannel;
  bool _loading = false;
  String? _error;
  final Set<String> _savedScorecardBattleIds = {};

  List<Battle> get battles => List.unmodifiable(_battles);
  Battle? get watchedBattle => _watchedBattle;
  bool get loading => _loading;
  String? get error => _error;
  String? get currentUserId => _service.currentUserId;

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadBattles() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _battles = await _service.fetchBattles();
    } catch (e) {
      _error = e.toString();
      debugPrint('BattleStore.loadBattles: $e');
    }

    _loading = false;
    notifyListeners();
  }

  // ── Realtime watch ────────────────────────────────────────────────────────

  /// Subscribe to row-level changes on [battleId].
  /// The server pushes a notification whenever the battles row is updated,
  /// so we only hit the DB on actual state changes — no polling.
  void watchBattle(String battleId) {
    _stopWatching();

    // Seed from already-loaded list if available.
    final existing = _battles.where((b) => b.id == battleId).firstOrNull;
    if (existing != null) _watchedBattle = existing;

    _realtimeChannel = Supabase.instance.client
        .channel('battle:$battleId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'battles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: battleId,
          ),
          callback: (_) => _refreshWatched(battleId),
        )
        .subscribe();
  }

  void stopWatching() {
    _stopWatching();
    _watchedBattle = null;
    notifyListeners();
  }

  Future<void> _refreshWatched(String battleId) async {
    try {
      final fresh = await _service.fetchBattle(battleId);
      _watchedBattle = fresh;
      final idx = _battles.indexWhere((b) => b.id == battleId);
      if (idx >= 0) {
        _battles = List<Battle>.from(_battles)..[idx] = fresh;
      }
      notifyListeners();

      if (fresh.isCompleted) {
        _stopWatching();
        _maybeSaveScorecard(fresh);
      }
    } catch (e) {
      debugPrint('BattleStore realtime refresh error: $e');
    }
  }

  void _maybeSaveScorecard(Battle battle) {
    if (!battle.isCompleted) return;
    // If battle ended early (KO), the player continues in catch mode and a
    // unified scorecard is saved when that round completes. Don't save a
    // separate battle-only scorecard here.
    if (battle.holeLog.length < battle.holeCount) return;

    final uid = currentUserId;
    if (uid == null) return;
    if (_savedScorecardBattleIds.contains(battle.id)) return;
    _savedScorecardBattleIds.add(battle.id);

    final isChallenger = battle.challengerId == uid;
    _service.insertBattleRound(battle: battle, isChallenger: isChallenger).catchError((e) {
      debugPrint('BattleStore: failed to save scorecard for ${battle.id}: $e');
      _savedScorecardBattleIds.remove(battle.id);
    });
  }

  void _stopWatching() {
    if (_realtimeChannel != null) {
      Supabase.instance.client.removeChannel(_realtimeChannel!);
      _realtimeChannel = null;
    }
  }

  // ── Create ────────────────────────────────────────────────────────────────

  Future<Battle> createBattle({
    required String courseId,
    required String courseName,
    required int holeCount,
    required List<int> coursePars,
    required List<BattlePokemon> team,
    required String challengerName,
  }) async {
    final battle = await _service.createBattle(
      courseId:       courseId,
      courseName:     courseName,
      holeCount:      holeCount,
      coursePars:     coursePars,
      team:           team,
      challengerName: challengerName,
    );
    _battles = [battle, ..._battles];
    notifyListeners();
    return battle;
  }

  // ── Join ──────────────────────────────────────────────────────────────────

  Future<Battle> joinBattle({
    required String battleId,
    required List<BattlePokemon> team,
  }) async {
    final updated = await _service.joinBattle(battleId: battleId, team: team);
    _upsertBattle(updated);
    return updated;
  }

  // ── Submit hole score ─────────────────────────────────────────────────────

  Future<Battle> submitHoleScore({
    required String battleId,
    required int hole,
    required int strokes,
  }) async {
    final updated = await _service.submitHoleScore(
      battleId: battleId,
      hole:     hole,
      strokes:  strokes,
    );
    _upsertBattle(updated);
    if (_watchedBattle?.id == battleId) {
      _watchedBattle = updated;
      if (updated.isCompleted) {
        _stopWatching();
        _maybeSaveScorecard(updated);
      }
    }
    notifyListeners();
    return updated;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _upsertBattle(Battle battle) {
    final idx = _battles.indexWhere((b) => b.id == battle.id);
    if (idx >= 0) {
      _battles = List<Battle>.from(_battles)..[idx] = battle;
    } else {
      _battles = [battle, ..._battles];
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _stopWatching();
    super.dispose();
  }
}

// ── BattleScope ───────────────────────────────────────────────────────────────

class BattleScope extends InheritedNotifier<BattleStore> {
  const BattleScope({
    super.key,
    required BattleStore notifier,
    required super.child,
  }) : super(notifier: notifier);

  static BattleStore of(BuildContext context) {
    final BattleScope? scope =
        context.dependOnInheritedWidgetOfExactType<BattleScope>();
    assert(scope != null, 'BattleScope not found in widget tree.');
    return scope!.notifier!;
  }
}
