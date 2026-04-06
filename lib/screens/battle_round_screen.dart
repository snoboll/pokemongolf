import 'package:flutter/material.dart';

import '../models/battle_models.dart';
import '../models/golf_score.dart';
import '../state/battle_store.dart';
import '../widgets/score_picker.dart';
import 'battle_result_screen.dart';

class BattleRoundScreen extends StatefulWidget {
  const BattleRoundScreen({super.key, required this.battleId});
  final String battleId;

  @override
  State<BattleRoundScreen> createState() => _BattleRoundScreenState();
}

class _BattleRoundScreenState extends State<BattleRoundScreen>
    with SingleTickerProviderStateMixin {
  GolfScore _selectedScore = GolfScore.par;
  bool _submitting = false;
  BattleHoleEvent? _pendingEvent; // resolved event to show before advancing
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _activeIndex(List<BattlePokemon> team) {
    for (int i = 0; i < team.length; i++) {
      if (team[i].isAlive) return i;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final store = BattleScope.of(context);
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final battle = store.watchedBattle;
        if (battle == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (battle.isCompleted && _pendingEvent == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _goToResult(context, store);
          });
        }

        final uid = store.currentUserId!;
        final isChallenger = battle.challengerId == uid;
        final myName = isChallenger ? battle.challengerName : (battle.opponentName ?? 'You');
        final theirName = isChallenger ? (battle.opponentName ?? 'Opponent') : battle.challengerName;

        final myTeam = isChallenger ? battle.currentChallengerTeam : battle.currentOpponentTeam;
        final theirTeam = isChallenger ? battle.currentOpponentTeam : battle.currentChallengerTeam;
        final resolvedHoles = battle.resolvedHoles;
        final myNextHole = battle.myNextHole(isChallenger);
        final isWaiting = battle.isWaiting(isChallenger);
        final currentHole = resolvedHoles + 1; // the hole we're working towards
        final par = battle.parForHole(currentHole);

        return Scaffold(
          appBar: AppBar(
            title: Column(
              children: [
                Text(battle.courseName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text('Hole $currentHole/${battle.holeCount}',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              ],
            ),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Battle'),
                Tab(text: 'Scorecard'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // ── Tab 0: Battle ──────────────────────────────────────────
              SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Team HP bars ───────────────────────────────────────────
                _TeamHpSection(
                  label: myName,
                  team: myTeam,
                  isMe: true,
                  activeIndex: _activeIndex(myTeam),
                ),
                const SizedBox(height: 8),
                _TeamHpSection(
                  label: theirName,
                  team: theirTeam,
                  isMe: false,
                  activeIndex: _activeIndex(theirTeam),
                ),
                const SizedBox(height: 28),

                // ── Pending event (show until dismissed) ───────────────────
                if (_pendingEvent != null) ...[
                  _HoleResultCard(
                    event:          _pendingEvent!,
                    isChallenger:   isChallenger,
                    myName:         myName,
                    theirName:      theirName,
                    onDismiss: () {
                      setState(() {
                        _pendingEvent = null;
                        _selectedScore = GolfScore.par;
                      });
                      if (battle.isCompleted) _goToResult(context, store);
                    },
                  ),
                  const SizedBox(height: 20),
                ] else if (battle.isPending) ...[
                  // ── Waiting for opponent to accept ─────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Waiting for $theirName to accept...',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Share your trainer name so they can find the challenge.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // ── Hole info ──────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Hole $currentHole',
                                style: theme.textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                            const SizedBox(width: 16),
                            Text('Par $par',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                )),
                          ],
                        ),
                        if (isWaiting) ...[
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Waiting for $theirName...',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          const SizedBox(height: 20),
                          ScorePicker(
                            par: par,
                            selected: _selectedScore,
                            onChanged: (s) => setState(() => _selectedScore = s),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _submitting
                                  ? null
                                  : () => _submit(context, store, battle, myNextHole, par),
                              icon: _submitting
                                  ? const SizedBox(width: 18, height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.send_rounded),
                              label: Text(_submitting ? 'Submitting...' : 'Submit Hole $myNextHole'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Hole log ───────────────────────────────────────────────
                if (battle.holeLog.isNotEmpty) ...[
                  Text('History',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      )),
                  const SizedBox(height: 8),
                  for (final event in battle.holeLog.reversed)
                    _HoleLogTile(
                      event:        event,
                      isChallenger: isChallenger,
                      myName:       myName,
                      theirName:    theirName,
                    ),
                ],
              ],
            ),
          ),
              // ── Tab 1: Scorecard ───────────────────────────────────────
              _BattleScorecardTab(
                battle:       battle,
                isChallenger: isChallenger,
                myName:       myName,
                theirName:    theirName,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit(
    BuildContext context,
    BattleStore store,
    Battle battle,
    int hole,
    int par,
  ) async {
    final strokes = par + _selectedScore.relativeToPar;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _submitting = true);
    try {
      final updated = await store.submitHoleScore(
        battleId: widget.battleId,
        hole:     hole,
        strokes:  strokes,
      );

      // If both players submitted and combat resolved, show the event
      if (updated.holeLog.isNotEmpty) {
        final lastEvent = updated.holeLog.last;
        if (lastEvent.hole == hole) {
          setState(() => _pendingEvent = lastEvent);
        }
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _goToResult(BuildContext context, BattleStore store) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BattleScope(
          notifier: store,
          child: BattleResultScreen(battleId: widget.battleId),
        ),
      ),
    );
  }
}

// ── _TeamHpSection ────────────────────────────────────────────────────────────

class _TeamHpSection extends StatelessWidget {
  const _TeamHpSection({
    required this.label,
    required this.team,
    required this.isMe,
    required this.activeIndex,
  });

  final String label;
  final List<BattlePokemon> team;
  final bool isMe;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isMe
            ? theme.colorScheme.primary.withValues(alpha: 0.07)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe
              ? theme.colorScheme.primary.withValues(alpha: 0.25)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isMe
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              )),
          const SizedBox(height: 10),
          if (team.isEmpty)
            Text('No team data yet',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4)))
          else
            for (int i = 0; i < team.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PokemonHpBar(
                  pokemon:  team[i],
                  isActive: i == activeIndex,
                ),
              ),
        ],
      ),
    );
  }
}

