import 'package:flutter/material.dart';

import '../app.dart';
import '../data/first_gen_bogeybeasts.dart';
import '../models/bogeybeast_rarity.dart';
import '../models/bogeybeast_species.dart';
import '../models/club.dart';
import '../models/course_leader.dart';
import '../models/golfer_team.dart';
import '../services/supabase_service.dart';
import '../state/bogeybeasts_golf_store.dart';
import 'my_bag_screen.dart';
import '../widgets/white_bg_image.dart';
import '../widgets/bogeybeast_art.dart';

class GolfersScreen extends StatefulWidget {
  const GolfersScreen({super.key});

  @override
  State<GolfersScreen> createState() => _GolfersScreenState();
}

class _GolfersScreenState extends State<GolfersScreen> {
  List<GolferProfile>? _golfers;
  Map<String, int> _leadershipCounts = <String, int>{};
  bool _loading = true;
  String? _error;

  /// Dismisses in-flight fetches so an older response cannot overwrite newer data (e.g. after reset).
  int _fetchGeneration = 0;

  BogeybeastGolfStore? _store;
  int? _lastLocalCaughtCount;

  @override
  void initState() {
    super.initState();
    _loadGolfers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final BogeybeastGolfStore store = BogeybeastGolfScope.of(context);
    if (!identical(_store, store)) {
      _store?.removeListener(_onStoreChanged);
      _store = store;
      _lastLocalCaughtCount = store.caughtDexNumbers.length;
      _store?.addListener(_onStoreChanged);
    }
  }

  @override
  void dispose() {
    _store?.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    final BogeybeastGolfStore? store = _store;
    if (store == null) return;
    final int n = store.caughtDexNumbers.length;
    if (_lastLocalCaughtCount == n) return;
    _lastLocalCaughtCount = n;
    _loadGolfers();
  }

  Future<void> _loadGolfers() async {
    final int generation = ++_fetchGeneration;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = SupabaseService();
      final List<Object> results = await Future.wait(<Future<Object>>[
        service.fetchAllGolfers(),
        service.fetchCourseLeadershipCounts(),
      ]);
      if (!mounted || generation != _fetchGeneration) {
        return;
      }
      final List<GolferProfile> golfers = results[0] as List<GolferProfile>;
      final Map<String, int> leadershipCounts = results[1] as Map<String, int>;

      golfers.removeWhere((t) => t.golferName == 'Test');

      setState(() {
        _golfers = golfers;
        _leadershipCounts = leadershipCounts;
        _loading = false;
      });
    } catch (e, st) {
      debugPrint('Golfers load error: $e\n$st');
      if (!mounted || generation != _fetchGeneration) {
        return;
      }
      setState(() {
        _error = 'Failed to load golfers.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = firstGenBogeybeast.length;

    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('Golfers'),
        centerTitle: false,
        titleSpacing: 20,
        toolbarHeight: 64,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    _error!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: _loadGolfers,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _golfers == null || _golfers!.isEmpty
          ? Center(
              child: Text(
                'No golfers yet',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadGolfers,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _golfers!.length,
                separatorBuilder: (context, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final golfer = _golfers![index];
                  final progress = golfer.caughtCount / total;

                  return _GolferCard(
                    rank: index + 1,
                    golfer: golfer,
                    total: total,
                    progress: progress,
                    homeCourseName: BogeybeastGolfScope.of(
                      context,
                    ).courseNameForId(golfer.homeCourseId),
                    leadershipCount: _leadershipCounts[golfer.userId] ?? 0,
                  );
                },
              ),
            ),
    );
  }
}

class _GolferCard extends StatelessWidget {
  const _GolferCard({
    required this.rank,
    required this.golfer,
    required this.total,
    required this.progress,
    required this.leadershipCount,
    this.homeCourseName,
  });

