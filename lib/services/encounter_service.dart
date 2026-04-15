import 'dart:math';

import '../data/first_gen_bogeybeasts.dart';
import '../models/encounter_modifiers.dart';
import '../models/bogeybeast_rarity.dart';
import '../models/bogeybeast_species.dart';
import '../models/bogeybeast_type.dart';

class EncounterService {
  EncounterService({
    Random? random,
    List<BogeybeastSpecies>? catalog,
  })  : _random = random ?? Random(),
        _catalog = catalog ?? firstGenBogeybeast;

  final Random _random;
  final List<BogeybeastSpecies> _catalog;

  late final Map<BogeybeastRarity, List<BogeybeastSpecies>> _bogeybeastByRarity =
      <BogeybeastRarity, List<BogeybeastSpecies>>{
    for (final rarity in BogeybeastRarity.values)
      rarity: _catalog
          .where((bogeybeast) => bogeybeast.rarity == rarity)
          .toList(growable: false),
  };

  int get totalEncounterWeight => BogeybeastRarity.values.fold<int>(
        0,
        (total, rarity) => total + rarity.encounterWeight,
      );

  BogeybeastSpecies generateEncounter([
    EncounterModifiers modifiers = const EncounterModifiers(),
  ]) {
    final Map<BogeybeastRarity, int> weights = {
      for (final r in BogeybeastRarity.values) r: r.encounterWeight,
    };

    // streakBonus: +3 per par, +6 per birdie, +12 per eagle. Resets on bogey.
    if (modifiers.streakBonus > 0) {
      weights[BogeybeastRarity.legendary] =
          weights[BogeybeastRarity.legendary]! + modifiers.streakBonus;
    }

    final int total = weights.values.fold<int>(0, (a, b) => a + b);
    final int roll = _random.nextInt(total);
    BogeybeastRarity rarity = BogeybeastRarity.common;
    int running = 0;
    for (final entry in weights.entries) {
      running += entry.value;
      if (roll < running) {
        rarity = entry.key;
        break;
      }
    }

    final List<BogeybeastSpecies> pool = _bogeybeastByRarity[rarity]!;

    if (!modifiers.hasTypeBoost) {
      return pool[_random.nextInt(pool.length)];
    }

    // Weight type-matched Bogeybeast 3x within the chosen rarity pool
    final Set<BogeybeastType> boosted = modifiers.boostedTypes;
    final List<_Weighted> weighted = pool.map((p) {
      final int w = p.hasAnyType(boosted) ? 3 : 1;
      return _Weighted(bogeybeast: p, weight: w);
    }).toList();

    final int poolTotal = weighted.fold<int>(0, (t, w) => t + w.weight);
    int poolRoll = _random.nextInt(poolTotal);
    for (final w in weighted) {
      poolRoll -= w.weight;
      if (poolRoll < 0) {
        return w.bogeybeast;
      }
    }

    return pool.last;
  }
}

class _Weighted {
  const _Weighted({required this.bogeybeast, required this.weight});
  final BogeybeastSpecies bogeybeast;
  final int weight;
}
