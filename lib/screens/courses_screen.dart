import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../app.dart';
import '../models/battle_models.dart';
import '../models/course_leader.dart';
import '../models/golf_course.dart';
import '../models/golfer_team.dart';
import '../services/battle_service.dart';
import '../services/supabase_service.dart';
import '../state/battle_store.dart';
import 'battle_round_screen.dart';
import 'battles_screen.dart';
import 'round_screen.dart';
import 'team_select_screen.dart';

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
    final store = BogeybeastGolfScope.of(context);
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

  void _startRound(GolfCourse course) {
    final store = BogeybeastGolfScope.of(context);

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

  void _startBattle(GolfCourse course) async {
    final store = BogeybeastGolfScope.of(context);

    if (store.caughtDexNumbers.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catch at least 3 Bogeybeast to battle')),
      );
      return;
    }

    final team = await Navigator.of(context).push<List<BattleBogeybeast>>(
      MaterialPageRoute(
        builder: (_) => TeamSelectScreen(
          caughtDexNumbers: Set<int>.from(store.caughtDexNumbers),
          title: 'Pick your team',
        ),
      ),
    );
    if (team == null || !mounted) return;

    final pars = course.flatPars;
    final holeCount = pars.length > 18 ? 18 : pars.length;
    final selectedPars = pars.take(holeCount).toList();

    try {
      final battleStore = BattleStore(service: BattleService());
      final battle = await battleStore.createBattle(
        courseId:       course.id,
        courseName:     course.name,
        holeCount:      holeCount,
        coursePars:     selectedPars,
        team:           team,
        challengerName: store.golferName ?? 'Golfer',
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PvP challenge created at ${course.name}!')),
      );

      battleStore.watchBattle(battle.id);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BattleScope(
            notifier: battleStore,
            child: BattleRoundScreen(battleId: battle.id),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _challengeLeader(GolfCourse course) async {
    final store = BogeybeastGolfScope.of(context);
    final leader = store.leaderForCourse(course.id);

    if (store.caughtDexNumbers.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catch at least 3 Bogeybeast to challenge a leader')),
      );
      return;
    }

    final team = await Navigator.of(context).push<List<BattleBogeybeast>>(
      MaterialPageRoute(
        builder: (_) => TeamSelectScreen(
          caughtDexNumbers: Set<int>.from(store.caughtDexNumbers),
          title: 'Pick your team',
          leader: leader,
        ),
      ),
    );
    if (team == null || !mounted) return;

    final pars = course.flatPars;
    final holeCount = pars.length > 18 ? 18 : pars.length;
    final selectedPars = pars.take(holeCount).toList();

    try {
      final battleStore = BattleStore(service: BattleService());
      final battle = await battleStore.createLeaderChallenge(
        courseId:       course.id,
        courseName:     course.name,
        holeCount:      holeCount,
        coursePars:     selectedPars,
        team:           team,
        challengerName: store.golferName ?? 'Golfer',
        leaderName:     leader.leaderName,
        leaderTeam:     leader.team,
        leaderHcp:      leader.hcp,
        leaderUserId:   leader.userId,
      );
      if (!mounted) return;

      battleStore.watchBattle(battle.id);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => BattleScope(
          notifier: battleStore,
          child: BattleRoundScreen(battleId: battle.id),
        ),
      )).then((_) {
        battleStore.stopWatching();
        if (mounted) {
          BogeybeastGolfScope.of(context).refreshCourseLeaders();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _setHomeCourse(GolfCourse course) async {
    final store = BogeybeastGolfScope.of(context);
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
    final store = BogeybeastGolfScope.of(context);

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
        actions: const <Widget>[],
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
                  onStartBattle: _startBattle,
                  onChallengeLeader: _challengeLeader,
                  leaderForCourse: store.leaderForCourse,
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
                            onBattle: () => _startBattle(homeCourse),
                            leader: store.leaderForCourse(homeCourse.id),
                            onChallenge: () => _challengeLeader(homeCourse),
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
                          onBattle: () => _startBattle(course),
                          leader: store.leaderForCourse(course.id),
                          onChallenge: () => _challengeLeader(course),
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
  const _CourseMap({
    required this.courses,
    required this.onStartRound,
    required this.onStartBattle,
    required this.onChallengeLeader,
    required this.leaderForCourse,
  });

  final List<GolfCourse> courses;
  final void Function(GolfCourse) onStartRound;
  final void Function(GolfCourse) onStartBattle;
  final void Function(GolfCourse) onChallengeLeader;
  final CourseLeader Function(String courseId) leaderForCourse;

  @override
  State<_CourseMap> createState() => _CourseMapState();
}

class _CourseMapState extends State<_CourseMap> {
  final MapController _mapController = MapController();
  double _zoom = 9.0;
  Position? _userPos;

  @override
  void initState() {
    super.initState();
    _acquireLocation();
  }

  Future<void> _acquireLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      if (!mounted) return;
      setState(() => _userPos = pos);
    } catch (_) {}
  }

  void _openCourseActions(GolfCourse course) {
    final leader = widget.leaderForCourse(course.id);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CourseActionSheet(
        course: course,
        leader: leader,
        onCatch: () {
          Navigator.of(context).pop();
          widget.onStartRound(course);
        },
        onBattle: () {
          Navigator.of(context).pop();
          widget.onStartBattle(course);
        },
        onGym: () {
          Navigator.of(context).pop();
          widget.onChallengeLeader(course);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final courses =
        widget.courses.where((c) => c.lat != null && c.lng != null).toList();

    return Stack(
      children: [
        FlutterMap(
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
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.rootpi.golf',
              retinaMode: true,
            ),
            MarkerLayer(
              markers: [
                if (_userPos != null)
                  Marker(
                    point: LatLng(_userPos!.latitude, _userPos!.longitude),
                    width: 18,
                    height: 18,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ...courses.map((course) {
                  final showLabel = _zoom >= 11;
                  final showDetail = _zoom >= 13;
                  final totalPar = course.flatPars.isEmpty
                      ? null
                      : course.flatPars.reduce((a, b) => a + b);
                  final holeCount = course.flatPars.length;

                  return Marker(
                    point: LatLng(course.lat!, course.lng!),
                    width: showDetail ? 300 : showLabel ? 140 : 16,
                    height: showDetail ? 200 : showLabel ? 40 : 16,
                    alignment:
                        showLabel ? Alignment.topCenter : Alignment.center,
                    child: GestureDetector(
                      onTap: () => _openCourseActions(course),
                      child: Builder(builder: (_) {
                        final leader = widget.leaderForCourse(course.id);
                        final dotColor = teamColor(GolferTeam.fromDb(leader.golferTeam));
                        return showDetail
                          ? _DetailMarker(
                              course: course,
                              totalPar: totalPar,
                              holeCount: holeCount,
                              theme: theme,
                              leader: leader,
                            )
                          : showLabel
                              ? _LabelMarker(name: course.name, theme: theme, color: dotColor)
                              : _DotMarker(color: dotColor);
                      }),
                    ),
                  );
                }),
              ],
            ),
            const RichAttributionWidget(
              attributions: [TextSourceAttribution('© OpenStreetMap © CARTO')],
              showFlutterMapAttribution: false,
            ),
          ],
        ),

      ],
    );
  }
}

// ── Course action sheet (Catch / PvP / Gym) ─────────────────────────────────

class _CourseActionSheet extends StatelessWidget {
  const _CourseActionSheet({
    required this.course,
    required this.leader,
    required this.onCatch,
    required this.onBattle,
    required this.onGym,
  });

  final GolfCourse course;
  final CourseLeader leader;
  final VoidCallback onCatch;
  final VoidCallback onBattle;
  final VoidCallback onGym;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final leaderColor = teamColor(GolferTeam.fromDb(leader.golferTeam));
    final totalPar = course.flatPars.isEmpty
        ? null
        : course.flatPars.reduce((a, b) => a + b);
    final holeCount = course.flatPars.length;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Text(
            course.name,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (totalPar != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '$holeCount holes  ·  Par $totalPar',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Leader info
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: leaderColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: leaderColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                _GolferAvatar(sprite: leader.golferSprite, size: 36),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leader.leaderName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: leaderColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'HCP ${leader.hcp}',
                        style: TextStyle(
                          color: leaderColor.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                for (final p in leader.team)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: Image.network(
                        p.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.pets, size: 18),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Three action buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.pets,
                  label: 'Catch',
                  color: theme.colorScheme.primary,
                  subtitle: 'Play a round',
                  onTap: onCatch,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.videogame_asset_rounded,
                  label: 'PvP',
                  color: Colors.redAccent,
                  subtitle: 'PvP challenge',
                  onTap: onBattle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: GolferTeam.fromDb(leader.golferTeam)?.icon ?? Icons.shield,
                  label: 'Gym',
                  color: leaderColor,
                  subtitle: 'Challenge leader',
                  onTap: onGym,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
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

// ── Map markers ──────────────────────────────────────────────────────────────

class _DotMarker extends StatelessWidget {
  const _DotMarker({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }
}

class _LabelMarker extends StatelessWidget {
  const _LabelMarker({required this.name, required this.theme, required this.color});
  final String name;
  final ThemeData theme;
  final Color color;

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
            border: Border.all(
                color: color.withValues(alpha: 0.6)),
          ),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          width: 2,
          height: 6,
          color: color.withValues(alpha: 0.6),
        ),
      ],
    );
  }
}

class _DetailMarker extends StatelessWidget {
  const _DetailMarker({
    required this.course,
    required this.totalPar,
    required this.holeCount,
    required this.theme,
    required this.leader,
  });
  final GolfCourse course;
  final int? totalPar;
  final int holeCount;
  final ThemeData theme;
  final CourseLeader leader;

  @override
  Widget build(BuildContext context) {
    final leaderColor = teamColor(GolferTeam.fromDb(leader.golferTeam));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF172417),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: leaderColor.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _GolferAvatar(sprite: leader.golferSprite, size: 56),
              const SizedBox(width: 10),
              Flexible(
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
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (totalPar != null)
                      Text(
                        '$holeCount holes · par $totalPar',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '${leader.leaderName}  ·  HCP ${leader.hcp}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: leaderColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final p in leader.team)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: Image.network(
                                p.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    const SizedBox.shrink(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
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
    required this.onBattle,
    required this.leader,
    required this.onChallenge,
  });

  final GolfCourse course;
  final bool isHome;
  final VoidCallback onSetHome;
  final VoidCallback onPlay;
  final VoidCallback onBattle;
  final CourseLeader leader;
  final VoidCallback onChallenge;

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
          _LeaderSection(leader: widget.leader, onChallenge: widget.onChallenge),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.pets,
                  label: 'Catch',
                  color: theme.colorScheme.primary,
                  subtitle: 'Play a round',
                  onTap: widget.onPlay,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.videogame_asset_rounded,
                  label: 'PvP',
                  color: Colors.redAccent,
                  subtitle: 'PvP challenge',
                  onTap: widget.onBattle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (!widget.isHome)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: widget.onSetHome,
                icon: const Icon(Icons.home_outlined, size: 18),
                label: const Text('Set as home'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LeaderSection extends StatelessWidget {
  const _LeaderSection({required this.leader, required this.onChallenge});

  final CourseLeader leader;
  final VoidCallback onChallenge;

  @override
  Widget build(BuildContext context) {
    final leaderColor = teamColor(GolferTeam.fromDb(leader.golferTeam));
    final roleLabel = leader.isNpc
        ? 'Gym Leader'
        : (GolferTeam.fromDb(leader.golferTeam)?.label ?? 'Gym Leader');

    return GestureDetector(
      onTap: onChallenge,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: leaderColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: leaderColor.withValues(alpha: 0.45), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _GolferAvatar(sprite: leader.golferSprite, size: 52),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield_rounded, size: 11, color: leaderColor.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Text(
                        roleLabel,
                        style: TextStyle(
                          color: leaderColor.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        leader.leaderName,
                        style: TextStyle(
                          color: leaderColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: leaderColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'HCP ${leader.hcp}',
                          style: TextStyle(
                            color: leaderColor.withValues(alpha: 0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (leader.team.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final b in leader.team)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: Image.network(
                                b.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.pets, size: 18),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: leaderColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: leaderColor.withValues(alpha: 0.4)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_rounded, color: leaderColor, size: 18),
                  const SizedBox(height: 3),
                  Text(
                    'Gym',
                    style: TextStyle(
                      color: leaderColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
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

class _GolferAvatar extends StatelessWidget {
  const _GolferAvatar({required this.sprite, this.size = 32});

  final String? sprite;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (sprite == null) {
      return Icon(Icons.person, size: size * 0.7, color: const Color(0xFFFFD700));
    }
    // Showdown sprites have ~40% transparent padding baked into the canvas,
    // so we render at a larger internal size to fill the visual space.
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
  // _mode: loop index (>=0) = single loop, -1 = 18h pick, -2 = all loops
  late int _mode;
  // Ordered list — tap order defines play order
  final List<int> _orderedPicks = [];

  @override
  void initState() {
    super.initState();
    _mode = widget.course.loops.length >= 2 ? -1 : 0;
  }

  bool get _canPlay {
    if (_mode >= 0) return true;
    if (_mode == -2) return true;
    return _orderedPicks.length == 2;
  }

  void _play() {
    final loops = widget.course.loops;
    final List<int> indices;
    if (_mode >= 0) {
      indices = [_mode];
    } else if (_mode == -2) {
      indices = List.generate(loops.length, (i) => i);
    } else {
      indices = List<int>.from(_orderedPicks); // already in tap order
    }
    final picked = indices.map((i) => loops[i]).toList();
    final pars = widget.course.parsForLoops(picked);
    final greens = widget.course.greensNullableForLoops(picked);
    widget.onStart(pars, greenCoords: greens.any((e) => e != null) ? greens : null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loops = widget.course.loops;

    String loopName(int i) => loops[i].name.isEmpty ? 'Loop ${i + 1}' : loops[i].name;
    String loopSub(int i) {
      final l = loops[i];
      return '${l.holeCount} holes  ·  Par ${l.holes.fold<int>(0, (a, h) => a + h.par)}';
    }

    final totalHoles = loops.fold<int>(0, (s, l) => s + l.holeCount);
    final totalPar = loops.expand((l) => l.holes).fold<int>(0, (s, h) => s + h.par);

    // Build inline pick hint label
    String pickHint() {
      if (_orderedPicks.isEmpty) return 'Tap to pick 1st loop';
      if (_orderedPicks.length == 1) return '${loopName(_orderedPicks[0])} → tap to pick 2nd';
      return '${loopName(_orderedPicks[0])} → ${loopName(_orderedPicks[1])}';
    }

    return _RoundPickerShell(
      courseName: widget.course.name,
      onPlay: _canPlay ? _play : null,
      children: [
        // Individual loops
        for (int i = 0; i < loops.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _RadioRow(
            label: loopName(i),
            subtitle: loopSub(i),
            selected: _mode == i,
            onTap: () => setState(() { _mode = i; _orderedPicks.clear(); }),
            theme: theme,
          ),
        ],
        // 18-hole option
        if (loops.length >= 2) ...[
          const SizedBox(height: 8),
          _RadioRow(
            label: '18 holes',
            subtitle: _mode == -1 ? pickHint() : 'Pick two loops',
            selected: _mode == -1,
            onTap: () => setState(() { _mode = -1; _orderedPicks.clear(); }),
            theme: theme,
          ),
          if (_mode == -1) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < loops.length; i++) ...[
                    if (i > 0) const SizedBox(height: 6),
                    _LoopCheckRow(
                      label: loopName(i),
                      subtitle: loopSub(i),
                      orderLabel: _orderedPicks.indexOf(i) >= 0
                          ? '${_orderedPicks.indexOf(i) + 1}'
                          : null,
                      enabled: _orderedPicks.contains(i) || _orderedPicks.length < 2,
                      onTap: () => setState(() {
                        if (_orderedPicks.contains(i)) {
                          _orderedPicks.remove(i);
                        } else if (_orderedPicks.length < 2) {
                          _orderedPicks.add(i);
                        }
                      }),
                      theme: theme,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
        // Full round for 3+ loops
        if (loops.length >= 3) ...[
          const SizedBox(height: 8),
          _RadioRow(
            label: 'Full round ($totalHoles holes)',
            subtitle: 'All loops  ·  Par $totalPar',
            selected: _mode == -2,
            onTap: () => setState(() { _mode = -2; _orderedPicks.clear(); }),
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
  final VoidCallback? onPlay;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPad = MediaQuery.of(context).viewInsets.bottom + 32;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header — fixed
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(courseName, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
            ],
          ),
        ),
        // Options — scrollable
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
        // Play button — fixed at bottom
        Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPad),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPlay,
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: const Text('Play'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoopCheckRow extends StatelessWidget {
  const _LoopCheckRow({
    required this.label,
    required this.subtitle,
    required this.orderLabel,
    required this.enabled,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final String subtitle;
  final String? orderLabel; // '1' or '2' when picked, null when not
  final bool enabled;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final picked = orderLabel != null;
    final color = theme.colorScheme.primary;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.35,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: picked ? color.withValues(alpha: 0.1) : theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: picked ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: picked ? color : Colors.transparent,
                  border: Border.all(
                    color: picked ? color : theme.colorScheme.outlineVariant,
                    width: 1.5,
                  ),
                ),
                child: picked
                    ? Center(
                        child: Text(
                          orderLabel!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    : null,
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

