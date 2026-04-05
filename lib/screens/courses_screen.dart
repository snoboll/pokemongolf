import 'package:flutter/material.dart';

import '../app.dart';
import '../models/golf_course.dart';
import '../services/supabase_service.dart';
import 'round_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<GolfCourse> _userCourses = <GolfCourse>[];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadUserCourses();
    });
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
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add course',
            onPressed: _showAddCourse,
          ),
        ],
      ),
      body: _loading && _userCourses.isEmpty
          ? const Center(child: CircularProgressIndicator())
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
  final Set<int> _selectedIndices = <int>{};

  int get _totalHoles =>
      _selectedIndices.fold<int>(0, (int sum, int i) => sum + widget.course.loops[i].holeCount);

  bool get _canStart => _selectedIndices.isNotEmpty && _selectedIndices.length <= 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<CourseLoop> loops = widget.course.loops;
    final dim = theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
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
            widget.course.name,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Select 1 loop (9 holes) or 2 loops (18 holes)',
            style: theme.textTheme.bodySmall?.copyWith(color: dim),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < loops.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_selectedIndices.contains(i)) {
                    _selectedIndices.remove(i);
                  } else {
                    if (_selectedIndices.length >= 2) _selectedIndices.remove(_selectedIndices.first);
                    _selectedIndices.add(i);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _selectedIndices.contains(i)
                      ? theme.colorScheme.primary.withValues(alpha: 0.12)
                      : theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: _selectedIndices.contains(i)
                      ? Border.all(color: theme.colorScheme.primary, width: 1.5)
                      : Border.all(color: Colors.transparent, width: 1.5),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      _selectedIndices.contains(i)
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 22,
                      color: _selectedIndices.contains(i)
                          ? theme.colorScheme.primary
                          : dim,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            loops[i].name.isEmpty ? 'Loop ${i + 1}' : loops[i].name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${loops[i].holeCount} holes  ·  Par ${loops[i].holes.fold<int>(0, (int a, CourseHole h) => a + h.par)}',
                            style: theme.textTheme.bodySmall?.copyWith(color: dim),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _canStart
                  ? () {
                      final List<int> sorted = _selectedIndices.toList()..sort();
                      final List<CourseLoop> picked =
                          sorted.map((i) => widget.course.loops[i]).toList();
                      final List<int> pars = widget.course.parsForLoops(picked);
                      final List<({double lat, double lng})?> greens =
                          widget.course.greensNullableForLoops(picked);
                      final bool anyGreen = greens.any((e) => e != null);
                      widget.onStart(pars, greenCoords: anyGreen ? greens : null);
                    }
                  : null,
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: Text(
                _canStart ? 'Start $_totalHoles holes' : 'Select loops',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoleCountSheet extends StatelessWidget {
  const _HoleCountSheet({required this.course, required this.onStart});

  final GolfCourse course;
  final void Function(List<int> pars, {List<({double lat, double lng})?>? greenCoords}) onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dim = theme.colorScheme.onSurface.withValues(alpha: 0.5);
    final allPars = course.flatPars;
    final allGreens = course.singleLoopNullableGreens;
    final frontPars = allPars.sublist(0, 9);
    final backPars = allPars.sublist(9);
    final frontGreens = allGreens?.sublist(0, 9);
    final backGreens = allGreens?.sublist(9);
    final frontPar = frontPars.fold<int>(0, (a, b) => a + b);
    final backPar = backPars.fold<int>(0, (a, b) => a + b);
    final totalPar = allPars.fold<int>(0, (a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
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
            course.name,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text('How many holes?', style: theme.textTheme.bodySmall?.copyWith(color: dim)),
          const SizedBox(height: 16),
          _HoleOption(
            title: 'Front 9',
            subtitle: 'Holes 1–9  ·  Par $frontPar',
            icon: Icons.looks_one_outlined,
            onTap: () => onStart(frontPars, greenCoords: frontGreens),
          ),
          const SizedBox(height: 8),
          _HoleOption(
            title: 'Back 9',
            subtitle: 'Holes 10–18  ·  Par $backPar',
            icon: Icons.looks_two_outlined,
            onTap: () => onStart(backPars, greenCoords: backGreens),
          ),
          const SizedBox(height: 8),
          _HoleOption(
            title: 'Full 18',
            subtitle: 'All holes  ·  Par $totalPar',
            icon: Icons.golf_course,
            isPrimary: true,
            onTap: () => onStart(allPars, greenCoords: allGreens),
          ),
        ],
      ),
    );
  }
}

class _HoleOption extends StatelessWidget {
  const _HoleOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPrimary
              ? cs.primary.withValues(alpha: 0.12)
              : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary ? cs.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 22,
                color: isPrimary ? cs.primary : cs.onSurface.withValues(alpha: 0.6)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  Text(subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.5))),
                ],
              ),
            ),
            Icon(Icons.play_arrow_rounded, size: 22,
                color: isPrimary ? cs.primary : cs.onSurface.withValues(alpha: 0.4)),
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
