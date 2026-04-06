import 'package:flutter/material.dart';

import '../app.dart';
import '../models/golf_score.dart';
import '../models/pokemon_rarity.dart';
import '../models/round_models.dart';
import 'scorecard_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PokemonGolfScope.of(context);
    final theme = Theme.of(context);
    final List<GolfRoundSummary> rounds = store.completedRounds;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Text(
              'Scorecards',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: rounds.isEmpty
                ? _EmptyState(theme: theme)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: rounds.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int index) {
                      final round = rounds[index];
                      return Dismissible(
                        key: ValueKey(round.id ?? round.completedAt.toIso8601String()),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete scorecard?'),
                              content: const Text(
                                  'This round will be permanently removed.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, true),
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Theme.of(ctx).colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ) ?? false;
                        },
                        onDismissed: (_) {
                          PokemonGolfScope.of(context).deleteRound(round);
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ScorecardDetailScreen(
                                  holes: round.holes,
                                  holeCount: round.holeCount,
                                  isBattle: round.isBattle,
                                  title: round.courseName != null
                                      ? '${round.isBattle ? '⚔️ ' : ''}${round.courseName}'
                                      : '${round.holeCount}H · ${_formatDate(round.completedAt)}',
                                ),
                              ),
                            );
                          },
                          child: _RoundCard(round: round),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime dt) {
  final String month = dt.month.toString().padLeft(2, '0');
  final String day = dt.day.toString().padLeft(2, '0');
  return '$month/$day/${dt.year}';
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.golf_course_outlined,
            size: 56,
            color: theme.colorScheme.outline.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No rounds yet',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete a round to see your scorecards here.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundCard extends StatelessWidget {
  const _RoundCard({required this.round});

  final GolfRoundSummary round;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String caughtNames = round.isBattle || round.caughtPokemon.isEmpty
        ? ''
        : round.caughtPokemon.take(4).map((p) => p.name).join(', ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${round.holeCount}H',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _formatTimestamp(round.completedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                    if (round.courseName != null)
                      Text(
                        round.courseName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    formatScoreToPar(round.scoreToPar),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: round.scoreToPar <= 0
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                    ),
                  ),
                  Text(
                    '${round.totalStrokes} strokes',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (round.isBattle) ...<Widget>[
            Row(
              children: <Widget>[
                const Text('⚔️', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  'Battle Mode · ${round.holes.length} holes',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ] else ...<Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.catching_pokemon,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 6),
                Text(
                  '${round.caughtCount}/${round.holes.length} caught',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.flag,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 4),
                Text(
                  '${round.onePuttCount} 1-putt',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                if (round.highestRarityCaught != null) ...<Widget>[
                  const SizedBox(width: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: round.highestRarityCaught!.color
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      round.highestRarityCaught!.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: round.highestRarityCaught!.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (round.caughtPokemon.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                caughtNames,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String day = dateTime.day.toString().padLeft(2, '0');
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    return '$month/$day/${dateTime.year} $hour:$minute';
  }
}
