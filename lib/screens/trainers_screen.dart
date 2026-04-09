import 'package:flutter/material.dart';

import '../app.dart';
import '../data/first_gen_pokemon.dart';
import '../data/trainer_tags.dart';
import '../models/pokemon_rarity.dart';
import '../models/pokemon_species.dart';
import '../models/trainer_team.dart';
import '../services/supabase_service.dart';
import '../state/pokemon_golf_store.dart';
import '../widgets/pokemon_art.dart';

class TrainersScreen extends StatefulWidget {
  const TrainersScreen({super.key});

  @override
  State<TrainersScreen> createState() => _TrainersScreenState();
}

class _TrainersScreenState extends State<TrainersScreen> {
  List<TrainerProfile>? _trainers;
  Map<String, String> _trainerTags = <String, String>{};
  Map<String, int> _gymCounts = <String, int>{};
  bool _loading = true;
  String? _error;

  /// Dismisses in-flight fetches so an older response cannot overwrite newer data (e.g. after reset).
  int _fetchGeneration = 0;

  PokemonGolfStore? _store;
  int? _lastLocalCaughtCount;

  @override
  void initState() {
    super.initState();
    _loadTrainers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final PokemonGolfStore store = PokemonGolfScope.of(context);
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
    final PokemonGolfStore? store = _store;
    if (store == null) return;
    final int n = store.caughtDexNumbers.length;
    if (_lastLocalCaughtCount == n) return;
    _lastLocalCaughtCount = n;
    _loadTrainers();
  }

  Future<void> _loadTrainers() async {
    final int generation = ++_fetchGeneration;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = SupabaseService();
      final List<Object> results = await Future.wait(<Future<Object>>[
        service.fetchAllTrainers(),
        service.fetchAllCaughtDexNumbers(),
        service.fetchGymOwnershipCounts(),
      ]);
      if (!mounted || generation != _fetchGeneration) {
        return;
      }
      final List<TrainerProfile> trainers =
          results[0] as List<TrainerProfile>;
      final Map<String, Set<int>> allCaught =
          results[1] as Map<String, Set<int>>;
      final Map<String, int> gymCounts =
          results[2] as Map<String, int>;

      final Map<String, String> tags = <String, String>{};
      for (final TrainerProfile trainer in trainers) {
        final Set<int>? caught = allCaught[trainer.userId];
        if (caught != null) {
          final String? tag = trainerTagForCaughtDex(caught);
          if (tag != null) tags[trainer.userId] = tag;
        }
      }

      trainers.removeWhere((t) => t.trainerName == 'Test');

      setState(() {
        _trainers = trainers;
        _trainerTags = tags;
        _gymCounts = gymCounts;
        _loading = false;
      });
    } catch (e, st) {
      debugPrint('Trainers load error: $e\n$st');
      if (!mounted || generation != _fetchGeneration) {
        return;
      }
      setState(() {
        _error = 'Failed to load trainers.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = firstGenPokemon.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Trainers')),
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
                        onPressed: _loadTrainers,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _trainers == null || _trainers!.isEmpty
                  ? Center(
                      child: Text(
                        'No trainers yet',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadTrainers,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: _trainers!.length,
                        separatorBuilder: (context, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final trainer = _trainers![index];
                          final progress = trainer.caughtCount / total;

                          return _TrainerCard(
                            rank: index + 1,
                            trainer: trainer,
                            total: total,
                            progress: progress,
                            homeCourseName: PokemonGolfScope.of(context)
                                .courseNameForId(trainer.homeCourseId),
                            tag: _trainerTags[trainer.userId],
                            gymCount: _gymCounts[trainer.userId] ?? 0,
                          );
                        },
                      ),
                    ),
    );
  }
}

class _TrainerCard extends StatelessWidget {
  const _TrainerCard({
    required this.rank,
    required this.trainer,
    required this.total,
    required this.progress,
    required this.gymCount,
    this.homeCourseName,
    this.tag,
  });

  final int rank;
  final TrainerProfile trainer;
  final int total;
  final double progress;
  final int gymCount;
  final String? homeCourseName;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isComplete = trainer.caughtCount == total;
    final TrainerTeam? tTeam = TrainerTeam.fromDb(trainer.trainerTeam);
    final Color borderColor = isComplete
        ? const Color(0xFFFFB300)
        : tTeam?.color ?? theme.colorScheme.primary.withValues(alpha: 0.3);

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => TrainerPokedexScreen(trainer: trainer),
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
              child: trainer.trainerSprite != null
                  ? ClipOval(
                      child: OverflowBox(
                        maxWidth: 52 * 1.4,
                        maxHeight: 52 * 1.4,
                        child: Image.asset(
                          trainer.trainerSprite!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.catching_pokemon,
                            color: isComplete
                                ? const Color(0xFFFFB300)
                                : theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    )
                  : Icon(
                      Icons.catching_pokemon,
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
                    trainer.trainerName,
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
                  '${trainer.caughtCount}',
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

class TrainerPokedexScreen extends StatefulWidget {
  const TrainerPokedexScreen({super.key, required this.trainer});

  final TrainerProfile trainer;

  @override
  State<TrainerPokedexScreen> createState() => _TrainerPokedexScreenState();
}

class _TrainerPokedexScreenState extends State<TrainerPokedexScreen> {
  Set<int>? _caughtDexNumbers;
  String? _tag;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    SupabaseService()
        .fetchTrainerCaughtDexNumbers(widget.trainer.userId)
        .then((numbers) {
      if (mounted) {
        setState(() {
          _caughtDexNumbers = numbers;
          _tag = trainerTagForCaughtDex(numbers);
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
    final total = firstGenPokemon.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.trainer.trainerName}\'s Pokédex'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '${widget.trainer.caughtCount} / $total caught',
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
              itemCount: firstGenPokemon.length,
              itemBuilder: (context, index) {
                final PokemonSpecies pokemon = firstGenPokemon[index];
                final bool caught = _caughtDexNumbers!.contains(pokemon.dexNumber);
                return _TrainerPokedexTile(pokemon: pokemon, caught: caught);
              },
            ),
    );
  }
}

class _TrainerPokedexTile extends StatelessWidget {
  const _TrainerPokedexTile({required this.pokemon, required this.caught});

  final PokemonSpecies pokemon;
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
              '#${pokemon.paddedDexNumber}',
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
                  color: pokemon.rarity.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pokemon.rarity.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: pokemon.rarity.color,
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
                      ? PokemonArt(imageUrl: pokemon.imageUrl, height: 100)
                      : Center(
                          child: Icon(
                            Icons.catching_pokemon,
                            size: 48,
                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                child: Text(
                  caught ? pokemon.name : '???',
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
