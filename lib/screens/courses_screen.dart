import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app.dart';
import '../models/golf_course.dart';
import '../services/supabase_service.dart';
import 'round_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen>
    with SingleTickerProviderStateMixin {
  List<GolfCourse> _userCourses = <GolfCourse>[];
  bool _loading = true;
  String _query = '';
  late final TabController _tabController;

  bool get _mapMode => _tabController.index == 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadUserCourses();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserCourses() async {
    if (!mounted) return;
    final store = PokemonGolfScope.of(context);
    setState(() => _loading = true);
    try {
      final service = SupabaseService();
      final courses = await service.fetchUserCourses();
      if (mounted) {
        store.syncUserCourses(courses);
        setState(() {
          _userCourses = courses;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showAddCourse() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddCourseSheet(
        onSaved: () {
          Navigator.of(context).pop();
          _loadUserCourses();
        },
      ),
    );
  }

  void _startRound(GolfCourse course) {
    final store = PokemonGolfScope.of(context);

    void launch(List<int> pars, {List<({double lat, double lng})?>? greenCoords}) {
      store.startRound(pars.length, holePars: pars, courseName: course.name, greenCoords: greenCoords);
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const RoundScreen()),
      );
    }

    if (course.hasMultipleLoops) {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _LoopPickerSheet(
          course: course,
          onStart: (List<int> pars, {List<({double lat, double lng})?>? greenCoords}) {
            Navigator.of(context).pop();
            launch(pars, greenCoords: greenCoords);
          },
        ),
      );
      return;
    }

    final pars = course.flatPars;
    if (pars.length >= 18) {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _HoleCountSheet(
          course: course,
          onStart: (List<int> selectedPars, {List<({double lat, double lng})?>? greenCoords}) {
            Navigator.of(context).pop();
            launch(selectedPars, greenCoords: greenCoords);
          },
        ),
      );
      return;
    }

    // 9-hole or shorter: start directly
    launch(pars, greenCoords: course.singleLoopNullableGreens);
  }

  Future<void> _setHomeCourse(GolfCourse course) async {
    final store = PokemonGolfScope.of(context);
    try {
      final service = SupabaseService();
      await service.setHomeCourse(course.id);
      if (!mounted) return;
      store.setHomeCourseId(course.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${course.name} set as home course')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to set home course')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = PokemonGolfScope.of(context);

    final allCourses = <GolfCourse>[
      ...store.catalogCourses,
      ..._userCourses,
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final homeCourse = store.homeCourseId != null
        ? allCourses.where((c) => c.id == store.homeCourseId).firstOrNull
        : null;

    final q = _query.toLowerCase();
    final filtered = q.isEmpty
        ? allCourses.where((c) => c.id != store.homeCourseId).toList()
        : allCourses
            .where((c) =>
                c.id != store.homeCourseId &&
                c.name.toLowerCase().contains(q))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        actions: <Widget>[
          if (!_mapMode)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add course',
              onPressed: _showAddCourse,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Tab>[
            Tab(icon: Icon(Icons.list, size: 18), text: 'List'),
            Tab(icon: Icon(Icons.map_outlined, size: 18), text: 'Map'),
          ],
        ),
      ),
      body: _loading && _userCourses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _mapMode
              ? _CourseMap(
                  courses: [...store.catalogCourses, ..._userCourses],
                  onStartRound: _startRound,
                )
              : CustomScrollView(
              slivers: <Widget>[
                // Home course (pinned)
                if (homeCourse != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.home_rounded,
                                    size: 14,
                                    color: theme.colorScheme.secondary),
                                const SizedBox(width: 6),
                                Text(
                                  'Home Course',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.secondary,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _CourseCard(
                            course: homeCourse,
                            isHome: true,
                            onSetHome: () {},
                            onPlay: () => _startRound(homeCourse),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Search bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'Search courses…',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () => setState(() => _query = ''),
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                // Course list
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        _query.isEmpty ? 'No courses yet' : 'No results',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final course = filtered[index];
                        return _CourseCard(
                          course: course,
                          isHome: false,
                          onSetHome: () => _setHomeCourse(course),
                          onPlay: () => _startRound(course),
                        );
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}

// ── Map view ──────────────────────────────────────────────────────────────────

class _CourseMap extends StatefulWidget {
  const _CourseMap({required this.courses, required this.onStartRound});

  final List<GolfCourse> courses;
  final void Function(GolfCourse) onStartRound;

  @override
  State<_CourseMap> createState() => _CourseMapState();
}

class _CourseMapState extends State<_CourseMap> {
  final MapController _mapController = MapController();
  double _zoom = 9.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final courses = widget.courses.where((c) => c.lat != null && c.lng != null).toList();

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(55.9, 13.4),
        initialZoom: 9.0,
        minZoom: 7.0,
        maxZoom: 16.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onMapEvent: (event) {
          if (event is MapEventMove || event is MapEventScrollWheelZoom) {
            final newZoom = _mapController.camera.zoom;
            if ((newZoom - _zoom).abs() > 0.3) {
              setState(() => _zoom = newZoom);
            }
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.rootpi.golf',
          retinaMode: true,
        ),
        MarkerLayer(
          markers: courses.map((course) {
            final showLabel = _zoom >= 11;
            final showDetail = _zoom >= 13;
            final totalPar = course.flatPars.isEmpty ? null : course.flatPars.reduce((a, b) => a + b);
            final holeCount = course.flatPars.length;

            return Marker(
              point: LatLng(course.lat!, course.lng!),
              width: showDetail ? 160 : showLabel ? 140 : 16,
              height: showDetail ? 80 : showLabel ? 40 : 16,
              alignment: showLabel ? Alignment.topCenter : Alignment.center,
              child: GestureDetector(
                onTap: () => widget.onStartRound(course),
                child: showDetail
                    ? _DetailMarker(course: course, totalPar: totalPar, holeCount: holeCount, theme: theme)
                    : showLabel
                        ? _LabelMarker(name: course.name, theme: theme)
                        : _DotMarker(theme: theme),
              ),
            );
          }).toList(),
        ),
        const RichAttributionWidget(
          attributions: [TextSourceAttribution('© OpenStreetMap © CARTO')],
          showFlutterMapAttribution: false,
        ),
      ],
    );
  }
}

class _DotMarker extends StatelessWidget {
  const _DotMarker({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primary,
        boxShadow: [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.5), blurRadius: 6)],
      ),
    );
  }
}

