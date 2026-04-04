import 'package:flutter/material.dart';

import '../app.dart';
import '../data/preset_courses.dart';
import '../models/golf_course.dart';
import '../services/supabase_service.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<GolfCourse> _userCourses = <GolfCourse>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserCourses();
  }

  Future<void> _loadUserCourses() async {
    setState(() => _loading = true);
    try {
      final service = SupabaseService();
      final courses = await service.fetchUserCourses();
      if (mounted) {
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

  Future<void> _setHomeCourse(GolfCourse course) async {
    try {
      final service = SupabaseService();
      await service.setHomeCourse(course.id);
      final store = PokemonGolfScope.of(context);
      store.setHomeCourseId(course.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${course.name} set as home course')),
        );
      }
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
    final allCourses = <GolfCourse>[...presetCourses, ..._userCourses];

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
          : allCourses.isEmpty
              ? Center(
                  child: Text(
                    'No courses yet',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: allCourses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final course = allCourses[index];
                    final isHome = store.homeCourseId == course.id;
                    return _CourseCard(
                      course: course,
                      isHome: isHome,
                      onSetHome: () => _setHomeCourse(course),
                    );
                  },
                ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.course,
    required this.isHome,
    required this.onSetHome,
  });

  final GolfCourse course;
  final bool isHome;
  final VoidCallback onSetHome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int holeCount = course.hasParts
        ? course.parts!.first.pars.length
        : (course.pars?.length ?? 0);
    final int? totalPar = course.hasParts
        ? null
        : course.pars?.fold<int>(0, (a, b) => a + b);

    return Card(
      shape: isHome
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    course.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isHome)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.home, size: 14, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Home',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  IconButton(
                    icon: Icon(Icons.home_outlined,
                        size: 20,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                    tooltip: 'Set as home course',
                    onPressed: onSetHome,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            if (course.hasParts)
              Text(
                '${course.parts!.length} parts  ·  ${holeCount} holes each',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              )
            else if (totalPar != null)
              Text(
                '$holeCount holes  ·  Par $totalPar',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            if (course.hasParts) ...[
              const SizedBox(height: 8),
              for (final part in course.parts!)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 56,
                        child: Text(
                          part.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      Text(
                        'Par ${part.pars.fold<int>(0, (a, b) => a + b)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
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
