import 'bogeybeast_type.dart';

const Set<BogeybeastType> bunkerTypes = {
  BogeybeastType.ground,
  BogeybeastType.rock,
  BogeybeastType.fire,
};

const Set<BogeybeastType> waterTypes = {
  BogeybeastType.water,
  BogeybeastType.ice,
};

const Set<BogeybeastType> roughTypes = {
  BogeybeastType.grass,
  BogeybeastType.poison,
  BogeybeastType.bug,
};

const Set<BogeybeastType> onePuttTypes = {
  BogeybeastType.psychic,
  BogeybeastType.ghost,
  BogeybeastType.electric,
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

  Set<BogeybeastType> get boostedTypes {
    final Set<BogeybeastType> types = <BogeybeastType>{};
    if (bunker) types.addAll(bunkerTypes);
    if (water) types.addAll(waterTypes);
    if (rough) types.addAll(roughTypes);
    if (onePutt) types.addAll(onePuttTypes);
    return types;
  }

  bool get hasTypeBoost => bunker || water || rough || onePutt;
  bool get hasLegendaryBoost => streakBonus > 0;
}