class _LabelMarker extends StatelessWidget {
  const _LabelMarker({required this.name, required this.theme});
  final String name;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF172417),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.6)),
          ),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          width: 2,
          height: 6,
          color: theme.colorScheme.primary.withValues(alpha: 0.6),
        ),
      ],
    );
  }
}

class _DetailMarker extends StatelessWidget {
  const _DetailMarker({required this.course, required this.totalPar, required this.holeCount, required this.theme});
  final GolfCourse course;
  final int? totalPar;
  final int holeCount;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF172417),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.7)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                course.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (totalPar != null)
                Text(
                  '$holeCount holes · par $totalPar',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        Container(
          width: 2,
          height: 6,
          color: theme.colorScheme.primary.withValues(alpha: 0.6),
        ),
      ],
    );
  }
}

// ── Course card ───────────────────────────────────────────────────────────────

class _CourseCard extends StatefulWidget {
  const _CourseCard({
    required this.course,
    required this.isHome,
    required this.onSetHome,
    required this.onPlay,
  });

  final GolfCourse course;
  final bool isHome;
  final VoidCallback onSetHome;
  final VoidCallback onPlay;

  @override
  State<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<_CourseCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final course = widget.course;
    final dim = theme.colorScheme.onSurface.withValues(alpha: 0.5);
    final int totalParAll = course.flatPars.fold<int>(0, (int a, int b) => a + b);

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: widget.isHome
              ? Border.all(color: theme.colorScheme.primary, width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.golf_course,
                  size: 20,
                  color: widget.isHome
                      ? theme.colorScheme.primary
                      : dim,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        course.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        course.hasMultipleLoops
                            ? '${course.loops.length} nine-hole loops'
                            : '${course.flatPars.length} holes  ·  Par $totalParAll',
                        style: theme.textTheme.bodySmall?.copyWith(color: dim),
                      ),
                    ],
                  ),
                ),
                if (widget.isHome)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.home, size: 13, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Home',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.expand_more, size: 22, color: dim),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildExpanded(theme, course, dim),
              crossFadeState:
                  _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpanded(ThemeData theme, GolfCourse course, Color dim) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (course.hasMultipleLoops)
            for (final CourseLoop loop in course.loops) ...[
              Row(
                children: <Widget>[
                  Text(
                    loop.name.isEmpty ? 'Loop' : loop.name,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Par ${loop.holes.fold<int>(0, (int a, CourseHole h) => a + h.par)}',
                    style: theme.textTheme.labelMedium?.copyWith(color: dim),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _HoleParGrid(
                pars: loop.holes.map((CourseHole h) => h.par).toList(growable: false),
                startHole: 1,
              ),
              const SizedBox(height: 12),
            ]
          else ...[
            if (course.flatPars.length >= 18) ...[
              Row(
                children: <Widget>[
                  Text('Front 9', style: theme.textTheme.labelMedium?.copyWith(color: dim)),
                  const Spacer(),
                  Text(
                    'Par ${course.flatPars.sublist(0, 9).fold<int>(0, (a, b) => a + b)}',
                    style: theme.textTheme.labelMedium?.copyWith(color: dim),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _HoleParGrid(pars: course.flatPars.sublist(0, 9), startHole: 1),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Text('Back 9', style: theme.textTheme.labelMedium?.copyWith(color: dim)),
                  const Spacer(),
                  Text(
                    'Par ${course.flatPars.sublist(9).fold<int>(0, (a, b) => a + b)}',
                    style: theme.textTheme.labelMedium?.copyWith(color: dim),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _HoleParGrid(pars: course.flatPars.sublist(9), startHole: 10),
            ] else ...[
              Row(
                children: <Widget>[
                  Text(
                    '${course.flatPars.length} holes',
                    style: theme.textTheme.labelMedium?.copyWith(color: dim),
                  ),
                  const Spacer(),
                  Text(
                    'Par ${course.flatPars.fold<int>(0, (a, b) => a + b)}',
                    style: theme.textTheme.labelMedium?.copyWith(color: dim),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _HoleParGrid(pars: course.flatPars, startHole: 1),
            ],
          ],
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              if (!widget.isHome)
                TextButton.icon(
                  onPressed: widget.onSetHome,
                  icon: const Icon(Icons.home_outlined, size: 18),
                  label: const Text('Set as home'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              const Spacer(),
              FilledButton.icon(
                onPressed: widget.onPlay,
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: const Text('Play'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HoleParGrid extends StatelessWidget {
  const _HoleParGrid({required this.pars, required this.startHole});

  final List<int> pars;
  final int startHole;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dim = theme.colorScheme.onSurface.withValues(alpha: 0.35);

    // Equal-width cells in one row — fixed pixel widths + Wrap left hole 9 alone on narrow screens.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < pars.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: 3),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 1),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${startHole + i}',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: dim,
                    ),
                  ),
                  const SizedBox(height: 1),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${pars[i]}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _LoopPickerSheet extends StatefulWidget {
  const _LoopPickerSheet({required this.course, required this.onStart});

  final GolfCourse course;
  final void Function(List<int> pars, {List<({double lat, double lng})?>? greenCoords}) onStart;

  @override
  State<_LoopPickerSheet> createState() => _LoopPickerSheetState();
}

class _LoopPickerSheetState extends State<_LoopPickerSheet> {
  late int _selected; // index into _options

  // Each option is either a single loop index or all loops combined (-1)
  late final List<_LoopOption> _options;

  @override
  void initState() {
    super.initState();
    final loops = widget.course.loops;
    _options = [
      for (int i = 0; i < loops.length; i++)
        _LoopOption(
          label: loops[i].name.isEmpty ? 'Loop ${i + 1}' : loops[i].name,
          subtitle: '${loops[i].holeCount} holes  ·  Par ${loops[i].holes.fold<int>(0, (a, h) => a + h.par)}',
          loopIndices: [i],
        ),
      if (loops.length == 2)
        _LoopOption(
          label: 'Full round',
          subtitle: '${loops.fold<int>(0, (s, l) => s + l.holeCount)} holes  ·  Par ${loops.expand((l) => l.holes).fold<int>(0, (a, h) => a + h.par)}',
          loopIndices: [0, 1],
        ),
    ];
    _selected = _options.length - 1; // default: full round or last loop
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _RoundPickerShell(
      courseName: widget.course.name,
      onPlay: () {
        final indices = _options[_selected].loopIndices;
        final picked = indices.map((i) => widget.course.loops[i]).toList();
        final pars = widget.course.parsForLoops(picked);
        final greens = widget.course.greensNullableForLoops(picked);
        widget.onStart(pars, greenCoords: greens.any((e) => e != null) ? greens : null);
      },
      children: [
        for (int i = 0; i < _options.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _RadioRow(
            label: _options[i].label,
            subtitle: _options[i].subtitle,
            selected: _selected == i,
            onTap: () => setState(() => _selected = i),
            theme: theme,
          ),
        ],
      ],
    );
  }
}

class _LoopOption {
  const _LoopOption({required this.label, required this.subtitle, required this.loopIndices});
  final String label;
  final String subtitle;
  final List<int> loopIndices;
}

class _HoleCountSheet extends StatefulWidget {
  const _HoleCountSheet({required this.course, required this.onStart});

  final GolfCourse course;
  final void Function(List<int> pars, {List<({double lat, double lng})?>? greenCoords}) onStart;

  @override
  State<_HoleCountSheet> createState() => _HoleCountSheetState();
}

class _HoleCountSheetState extends State<_HoleCountSheet> {
  int _selected = 2; // 0=front9, 1=back9, 2=full18

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allPars = widget.course.flatPars;
    final allGreens = widget.course.singleLoopNullableGreens;
    final frontPars = allPars.sublist(0, 9);
    final backPars = allPars.sublist(9);
    final frontGreens = allGreens?.sublist(0, 9);
    final backGreens = allGreens?.sublist(9);
    final frontPar = frontPars.fold<int>(0, (a, b) => a + b);
    final backPar = backPars.fold<int>(0, (a, b) => a + b);
    final totalPar = allPars.fold<int>(0, (a, b) => a + b);

    return _RoundPickerShell(
      courseName: widget.course.name,
      onPlay: () {
        switch (_selected) {
          case 0: widget.onStart(frontPars, greenCoords: frontGreens);
          case 1: widget.onStart(backPars, greenCoords: backGreens);
          case _: widget.onStart(allPars, greenCoords: allGreens);
        }
      },
      children: [
        _RadioRow(label: 'Front 9', subtitle: 'Holes 1–9  ·  Par $frontPar', selected: _selected == 0, onTap: () => setState(() => _selected = 0), theme: theme),
        const SizedBox(height: 8),
        _RadioRow(label: 'Back 9', subtitle: 'Holes 10–18  ·  Par $backPar', selected: _selected == 1, onTap: () => setState(() => _selected = 1), theme: theme),
        const SizedBox(height: 8),
        _RadioRow(label: 'Full 18', subtitle: 'All holes  ·  Par $totalPar', selected: _selected == 2, onTap: () => setState(() => _selected = 2), theme: theme),
      ],
    );
  }
}

// ── Shared picker widgets ─────────────────────────────────────────────────────

class _RoundPickerShell extends StatelessWidget {
  const _RoundPickerShell({required this.courseName, required this.onPlay, required this.children});

  final String courseName;
  final VoidCallback onPlay;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text(courseName, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          ...children,
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPlay,
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: const Text('Play'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({required this.label, required this.subtitle, required this.selected, required this.onTap, required this.theme});

  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary.withValues(alpha: 0.1) : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: selected,
              onChanged: (_) => onTap(),
              activeColor: theme.colorScheme.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCourseSheet extends StatefulWidget {
  const _AddCourseSheet({required this.onSaved});

  final VoidCallback onSaved;

  @override
  State<_AddCourseSheet> createState() => _AddCourseSheetState();
}

class _AddCourseSheetState extends State<_AddCourseSheet> {
  final TextEditingController _nameController = TextEditingController();
  final List<int> _pars = List<int>.filled(18, 4);
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _cyclePar(int index) {
    setState(() {
      _pars[index] = _pars[index] == 5 ? 3 : _pars[index] + 1;
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a course name.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final service = SupabaseService();
      await service.insertUserCourse(name, _pars);
      widget.onSaved();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to save course.';
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPar = _pars.fold<int>(0, (a, b) => a + b);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
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
          const SizedBox(height: 16),
          Text('Add Course',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Course name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Text('Par per hole',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('Total: $totalPar',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  )),
            ],
          ),
          const SizedBox(height: 4),
          Text('Tap a hole to cycle 3 → 4 → 5',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              )),
          const SizedBox(height: 12),
          for (int row = 0; row < 2; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: <Widget>[
                  for (int col = 0; col < 9; col++) ...[
                    if (col > 0) const SizedBox(width: 4),
                    Expanded(
                      child: _ParCell(
                        hole: row * 9 + col + 1,
                        par: _pars[row * 9 + col],
                        onTap: () => _cyclePar(row * 9 + col),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save Course'),
          ),
        ],
      ),
    );
  }
}

class _ParCell extends StatelessWidget {
  const _ParCell({
    required this.hole,
    required this.par,
    required this.onTap,
  });

  final int hole;
  final int par;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '$hole',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                fontSize: 10,
              ),
            ),
            Text(
              '$par',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
