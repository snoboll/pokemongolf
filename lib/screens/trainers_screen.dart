import 'package:flutter/material.dart';

import '../app.dart';
import '../data/first_gen_pokemon.dart';
import '../services/supabase_service.dart';

class TrainersScreen extends StatefulWidget {
  const TrainersScreen({super.key});

  @override
  State<TrainersScreen> createState() => _TrainersScreenState();
}

class _TrainersScreenState extends State<TrainersScreen> {
  List<TrainerProfile>? _trainers;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTrainers();
  }

  Future<void> _loadTrainers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = SupabaseService();
      final trainers = await service.fetchAllTrainers();
      if (mounted) {
        setState(() {
          _trainers = trainers;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load trainers.';
          _loading = false;
        });
      }
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
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
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
    this.homeCourseName,
  });

  final int rank;
  final TrainerProfile trainer;
  final int total;
  final double progress;
  final String? homeCourseName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isComplete = trainer.caughtCount == total;

    return Card(
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
            Icon(
              Icons.catching_pokemon,
              color: isComplete
                  ? const Color(0xFFFFB300)
                  : theme.colorScheme.primary,
              size: 28,
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
