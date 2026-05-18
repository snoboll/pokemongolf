import 'dart:math';

import 'package:flutter/material.dart';

import '../app.dart';
import '../data/bogeybeast_battle_stats.dart';
import '../models/encounter_modifiers.dart';
import '../models/golf_score.dart';
import '../models/item.dart';
import '../models/hole_stats.dart';
import '../models/bogeybeast_rarity.dart';
import '../models/bogeybeast_species.dart';
import '../models/bogeybeast_type.dart';
import '../models/round_models.dart';
import '../widgets/distance_to_green.dart';
import '../widgets/beast_detail_sheet.dart';
import '../widgets/bogeycube_badge.dart';
import '../widgets/bogeycube_throw.dart';
import '../widgets/bogeybeast_art.dart';
import '../widgets/score_picker.dart';
import 'scorecard_detail_screen.dart';

class RoundScreen extends StatefulWidget {
  const RoundScreen({super.key, this.skipEncounterIntro = false});

  final bool skipEncounterIntro;

  @override
  State<RoundScreen> createState() => _RoundScreenState();
}

class _RoundScreenState extends State<RoundScreen>
    with TickerProviderStateMixin {
  int _par = 4;
  GolfScore _selectedScore = GolfScore.par;
  int? _customStrokes; // set when user enters a stroke count manually
  HoleStats _holeStats = const HoleStats();
  HoleResolution? _resolution;

  // Set while the Bogeycube throw animation plays, before the result screen.
  HoleResolution? _pendingResolution;

  // Encounter animation
  late final AnimationController _encounterController;
  late final Animation<double> _flashOpacity;
  late final Animation<double> _stripesIn;
  late final Animation<double> _overlayAlpha;
  late final Animation<Offset> _bogeybeastSlide;
  late final Animation<double> _grayscaleAmount;

  // Re-rolled each time the encounter intro plays (see [_resetForNextHole]).
  _WipeStyle _wipeStyle =
      _WipeStyle.values[Random().nextInt(_WipeStyle.values.length)];

  // Takanaj re-roll spin animation.
  late final AnimationController _rerollController;
  bool _rerollSwapped = false;
  bool _rerolledThisHole = false;

  int get _strokes => _customStrokes ?? (_par + _selectedScore.relativeToPar);

  static GolfScore _scoreFromRelative(int rel) {
    if (rel <= -2) return GolfScore.eagle;
    if (rel == -1) return GolfScore.birdie;
    if (rel == 0) return GolfScore.par;
    if (rel == 1) return GolfScore.bogey;
    if (rel == 2) return GolfScore.doubleBogey;
    return GolfScore.tripleOrWorse;
  }

  void _showCustomStrokeDialog() {
    final controller = TextEditingController(text: '$_strokes');
    showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Custom strokes'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Strokes',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final v = int.tryParse(controller.text.trim());
              if (v != null && v >= 1) Navigator.of(ctx).pop(v);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    ).then((strokes) {
      if (strokes != null && mounted) {
        setState(() {
          _customStrokes = strokes;
          _selectedScore = _scoreFromRelative(strokes - _par);
        });
      }
    });
  }

  void _confirmExitAndSave(BuildContext context, dynamic store) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save & exit?'),
        content: const Text(
          'Your completed holes will be saved as a scorecard.',
        ),
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
      if (confirmed != true || !context.mounted) return;
      store.endRoundEarly();
      Navigator.of(context).pop();
    });
  }

  void _confirmExitAndDiscard(BuildContext context, dynamic store) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard round?'),
        content: const Text('All progress for this round will be lost.'),
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
      if (confirmed != true || !context.mounted) return;
      store.discardRound();
      Navigator.of(context).pop();
    });
  }

  void _resetForNextHole() {
    final store = BogeybeastGolfScope.of(context);
    final nextPar = store.activeRound?.currentHolePar;
    setState(() {
      _par = nextPar ?? 4;
      _selectedScore = GolfScore.par;
      _customStrokes = null;
      _holeStats = const HoleStats();
      _resolution = null;
      _pendingResolution = null;
    });
    _rerolledThisHole = false;
    _wipeStyle = _WipeStyle.values[Random().nextInt(_WipeStyle.values.length)];
    _encounterController.forward(from: 0);
  }

  @override
  void initState() {
    super.initState();
    _encounterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Double flash: 0–800ms (0.00–0.20)
    _flashOpacity =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: _encounterController,
            curve: const Interval(0.00, 0.20),
          ),
        );

    // Stripes cover screen: 800–1800ms (0.20–0.45)
    _stripesIn = CurvedAnimation(
      parent: _encounterController,
      curve: const Interval(0.20, 0.45, curve: Curves.easeInOut),
    );

    // Overlay fades out (no retraction): 2100–2500ms (0.525–0.625)
    _overlayAlpha = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _encounterController,
        curve: const Interval(0.525, 0.625, curve: Curves.easeIn),
      ),
    );

    // Bogeybeast slides in slowly from right: 2400–3700ms (0.60–0.925)
    _bogeybeastSlide =
        Tween<Offset>(begin: const Offset(1.5, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _encounterController,
            curve: const Interval(0.60, 0.925, curve: Curves.easeOutCubic),
          ),
        );

    // Grayscale fades to color: 3500–4000ms (0.875–1.00)
    _grayscaleAmount = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _encounterController,
        curve: const Interval(0.875, 1.00, curve: Curves.easeOut),
      ),
    );

    _rerollController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..addListener(() {
        // Swap the encounter at the midpoint of the spin.
        if (!_rerollSwapped && _rerollController.value >= 0.5) {
          _rerollSwapped = true;
          if (mounted) BogeybeastGolfScope.of(context).rerollEncounter();
        }
      });

    if (widget.skipEncounterIntro) {
      _encounterController.value = 1.0;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _encounterController.forward();
      });
    }
  }

  void _startReroll() {
    if (_rerolledThisHole || _rerollController.isAnimating) return;
    _rerolledThisHole = true;
    _rerollSwapped = false;
    _rerollController.forward(from: 0.0);
  }

  void _showRoundItemsSheet(dynamic store) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => _RoundItemsSheet(
        items: Map<ItemType, int>.from(store.items as Map),
        takanajAvailable: !_rerolledThisHole,
        onUseTakanaj: () {
          Navigator.of(sheetCtx).pop();
          _startReroll();
        },
      ),
    );
  }

  @override
  void dispose() {
    _encounterController.dispose();
    _rerollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = BogeybeastGolfScope.of(context);
    final coursePar = store.activeRound?.currentHolePar;
    if (coursePar != null && _resolution == null) {
      _par = coursePar;
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = BogeybeastGolfScope.of(context);
    final ActiveRound? activeRound = store.activeRound;

    if (_resolution != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Result')),
        body: _HoleResolutionView(
          resolution: _resolution!,
          nextHoleStreak: store.activeRound?.streakBonus ?? 0,
          nextHoleStreakCount: store.activeRound?.streakCount ?? 0,
          nextHoleStats: _resolution!.holeResult.stats,
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

    if (_pendingResolution != null) {
      final HoleResult pending = _pendingResolution!.holeResult;
      return Scaffold(
        body: SafeArea(
          child: BogeycubeThrowOverlay(
            caught: pending.caught,
            beastAssetPath: pending.bogeybeast.assetPath,
            beastName: pending.bogeybeast.name,
            onComplete: () {
              if (!mounted) return;
              setState(() {
                _resolution = _pendingResolution;
                _pendingResolution = null;
              });
            },
          ),
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
              Text(
                'No active round',
                style: Theme.of(context).textTheme.titleLarge,
              ),
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
          'Hole ${activeRound.currentHoleNumber} / ${activeRound.holeCount}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _ScoreChip(scoreToPar: activeRound.scoreToPar),
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
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            children: <Widget>[
              LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                backgroundColor: theme.colorScheme.surfaceContainerHigh,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: AnimatedBuilder(
                    animation: _encounterController,
                    builder: (context, child) {
                      final double v = _encounterController.value;
                      // Hide content during flash+stripe-in phase; reveal once black
                      final bool hidden = v > 0 && v < 0.45;
                      return Opacity(opacity: hidden ? 0.0 : 1.0, child: child);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        if (activeRound.currentGreenCoord != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: DistanceToGreen(
                              target: activeRound.currentGreenCoord!,
                            ),
                          ),
                        SizedBox(
                          height: 180,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              AnimatedBuilder(
                                animation: _rerollController,
                                builder: (context, child) {
                                  final double v = _rerollController.value;
                                  if (v == 0) return child!;
                                  return Transform.rotate(
                                    angle: v * 4 * pi, // two full spins
                                    child: Transform.scale(
                                      scale: 1.0 - sin(v * pi) * 0.8,
                                      child: child,
                                    ),
                                  );
                                },
                                child: AnimatedBuilder(
                                  animation: _encounterController,
                                  builder: (context, child) {
                                    return SlideTransition(
                                      position: _bogeybeastSlide,
                                      child: ColorFiltered(
                                        colorFilter: _encounterGrayscaleFilter(
                                          _grayscaleAmount.value,
                                        ),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: BogeybeastArt(
                                    assetPath:
                                        activeRound.currentEncounter.assetPath,
                                    height: 180,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: BogeycubeCaughtBadge(
                                  caught: store.hasCaught(
                                    activeRound.currentEncounter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          activeRound.currentEncounter.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '#${activeRound.currentEncounter.paddedDexNumber}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
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
                        if (activeRound.streakBonus >= 1) ...<Widget>[
                          const SizedBox(height: 10),
                          _StreakBadge(
                            streakBonus: activeRound.streakBonus,
                            streakCount: activeRound.streakCount,
                          ),
                        ],
                        const SizedBox(height: 28),
                        if (activeRound.currentHolePar != null) ...<Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                'Par ${activeRound.currentHolePar}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (activeRound.courseName != null) ...<Widget>[
                                const SizedBox(width: 8),
                                Text(
                                  activeRound.courseName!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ] else ...<Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Hole par',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _ParSelector(
                            selected: _par,
                            onChanged: (v) => setState(() => _par = v),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Text(
                              'Your score',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            if (_customStrokes != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Text(
                                  '$_customStrokes strokes',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.backpack_rounded, size: 20),
                              tooltip: 'Items',
                              visualDensity: VisualDensity.compact,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.55,
                              ),
                              onPressed: () => _showRoundItemsSheet(store),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              tooltip: 'Enter exact strokes',
                              visualDensity: VisualDensity.compact,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                              onPressed: _showCustomStrokeDialog,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ScorePicker(
                          par: _par,
                          selected: _selectedScore,
                          onChanged: (GolfScore score) {
                            setState(() {
                              _selectedScore = score;
                              _customStrokes =
                                  null; // clear custom when chip tapped
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Hole stats',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            _StatToggle(
                              label: '1-Putt',
                              icon: Icons.sports_golf,
                              active: _holeStats.onePutt,
                              activeColor: const Color(0xFF7E57C2),
                              onToggle: () => setState(
                                () => _holeStats = _holeStats.copyWith(
                                  onePutt: !_holeStats.onePutt,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _StatToggle(
                              label: 'Bunker',
                              icon: Icons.landscape,
                              active: _holeStats.bunker,
                              activeColor: const Color(0xFFFFB74D),
                              onToggle: () => setState(
                                () => _holeStats = _holeStats.copyWith(
                                  bunker: !_holeStats.bunker,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _StatToggle(
                              label: 'Water',
                              icon: Icons.water_drop,
                              active: _holeStats.water,
                              activeColor: const Color(0xFF42A5F5),
                              onToggle: () => setState(
                                () => _holeStats = _holeStats.copyWith(
                                  water: !_holeStats.water,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _StatToggle(
                              label: 'Rough',
                              icon: Icons.grass,
                              active: _holeStats.rough,
                              activeColor: const Color(0xFF66BB6A),
                              onToggle: () => setState(
                                () => _holeStats = _holeStats.copyWith(
                                  rough: !_holeStats.rough,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              final HoleResolution resolution = store
                                  .playCurrentHole(
                                    par: _par,
                                    strokes: _strokes,
                                    stats: _holeStats,
                                  );
                              setState(() {
                                _pendingResolution = resolution;
                              });
                            },
                            icon: const Bogeycube(size: 22),
                            label: const Text('Launch Bogeycube'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Encounter animation overlay (flash + stripes)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _encounterController,
                builder: (context, _) {
                  final double v = _encounterController.value;
                  if (v == 0 || v >= 0.625) return const SizedBox.shrink();
                  return CustomPaint(
                    painter: _EncounterWipePainter(
                      style: _wipeStyle,
                      flashOpacity: _flashOpacity.value,
                      stripesIn: _stripesIn.value,
                      overlayAlpha: _overlayAlpha.value,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.scoreToPar});
  final int scoreToPar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = formatScoreToPar(scoreToPar);
    final Color bg;
    final Color fg;
    if (scoreToPar < 0) {
      bg = Colors.green.shade700;
      fg = Colors.white;
    } else if (scoreToPar == 0) {
      bg = theme.colorScheme.surfaceContainerHighest;
      fg = theme.colorScheme.onSurface;
    } else {
      bg = Colors.red.shade700;
      fg = Colors.white;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

class _ParSelector extends StatelessWidget {
  const _ParSelector({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: <int>[3, 4, 5]
          .map((par) {
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
          })
          .toList(growable: false),
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
    this.nextHoleStreak = 0,
    this.nextHoleStreakCount = 0,
    this.nextHoleStats,
  });

  final HoleResolution resolution;
  final VoidCallback onContinue;
  final int nextHoleStreak;
  final int nextHoleStreakCount;
  final HoleStats? nextHoleStats;

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

    _slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(1.5, 0)).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInBack),
        );

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
    final bool shiny = widget.resolution.caughtShiny;
    final theme = Theme.of(context);
    const Color shinyGold = Color(0xFFFFB300);

    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            children: <Widget>[
              Text(
                !result.caught
                    ? 'It broke free...'
                    : shiny
                        ? 'Shiny Catch!'
                        : 'Caught!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: shiny && result.caught ? shinyGold : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${result.bogeybeast.name}  ·  ${result.score.label}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              SlideTransition(
                position: _slideAnimation,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: <Widget>[
                    BogeybeastArt(
                      assetPath: result.bogeybeast.assetPath,
                      height: 200,
                      shiny: shiny,
                    ),
                    if (result.caught)
                      const Positioned(
                        top: 0,
                        right: 0,
                        child: BogeycubeCaughtBadge(caught: true),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (result.caught) ...<Widget>[
                _CaughtBeastInfo(bogeybeast: result.bogeybeast),
                const SizedBox(height: 24),
              ],
              if (widget.resolution.takanajMessage != null) ...<Widget>[
                _TakanajBanner(message: widget.resolution.takanajMessage!),
                const SizedBox(height: 16),
              ],
              if (widget.resolution.roundCompleted &&
                  widget.resolution.roundSummary != null)
                _RoundCompleteCard(summary: widget.resolution.roundSummary!),
              if (!widget.resolution.roundCompleted) ...<Widget>[
                const SizedBox(height: 16),
                _NextEncounterBoostsCard(
                  stats: widget.nextHoleStats ?? const HoleStats(),
                  streakBonus: widget.nextHoleStreak,
                  streakCount: widget.nextHoleStreakCount,
                ),
              ],
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
          Rect.fromCenter(
            center: Offset(x, y),
            width: p.size,
            height: p.size * 1.4,
          ),
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

/// Flavor text + battle stats for a freshly caught Bogeybeast, mirroring
/// the Bogeydex detail sheet.
class _CaughtBeastInfo extends StatelessWidget {
  const _CaughtBeastInfo({required this.bogeybeast});

  final BogeybeastSpecies bogeybeast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = bogeybeastBattleStats[bogeybeast.dexNumber];
    final String? flavor = bogeybeast.flavorText;

    final Widget? flavorWidget = flavor == null
        ? null
        : Center(
            child: Text(
              flavor,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.4,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          );

    final Widget? statsWidget = stats == null
        ? null
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 150,
                child: BeastStatsDiamondChart(
                  hp: stats.hp,
                  attack: stats.offense,
                  defense: stats.defense,
                  theme: theme,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  BeastStatLabel(
                      label: 'HP',
                      value: stats.hp,
                      color: const Color(0xFFEF5350)),
                  BeastStatLabel(
                      label: 'Atk',
                      value: stats.offense,
                      color: const Color(0xFFFF9800)),
                  BeastStatLabel(
                      label: 'Def',
                      value: stats.defense,
                      color: const Color(0xFF42A5F5)),
                ],
              ),
            ],
          );

    return Column(
      children: <Widget>[
        // Type chips — sit just below the beast art.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: bogeybeast.types
              .map((t) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: BeastTypeChip(type: t),
                  ))
              .toList(),
        ),
        if (flavorWidget != null || statsWidget != null) ...<Widget>[
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (flavorWidget != null) Expanded(flex: 5, child: flavorWidget),
                if (flavorWidget != null && statsWidget != null)
                  const SizedBox(width: 12),
                if (statsWidget != null)
                  Expanded(flex: 5, child: statsWidget),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TakanajBanner extends StatelessWidget {
  const _TakanajBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color accent = ItemType.takanaj.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.casino, size: 40, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundItemsSheet extends StatelessWidget {
  const _RoundItemsSheet({
    required this.items,
    required this.takanajAvailable,
    required this.onUseTakanaj,
  });

  final Map<ItemType, int> items;
  final bool takanajAvailable;
  final VoidCallback onUseTakanaj;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<ItemType> owned = ItemType.values
        .where((ItemType t) => (items[t] ?? 0) > 0)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Items',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (owned.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No items in your bag.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          else
            for (final ItemType type in owned)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _row(context, type, items[type]!),
              ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, ItemType type, int qty) {
    final theme = Theme.of(context);
    final Color accent = type.accent;
    final bool isTakanaj = type == ItemType.takanaj;
    final bool usable = isTakanaj && takanajAvailable;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF243024)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(type.icon, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${type.name}  ×$qty',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  isTakanaj
                      ? (takanajAvailable
                          ? type.description
                          : 'Already re-rolled this hole.')
                      : 'Use from the Items screen.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          if (isTakanaj) ...<Widget>[
            const SizedBox(width: 10),
            FilledButton(
              onPressed: usable ? onUseTakanaj : null,
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                visualDensity: VisualDensity.compact,
              ),
              child: Text(usable ? 'Use' : 'Used'),
            ),
          ],
        ],
      ),
    );
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
          Text(
            'Round Complete',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _SummaryValue(
                label: 'Score',
                value: formatScoreToPar(summary.scoreToPar),
              ),
              _SummaryValue(label: 'Strokes', value: '${summary.totalStrokes}'),
              _SummaryValue(
                label: 'Caught',
                value: '${summary.caughtCount}/${summary.holes.length}',
              ),
            ],
          ),
          if (summary.caughtBogeybeast.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              summary.caughtBogeybeast.map((p) => p.name).join(', '),
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

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streakBonus, required this.streakCount});
  final int streakBonus;
  final int streakCount;

  int get _legendaryPct =>
      ((5 + streakBonus) / (100 + streakBonus) * 100).round();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const Color fireColor = Color(0xFFFFB300);

    return GestureDetector(
      onTap: () => _showParstreakModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: fireColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: fireColor.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('🔥', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              '$streakCount',
              style: theme.textTheme.labelMedium?.copyWith(
                color: fireColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Parstreak',
              style: theme.textTheme.labelMedium?.copyWith(
                color: fireColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '·  $_legendaryPct% legendary',
              style: theme.textTheme.labelMedium?.copyWith(
                color: fireColor.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showParstreakModal(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => const _ParstreakInfoDialog(),
  );
}

class _ParstreakInfoDialog extends StatelessWidget {
  const _ParstreakInfoDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const Color fireColor = Color(0xFFFFB300);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: fireColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: fireColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('🔥', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    'Parstreak',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: fireColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Image.asset(
                        'assets/golfers/starter_hickory.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Score par or better on consecutive holes to build your Parstreak! '
                            'The longer your streak, the higher your chance of encountering a legendary Bogeybeast.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        'Hickory',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _ParstreakRow(
                    emoji: '🦅',
                    label: 'Eagle',
                    description: '+12 streak bonus',
                    color: const Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 8),
                  _ParstreakRow(
                    emoji: '🐦',
                    label: 'Birdie',
                    description: '+6 streak bonus',
                    color: const Color(0xFF2196F3),
                  ),
                  const SizedBox(height: 8),
                  _ParstreakRow(
                    emoji: '⛳',
                    label: 'Par',
                    description: '+3 streak bonus',
                    color: fireColor,
                  ),
                  const SizedBox(height: 8),
                  _ParstreakRow(
                    emoji: '💔',
                    label: 'Bogey or worse',
                    description: 'Streak resets',
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Got it!'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParstreakRow extends StatelessWidget {
  const _ParstreakRow({
    required this.emoji,
    required this.label,
    required this.description,
    required this.color,
  });

  final String emoji;
  final String label;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _NextEncounterBoostsCard extends StatelessWidget {
  const _NextEncounterBoostsCard({
    required this.stats,
    required this.streakBonus,
    required this.streakCount,
  });

  final HoleStats stats;
  final int streakBonus;
  final int streakCount;

  static String _typeNames(Set<BogeybeastType> types) => types
      .map((t) => t.name[0].toUpperCase() + t.name.substring(1))
      .join(' · ');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bool hasBunker = stats.bunker;
    final bool hasWater = stats.water;
    final bool hasRough = stats.rough;
    final bool hasOnePutt = stats.onePutt;
    final bool hasStreak = streakBonus > 0;

    if (!hasBunker && !hasWater && !hasRough && !hasOnePutt && !hasStreak) {
      return const SizedBox.shrink();
    }

    final int legendaryPct = ((5 + streakBonus) / (100 + streakBonus) * 100)
        .round();

    Widget terrainRow(
      IconData icon,
      Color color,
      String label,
      Set<BogeybeastType> types,
    ) {
      return Padding(
        padding: const EdgeInsets.only(top: 7),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${_typeNames(types)}  ×3',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'NEXT ENCOUNTER',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          if (hasOnePutt)
            terrainRow(
              Icons.sports_golf,
              const Color(0xFF7E57C2),
              '1-Putt',
              onePuttTypes,
            ),
          if (hasBunker)
            terrainRow(
              Icons.landscape,
              const Color(0xFFFFB74D),
              'Bunker',
              bunkerTypes,
            ),
          if (hasWater)
            terrainRow(
              Icons.water_drop,
              const Color(0xFF42A5F5),
              'Water',
              waterTypes,
            ),
          if (hasRough)
            terrainRow(
              Icons.grass,
              const Color(0xFF66BB6A),
              'Rough',
              roughTypes,
            ),
          if (hasStreak)
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Row(
                children: <Widget>[
                  const Text('🔥', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  Text(
                    '$streakCount in a row',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFFFFB300),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$legendaryPct% legendary',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.65,
                      ),
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

/// Interpolates a ColorFilter between full color (amount=0) and grayscale (amount=1).
ColorFilter _encounterGrayscaleFilter(double amount) =>
    grayscaleColorFilter(amount);

/// The "screen turns to black" wipe style for the encounter intro.
enum _WipeStyle { stripes, clockwiseSweep, irisClose }

class _EncounterWipePainter extends CustomPainter {
  _EncounterWipePainter({
    required this.style,
    required this.flashOpacity,
    required this.stripesIn,
    required this.overlayAlpha,
  });

  final _WipeStyle style;
  final double flashOpacity;
  final double stripesIn;
  final double
  overlayAlpha; // 1 = fully opaque, 0 = transparent (fades out after hold)

  static const int _stripeCount = 20;

  @override
  void paint(Canvas canvas, Size size) {
    // White flash (not affected by overlayAlpha — it's a separate effect)
    if (flashOpacity > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white.withValues(alpha: flashOpacity),
      );
    }

    if (stripesIn <= 0 && overlayAlpha >= 1) return;
    if (stripesIn <= 0) return;

    final Paint paint = Paint()
      ..color = Colors.black.withValues(alpha: overlayAlpha);

    // Fully covered — draw solid black rect (fades with overlayAlpha).
    if (stripesIn >= 1.0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        paint,
      );
      return;
    }

    // Mid-wipe — draw the chosen style at the current progress.
    switch (style) {
      case _WipeStyle.stripes:
        _paintStripes(canvas, size, paint);
      case _WipeStyle.clockwiseSweep:
        _paintClockwiseSweep(canvas, size, paint);
      case _WipeStyle.irisClose:
        _paintIrisClose(canvas, size, paint);
    }
  }

  void _paintStripes(Canvas canvas, Size size, Paint paint) {
    final double stripeH = size.height / _stripeCount;
    for (int i = 0; i < _stripeCount; i++) {
      final bool fromLeft = i.isEven;
      final double y = i * stripeH;
      final double x = fromLeft
          ? size.width * (stripesIn - 1.0) // slides in from left
          : size.width * (1.0 - stripesIn); // slides in from right
      canvas.drawRect(Rect.fromLTWH(x, y, size.width, stripeH), paint);
    }
  }

  void _paintClockwiseSweep(Canvas canvas, Size size, Paint paint) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    // Radius large enough to cover every corner.
    final double radius =
        sqrt(size.width * size.width + size.height * size.height);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // start at 12 o'clock
      2 * pi * stripesIn, // sweep clockwise
      true, // pie wedge from center
      paint,
    );
  }

  void _paintIrisClose(Canvas canvas, Size size, Paint paint) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double maxRadius =
        0.5 * sqrt(size.width * size.width + size.height * size.height);
    final double clearRadius = maxRadius * (1.0 - stripesIn);
    final Path path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: clearRadius))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_EncounterWipePainter old) =>
      old.style != style ||
      old.flashOpacity != flashOpacity ||
      old.stripesIn != stripesIn ||
      old.overlayAlpha != overlayAlpha;
}
