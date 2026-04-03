import 'pokemon_rarity.dart';
import 'pokemon_type.dart';

class PokemonSpecies {
  const PokemonSpecies({
    required this.dexNumber,
    required this.name,
    required this.rarity,
    required this.types,
  });

  final int dexNumber;
  final String name;
  final PokemonRarity rarity;
  final List<PokemonType> types;

  String get paddedDexNumber => dexNumber.toString().padLeft(3, '0');

  String get imageUrl =>
      'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/$paddedDexNumber.png';

  bool hasAnyType(Set<PokemonType> typeSet) {
    for (final t in types) {
      if (typeSet.contains(t)) {
        return true;
      }
    }
    return false;
  }
}
