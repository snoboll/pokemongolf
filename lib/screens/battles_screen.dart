import 'package:flutter/material.dart';

import '../app.dart';
import '../models/battle_models.dart';
import '../models/golf_course.dart';
import '../services/battle_service.dart';
import '../state/battle_store.dart';
import 'team_select_screen.dart';
import 'battle_round_screen.dart';
import 'battle_result_screen.dart';

// ── Entry point: BattleFlow ───────────────────────────────────────────────────

/// Initialises BattleStore and provides it to the battles sub-tree.
/// Push this from HomeScreen.
class BattleFlow extends StatefulWidget {
  const BattleFlow({super.key});

  @override
  State<BattleFlow> createState() => _BattleFlowState();
}

class _BattleFlowState extends State<BattleFlow> {
  late final BattleStore _store;

  @override
  void initState() {
    super.initState();
    _store = BattleStore(service: BattleService());
    _store.loadBattles();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BattleScope(
      notifier: _store,
      child: const BattlesScreen(),
    );
  }
}

// ── BattlesScreen ─────────────────────────────────────────────────────────────

class BattlesScreen extends StatelessWidget {
  const BattlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final battleStore  = BattleScope.of(context);
    final bogeybeastStore = BogeybeastGolfScope.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Battle Mode'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _newBattle(context, bogeybeastStore, battleStore),
        icon: const Icon(Icons.add),
        label: const Text('Challenge'),
      ),
      body: ListenableBuilder(
        listenable: battleStore,
        builder: (context, _) {
          if (battleStore.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final uid = battleStore.currentUserId;
          final all = battleStore.battles;
          final mine = all.where((b) => b.challengerId == uid || b.opponentId == uid).toList();
          final open = all.where((b) => b.isPending && b.challengerId != uid).toList();

          if (mine.isEmpty && open.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('⚔️',
                        style: TextStyle(
                          fontSize: 56,
                          color: theme.colorScheme.primary.withValues(alpha: 0.6),
                        )),
                    const SizedBox(height: 16),
                    Text('No battles yet',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(
                      'Tap Challenge to invite another golfer.\nPick 3 Bogeybeast and a course.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: battleStore.loadBattles,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                if (open.isNotEmpty) ...[
                  _sectionHeader(theme, 'Open challenges'),
                  for (final b in open)
                    _BattleCard(
                      battle:      b,
                      uid:         uid!,
                      onTap:       () => _openChallenge(context, b, bogeybeastStore, battleStore),
                    ),
                  const SizedBox(height: 16),
                ],
                if (mine.isNotEmpty) ...[
                  _sectionHeader(theme, 'My battles'),
                  for (final b in mine)
                    _BattleCard(
                      battle:      b,
                      uid:         uid!,
                      onTap:       () => _openMine(context, b, battleStore),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionHeader(ThemeData theme, String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              letterSpacing: 0.8,
            )),
      );

  void _newBattle(BuildContext context, dynamic bogeybeastStore, BattleStore battleStore) async {
    final courses = (bogeybeastStore.catalogCourses as List<GolfCourse>)
        .where((c) => c.flatPars.isNotEmpty)
        .toList();

    if (courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No courses available')),
      );
      return;
    }

    // Step 1: pick course + hole count
    final pick = await showModalBottomSheet<({GolfCourse course, int holeCount})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CoursePickerSheet(courses: courses),
    );
    if (pick == null || !context.mounted) return;

    // Step 2: pick team
    final team = await Navigator.of(context).push<List<BattleBogeybeast>>(
      MaterialPageRoute(
        builder: (_) => BattleScope(
          notifier: battleStore,
          child: TeamSelectScreen(
            caughtDexNumbers: Set<int>.from(bogeybeastStore.caughtDexNumbers),
            title: 'Pick your team',
          ),
        ),
      ),
    );
    if (team == null || !context.mounted) return;

    try {
      final pars = pick.course.flatPars.take(pick.holeCount).toList();
      final battle = await battleStore.createBattle(
        courseId:       pick.course.id,
        courseName:     pick.course.name,
        holeCount:      pick.holeCount,
        coursePars:     pars,
        team:           team,
        challengerName: bogeybeastStore.golferName ?? 'Golfer',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Challenge created! Share with ${pick.course.name}')),
        );
        _openMine(context, battle, battleStore);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _openChallenge(BuildContext context, Battle battle, dynamic bogeybeastStore, BattleStore battleStore) async {
    // Opponent joining: pick team then join
    final team = await Navigator.of(context).push<List<BattleBogeybeast>>(
      MaterialPageRoute(
        builder: (_) => BattleScope(
          notifier: battleStore,
          child: TeamSelectScreen(
            caughtDexNumbers: Set<int>.from(bogeybeastStore.caughtDexNumbers),
            title: 'Pick your team to accept',
          ),
        ),
      ),
    );
    if (team == null || !context.mounted) return;

    try {
      final updated = await battleStore.joinBattle(
        battleId: battle.id,
        team:     team,
      );
      if (context.mounted) {
        _openMine(context, updated, battleStore);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _openMine(BuildContext context, Battle battle, BattleStore battleStore) {
    if (battle.isCompleted) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => BattleScope(
          notifier: battleStore,
          child: BattleResultScreen(battleId: battle.id),
        ),
      ));
    } else {
      battleStore.watchBattle(battle.id);
      Navigator.of(context)
          .push(MaterialPageRoute(
            builder: (_) => BattleScope(
              notifier: battleStore,
              child: BattleRoundScreen(battleId: battle.id),
            ),
          ))
          .then((_) => battleStore.stopWatching());
    }
  }
}

// ── _BattleCard ───────────────────────────────────────────────────────────────

class _BattleCard extends StatelessWidget {
  const _BattleCard({
    required this.battle,
    required this.uid,
    required this.onTap,
  });

  final Battle battle;
  final String uid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isChallenger = battle.challengerId == uid;
    final otherName = isChallenger
        ? (battle.opponentName ?? '???')
        : battle.challengerName;
    final isPending = battle.isPending;
    final isCompleted = battle.isCompleted;

    Color statusColor = theme.colorScheme.primary;
    String statusLabel = 'Active';
    if (isPending && !isChallenger) {
      statusColor = const Color(0xFFFFD700);
      statusLabel = 'Accept?';
    } else if (isPending && isChallenger) {
      statusColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);
      statusLabel = 'Waiting';
    } else if (isCompleted) {
      final won = battle.winnerId == uid;
      statusColor = won ? theme.colorScheme.primary : theme.colorScheme.error;
      statusLabel = won ? 'Won' : 'Lost';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Text('⚔️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPending && !isChallenger
                          ? 'From ${battle.challengerName}'
                          : 'vs $otherName',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${battle.courseName} · ${battle.holeCount} holes',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── _CoursePickerSheet ────────────────────────────────────────────────────────

class _CoursePickerSheet extends StatefulWidget {
  const _CoursePickerSheet({required this.courses});
  final List<GolfCourse> courses;

  @override
  State<_CoursePickerSheet> createState() => _CoursePickerSheetState();
}

class _CoursePickerSheetState extends State<_CoursePickerSheet> {
  GolfCourse? _selected;
  int _holeCount = 18;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('Choose course', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [9, 18].map((n) {
                final active = _holeCount == n;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: FilterChip(
                    label: Text('$n holes'),
                    selected: active,
                    onSelected: (_) => setState(() => _holeCount = n),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                controller: controller,
                itemCount: widget.courses.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final c = widget.courses[i];
                  final pars = c.flatPars;
                  if (pars.length < _holeCount) return const SizedBox.shrink();
                  final isSelected = _selected?.id == c.id;
                  return ListTile(
                    title: Text(c.name),
                    subtitle: Text('Par ${pars.take(_holeCount).reduce((a, b) => a + b)}'),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                        : null,
                    onTap: () => setState(() => _selected = c),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selected == null
                    ? null
                    : () => Navigator.of(context)
                        .pop((course: _selected!, holeCount: _holeCount)),
                child: const Text('Next: Pick Team'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
