import 'package:flutter/material.dart';

import '../app.dart';
import '../data/first_gen_pokemon.dart';
import '../models/pokemon_rarity.dart';
import '../models/pokemon_species.dart';
import '../widgets/pokemon_art.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  PokemonRarity? _selectedRarity;
  bool _caughtOnly = false;

  @override
  Widget build(BuildContext context) {
    final store = PokemonGolfScope.of(context);
    final theme = Theme.of(context);
    final List<PokemonSpecies> filteredPokemon =
        firstGenPokemon.where((pokemon) {
      if (_selectedRarity != null && pokemon.rarity != _selectedRarity) {
        return false;
      }

      if (_caughtOnly && !store.hasCaught(pokemon)) {
        return false;
      }

      return true;
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
                    'Pokedex',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${store.caughtDexNumbers.length} / ${firstGenPokemon.length}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: <Widget>[
                _FilterChipButton(
                  label: 'All',
                  selected: _selectedRarity == null && !_caughtOnly,
                  onSelected: () {
                    setState(() {
                      _selectedRarity = null;
                      _caughtOnly = false;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ...PokemonRarity.values.map(
                  (rarity) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChipButton(
                      label: rarity.label,
                      accentColor: rarity.color,
                      selected: _selectedRarity == rarity,
                      onSelected: () {
                        setState(() {
                          _selectedRarity =
                              _selectedRarity == rarity ? null : rarity;
                        });
                      },
                    ),
                  ),
                ),
                _FilterChipButton(
                  label: 'Caught',
                  selected: _caughtOnly,
                  onSelected: () {
                    setState(() {
                      _caughtOnly = !_caughtOnly;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisExtent: 200,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: filteredPokemon.length,
              itemBuilder: (BuildContext context, int index) {
                final PokemonSpecies pokemon = filteredPokemon[index];
                final bool caught = store.hasCaught(pokemon);

                return _PokedexTile(pokemon: pokemon, caught: caught);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.accentColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? (accentColor ?? theme.colorScheme.primary)
                  .withValues(alpha: 0.2)
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? (accentColor ?? theme.colorScheme.primary)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: selected
                ? (accentColor ?? theme.colorScheme.primary)
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _PokedexTile extends StatelessWidget {
  const _PokedexTile({
    required this.pokemon,
    required this.caught,
  });

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
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.3),
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
