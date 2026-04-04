import 'dart:math';

import 'package:flutter/material.dart';

import '../app.dart';
import '../models/golf_score.dart';
import '../models/hole_stats.dart';
import '../models/pokemon_rarity.dart';
import '../models/round_models.dart';
import '../widgets/pokemon_art.dart';
import '../widgets/score_picker.dart';
import 'scorecard_detail_screen.dart';

class RoundScreen extends StatefulWidget {
  const RoundScreen({super.key});

  @override
  State<RoundScreen> createState() => _RoundScreenState();
}

class _RoundScreenState extends State<RoundScreen> {
  int _par = 4;
  GolfScore _selectedScore = GolfScore.par;
  HoleStats _holeStats = const HoleStats();
  HoleResolution? _resolution;

  int get _strokes => _par + _selectedScore.relativeToPar;

  void _confirmExitAndSave(BuildContext context, dynamic store) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save & exit?'),
        content: const Text(
            'Your completed holes will be saved as a scorecard.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save & exit'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        store.endRoundEarly();
        Navigator.of(context).pop();
      }
    });
  }

  void _confirmExitAndDiscard(BuildContext context, dynamic store) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard round?'),
        content: const Text(
            'All progress for this round will be lost.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        store.discardRound();
        Navigator.of(context).pop();
      }
    });
  }

  void _resetForNextHole() {
    final store = PokemonGolfScope.of(context);
    final nextPar = store.activeRound?.currentHolePar;
    setState(() {
      _par = nextPar ?? 4;
      _selectedScore = GolfScore.par;
      _holeStats = const HoleStats();
      _resolution = null;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = PokemonGolfScope.of(context);
    final coursePar = store.activeRound?.currentHolePar;
    if (coursePar != null && _resolution == null) {
      _par = coursePar;
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = PokemonGolfScope.of(context);
    final ActiveRound? activeRound = store.activeRound;

    if (_resolution != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Result')),
        body: _HoleResolutionView(
          resolution: _resolution!,
          onContinue: () {
            if (_resolution!.roundCompleted) {
              Navigator.of(context).pop();
              return;
            }
            _resetForNextHole();
          },
        ),
      );
    }

    if (activeRound == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.golf_course_outlined, size: 56),
              const SizedBox(height: 16),
              Text('No active round',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    }

    final double progress =
        (activeRound.currentHoleNumber - 1) / activeRound.holeCount;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Hole ${activeRound.currentHoleNumber} / ${activeRound.holeCount}'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(formatScoreToPar(activeRound.scoreToPar),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(width: 12),
                Icon(Icons.catching_pokemon,
                    size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Text('${activeRound.caughtCount}',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                if (activeRound.parOrBetterStreak >= 2) ...<Widget>[
                  const SizedBox(width: 12),
                  Icon(Icons.local_fire_department,
                      size: 16, color: const Color(0xFFFFB300)),
                  const SizedBox(width: 2),
                  Text('${activeRound.parOrBetterStreak}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFB300),
                      )),
                ],
              ],
            ),
          ),
          if (activeRound.completedHoles.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.scoreboard_outlined, size: 22),
              tooltip: 'View scorecard',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ScorecardDetailScreen(
                      holes: activeRound.completedHoles,
                      holeCount: activeRound.holeCount,
                      title: 'Current Round',
                      isActive: true,
                    ),
                  ),
                );
              },
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 22),
            onSelected: (value) {
              if (value == 'save') {
                _confirmExitAndSave(context, store);
              } else if (value == 'discard') {
                _confirmExitAndDiscard(context, store);
              }
            },
            itemBuilder: (_) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'save',
                child: Text('Exit & save'),
              ),
              const PopupMenuItem<String>(
                value: 'discard',
                child: Text('Exit & discard'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          LinearProgressIndicator(
            value: progress,
            minHeight: 3,
            backgroundColor: theme.colorScheme.surfaceContainerHigh,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  PokemonArt(
                    imageUrl: activeRound.currentEncounter.imageUrl,
                    height: 180,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    activeRound.currentEncounter.name,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '#${activeRound.currentEncounter.paddedDexNumber}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: activeRound.currentEncounter.rarity.color
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          activeRound.currentEncounter.rarity.label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color:
                                activeRound.currentEncounter.rarity.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  if (activeRound.currentHolePar != null) ...<Widget>[
                    Row(
                      children: <Widget>[
                        Text('Par ${activeRound.currentHolePar}',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        if (activeRound.courseName != null) ...<Widget>[
                          const SizedBox(width: 8),
                          Text(
                            activeRound.courseName!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ] else ...<Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Hole par',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 10),
                    _ParSelector(
                      selected: _par,
                      onChanged: (v) => setState(() => _par = v),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Your score',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 10),
                  ScorePicker(
                    par: _par,
                    selected: _selectedScore,
                    onChanged: (GolfScore score) {
                      setState(() => _selectedScore = score);
                    },
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Hole stats',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      _StatToggle(
                        label: '1-Putt',
                        icon: Icons.sports_golf,
                        active: _holeStats.onePutt,
                        activeColor: const Color(0xFF7E57C2),
                        onToggle: () => setState(() =>
                            _holeStats =
                                _holeStats.copyWith(onePutt: !_holeStats.onePutt)),
                      ),
                      const SizedBox(width: 8),
                      _StatToggle(
                        label: 'Bunker',
                        icon: Icons.landscape,
                        active: _holeStats.bunker,
                        activeColor: const Color(0xFFFFB74D),
                        onToggle: () => setState(() =>
                            _holeStats = _holeStats.copyWith(
                                bunker: !_holeStats.bunker)),
                      ),
                      const SizedBox(width: 8),
                      _StatToggle(
                        label: 'Water',
                        icon: Icons.water_drop,
                        active: _holeStats.water,
                        activeColor: const Color(0xFF42A5F5),
                        onToggle: () => setState(() =>
                            _holeStats = _holeStats.copyWith(
                                water: !_holeStats.water)),
                      ),
                      const SizedBox(width: 8),
                      _StatToggle(
                        label: 'Rough',
                        icon: Icons.grass,
                        active: _holeStats.rough,
                        activeColor: const Color(0xFF66BB6A),
                        onToggle: () => setState(() =>
                            _holeStats = _holeStats.copyWith(
                                rough: !_holeStats.rough)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          _resolution = store.playCurrentHole(
                            par: _par,
                            strokes: _strokes,
                            stats: _holeStats,
                          );
                        });
                      },
                      icon: const Icon(Icons.catching_pokemon),
                      label: const Text('Throw Pokeball'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParSelector extends StatelessWidget {
  const _ParSelector({
    required this.selected,
    required this.onChanged,
  });

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: <int>[3, 4, 5].map((par) {
        final bool isSelected = selected == par;
        final Color color = isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.4);

        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(par),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? color.withValues(alpha: 0.4)
                      : theme.colorScheme.outlineVariant,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '$par',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(growable: false),
    );
  }
}

class _StatToggle extends StatelessWidget {
  const _StatToggle({
    required this.label,
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onToggle,
  });

  final String label;
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? activeColor.withValues(alpha: 0.15)
                : theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? activeColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 20,
                color: active
                    ? activeColor
                    : theme.colorScheme.onSurface.withValues(alpha: 0.35),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active
                      ? activeColor
                      : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoleResolutionView extends StatefulWidget {
  const _HoleResolutionView({
    required this.resolution,
    required this.onContinue,
  });

  final HoleResolution resolution;
  final VoidCallback onContinue;

  @override
  State<_HoleResolutionView> createState() => _HoleResolutionViewState();
}

class _HoleResolutionViewState extends State<_HoleResolutionView>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  late final AnimationController _confettiController;
  late final List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    final bool caught = widget.resolution.holeResult.caught;

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInBack,
    ));

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    final rng = Random();
    _particles = List<_ConfettiParticle>.generate(
      30,
      (_) => _ConfettiParticle(
        x: rng.nextDouble(),
        speed: 0.5 + rng.nextDouble() * 0.8,
        drift: (rng.nextDouble() - 0.5) * 0.6,
        size: 4 + rng.nextDouble() * 6,
        color: [
          const Color(0xFF4CAF50),
          const Color(0xFFFFB300),
          const Color(0xFF1E88E5),
          const Color(0xFFE53935),
          const Color(0xFF8E24AA),
        ][rng.nextInt(5)],
      ),
    );

    if (caught) {
      _confettiController.forward();
    } else {
      Future<void>.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _slideController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HoleResult result = widget.resolution.holeResult;
    final theme = Theme.of(context);

    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            children: <Widget>[
              Icon(
                result.caught ? Icons.catching_pokemon : Icons.close,
                size: 56,
                color: result.caught
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                result.caught ? 'Caught!' : 'It broke free...',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                '${result.pokemon.name}  ·  ${result.score.label}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              SlideTransition(
                position: _slideAnimation,
                child: PokemonArt(
                  imageUrl: result.pokemon.imageUrl,
                  height: 200,
                ),
              ),
              const SizedBox(height: 24),
              if (widget.resolution.roundCompleted &&
                  widget.resolution.roundSummary != null)
                _RoundCompleteCard(
                    summary: widget.resolution.roundSummary!),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: widget.onContinue,
                  child: Text(
                    widget.resolution.roundCompleted
                        ? 'Back to clubhouse'
                        : 'Hole ${widget.resolution.nextHoleNumber}',
                  ),
                ),
              ),
            ],
          ),
        ),
        if (result.caught)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _confettiController,
                builder: (BuildContext context, Widget? child) {
                  return CustomPaint(
                    painter: _ConfettiPainter(
                      particles: _particles,
                      progress: _confettiController.value,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiParticle {
  const _ConfettiParticle({
    required this.x,
    required this.speed,
    required this.drift,
    required this.size,
    required this.color,
  });

  final double x;
  final double speed;
  final double drift;
  final double size;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.progress});

  final List<_ConfettiParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final double opacity = (1.0 - progress).clamp(0.0, 1.0);
    if (opacity <= 0) {
      return;
    }

    for (final p in particles) {
      final double y = -20 + progress * p.speed * size.height * 1.3;
      final double x = p.x * size.width + progress * p.drift * size.width;

      final Paint paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: p.size, height: p.size * 1.4),
          Radius.circular(p.size * 0.3),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _RoundCompleteCard extends StatelessWidget {
  const _RoundCompleteCard({required this.summary});

  final GolfRoundSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: <Widget>[
          Text('Round Complete',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _SummaryValue(
                  label: 'Score',
                  value: formatScoreToPar(summary.scoreToPar)),
              _SummaryValue(
                  label: 'Strokes', value: '${summary.totalStrokes}'),
              _SummaryValue(
                  label: 'Caught',
                  value: '${summary.caughtCount}/${summary.holes.length}'),
            ],
          ),
          if (summary.caughtPokemon.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              summary.caughtPokemon.map((p) => p.name).join(', '),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: <Widget>[
        Text(value,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            )),
      ],
    );
  }
}
