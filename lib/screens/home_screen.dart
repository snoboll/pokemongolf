import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app.dart';
import '../data/first_gen_bogeybeasts.dart';
import '../models/course_leader.dart';
import '../models/golf_course.dart';
import '../models/golfer_team.dart';
import '../state/bogeybeasts_golf_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onPlay,
    required this.onResumeRound,
    required this.onBattleMode,
    required this.onGymChallenge,
  });

  final VoidCallback onPlay;
  final VoidCallback onResumeRound;
  final VoidCallback onBattleMode;
  final void Function(GolfCourse course) onGymChallenge;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _version = '';
  GolfCourse? _nearestCourse;
  bool _locationDone = false;

  static const double _nearbyRadiusKm = 5.0;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = info.version);
    });
    _findNearestGym();
  }

  Future<void> _findNearestGym() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) setState(() => _locationDone = true);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      if (!mounted) return;

      final store = BogeybeastGolfScope.of(context);
      final courses = store.catalogCourses
          .where((c) => c.lat != null && c.lng != null)
          .toList();

      GolfCourse? nearest;
      double bestDist = double.infinity;
      for (final c in courses) {
        final d = _haversineKm(pos.latitude, pos.longitude, c.lat!, c.lng!);
        if (d < bestDist) {
          bestDist = d;
          nearest = c;
        }
      }

      setState(() {
        _nearestCourse = bestDist <= _nearbyRadiusKm ? nearest : null;
        _locationDone = true;
      });
    } catch (_) {
      if (mounted) setState(() => _locationDone = true);
    }
  }

  static double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLng = _deg2rad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _deg2rad(double deg) => deg * (math.pi / 180);

  @override
  Widget build(BuildContext context) {
    final store = BogeybeastGolfScope.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: Stack(
        children: <Widget>[
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: ListenableBuilder(
                listenable: store,
                builder: (BuildContext context, _) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.pets,
                        size: 72,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Bogeybeasts',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (store.golferName != null) ...<Widget>[
                        Text(
                          'Golfer ${store.golferName}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (store.homeCourseId != null)
                          Builder(builder: (context) {
                            final name =
                                store.courseNameForId(store.homeCourseId);
                            if (name == null) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(Icons.home, size: 14,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5)),
                                  const SizedBox(width: 4),
                                  Text(
                                    name,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ] else
                        Text(
                          'Catch them on the course',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      const SizedBox(height: 48),
                      if (store.activeRound != null) ...<Widget>[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: widget.onResumeRound,
                            icon: const Icon(Icons.play_circle_outline_rounded, size: 22),
                            label: Text(
                              'Resume Hole ${store.activeRound!.currentHoleNumber}',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // ── Catch (primary) ──────────────────────────────
                      _CatchCard(onTap: widget.onPlay),
                      const SizedBox(height: 10),
                      // ── PvP + Gym (secondary row) ─────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _ActionCard(
                              icon: Icons.videogame_asset_rounded,
                              label: 'PvP',
                              subtitle: 'PvP challenge',
                              color: const Color(0xFFEF1010),
                              onTap: store.caughtDexNumbers.length >= 3
                                  ? widget.onBattleMode
                                  : null,
                              lockHint: store.caughtDexNumbers.length < 3
                                  ? 'Catch ${3 - store.caughtDexNumbers.length} more'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _GymCard(
                              nearestCourse: _nearestCourse,
                              locationDone: _locationDone,
                              leader: _nearestCourse != null
                                  ? store.leaderForCourse(_nearestCourse!.id)
                                  : null,
                              canChallenge: store.caughtDexNumbers.length >= 3,
                              lockHint: store.caughtDexNumbers.length < 3
                                  ? 'Catch ${3 - store.caughtDexNumbers.length} more'
                                  : null,
                              onTap: store.caughtDexNumbers.length >= 3 && _nearestCourse != null
                                  ? () => widget.onGymChallenge(_nearestCourse!)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.6),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            _QuickStat(
                              icon: Icons.pets,
                              value: '${store.caughtDexNumbers.length}',
                              label: '/ ${firstGenBogeybeast.length}',
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.6),
                            ),
                            _QuickStat(
                              icon: Icons.sports_golf,
                              value: '${store.completedRounds.length}',
                              label: 'rounds',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _version.isEmpty ? '' : 'v$_version',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.settings, size: 22),
              tooltip: 'Settings',
              onSelected: (value) {
                if (value == 'reset') {
                  _confirmResetProgress(context);
                } else if (value == 'signout') {
                  _confirmSignOut(context);
                }
              },
              itemBuilder: (_) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'reset',
                  child: Text('Reset all progress'),
                ),
                const PopupMenuItem<String>(
                  value: 'signout',
                  child: Text('Sign out'),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'How it works',
              onPressed: () => _showInfoSheet(context),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmResetProgress(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset all progress?'),
        content: const Text(
          'This will permanently delete your entire Bogeydex and all scorecards. This cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final store = BogeybeastGolfScope.of(context);
              try {
                await store.resetProgress();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All progress has been reset')),
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to reset progress')),
                  );
                }
              }
            },
            child: const Text('Reset everything'),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('Your data is saved in the cloud.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Supabase.instance.client.auth.signOut();
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  void _showInfoSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _InfoSheet(),
    );
  }
}

class _InfoSheet extends StatelessWidget {
  const _InfoSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dim = theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: <Widget>[
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('How It Works',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          _section(theme, 'Catch Rates'),
          const SizedBox(height: 8),
          _rateTable(theme),
          const SizedBox(height: 20),
          _section(theme, 'Encounter Rates'),
          const SizedBox(height: 8),
          Text('Base encounter chance per rarity:', style: TextStyle(color: dim)),
          const SizedBox(height: 6),
          _encounterRow(theme, 'Common', '35%', const Color(0xFF4CAF50)),
          _encounterRow(theme, 'Uncommon', '25%', const Color(0xFF26A69A)),
          _encounterRow(theme, 'Rare', '20%', const Color(0xFF1E88E5)),
          _encounterRow(theme, 'Epic', '14%', const Color(0xFF8E24AA)),
          _encounterRow(theme, 'Legendary', '6%', const Color(0xFFFFB300)),
          const SizedBox(height: 20),
          _section(theme, 'Terrain Bonuses'),
          const SizedBox(height: 8),
          Text(
            'Toggle terrain on a hole to boost the chance of encountering matching Bogeybeast types on the next hole.',
            style: TextStyle(color: dim),
          ),
          const SizedBox(height: 10),
          _terrainRow(theme, 'Bunker', 'Ground · Rock · Fire',
              const Color(0xFFFFB74D)),
          _terrainRow(theme, 'Water', 'Water · Ice',
              const Color(0xFF42A5F5)),
          _terrainRow(theme, 'Rough', 'Grass · Poison · Bug',
              const Color(0xFF66BB6A)),
          _terrainRow(theme, '1-Putt', 'Psychic · Ghost · Electric',
              const Color(0xFF7E57C2)),
          const SizedBox(height: 20),
          _section(theme, 'Legendary Streak'),
          const SizedBox(height: 8),
          Text(
            'Making par or better on consecutive holes builds a streak. '
            'At 2+ holes in a row, each hole in the streak adds +3% legendary encounter rate.',
            style: TextStyle(color: dim),
          ),
          const SizedBox(height: 6),
          Text(
            'Example: 4 pars in a row = +12% legendary chance on the next hole.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: dim,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(ThemeData theme, String title) {
    return Text(title,
        style: theme.textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.w700));
  }

  Widget _rateTable(ThemeData theme) {
    const List<String> headers = ['', 'Eagle', 'Birdie', 'Par', 'Bogey', 'Dbl', 'Trpl+'];
    const List<List<String>> rows = [
      ['Common', '100', '100', '100', '65', '20', '5'],
      ['Uncomn', '100', '100', '95', '50', '12', '3'],
      ['Rare', '100', '95', '90', '40', '5', '2'],
      ['Epic', '90', '70', '50', '15', '3', '1'],
      ['Legend', '60', '40', '25', '8', '2', '1'],
    ];
    const List<Color> rowColors = [
      Color(0xFF4CAF50),
      Color(0xFF26A69A),
      Color(0xFF1E88E5),
      Color(0xFF8E24AA),
      Color(0xFFFFB300),
    ];

    final dim = theme.colorScheme.onSurface.withValues(alpha: 0.4);
    final headerStyle = theme.textTheme.labelSmall!
        .copyWith(fontWeight: FontWeight.w700, color: dim);
    final cellStyle = theme.textTheme.bodySmall!
        .copyWith(fontWeight: FontWeight.w600);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: <Widget>[
          Row(
            children: headers
                .map((h) => SizedBox(
                    width: h.isEmpty ? 60 : 46,
                    child: Text(h, style: headerStyle, textAlign: TextAlign.center)))
                .toList(),
          ),
          const SizedBox(height: 4),
          for (int i = 0; i < rows.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 60,
                    child: Text(rows[i][0],
                        style: cellStyle.copyWith(color: rowColors[i])),
                  ),
                  for (int j = 1; j < rows[i].length; j++)
                    SizedBox(
                      width: 46,
                      child: Text('${rows[i][j]}%',
                          style: cellStyle, textAlign: TextAlign.center),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _encounterRow(
      ThemeData theme, String label, String pct, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: <Widget>[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 80, child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(pct,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _terrainRow(
      ThemeData theme, String terrain, String types, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 64,
            child: Text(terrain,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(types,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                )),
          ),
        ],
      ),
    );
  }
}
// Full-width primary Catch card.
class _CatchCard extends StatelessWidget {
  const _CatchCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const color = Color(0xFF2E7D32);
    const fgColor = Color(0xFF4EE566); // vivid neon green matching the logo
    final cardBg = Color.alphaBlend(color.withValues(alpha: 0.22), theme.colorScheme.surface);
    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: fgColor.withValues(alpha: 0.55), width: 1.5),
          ),
          child: Column(
            children: [
              Icon(Icons.pets_rounded, color: fgColor, size: 30),
              const SizedBox(height: 6),
              Text(
                'Catch',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: fgColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Play a round',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Compact secondary card (PvP).
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.lockHint,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final String? lockHint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onTap != null;
    final baseColor = enabled ? color : color.withValues(alpha: 0.35);
    final fgColor = enabled
        ? Color.lerp(color, Colors.white, 0.45)!
        : Color.lerp(color, Colors.white, 0.45)!.withValues(alpha: 0.35);

    final cardBg = Color.alphaBlend(
      baseColor.withValues(alpha: enabled ? 0.22 : 0.10),
      theme.colorScheme.surface,
    );
    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: fgColor.withValues(alpha: enabled ? 0.55 : 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: fgColor, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: fgColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                enabled ? subtitle : (lockHint ?? subtitle),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withValues(alpha: enabled ? 0.4 : 0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Gym card: compact secondary card with embedded leader preview.
class _GymCard extends StatelessWidget {
  const _GymCard({
    required this.nearestCourse,
    required this.locationDone,
    required this.leader,
    required this.canChallenge,
    required this.onTap,
    this.lockHint,
  });

  final GolfCourse? nearestCourse;
  final bool locationDone;
  final CourseLeader? leader;
  final bool canChallenge;
  final VoidCallback? onTap;
  final String? lockHint;

  @override
  Widget build(BuildContext context) {
    const gymColor = Color(0xFFF9A825);
    final leaderColor = leader != null
        ? teamColor(GolferTeam.fromDb(leader!.golferTeam))
        : gymColor;
    final enabled = onTap != null;
    final gymFg = Color.lerp(gymColor, Colors.white, 0.45)!;

    // Loading / no gym nearby — simple compact state
    if (nearestCourse == null || leader == null) {
      final dimBg = Color.alphaBlend(gymColor.withValues(alpha: 0.10), Theme.of(context).colorScheme.surface);
      return Material(
        color: dimBg,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: gymFg.withValues(alpha: 0.25), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_rounded, color: gymFg.withValues(alpha: 0.35), size: 26),
              const SizedBox(height: 6),
              Text(
                'Gym',
                style: TextStyle(
                  color: gymFg.withValues(alpha: 0.35),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                !locationDone ? 'Finding gym…' : 'No gym nearby',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: gymFg.withValues(alpha: 0.3),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final fgColor = enabled
        ? Color.lerp(leaderColor, Colors.white, 0.45)!
        : Color.lerp(leaderColor, Colors.white, 0.45)!.withValues(alpha: 0.35);

    // Gym found — show leader info inside the card
    final cardBg = Color.alphaBlend(
      (enabled ? leaderColor : leaderColor.withValues(alpha: 0.35)).withValues(alpha: enabled ? 0.22 : 0.10),
      Theme.of(context).colorScheme.surface,
    );
    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: fgColor.withValues(alpha: enabled ? 0.55 : 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_rounded, color: fgColor, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Gym',
                    style: TextStyle(
                      color: fgColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _GolferSprite(sprite: leader!.golferSprite, size: 36),
              const SizedBox(height: 4),
              Text(
                leader!.leaderName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: fgColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                nearestCourse!.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: fgColor.withValues(alpha: 0.6),
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (leader!.team.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final p in leader!.team.take(3))
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: Image.network(
                            p.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              if (!enabled && lockHint != null) ...[
                const SizedBox(height: 4),
                Text(
                  lockHint!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: fgColor.withValues(alpha: 0.5),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GolferSprite extends StatelessWidget {
  const _GolferSprite({required this.sprite, this.size = 32});

  final String? sprite;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (sprite == null) {
      return Icon(Icons.person, size: size * 0.7, color: const Color(0xFFFFD700));
    }
    final inner = size * 1.5;
    return SizedBox(
      width: size,
      height: size,
      child: OverflowBox(
        maxWidth: inner,
        maxHeight: inner,
        child: Image.asset(
          sprite!,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.person, size: size * 0.7, color: const Color(0xFFFFD700)),
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