// ── _PokemonHpBar ─────────────────────────────────────────────────────────────

class _PokemonHpBar extends StatelessWidget {
  const _PokemonHpBar({required this.pokemon, this.isActive = false});
  final BattlePokemon pokemon;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final frac = pokemon.hpPercent.clamp(0.0, 1.0);
    final color = frac > 0.5
        ? theme.colorScheme.primary
        : frac > 0.25
            ? const Color(0xFFFFD700)
            : theme.colorScheme.error;

    return Opacity(
      opacity: pokemon.isAlive ? 1.0 : 0.4,
      child: Row(
        children: [
          // Active indicator: small triangle for first-alive Pokemon
          SizedBox(
            width: 12,
            child: isActive
                ? Icon(Icons.play_arrow,
                    size: 12, color: pokemon.isAlive ? const Color(0xFFFFD700) : Colors.transparent)
                : null,
          ),
          SizedBox(
            width: 36,
            height: 36,
            child: Image.network(
              pokemon.imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.catching_pokemon, size: 24),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(pokemon.name,
                        style: theme.textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text(
                      pokemon.isAlive
                          ? '${pokemon.hpCurrent}/${pokemon.hpMax}'
                          : 'KO',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: pokemon.isAlive
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.55)
                            : theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: frac,
                    minHeight: 6,
                    backgroundColor:
                        theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── _HoleResultCard ───────────────────────────────────────────────────────────

class _HoleResultCard extends StatelessWidget {
  const _HoleResultCard({
    required this.event,
    required this.isChallenger,
    required this.myName,
    required this.theirName,
    required this.onDismiss,
  });

  final BattleHoleEvent event;
  final bool isChallenger;
  final String myName;
  final String theirName;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myStrokes = isChallenger ? event.challengerStrokes : event.opponentStrokes;
    final theirStrokes = isChallenger ? event.opponentStrokes : event.challengerStrokes;

    final iWon = (isChallenger && event.result == BattleHoleResult.challengerWins) ||
        (!isChallenger && event.result == BattleHoleResult.opponentWins);
    final isTie = event.result == BattleHoleResult.tie;

    Color headerColor = isTie
        ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
        : iWon
            ? theme.colorScheme.primary
            : theme.colorScheme.error;
    String headline = isTie ? 'Tie — no damage' : iWon ? 'You win the hole!' : '$theirName wins the hole';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: headerColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: headerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hole ${event.hole}',
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
          const SizedBox(height: 4),
          Text(headline,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800, color: headerColor)),
          const SizedBox(height: 12),
          Row(
            children: [
              _ScorePill(name: myName, strokes: myStrokes, isWinner: iWon && !isTie),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('vs', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              _ScorePill(name: theirName, strokes: theirStrokes, isWinner: !iWon && !isTie),
            ],
          ),
          if (!isTie) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${event.attackerPokemonName} → ${event.defenderPokemonName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 8),
                _TypeMultBadge(mult: event.typeMult),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${event.damage} damage dealt',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onDismiss,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({
    required this.name,
    required this.strokes,
    required this.isWinner,
  });
  final String name;
  final int strokes;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(name,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            )),
        const SizedBox(height: 2),
        Text(
          '$strokes',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: isWinner ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}

class _TypeMultBadge extends StatelessWidget {
  const _TypeMultBadge({required this.mult});
  final double mult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSuper = mult >= 2.0;
    final isResisted = mult <= 0.5;
    final color = isSuper
        ? const Color(0xFFFF6B35)
        : isResisted
            ? const Color(0xFF90CAF9)
            : theme.colorScheme.onSurface.withValues(alpha: 0.4);
    final label = isSuper
        ? '${mult.toStringAsFixed(mult == mult.truncate() ? 0 : 1)}× super!'
        : isResisted
            ? '${mult.toStringAsFixed(mult == mult.truncate() ? 0 : 1)}× resisted'
            : '1× neutral';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ── _HoleLogTile ──────────────────────────────────────────────────────────────

class _HoleLogTile extends StatelessWidget {
  const _HoleLogTile({
    required this.event,
    required this.isChallenger,
    required this.myName,
    required this.theirName,
  });

  final BattleHoleEvent event;
  final bool isChallenger;
  final String myName;
  final String theirName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTie = event.result == BattleHoleResult.tie;
    final iWon = (isChallenger && event.result == BattleHoleResult.challengerWins) ||
        (!isChallenger && event.result == BattleHoleResult.opponentWins);

    final color = isTie
        ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
        : iWon
            ? theme.colorScheme.primary
            : theme.colorScheme.error;

    final myStrokes = isChallenger ? event.challengerStrokes : event.opponentStrokes;
    final theirStrokes = isChallenger ? event.opponentStrokes : event.challengerStrokes;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text('H${event.hole}',
                style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isTie
                  ? 'Tie ($myStrokes vs $theirStrokes)'
                  : iWon
                      ? 'Won — dealt ${event.damage} dmg ($myStrokes vs $theirStrokes)'
                      : 'Lost — took ${event.damage} dmg ($myStrokes vs $theirStrokes)',
              style: theme.textTheme.bodySmall,
            ),
          ),
          if (!isTie) _TypeMultBadge(mult: event.typeMult),
        ],
      ),
    );
  }
}

