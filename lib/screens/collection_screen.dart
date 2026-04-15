import 'package:flutter/material.dart';

import '../app.dart';
import '../state/bogeybeasts_golf_store.dart';
import '../data/first_gen_bogeybeasts.dart';
import '../models/bogeybeast_species.dart';
import '../widgets/bogeycube_badge.dart';
import '../widgets/bogeybeast_art.dart';

enum _CatchFilter { all, notCaught, caught }

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  _CatchFilter _filter = _CatchFilter.all;

  void _confirmRelease(
      BuildContext context, BogeybeastGolfStore store, BogeybeastSpecies bogeybeast) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Release ${bogeybeast.name}?'),
        content: const Text('This Bogeybeast will be removed from your Bogeydex.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Release',
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) store.releaseBogeybeast(bogeybeast);
    });
  }

  @override
  Widget build(BuildContext context) {
    final BogeybeastGolfStore store = BogeybeastGolfScope.of(context);
    final ThemeData theme = Theme.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (BuildContext context, _) {
        final List<BogeybeastSpecies> filteredBogeybeast =
            firstGenBogeybeast.where((BogeybeastSpecies bogeybeast) {
          final bool caught = store.hasCaught(bogeybeast);
          return switch (_filter) {
            _CatchFilter.all => true,
            _CatchFilter.caught => caught,
            _CatchFilter.notCaught => !caught,
          };
        }).toList(growable: false);

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Bogeydex',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${store.caughtDexNumbers.length} / ${firstGenBogeybeast.length}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: <Widget>[
                    _FilterChipButton(
                      label: 'All',
                      selected: _filter == _CatchFilter.all,
                      onSelected: () =>
                          setState(() => _filter = _CatchFilter.all),
                    ),
                    const SizedBox(width: 8),
                    _FilterChipButton(
                      label: 'Not caught',
                      selected: _filter == _CatchFilter.notCaught,
                      onSelected: () =>
                          setState(() => _filter = _CatchFilter.notCaught),
                    ),
                    const SizedBox(width: 8),
                    _FilterChipButton(
                      label: 'Caught',
                      selected: _filter == _CatchFilter.caught,
                      onSelected: () =>
                          setState(() => _filter = _CatchFilter.caught),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: filteredBogeybeast.length,
                  itemBuilder: (BuildContext context, int index) {
                    final BogeybeastSpecies bogeybeast = filteredBogeybeast[index];
                    final bool caught = store.hasCaught(bogeybeast);
                    final bool seen = store.seenDexNumbers.contains(bogeybeast.dexNumber);

                    return _BogeydexTile(
                      bogeybeast: bogeybeast,
                      caught: caught,
                      seen: seen,
                      onRelease: caught
                          ? () => _confirmRelease(context, store, bogeybeast)
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color color = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.2)
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: selected
                ? color
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _BogeydexTile extends StatelessWidget {
  const _BogeydexTile({
    required this.bogeybeast,
    required this.caught,
    required this.seen,
    this.onRelease,
  });

  final BogeybeastSpecies bogeybeast;
  final bool caught;
  final bool seen;
  final VoidCallback? onRelease;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onLongPress: onRelease,
      child: Container(
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
            Positioned(
              top: 4,
              right: 6,
              child: BogeycubeCaughtBadge(caught: caught),
            ),
            Column(
              children: <Widget>[
                const SizedBox(height: 28),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: caught
                        ? BogeybeastArt(imageUrl: bogeybeast.imageUrl, height: 100)
                        : seen
                            ? ColorFiltered(
                                colorFilter: grayscaleColorFilter(1.0),
                                child: BogeybeastArt(imageUrl: bogeybeast.imageUrl, height: 100),
                              )
                            : Center(
                                child: Icon(
                                  Icons.pets,
                                  size: 48,
                                  color: theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.3),
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
      ),
    );
  }
}
