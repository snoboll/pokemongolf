import 'package:flutter/material.dart';

import '../app.dart';
import '../models/battle_models.dart';
import '../models/course_leader.dart';
import '../models/golf_score.dart';
import '../models/hole_stats.dart';
import '../models/bogeybeast_species.dart';
import '../models/round_models.dart';
import '../state/battle_store.dart';
import 'round_screen.dart';
import 'team_select_screen.dart';

class BattleResultScreen extends StatelessWidget {
  const BattleResultScreen({super.key, required this.battleId});
  final String battleId;

  @override
  Widget build(BuildContext context) {
    final store = BattleScope.of(context);
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        Battle? battle = store.watchedBattle?.id == battleId
            ? store.watchedBattle
            : store.battles.where((b) => b.id == battleId).firstOrNull;

        if (battle == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final uid = store.currentUserId!;
        final isChallenger = battle.challengerId == uid;
        final myName = isChallenger ? battle.challengerName : (battle.opponentName ?? 'You');
        final theirName = isChallenger ? (battle.opponentName ?? 'Opponent') : battle.challengerName;
        final won = battle.winnerId == uid;

        final myTeam = isChallenger ? battle.currentChallengerTeam : battle.currentOpponentTeam;
        final theirTeam = isChallenger ? battle.currentOpponentTeam : battle.currentChallengerTeam;

        final primaryColor = won ? theme.colorScheme.primary : theme.colorScheme.error;
        final headline = won ? 'Victory!' : 'Defeated';

        return Scaffold(
          appBar: AppBar(
            title: Text('${battle.courseName} · Battle'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Result banner ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        won ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied_rounded,
                        size: 56,
                        color: primaryColor,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        headline,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        battle.holeLog.length < battle.holeCount
                            ? 'KO on hole ${battle.holeLog.length} of ${battle.holeCount} · ${battle.courseName}'
                            : '${battle.holeLog.length} holes played · ${battle.courseName}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Final team states ──────────────────────────────────────
                _FinalTeamCard(
                  label: myName,
                  team: myTeam,
                  isMe: true,
                ),
                const SizedBox(height: 12),
                _FinalTeamCard(
                  label: theirName,
                  team: theirTeam,
                  isMe: false,
                ),
                const SizedBox(height: 24),

                // ── Hole log ───────────────────────────────────────────────
                Text('Hole Summary',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                _SummaryTable(
                  holeLog:      battle.holeLog,
                  isChallenger: isChallenger,
                  myName:       myName,
                  theirName:    theirName,
                ),
                const SizedBox(height: 32),

                // ── Claim leadership if this was a leader challenge and player won ─
                if (battle.isLeaderChallenge && won)
                  _ClaimLeadershipSection(battle: battle),

                // ── Continue to catch mode if holes remain ─────────────────
                Builder(builder: (context) {
                  final remainingHoles = battle.holeCount - battle.holeLog.length;
                  final remainingPars = battle.coursePars.length >= battle.holeCount
                      ? battle.coursePars.sublist(battle.holeLog.length)
                      : <int>[];

                  if (remainingHoles > 0 && remainingPars.isNotEmpty) {
                    final startHole = battle.holeLog.length + 1;
                    // Pre-build HoleResult objects for the battle holes so they
                    // land in the same scorecard as the catch holes.
                    final battleHoles = battle.holeLog.map((event) {
                      final strokes = isChallenger
                          ? event.challengerStrokes
                          : event.opponentStrokes;
                      final par = battle.parForHole(event.hole);
                      return HoleResult(
                        holeNumber:  event.hole,
                        par:         par,
                        strokes:     strokes,
                        bogeybeast:     battleSentinelBogeybeast,
                        score:       scoreFromStrokes(par, strokes),
                        catchChance: 0,
                        caught:      false,
                        stats:       const HoleStats(),
                      );
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton.icon(
                          onPressed: () {
                            final bogeybeastStore = BogeybeastGolfScope.of(context);
                            bogeybeastStore.startRound(
                              battle.holeCount,
                              holePars:          battle.coursePars,
                              courseName:        battle.courseName,
                              startingHoleNumber: startHole,
                              prefilledHoles:    battleHoles,
                            );
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            Navigator.of(context).push(MaterialPageRoute<void>(
                              builder: (_) => const RoundScreen(),
                            ));
                          },
                          icon: const Icon(Icons.pets),
                          label: Text(
                              'Catch Mode — $remainingHoles holes left'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => Navigator.of(context)
                              .popUntil((route) => route.isFirst),
                          child: const Text('Back to Clubhouse'),
                        ),
                      ],
                    );
                  }

                  return FilledButton(
                    onPressed: () => Navigator.of(context)
                        .popUntil((route) => route.isFirst),
                    child: const Text('Back to Clubhouse'),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── _FinalTeamCard ────────────────────────────────────────────────────────────

class _FinalTeamCard extends StatelessWidget {
  const _FinalTeamCard({
    required this.label,
    required this.team,
    required this.isMe,
  });

  final String label;
  final List<BattleBogeybeast> team;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alive = team.where((p) => p.isAlive).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label,
                  style: theme.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(
                '$alive/${team.length} standing',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: alive > 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: team.map((p) => _BogeybeastResultPip(bogeybeast: p)).toList(),
          ),
        ],
      ),
    );
  }
}

class _BogeybeastResultPip extends StatelessWidget {
  const _BogeybeastResultPip({required this.bogeybeast});
  final BattleBogeybeast bogeybeast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final frac = bogeybeast.hpPercent.clamp(0.0, 1.0);
    final barColor = bogeybeast.isAlive
        ? (frac > 0.5
            ? theme.colorScheme.primary
            : frac > 0.25
                ? const Color(0xFFFFD700)
                : theme.colorScheme.error)
        : theme.colorScheme.onSurface.withValues(alpha: 0.2);

    return Opacity(
      opacity: bogeybeast.isAlive ? 1.0 : 0.4,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: Image.network(
                bogeybeast.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.pets, size: 36),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              bogeybeast.name,
              style: theme.textTheme.labelSmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: frac,
                minHeight: 5,
                backgroundColor:
                    theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
            Text(
              bogeybeast.isAlive
                  ? '${bogeybeast.hpCurrent}hp'
                  : 'KO',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 9,
                color: bogeybeast.isAlive
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                    : theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _SummaryTable ─────────────────────────────────────────────────────────────

class _SummaryTable extends StatelessWidget {
  const _SummaryTable({
    required this.holeLog,
    required this.isChallenger,
    required this.myName,
    required this.theirName,
  });

  final List<BattleHoleEvent> holeLog;
  final bool isChallenger;
  final String myName;
  final String theirName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int myWins = 0;
    int theirWins = 0;
    int ties = 0;

    for (final e in holeLog) {
      if (e.result == BattleHoleResult.tie) {
        ties++;
      } else if ((isChallenger && e.result == BattleHoleResult.challengerWins) ||
          (!isChallenger && e.result == BattleHoleResult.opponentWins)) {
        myWins++;
      } else {
        theirWins++;
      }
    }

    return Column(
      children: [
        // Score tally
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _TallyItem(label: myName, value: myWins, color: theme.colorScheme.primary),
              _TallyItem(label: 'Tied', value: ties,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
              _TallyItem(label: theirName, value: theirWins, color: theme.colorScheme.error),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Per-hole rows
        for (final event in holeLog)
          _HoleSummaryRow(
            event:        event,
            isChallenger: isChallenger,
          ),
      ],
    );
  }
}

class _TallyItem extends StatelessWidget {
  const _TallyItem({required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          '$value',
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800, color: color),
        ),
        Text(label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
      ],
    );
  }
}

class _HoleSummaryRow extends StatelessWidget {
  const _HoleSummaryRow({required this.event, required this.isChallenger});
  final BattleHoleEvent event;
  final bool isChallenger;

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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text('H${event.hole}',
                style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
          ),
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 10),
          Text('$myStrokes vs $theirStrokes',
              style: theme.textTheme.bodySmall),
          const SizedBox(width: 8),
          if (!isTie)
            Expanded(
              child: Text(
                '${event.attackerBogeybeastName} → ${event.defenderBogeybeastName} '
                '(${event.damage} dmg, ${event.typeMult.toStringAsFixed(1)}×)',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55)),
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            Expanded(
              child: Text('Tie',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
            ),
        ],
      ),
    );
  }
}

// ── _ClaimLeadershipSection ──────────────────────────────────────────────────

class _ClaimLeadershipSection extends StatefulWidget {
  const _ClaimLeadershipSection({required this.battle});
  final Battle battle;

  @override
  State<_ClaimLeadershipSection> createState() => _ClaimLeadershipSectionState();
}

class _ClaimLeadershipSectionState extends State<_ClaimLeadershipSection> {
  bool _claimed = false;
  bool _claiming = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const amber = Color(0xFFFFD700);

    if (_claimed) {
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: amber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: amber.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.emoji_events, color: amber, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'You are the new Course Leader!',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: amber,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: amber, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Claim the course!',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Pick 3 Bogeybeast to defend the course as Leader.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _claiming ? null : _startClaim,
            icon: _claiming
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('⚔️', style: TextStyle(fontSize: 14)),
            label: Text(_claiming ? 'Claiming...' : 'Assign Defenders'),
            style: FilledButton.styleFrom(
              backgroundColor: amber,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startClaim() async {
    final bogeybeastStore = BogeybeastGolfScope.of(context);
    final battleStore = BattleScope.of(context);

    final team = await Navigator.of(context).push<List<BattleBogeybeast>>(
      MaterialPageRoute(
        builder: (_) => TeamSelectScreen(
          caughtDexNumbers: Set<int>.from(bogeybeastStore.caughtDexNumbers),
          title: 'Pick defenders',
        ),
      ),
    );
    if (team == null || !mounted) return;

    setState(() => _claiming = true);
    try {
      await battleStore.claimCourseLeadership(
        courseId:     widget.battle.courseId,
        battleId:     widget.battle.id,
        defenderTeam: team,
      );

      if (mounted) {
        bogeybeastStore.updateCourseLeader(CourseLeader(
          courseId: widget.battle.courseId,
          userId: battleStore.currentUserId,
          leaderName: bogeybeastStore.golferName ?? 'Golfer',
          hcp: bogeybeastStore.playerHcp.round(),
          team: team,
          isNpc: false,
        ));
        setState(() {
          _claimed = true;
          _claiming = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _claiming = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to claim: $e')),
        );
      }
    }
  }
}
