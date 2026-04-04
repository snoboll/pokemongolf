import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app.dart';
import '../data/first_gen_pokemon.dart';
import '../data/preset_courses.dart';
import '../models/golf_course.dart';
import '../services/supabase_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onStartRound,
    required this.onResumeRound,
  });

  final void Function({required int holeCount, List<int>? holePars, String? courseName, List<({double lat, double lng})>? greenCoords}) onStartRound;
  final VoidCallback onResumeRound;

  @override
  Widget build(BuildContext context) {
    final store = PokemonGolfScope.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: Stack(
        children: <Widget>[
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.catching_pokemon,
                    size: 72,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pokemon Golf',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (store.trainerName != null) ...<Widget>[
                    Text(
                      'Trainer ${store.trainerName}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (store.homeCourseId != null)
                      Builder(builder: (context) {
                        final name = presetCourses
                            .where((c) => c.id == store.homeCourseId)
                            .map((c) => c.name)
                            .firstOrNull;
                        if (name == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.home, size: 14,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                              const SizedBox(width: 4),
                              Text(
                                name,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _showCourseSelection(context, 18),
                      icon: const Icon(Icons.golf_course, size: 24),
                      label: const Text('18 Holes'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () => _showCourseSelection(context, 9),
                      icon: const Icon(Icons.flag, size: 24),
                      label: const Text('9 Holes'),
                    ),
                  ),
                  if (store.activeRound != null) ...<Widget>[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onResumeRound,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        icon:
                            const Icon(Icons.play_arrow_rounded, size: 24),
                        label: Text(
                          'Resume Hole ${store.activeRound!.currentHoleNumber}',
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _QuickStat(
                        icon: Icons.catching_pokemon,
                        value: '${store.caughtDexNumbers.length}',
                        label: '/ ${firstGenPokemon.length}',
                      ),
                      Container(
                        width: 1,
                        height: 32,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        color: theme.colorScheme.outlineVariant,
                      ),
                      _QuickStat(
                        icon: Icons.sports_golf,
                        value: '${store.completedRounds.length}',
                        label: 'rounds',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.logout, size: 22),
              tooltip: 'Sign out',
              onPressed: () => _confirmSignOut(context),
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

  void _showCourseSelection(BuildContext context, int holeCount) {
    final store = PokemonGolfScope.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CoursePickerSheet(
        holeCount: holeCount,
        homeCourseId: store.homeCourseId,
        onStart: ({List<int>? holePars, String? courseName, List<({double lat, double lng})>? greenCoords}) {
          Navigator.of(context).pop();
          onStartRound(holeCount: holeCount, holePars: holePars, courseName: courseName, greenCoords: greenCoords);
        },
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
            'Toggle terrain on a hole to boost the chance of encountering matching Pokemon types on the next hole.',
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

class _CoursePickerSheet extends StatefulWidget {
  const _CoursePickerSheet({
    required this.holeCount,
    required this.homeCourseId,
    required this.onStart,
  });

  final int holeCount;
  final String? homeCourseId;
  final void Function({List<int>? holePars, String? courseName, List<({double lat, double lng})>? greenCoords}) onStart;

  @override
  State<_CoursePickerSheet> createState() => _CoursePickerSheetState();
}

class _CoursePickerSheetState extends State<_CoursePickerSheet> {
  List<GolfCourse> _allCourses = <GolfCourse>[];
  GolfCourse? _selectedCourse;
  final List<CoursePart> _selectedParts = <CoursePart>[];
  bool _loading = true;

  int get _requiredParts => widget.holeCount == 18 ? 2 : 1;

  bool get _canStart {
    if (_selectedCourse == null) return true;
    if (!_selectedCourse!.hasParts) return true;
    return _selectedParts.length == _requiredParts;
  }

  List<int>? get _holePars {
    if (_selectedCourse == null) return null;
    if (_selectedCourse!.hasParts) {
      return _selectedCourse!.parsForParts(_selectedParts);
    }
    if (_selectedCourse!.pars != null) {
      if (widget.holeCount == 9) {
        return _selectedCourse!.pars!.sublist(0, 9);
      }
      return _selectedCourse!.pars;
    }
    return null;
  }

  List<({double lat, double lng})>? get _greenCoords {
    if (_selectedCourse == null || !_selectedCourse!.hasParts) return null;
    final coords = <({double lat, double lng})>[];
    for (final part in _selectedParts) {
      if (part.greenCoords != null) {
        coords.addAll(part.greenCoords!);
      }
    }
    return coords.isEmpty ? null : coords;
  }

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final service = SupabaseService();
      final userCourses = await service.fetchUserCourses();
      final all = <GolfCourse>[...presetCourses, ...userCourses];

      GolfCourse? home;
      if (widget.homeCourseId != null) {
        for (final c in all) {
          if (c.id == widget.homeCourseId) {
            home = c;
            break;
          }
        }
      }

      if (mounted) {
        setState(() {
          _allCourses = all;
          _selectedCourse = home;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _allCourses = <GolfCourse>[...presetCourses];
          _loading = false;
        });
      }
    }
  }

  void _togglePart(CoursePart part) {
    setState(() {
      if (_selectedParts.contains(part)) {
        _selectedParts.remove(part);
      } else {
        if (_selectedParts.length < _requiredParts) {
          _selectedParts.add(part);
        } else {
          _selectedParts
            ..removeAt(0)
            ..add(part);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 16),
          Text(
            '${widget.holeCount} Holes',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Text('Course', style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          )),
          const SizedBox(height: 8),
          if (_loading)
            const Center(child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(strokeWidth: 2),
            ))
          else
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: <Widget>[
                if (widget.homeCourseId != null)
                  ChoiceChip(
                    avatar: const Icon(Icons.home, size: 16),
                    label: Text(_allCourses
                        .where((c) => c.id == widget.homeCourseId)
                        .map((c) => c.name)
                        .firstOrNull ?? 'Home'),
                    selected: _selectedCourse?.id == widget.homeCourseId,
                    onSelected: (_) {
                      final home = _allCourses.where((c) => c.id == widget.homeCourseId).firstOrNull;
                      if (home != null) {
                        setState(() {
                          _selectedCourse = home;
                          _selectedParts.clear();
                        });
                      }
                    },
                  ),
                ChoiceChip(
                  label: const Text('No course'),
                  selected: _selectedCourse == null,
                  onSelected: (_) => setState(() {
                    _selectedCourse = null;
                    _selectedParts.clear();
                  }),
                ),
                for (final course in _allCourses)
                  if (course.id != widget.homeCourseId)
                    ChoiceChip(
                      label: Text(course.name),
                      selected: _selectedCourse?.id == course.id,
                      onSelected: (_) => setState(() {
                        _selectedCourse = course;
                        _selectedParts.clear();
                      }),
                    ),
              ],
            ),
          if (_selectedCourse != null && _selectedCourse!.hasParts) ...<Widget>[
            const SizedBox(height: 16),
            Text(
              'Select $_requiredParts part${_requiredParts > 1 ? "s" : ""}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: <Widget>[
                for (final part in _selectedCourse!.parts!)
                  FilterChip(
                    label: Text(part.name),
                    selected: _selectedParts.contains(part),
                    onSelected: (_) => _togglePart(part),
                  ),
              ],
            ),
            if (_selectedParts.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                _selectedParts.map((p) => '${p.name} (par ${p.pars.fold<int>(0, (a, b) => a + b)})').join(' + '),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _canStart
                  ? () => widget.onStart(
                        holePars: _holePars,
                        courseName: _selectedCourse?.name,
                        greenCoords: _greenCoords,
                      )
                  : null,
              child: const Text('Start Round'),
            ),
          ),
        ],
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
