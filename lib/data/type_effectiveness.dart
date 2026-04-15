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

import '../models/bogeybeast_type.dart';

/// Returns 2.0, 1.0, or 0.5 for a single attacker type vs a single defender type.
double _singleMult(BogeybeastType atk, BogeybeastType def) {
  switch (atk) {
    case BogeybeastType.normal:
      if (def == BogeybeastType.rock || def == BogeybeastType.ghost) { return 0.5; }
    case BogeybeastType.fire:
      if (def == BogeybeastType.grass || def == BogeybeastType.ice || def == BogeybeastType.bug) { return 2.0; }
      if (def == BogeybeastType.fire || def == BogeybeastType.water || def == BogeybeastType.rock || def == BogeybeastType.dragon) { return 0.5; }
    case BogeybeastType.water:
      if (def == BogeybeastType.fire || def == BogeybeastType.ground || def == BogeybeastType.rock) { return 2.0; }
      if (def == BogeybeastType.water || def == BogeybeastType.grass || def == BogeybeastType.dragon) { return 0.5; }
    case BogeybeastType.grass:
      if (def == BogeybeastType.water || def == BogeybeastType.ground || def == BogeybeastType.rock) { return 2.0; }
      if (def == BogeybeastType.fire || def == BogeybeastType.grass || def == BogeybeastType.poison ||
          def == BogeybeastType.flying || def == BogeybeastType.bug || def == BogeybeastType.dragon) { return 0.5; }
    case BogeybeastType.electric:
      if (def == BogeybeastType.water || def == BogeybeastType.flying) { return 2.0; }
      if (def == BogeybeastType.electric || def == BogeybeastType.grass || def == BogeybeastType.dragon || def == BogeybeastType.ground) { return 0.5; }
    case BogeybeastType.ice:
      if (def == BogeybeastType.grass || def == BogeybeastType.ground || def == BogeybeastType.flying || def == BogeybeastType.dragon) { return 2.0; }
      if (def == BogeybeastType.water || def == BogeybeastType.ice) { return 0.5; }
    case BogeybeastType.fighting:
      if (def == BogeybeastType.normal || def == BogeybeastType.ice || def == BogeybeastType.rock) { return 2.0; }
      if (def == BogeybeastType.poison || def == BogeybeastType.bug || def == BogeybeastType.psychic ||
          def == BogeybeastType.flying || def == BogeybeastType.ghost) { return 0.5; }
    case BogeybeastType.poison:
      if (def == BogeybeastType.grass || def == BogeybeastType.bug) { return 2.0; }
      if (def == BogeybeastType.poison || def == BogeybeastType.ground || def == BogeybeastType.rock || def == BogeybeastType.ghost) { return 0.5; }
    case BogeybeastType.ground:
      if (def == BogeybeastType.fire || def == BogeybeastType.electric || def == BogeybeastType.poison || def == BogeybeastType.rock) { return 2.0; }
      if (def == BogeybeastType.grass || def == BogeybeastType.bug || def == BogeybeastType.flying) { return 0.5; }
    case BogeybeastType.flying:
      if (def == BogeybeastType.grass || def == BogeybeastType.fighting || def == BogeybeastType.bug) { return 2.0; }
      if (def == BogeybeastType.electric || def == BogeybeastType.rock) { return 0.5; }
    case BogeybeastType.psychic:
      if (def == BogeybeastType.fighting || def == BogeybeastType.poison) { return 2.0; }
      if (def == BogeybeastType.psychic || def == BogeybeastType.ghost) { return 0.5; }
    case BogeybeastType.bug:
      if (def == BogeybeastType.grass || def == BogeybeastType.poison || def == BogeybeastType.psychic) { return 2.0; }
      if (def == BogeybeastType.fire || def == BogeybeastType.fighting || def == BogeybeastType.flying || def == BogeybeastType.ghost) { return 0.5; }
    case BogeybeastType.rock:
      if (def == BogeybeastType.fire || def == BogeybeastType.ice || def == BogeybeastType.flying || def == BogeybeastType.bug) { return 2.0; }
      if (def == BogeybeastType.fighting || def == BogeybeastType.ground) { return 0.5; }
    case BogeybeastType.ghost:
      if (def == BogeybeastType.ghost || def == BogeybeastType.psychic) { return 2.0; }
      if (def == BogeybeastType.normal) { return 0.5; }
    case BogeybeastType.dragon:
      if (def == BogeybeastType.dragon) { return 2.0; }
    case BogeybeastType.fairy:
      break; // Gen 1: no fairy effectiveness
  }
  return 1.0;
}

/// Computes the combined type multiplier for a dual-type attacker vs a dual-type defender.
///
/// Attacker: best of its types (highest single-type multiplier against the full defender).
/// Defender: product of both type multipliers.
double typeMultiplier({
  required List<BogeybeastType> attackerTypes,
  required List<BogeybeastType> defenderTypes,
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
