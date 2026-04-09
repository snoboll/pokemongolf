import '../models/pokemon_type.dart';
import 'first_gen_pokemon.dart';

const Map<PokemonType, String> _typeToTag = <PokemonType, String>{
  PokemonType.bug: 'Bug Catcher',
  PokemonType.water: 'Fisherman',
  PokemonType.rock: 'Hiker',
  PokemonType.ground: 'Hiker',
  PokemonType.fighting: 'Blackbelt',
  PokemonType.flying: 'Bird Keeper',
  PokemonType.fire: 'Burglar',
  PokemonType.poison: 'Rocket Grunt',
  PokemonType.psychic: 'Psychic',
  PokemonType.ghost: 'Channeler',
  PokemonType.grass: 'Lass',
  PokemonType.normal: 'Youngster',
  PokemonType.dragon: 'Ace Trainer',
  PokemonType.ice: 'Ace Trainer',
  PokemonType.electric: 'Engineer',
};

/// Returns the trainer class tag for a set of caught dex numbers,
/// based on the most common type across all caught Pokemon.
String? trainerTagForCaughtDex(Set<int> caughtDexNumbers) {
  if (caughtDexNumbers.isEmpty) return null;

  final Map<PokemonType, int> counts = <PokemonType, int>{};
  for (final int dex in caughtDexNumbers) {
    for (final p in firstGenPokemon) {
      if (p.dexNumber == dex) {
        for (final PokemonType type in p.types) {
          counts[type] = (counts[type] ?? 0) + 1;
        }
        break;
      }
    }
  }

  if (counts.isEmpty) return null;

  final List<MapEntry<PokemonType, int>> sorted = counts.entries.toList()
    ..sort((MapEntry<PokemonType, int> a, MapEntry<PokemonType, int> b) =>
        b.value.compareTo(a.value));

  for (final MapEntry<PokemonType, int> entry in sorted) {
    final String? tag = _typeToTag[entry.key];
    if (tag != null) return tag;
  }

  return null;
}
