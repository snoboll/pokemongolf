import 'dart:math';

import '../models/golf_score.dart';
import '../models/bogeybeast_rarity.dart';

const Map<BogeybeastRarity, Map<GolfScore, int>> catchRateTable =
    <BogeybeastRarity, Map<GolfScore, int>>{
  BogeybeastRarity.common: <GolfScore, int>{
    GolfScore.albatross: 100,
    GolfScore.eagle: 100,
    GolfScore.birdie: 100,
    GolfScore.par: 100,
    GolfScore.bogey: 65,
    GolfScore.doubleBogey: 20,
    GolfScore.tripleOrWorse: 5,
  },
  BogeybeastRarity.uncommon: <GolfScore, int>{
    GolfScore.albatross: 100,
    GolfScore.eagle: 100,
    GolfScore.birdie: 100,
    GolfScore.par: 95,
    GolfScore.bogey: 50,
    GolfScore.doubleBogey: 12,
    GolfScore.tripleOrWorse: 3,
  },
  BogeybeastRarity.rare: <GolfScore, int>{
    GolfScore.albatross: 100,
    GolfScore.eagle: 100,
    GolfScore.birdie: 95,
    GolfScore.par: 90,
    GolfScore.bogey: 40,
    GolfScore.doubleBogey: 5,
    GolfScore.tripleOrWorse: 2,
  },
  BogeybeastRarity.epic: <GolfScore, int>{
    GolfScore.albatross: 95,
    GolfScore.eagle: 90,
    GolfScore.birdie: 70,
    GolfScore.par: 50,
    GolfScore.bogey: 15,
    GolfScore.doubleBogey: 3,
    GolfScore.tripleOrWorse: 1,
  },
  BogeybeastRarity.legendary: <GolfScore, int>{
    GolfScore.albatross: 70,
    GolfScore.eagle: 60,
    GolfScore.birdie: 40,
    GolfScore.par: 25,
    GolfScore.bogey: 8,
    GolfScore.doubleBogey: 2,
    GolfScore.tripleOrWorse: 1,
  },
};

class CatchService {
  CatchService({Random? random}) : _random = random ?? Random();

  final Random _random;

  int catchChance({
    required BogeybeastRarity rarity,
    required GolfScore score,
  }) {
    return catchRateTable[rarity]![score]!;
  }

  bool rollCatch(int chance) {
    return _random.nextInt(100) < chance;
  }
}
