import 'bogeybeast_rarity.dart';
import 'bogeybeast_type.dart';

/// Sentinel used for battle scorecards (no real Bogeybeast on each hole).
const BogeybeastSpecies battleSentinelBogeybeast = BogeybeastSpecies(
  dexNumber: 0,
  name: 'Battle',
  rarity: BogeybeastRarity.common,
  types: [],
);

class BogeybeastSpecies {
  const BogeybeastSpecies({
    required this.dexNumber,
    required this.name,
    required this.rarity,
    required this.types,
  });

  final int dexNumber;
  final String name;
  final BogeybeastRarity rarity;
  final List<BogeybeastType> types;

  String get paddedDexNumber => dexNumber.toString().padLeft(3, '0');

  String get imageUrl =>
      'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/${dexNumber.toString().padLeft(4, '0')}.png';

  bool hasAnyType(Set<BogeybeastType> typeSet) {
    for (final t in types) {
      if (typeSet.contains(t)) {
        return true;
      }
    }
    return false;
  }
}
