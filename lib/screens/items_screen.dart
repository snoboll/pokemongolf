import 'package:flutter/material.dart';

import '../app.dart';
import '../data/evolution_chains.dart';
import '../data/first_gen_bogeybeasts.dart';
import '../models/bogeybeast_species.dart';
import '../models/item.dart';
import '../state/bogeybeasts_golf_store.dart';
import 'evolve_animation_screen.dart';

const Color _itemAccent = Color(0xFF8A9BB0);

class ItemsScreen extends StatelessWidget {
  const ItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BogeybeastGolfStore store = BogeybeastGolfScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Items')),
      body: ListenableBuilder(
        listenable: store,
        builder: (BuildContext context, _) {
          final List<ItemType> owned = ItemType.values
              .where((ItemType t) => store.itemCount(t) > 0)
              .toList();

          if (owned.isEmpty) {
            return const _EmptyItems();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: owned.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) {
              final ItemType type = owned[index];
              return _ItemTile(
                type: type,
                quantity: store.itemCount(type),
                onUse: () => _useItem(context, store, type),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _useItem(
    BuildContext context,
    BogeybeastGolfStore store,
    ItemType type,
  ) async {
    switch (type) {
      case ItemType.evoHotDog:
        await _useEvoHotDog(context, store);
    }
  }

  Future<void> _useEvoHotDog(
    BuildContext context,
    BogeybeastGolfStore store,
  ) async {
    // Build list of (species, targets) for caught beasts that can evolve.
    final List<(BogeybeastSpecies, List<int>)> evolvable =
        <(BogeybeastSpecies, List<int>)>[];
    for (final int dex in store.caughtDexNumbers) {
      final List<int>? targets = nextEvolutionTargets(dex);
      if (targets != null) {
        try {
          final BogeybeastSpecies species = firstGenBogeybeast.firstWhere(
            (BogeybeastSpecies s) => s.dexNumber == dex,
          );
          evolvable.add((species, targets));
        } catch (_) {}
      }
    }

    if (evolvable.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('None of your Bogeybeasts can evolve yet.'),
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;
    final (BogeybeastSpecies, BogeybeastSpecies)? result =
        await showModalBottomSheet<(BogeybeastSpecies, BogeybeastSpecies)>(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _EvolvePickerSheet(evolvable: evolvable),
        );

    if (result == null || !context.mounted) return;

    final (BogeybeastSpecies from, BogeybeastSpecies into) = result;

    // Push the animation; it calls onEvolve at the flash peak.
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) => EvolveAnimationScreen(
          from: from,
          into: into,
          onEvolve: () async {
            store.consumeItem(ItemType.evoHotDog);
            await store.evolveBogeybeast(from.dexNumber, into.dexNumber);
          },
        ),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }
}

class _EmptyItems extends StatelessWidget {
  const _EmptyItems();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.inventory_2_outlined,
              size: 56,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 16),
            Text(
              'No items yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Win PvP battles to earn Evo-HotDogs.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.type,
    required this.quantity,
    required this.onUse,
  });

  final ItemType type;
  final int quantity;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF243024)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _itemAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(type.icon, color: _itemAccent, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      type.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      type.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _itemAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '×$quantity',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _itemAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onUse,
            style: FilledButton.styleFrom(
              backgroundColor: _itemAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Use'),
          ),
        ],
      ),
    );
  }
}

class _EvolvePickerSheet extends StatelessWidget {
  const _EvolvePickerSheet({required this.evolvable});
  final List<(BogeybeastSpecies, List<int>)> evolvable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      maxChildSize: 0.9,
      builder: (_, ScrollController controller) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          children: <Widget>[
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Choose a Bogeybeast to evolve',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'This consumes one Evo-HotDog — choose wisely.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: evolvable.length,
                itemBuilder: (_, int i) {
                  final (BogeybeastSpecies species, List<int> targets) =
                      evolvable[i];
                  final List<BogeybeastSpecies> targetSpecies = targets
                      .map((int dex) {
                        try {
                          return firstGenBogeybeast.firstWhere(
                            (BogeybeastSpecies s) => s.dexNumber == dex,
                          );
                        } catch (_) {
                          return null;
                        }
                      })
                      .whereType<BogeybeastSpecies>()
                      .toList();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: targetSpecies.length == 1
                          ? () => Navigator.of(
                              context,
                            ).pop((species, targetSpecies.first))
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: Image.asset(
                                species.assetPath,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) =>
                                    const Icon(Icons.view_in_ar_rounded),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    species.name,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '#${species.paddedDexNumber}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: _itemAccent.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 6),
                            Row(
                              children: targetSpecies
                                  .map(
                                    (BogeybeastSpecies t) => GestureDetector(
                                      onTap: () => Navigator.of(
                                        context,
                                      ).pop((species, t)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Column(
                                          children: <Widget>[
                                            SizedBox(
                                              width: 44,
                                              height: 44,
                                              child: Image.asset(
                                                t.assetPath,
                                                fit: BoxFit.contain,
                                                errorBuilder: (_, _, _) =>
                                                    const Icon(Icons.view_in_ar_rounded),
                                              ),
                                            ),
                                            Text(
                                              t.name,
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w600,
                                                    color: _itemAccent,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