// ── _BattleScorecardTab ───────────────────────────────────────────────────────

class _BattleScorecardTab extends StatelessWidget {
  const _BattleScorecardTab({
    required this.battle,
    required this.isChallenger,
    required this.myName,
    required this.theirName,
  });

  final Battle battle;
  final bool isChallenger;
  final String myName;
  final String theirName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final log = battle.holeLog;

    if (log.isEmpty) {
      return Center(
        child: Text(
          'No holes played yet',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
      );
    }

    // Compute running totals for summary
    int myTotal = 0, theirTotal = 0;
    for (final e in log) {
      final my = isChallenger ? e.challengerStrokes : e.opponentStrokes;
      final their = isChallenger ? e.opponentStrokes : e.challengerStrokes;
      myTotal += my;
      theirTotal += their;
    }
    final totalPar = log.fold<int>(0, (s, e) => s + battle.parForHole(e.hole));

    final headerStyle = theme.textTheme.labelSmall!.copyWith(
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
    );

    return Column(
      children: [
        // Summary row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: theme.cardTheme.color,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ScoreStat(label: myName,    value: '$myTotal',    theme: theme, highlight: myTotal < theirTotal),
              _ScoreStat(label: 'Par',     value: '$totalPar',   theme: theme),
              _ScoreStat(label: theirName, value: '$theirTotal', theme: theme, highlight: theirTotal < myTotal),
            ],
          ),
        ),
        // Column headers
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: theme.colorScheme.surfaceContainerHigh,
          child: Row(
            children: [
              SizedBox(width: 40, child: Text('Hole', style: headerStyle)),
              SizedBox(width: 36, child: Text('Par',  style: headerStyle)),
              Expanded(child: Text(myName,    style: headerStyle)),
              Expanded(child: Text(theirName, style: headerStyle, textAlign: TextAlign.center)),
              SizedBox(width: 44, child: Text('Result', style: headerStyle, textAlign: TextAlign.right)),
            ],
          ),
        ),
        // Hole rows
        Expanded(
          child: ListView.builder(
            itemCount: battle.holeCount,
            itemBuilder: (context, index) {
              final holeNum = index + 1;
              final event = log.where((e) => e.hole == holeNum).firstOrNull;
              if (event == null) {
                // Hole not yet played
                return _ScorecardRow(
                  holeNum: holeNum,
                  par: battle.parForHole(holeNum),
                  myStrokes: null,
                  theirStrokes: null,
                  iWon: false,
                  isTie: false,
                  theme: theme,
                );
              }
              final my    = isChallenger ? event.challengerStrokes : event.opponentStrokes;
              final their = isChallenger ? event.opponentStrokes   : event.challengerStrokes;
              final iWon = (isChallenger && event.result == BattleHoleResult.challengerWins) ||
                  (!isChallenger && event.result == BattleHoleResult.opponentWins);
              return _ScorecardRow(
                holeNum:      holeNum,
                par:          battle.parForHole(holeNum),
                myStrokes:    my,
                theirStrokes: their,
                iWon:         iWon,
                isTie:        event.result == BattleHoleResult.tie,
                theme:        theme,
                showDivider:  holeNum == 9 && battle.holeCount == 18,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ScoreStat extends StatelessWidget {
  const _ScoreStat({required this.label, required this.value, required this.theme, this.highlight = false});
  final String label;
  final String value;
  final ThemeData theme;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: highlight ? theme.colorScheme.primary : null,
            )),
        Text(label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
            )),
      ],
    );
  }
}

