import 'package:flutter/material.dart';

import '../app.dart';
import '../data/first_gen_bogeybeasts.dart';
import '../data/golfer_tags.dart';
import '../models/bogeybeast_rarity.dart';
import '../models/bogeybeast_species.dart';
import '../models/golfer_team.dart';
import '../services/supabase_service.dart';
import '../state/bogeybeasts_golf_store.dart';
import '../widgets/bogeybeast_art.dart';

class GolfersScreen extends StatefulWidget {
  const GolfersScreen({super.key});

  @override
  State<GolfersScreen> createState() => _GolfersScreenState();
}

class _GolfersScreenState extends State<GolfersScreen> {
  List<GolferProfile>? _golfers;
  Map<String, String> _golferTags = <String, String>{};
  Map<String, int> _gymCounts = <String, int>{};
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
        service.fetchAllCaughtDexNumbers(),
        service.fetchGymOwnershipCounts(),
      ]);
      if (!mounted || generation != _fetchGeneration) {
        return;
      }
      final List<GolferProfile> golfers =
          results[0] as List<GolferProfile>;
      final Map<String, Set<int>> allCaught =
          results[1] as Map<String, Set<int>>;
      final Map<String, int> gymCounts =
          results[2] as Map<String, int>;

      final Map<String, String> tags = <String, String>{};
      for (final GolferProfile golfer in golfers) {
        final Set<int>? caught = allCaught[golfer.userId];
        if (caught != null) {
          final String? tag = golferTagForCaughtDex(caught);
          if (tag != null) tags[golfer.userId] = tag;
        }
      }

      golfers.removeWhere((t) => t.golferName == 'Test');

      setState(() {
        _golfers = golfers;
        _golferTags = tags;
        _gymCounts = gymCounts;
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
      appBar: AppBar(title: const Text('Golfers')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                            homeCourseName: BogeybeastGolfScope.of(context)
                                .courseNameForId(golfer.homeCourseId),
                            tag: _golferTags[golfer.userId],
                            gymCount: _gymCounts[golfer.userId] ?? 0,
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
    required this.gymCount,
    this.homeCourseName,
    this.tag,
  });

  final int rank;
  final GolferProfile golfer;
  final int total;
  final double progress;
  final int gymCount;
  final String? homeCourseName;
  final String? tag;

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
            builder: (_) => GolferBogeydexScreen(golfer: golfer),
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
                color: (tTeam?.color ?? theme.colorScheme.primary).withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: golfer.golferSprite != null
                  ? ClipOval(
                      child: OverflowBox(
                        maxWidth: 52 * 1.4,
                        maxHeight: 52 * 1.4,
                        child: Image.asset(
                          golfer.golferSprite!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.pets,
                            color: isComplete
                                ? const Color(0xFFFFB300)
                                : theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    )
                  : Icon(
                      Icons.pets,
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
                  if (homeCourseName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        homeCourseName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  if (tTeam != null || tag != null || gymCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: <Widget>[
                          if (tTeam != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
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
                          if (gymCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Icon(Icons.shield, size: 10, color: Color(0xFFFFB300)),
                                  const SizedBox(width: 3),
                                  Text(
                                    '$gymCount ${gymCount == 1 ? 'gym' : 'gyms'}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: const Color(0xFFFFB300),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (tag != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tag!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9,
                                ),
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
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
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

class GolferBogeydexScreen extends StatefulWidget {
  const GolferBogeydexScreen({super.key, required this.golfer});

  final GolferProfile golfer;

  @override
  State<GolferBogeydexScreen> createState() => _GolferBogeydexScreenState();
}

class _GolferBogeydexScreenState extends State<GolferBogeydexScreen> {
  Set<int>? _caughtDexNumbers;
  String? _tag;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    SupabaseService()
        .fetchGolferCaughtDexNumbers(widget.golfer.userId)
        .then((numbers) {
      if (mounted) {
        setState(() {
          _caughtDexNumbers = numbers;
          _tag = golferTagForCaughtDex(numbers);
          _loading = false;
        });
      }
    }).catchError((_) {
      if (mounted) setState(() { _caughtDexNumbers = {}; _loading = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = firstGenBogeybeast.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.golfer.golferName}\'s Bogeydex'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '${widget.golfer.caughtCount} / $total caught',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_tag != null) ...<Widget>[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _tag!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: firstGenBogeybeast.length,
              itemBuilder: (context, index) {
                final BogeybeastSpecies bogeybeast = firstGenBogeybeast[index];
                final bool caught = _caughtDexNumbers!.contains(bogeybeast.dexNumber);
                return _GolferBogeydexTile(bogeybeast: bogeybeast, caught: caught);
              },
            ),
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
                      ? BogeybeastArt(imageUrl: bogeybeast.imageUrl, height: 100)
                      : Center(
                          child: Icon(
                            Icons.pets,
                            size: 48,
                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
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
