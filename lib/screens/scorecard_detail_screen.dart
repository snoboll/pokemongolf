import 'package:flutter/material.dart';

import '../models/golf_score.dart';
import '../models/pokemon_rarity.dart';
import '../models/round_models.dart';

class ScorecardDetailScreen extends StatelessWidget {
  const ScorecardDetailScreen({
    super.key,
    required this.holes,
    required this.holeCount,
    this.title = 'Scorecard',
    this.isActive = false,
    this.isBattle = false,
  });

  final List<HoleResult> holes;
  final int holeCount;
  final String title;
  final bool isActive;
  final bool isBattle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Map<int, HoleResult> holeMap = {
      for (final h in holes) h.holeNumber: h,
    };

    final int totalStrokes = holes.fold<int>(0, (t, h) => t + h.strokes);
    final int totalPar = holes.fold<int>(0, (t, h) => t + h.par);
    final int scoreToPar =
        holes.fold<int>(0, (t, h) => t + h.score.relativeToPar);
    final int caughtCount = holes.where((h) => h.caught).length;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: <Widget>[
          _SummaryBar(
            scoreToPar: scoreToPar,
            totalStrokes: totalStrokes,
            totalPar: totalPar,
            caughtCount: caughtCount,
            holesPlayed: holes.length,
            holeCount: holeCount,
            isBattle: isBattle,
          ),
          const SizedBox(height: 4),
          _TableHeader(theme: theme),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 32),
              itemCount: holeCount,
              itemBuilder: (context, index) {
                final int holeNum = index + 1;
                final HoleResult? result = holeMap[holeNum];
                return _HoleRow(
                  holeNumber: holeNum,
                  result: result,
                  showDivider: holeNum == 9 && holeCount == 18,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({
    required this.scoreToPar,
    required this.totalStrokes,
    required this.totalPar,
    required this.caughtCount,
    required this.holesPlayed,
    required this.holeCount,
    this.isBattle = false,
  });

  final int scoreToPar;
  final int totalStrokes;
  final int totalPar;
  final int caughtCount;
  final int holesPlayed;
  final int holeCount;
  final bool isBattle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.cardTheme.color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _Stat(
            value: formatScoreToPar(scoreToPar),
            label: 'Score',
            color: scoreToPar <= 0
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
          ),
          _Stat(value: '$totalStrokes', label: 'Strokes'),
          _Stat(value: '$totalPar', label: 'Par'),
          if (isBattle)
            const _Stat(value: '⚔️', label: 'Battle')
          else
            _Stat(value: '$caughtCount/$holesPlayed', label: 'Caught'),
          _Stat(value: '$holesPlayed/$holeCount', label: 'Thru'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.color});

  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: <Widget>[
        Text(value,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800, color: color)),
        Text(label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
            )),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final style = theme.textTheme.labelSmall!.copyWith(
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.surfaceContainerHigh,
      child: Row(
        children: <Widget>[
          SizedBox(width: 36, child: Text('Hole', style: style)),
          SizedBox(width: 36, child: Text('Par', style: style)),
          SizedBox(
            width: 48,
            child: Text('Score', style: style),
          ),
          SizedBox(width: 40, child: Text('+/-', style: style)),
          Expanded(
              child: Text('Pokemon', style: style, textAlign: TextAlign.right)),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _HoleRow extends StatelessWidget {
  const _HoleRow({
    required this.holeNumber,
    required this.result,
    required this.showDivider,
  });

  final int holeNumber;
  final HoleResult? result;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool played = result != null;
    final Color dimColor =
        theme.colorScheme.onSurface.withValues(alpha: 0.2);
    final TextStyle baseStyle = theme.textTheme.bodyMedium!;
    final TextStyle dimStyle = baseStyle.copyWith(color: dimColor);

    Color? scoreColor;
    if (played) {
      final int rel = result!.score.relativeToPar;
      if (rel < 0) {
        scoreColor = const Color(0xFF4CAF50);
      } else if (rel > 0) {
        scoreColor = const Color(0xFFE57373);
      }
    }

    return Column(
      children: <Widget>[
        if (showDivider)
          Container(
            height: 3,
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: holeNumber.isOdd
              ? Colors.transparent
              : theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 36,
                child: Text(
                  '$holeNumber',
                  style: baseStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  played ? '${result!.par}' : '-',
                  style: played
                      ? baseStyle.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.45))
                      : dimStyle,
                ),
              ),
              SizedBox(
                width: 48,
                child: played
                    ? _ScoreCell(result: result!, scoreColor: scoreColor)
                    : Text('-', style: dimStyle),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  played ? result!.score.shortLabel : '',
                  style: baseStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scoreColor ??
                        theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: played
                    ? _PokemonCell(result: result!)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScoreCell extends StatelessWidget {
  const _ScoreCell({required this.result, this.scoreColor});

  final HoleResult result;
  final Color? scoreColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int rel = result.score.relativeToPar;
    final TextStyle style = theme.textTheme.bodyMedium!.copyWith(
      fontWeight: FontWeight.w700,
      color: scoreColor,
    );

    final Widget text = Text('${result.strokes}', style: style);

    if (rel < 0) {
      final int circles = rel.abs().clamp(1, 2);
      return SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            for (int i = 0; i < circles; i++)
              Container(
                width: 22.0 + i * 8,
                height: 22.0 + i * 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: scoreColor!, width: 1.2),
                ),
              ),
            text,
          ],
        ),
      );
    } else if (rel > 0) {
      final int squares = rel.clamp(1, 2);
      return SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            for (int i = 0; i < squares; i++)
              Container(
                width: 22.0 + i * 8,
                height: 22.0 + i * 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: scoreColor!, width: 1.2),
                ),
              ),
            text,
          ],
        ),
      );
    }

    return SizedBox(
      width: 36,
      height: 36,
      child: Center(child: text),
    );
  }
}

class _PokemonCell extends StatelessWidget {
  const _PokemonCell({required this.result});

  final HoleResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Battle sentinel (dex=0) — show swords emoji, no catch indicator
    if (result.pokemon.dexNumber == 0) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text('⚔️', style: TextStyle(fontSize: 18)),
          SizedBox(width: 4),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Flexible(
          child: Text(
            result.pokemon.name,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(width: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            width: 28,
            height: 28,
            child: Image.network(
              result.pokemon.imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) => Icon(
                Icons.catching_pokemon,
                size: 18,
                color: result.pokemon.rarity.color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          result.caught ? Icons.check_circle : Icons.close,
          size: 16,
          color: result.caught
              ? theme.colorScheme.primary
              : theme.colorScheme.error.withValues(alpha: 0.35),
        ),
      ],
    );
  }
}
