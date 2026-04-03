import 'dart:math';

import '../data/first_gen_pokemon.dart';
import '../models/encounter_modifiers.dart';
import '../models/pokemon_rarity.dart';
import '../models/pokemon_species.dart';
import '../models/pokemon_type.dart';

class EncounterService {
  EncounterService({
    Random? random,
    List<PokemonSpecies>? catalog,
  })  : _random = random ?? Random(),
        _catalog = catalog ?? firstGenPokemon;

  final Random _random;
  final List<PokemonSpecies> _catalog;

  late final Map<PokemonRarity, List<PokemonSpecies>> _pokemonByRarity =
      <PokemonRarity, List<PokemonSpecies>>{
    for (final rarity in PokemonRarity.values)
      rarity: _catalog
          .where((pokemon) => pokemon.rarity == rarity)
          .toList(growable: false),
  };

  int get totalEncounterWeight => PokemonRarity.values.fold<int>(
        0,
        (total, rarity) => total + rarity.encounterWeight,
      );

  PokemonSpecies generateEncounter([
    EncounterModifiers modifiers = const EncounterModifiers(),
  ]) {
    final Map<PokemonRarity, int> weights = {
      for (final r in PokemonRarity.values) r: r.encounterWeight,
    };

    // Each par-or-better in the streak adds +3% legendary weight
    if (modifiers.parOrBetterStreak >= 2) {
      final int bonus = modifiers.parOrBetterStreak * 3;
      weights[PokemonRarity.legendary] =
          weights[PokemonRarity.legendary]! + bonus;
    }

    final int total = weights.values.fold<int>(0, (a, b) => a + b);
    final int roll = _random.nextInt(total);
    PokemonRarity rarity = PokemonRarity.common;
    int running = 0;
    for (final entry in weights.entries) {
      running += entry.value;
      if (roll < running) {
        rarity = entry.key;
        break;
      }
    }

    final List<PokemonSpecies> pool = _pokemonByRarity[rarity]!;

    if (!modifiers.hasTypeBoost) {
      return pool[_random.nextInt(pool.length)];
    }

    // Weight type-matched Pokemon 3x within the chosen rarity pool
    final Set<PokemonType> boosted = modifiers.boostedTypes;
    final List<_Weighted> weighted = pool.map((p) {
      final int w = p.hasAnyType(boosted) ? 3 : 1;
      return _Weighted(pokemon: p, weight: w);
    }).toList();

    final int poolTotal = weighted.fold<int>(0, (t, w) => t + w.weight);
    int poolRoll = _random.nextInt(poolTotal);
    for (final w in weighted) {
      poolRoll -= w.weight;
      if (poolRoll < 0) {
        return w.pokemon;
      }
    }

    return pool.last;
  }
}

class _Weighted {
  const _Weighted({required this.pokemon, required this.weight});
  final PokemonSpecies pokemon;
  final int weight;
}
