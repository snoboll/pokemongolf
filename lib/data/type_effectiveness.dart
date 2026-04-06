/// Gen 1 type effectiveness chart.
///
/// Attack rule for dual-type attackers: use whichever of their two types
/// deals MORE damage against the defender (best of two).
///
/// Defense rule for dual-type defenders: multiply both type multipliers
/// (e.g. 2× × 2× = 4×, 2× × 0.5× = 1×).
///
/// Fairy is not in Gen 1; it is treated as neutral (1×) against everything.
library;

import '../models/pokemon_type.dart';

/// Returns 2.0, 1.0, or 0.5 for a single attacker type vs a single defender type.
double _singleMult(PokemonType atk, PokemonType def) {
  switch (atk) {
    case PokemonType.normal:
      if (def == PokemonType.rock || def == PokemonType.ghost) { return 0.5; }
    case PokemonType.fire:
      if (def == PokemonType.grass || def == PokemonType.ice || def == PokemonType.bug) { return 2.0; }
      if (def == PokemonType.fire || def == PokemonType.water || def == PokemonType.rock || def == PokemonType.dragon) { return 0.5; }
    case PokemonType.water:
      if (def == PokemonType.fire || def == PokemonType.ground || def == PokemonType.rock) { return 2.0; }
      if (def == PokemonType.water || def == PokemonType.grass || def == PokemonType.dragon) { return 0.5; }
    case PokemonType.grass:
      if (def == PokemonType.water || def == PokemonType.ground || def == PokemonType.rock) { return 2.0; }
      if (def == PokemonType.fire || def == PokemonType.grass || def == PokemonType.poison ||
          def == PokemonType.flying || def == PokemonType.bug || def == PokemonType.dragon) { return 0.5; }
    case PokemonType.electric:
      if (def == PokemonType.water || def == PokemonType.flying) { return 2.0; }
      if (def == PokemonType.electric || def == PokemonType.grass || def == PokemonType.dragon || def == PokemonType.ground) { return 0.5; }
    case PokemonType.ice:
      if (def == PokemonType.grass || def == PokemonType.ground || def == PokemonType.flying || def == PokemonType.dragon) { return 2.0; }
      if (def == PokemonType.water || def == PokemonType.ice) { return 0.5; }
    case PokemonType.fighting:
      if (def == PokemonType.normal || def == PokemonType.ice || def == PokemonType.rock) { return 2.0; }
      if (def == PokemonType.poison || def == PokemonType.bug || def == PokemonType.psychic ||
          def == PokemonType.flying || def == PokemonType.ghost) { return 0.5; }
    case PokemonType.poison:
      if (def == PokemonType.grass || def == PokemonType.bug) { return 2.0; }
      if (def == PokemonType.poison || def == PokemonType.ground || def == PokemonType.rock || def == PokemonType.ghost) { return 0.5; }
    case PokemonType.ground:
      if (def == PokemonType.fire || def == PokemonType.electric || def == PokemonType.poison || def == PokemonType.rock) { return 2.0; }
      if (def == PokemonType.grass || def == PokemonType.bug || def == PokemonType.flying) { return 0.5; }
    case PokemonType.flying:
      if (def == PokemonType.grass || def == PokemonType.fighting || def == PokemonType.bug) { return 2.0; }
      if (def == PokemonType.electric || def == PokemonType.rock) { return 0.5; }
    case PokemonType.psychic:
      if (def == PokemonType.fighting || def == PokemonType.poison) { return 2.0; }
      if (def == PokemonType.psychic || def == PokemonType.ghost) { return 0.5; }
    case PokemonType.bug:
      if (def == PokemonType.grass || def == PokemonType.poison || def == PokemonType.psychic) { return 2.0; }
      if (def == PokemonType.fire || def == PokemonType.fighting || def == PokemonType.flying || def == PokemonType.ghost) { return 0.5; }
    case PokemonType.rock:
      if (def == PokemonType.fire || def == PokemonType.ice || def == PokemonType.flying || def == PokemonType.bug) { return 2.0; }
      if (def == PokemonType.fighting || def == PokemonType.ground) { return 0.5; }
    case PokemonType.ghost:
      if (def == PokemonType.ghost || def == PokemonType.psychic) { return 2.0; }
      if (def == PokemonType.normal) { return 0.5; }
    case PokemonType.dragon:
      if (def == PokemonType.dragon) { return 2.0; }
    case PokemonType.fairy:
      break; // Gen 1: no fairy effectiveness
  }
  return 1.0;
}

/// Computes the combined type multiplier for a dual-type attacker vs a dual-type defender.
///
/// Attacker: best of its types (highest single-type multiplier against the full defender).
/// Defender: product of both type multipliers.
double typeMultiplier({
  required List<PokemonType> attackerTypes,
  required List<PokemonType> defenderTypes,
}) {
  double best = 0.0;
  for (final atkType in attackerTypes) {
    double mult = 1.0;
    for (final defType in defenderTypes) {
      mult *= _singleMult(atkType, defType);
    }
    if (mult > best) best = mult;
  }
  return best;
}

/// Human-readable label for a type multiplier value.
String typeMultLabel(double mult) {
  if (mult >= 4.0) return '4×';
  if (mult >= 2.0) return '2×';
  if (mult <= 0.25) return '¼×';
  if (mult <= 0.5) return '½×';
  return '1×';
}

/// Color hint for a type multiplier (for UI badges).
bool typeMultIsSuper(double mult) => mult >= 2.0;
bool typeMultIsResisted(double mult) => mult <= 0.5;