class _ScorecardRow extends StatelessWidget {
  const _ScorecardRow({
    required this.holeNum,
    required this.par,
    required this.myStrokes,
    required this.theirStrokes,
    required this.iWon,
    required this.isTie,
    required this.theme,
    this.showDivider = false,
  });

  final int holeNum;
  final int par;
  final int? myStrokes;
  final int? theirStrokes;
  final bool iWon;
  final bool isTie;
  final ThemeData theme;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final dim = theme.colorScheme.onSurface.withValues(alpha: 0.25);
    Color? resultColor;
    String resultLabel = '';
    if (myStrokes != null) {
      if (isTie) {
        resultColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);
        resultLabel = 'Tie';
      } else if (iWon) {
        resultColor = theme.colorScheme.primary;
        resultLabel = 'Win';
      } else {
        resultColor = theme.colorScheme.error;
        resultLabel = 'Loss';
      }
    }

    return Column(
      children: [
        if (showDivider)
          Container(height: 3, color: theme.colorScheme.primary.withValues(alpha: 0.25)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          color: holeNum.isOdd
              ? Colors.transparent
              : theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text('$holeNum',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    )),
              ),
              SizedBox(
                width: 36,
                child: Text('$par',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                    )),
              ),
              Expanded(
                child: Text(
                  myStrokes != null ? '$myStrokes' : '-',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: myStrokes != null
                        ? iWon && !isTie
                            ? theme.colorScheme.primary
                            : null
                        : dim,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  theirStrokes != null ? '$theirStrokes' : '-',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theirStrokes != null
                        ? !iWon && !isTie
                            ? theme.colorScheme.error
                            : null
                        : dim,
                  ),
                ),
              ),
              SizedBox(
                width: 44,
                child: Text(
                  resultLabel,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: resultColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
