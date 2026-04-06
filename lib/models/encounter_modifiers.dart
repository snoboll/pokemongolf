import 'pokemon_type.dart';

const Set<PokemonType> bunkerTypes = {
  PokemonType.ground,
  PokemonType.rock,
  PokemonType.fire,
};

const Set<PokemonType> waterTypes = {
  PokemonType.water,
  PokemonType.ice,
};

const Set<PokemonType> roughTypes = {
  PokemonType.grass,
  PokemonType.poison,
  PokemonType.bug,
};

const Set<PokemonType> onePuttTypes = {
  PokemonType.psychic,
  PokemonType.ghost,
  PokemonType.electric,
};

class EncounterModifiers {
  const EncounterModifiers({
    this.bunker = false,
    this.water = false,
    this.rough = false,
    this.onePutt = false,
    this.streakBonus = 0,
  });

  final bool bunker;
  final bool water;
  final bool rough;
  final bool onePutt;
  /// Accumulated streak bonus points: +3 per par, +6 per birdie, +12 per eagle.
  /// Resets to 0 on bogey or worse.
  final int streakBonus;

  Set<PokemonType> get boostedTypes {
    final Set<PokemonType> types = <PokemonType>{};
    if (bunker) types.addAll(bunkerTypes);
    if (water) types.addAll(waterTypes);
    if (rough) types.addAll(roughTypes);
    if (onePutt) types.addAll(onePuttTypes);
    return types;
  }

  bool get hasTypeBoost => bunker || water || rough || onePutt;
  bool get hasLegendaryBoost => streakBonus > 0;
}