  final int rank;
  final GolferProfile golfer;
  final int total;
  final double progress;
  final int leadershipCount;
  final String? homeCourseName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isComplete = golfer.caughtCount == total;
    final GolferTeam? tTeam = GolferTeam.fromDb(golfer.golferTeam);
    final Color borderColor = isComplete
        ? const Color(0xFFFFB300)
        : tTeam?.color ?? theme.colorScheme.primary.withValues(alpha: 0.3);

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => GolferProfileScreen(golfer: golfer),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 32,
                child: Text(
                  '#$rank',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _rankColor(rank),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: (tTeam?.color ?? theme.colorScheme.primary).withValues(
                    alpha: 0.10,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: golfer.golferSprite != null
                    ? WhiteBgImage(
                        asset: golfer.golferSprite!,
                        width: 52,
                        height: 52,
                        placeholder: Icon(
                          Icons.sports_golf_rounded,
                          color: isComplete
                              ? const Color(0xFFFFB300)
                              : theme.colorScheme.primary,
                          size: 24,
                        ),
                      )
                    : Icon(
                        Icons.sports_golf_rounded,
                        color: isComplete
                            ? const Color(0xFFFFB300)
                            : theme.colorScheme.primary,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      golfer.golferName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (homeCourseName != null || golfer.hcp != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          [
                            ?homeCourseName,
                            if (golfer.hcp != null) 'HCP ${golfer.hcp}',
                          ].nonNulls.join(' · '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                      ),
                    if (tTeam != null || leadershipCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: <Widget>[
                            if (tTeam != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: tTeam.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  tTeam.label,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: tTeam.color,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            if (leadershipCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFFB300,
                                  ).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const Icon(
                                      Icons.shield,
                                      size: 10,
                                      color: Color(0xFFFFB300),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '$leadershipCount ${leadershipCount == 1 ? 'course' : 'courses'}',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: const Color(0xFFFFB300),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 9,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        color: isComplete
                            ? const Color(0xFFFFB300)
                            : theme.colorScheme.primary,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    '${golfer.caughtCount}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '/ $total',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _rankColor(int rank) {
    return switch (rank) {
      1 => const Color(0xFFFFB300),
      2 => const Color(0xFFB0BEC5),
      3 => const Color(0xFF8D6E63),
      _ => const Color(0xFF78909C),
    };
  }
}

class GolferProfileScreen extends StatefulWidget {
  const GolferProfileScreen({super.key, required this.golfer});

  final GolferProfile golfer;

  @override
  State<GolferProfileScreen> createState() => _GolferProfileScreenState();
}

class _GolferProfileScreenState extends State<GolferProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Set<int>? _caughtDexNumbers;
  List<CourseLeader>? _ledCourses;
  List<Club>? _clubs;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final service = SupabaseService();
    final results = await Future.wait([
      service.fetchGolferCaughtDexNumbers(widget.golfer.userId),
      service.fetchCourseLeadersForUser(widget.golfer.userId),
      service.fetchClubsForUser(widget.golfer.userId),
    ]);
    if (mounted) {
      setState(() {
        _caughtDexNumbers = results[0] as Set<int>;
        _ledCourses = results[1] as List<CourseLeader>;
        _clubs = results[2] as List<Club>;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final golfer = widget.golfer;
    final GolferTeam? tTeam = GolferTeam.fromDb(golfer.golferTeam);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(golfer.golferName),
            Text(
              [
                '${golfer.caughtCount}/${firstGenBogeybeast.length} caught',
                if (golfer.hcp != null) 'HCP ${golfer.hcp}',
                if (tTeam != null) tTeam.label,
              ].join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.pets, size: 18), text: 'Bogeydex'),
            Tab(icon: Icon(Icons.shield_rounded, size: 18), text: 'Courses'),
            Tab(icon: Icon(Icons.golf_course_rounded, size: 18), text: 'Bag'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _BogeydexTab(caughtDexNumbers: _caughtDexNumbers!),
                _CoursesTab(
                  courses: _ledCourses!,
                  courseNameForId: BogeybeastGolfScope.of(context).courseNameForId,
                ),
                _BagTab(clubs: _clubs!),
              ],
            ),
    );
  }
}

class _BogeydexTab extends StatelessWidget {
  const _BogeydexTab({required this.caughtDexNumbers});
  final Set<int> caughtDexNumbers;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: firstGenBogeybeast.length,
      itemBuilder: (context, index) {
        final bogeybeast = firstGenBogeybeast[index];
        final caught = caughtDexNumbers.contains(bogeybeast.dexNumber);
        return _GolferBogeydexTile(bogeybeast: bogeybeast, caught: caught);
      },
    );
  }
}

class _BagTab extends StatelessWidget {
  const _BagTab({required this.clubs});
  final List<Club> clubs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (clubs.isEmpty) {
      return Center(
        child: Text(
          'No clubs in bag',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    int distanceOf(Club c) => c.totalDistance ?? c.carryDistance ?? 0;
    final sorted = List<Club>.from(clubs)
      ..sort((a, b) => distanceOf(b).compareTo(distanceOf(a)));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length + 1, // +1 for putter
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == sorted.length) {
          return const PutterTile();
        }
        return ClubTile(club: sorted[index], showEditAffordance: false);
      },
    );
  }
}

class _CoursesTab extends StatelessWidget {
  const _CoursesTab({required this.courses, required this.courseNameForId});
  final List<CourseLeader> courses;
  final String? Function(String?) courseNameForId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (courses.isEmpty) {
      return Center(
        child: Text(
          'No courses led yet',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final leader = courses[index];
        final color = teamColor(GolferTeam.fromDb(leader.golferTeam));
        final courseName = courseNameForId(leader.courseId) ?? leader.courseId;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.golf_course, size: 20, color: color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            courseName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'HCP ${leader.hcp}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield, size: 12, color: color),
                          const SizedBox(width: 4),
                          Text(
                            'Leader',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (leader.team.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Guarding beasts',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: leader.team
                        .take(3)
                        .map((b) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Column(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: theme.cardTheme.color,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: theme.colorScheme.outlineVariant,
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: BogeybeastArt(
                                      assetPath: b.assetPath,
                                      height: 44,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    b.name,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GolferBogeydexTile extends StatelessWidget {
  const _GolferBogeydexTile({required this.bogeybeast, required this.caught});

  final BogeybeastSpecies bogeybeast;
  final bool caught;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 8,
            left: 10,
            child: Text(
              '#${bogeybeast.paddedDexNumber}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (caught)
            Positioned(
              top: 6,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: bogeybeast.rarity.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  bogeybeast.rarity.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: bogeybeast.rarity.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          Column(
            children: <Widget>[
              const SizedBox(height: 28),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: caught
                      ? BogeybeastArt(
                          assetPath: bogeybeast.assetPath,
                          height: 100,
                        )
                      : Center(
                          child: Icon(
                            Icons.pets,
                            size: 48,
                            color: theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                child: Text(
                  caught ? bogeybeast.name : '???',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: caught
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
