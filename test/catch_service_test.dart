import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_golf/models/golf_score.dart';
import 'package:pokemon_golf/models/pokemon_rarity.dart';
import 'package:pokemon_golf/services/catch_service.dart';

void main() {
  group('CatchService', () {
    final CatchService service = CatchService();

    test('common par and better is 100%', () {
      expect(
        service.catchChance(rarity: PokemonRarity.common, score: GolfScore.par),
        100,
      );
      expect(
        service.catchChance(
          rarity: PokemonRarity.common,
          score: GolfScore.birdie,
        ),
        100,
      );
      expect(
        service.catchChance(
          rarity: PokemonRarity.common,
          score: GolfScore.eagle,
        ),
        100,
      );
    });

    test('common bogey is 65%, double is 20%', () {
      expect(
        service.catchChance(
          rarity: PokemonRarity.common,
          score: GolfScore.bogey,
        ),
        65,
      );
      expect(
        service.catchChance(
          rarity: PokemonRarity.common,
          score: GolfScore.doubleBogey,
        ),
        20,
      );
    });

    test('rare par is 90%, double is 5%', () {
      expect(
        service.catchChance(rarity: PokemonRarity.rare, score: GolfScore.par),
        90,
      );
      expect(
        service.catchChance(
          rarity: PokemonRarity.rare,
          score: GolfScore.doubleBogey,
        ),
        5,
      );
    });

    test('better golf score always improves catch rate within rarity', () {
      for (final rarity in PokemonRarity.values) {
        final par = service.catchChance(
          rarity: rarity,
          score: GolfScore.par,
        );
        final bogey = service.catchChance(
          rarity: rarity,
          score: GolfScore.bogey,
        );
        expect(par, greaterThan(bogey));
      }
    });

    test('rarer Pokemon are harder to catch at the same score', () {
      final commonPar = service.catchChance(
        rarity: PokemonRarity.common,
        score: GolfScore.par,
      );
      final legendaryPar = service.catchChance(
        rarity: PokemonRarity.legendary,
        score: GolfScore.par,
      );
      expect(commonPar, greaterThan(legendaryPar));
    });

    test('uncommon par is 95%, bogey is 50%', () {
      expect(
        service.catchChance(
          rarity: PokemonRarity.uncommon,
          score: GolfScore.par,
        ),
        95,
      );
      expect(
        service.catchChance(
          rarity: PokemonRarity.uncommon,
          score: GolfScore.bogey,
        ),
        50,
      );
    });

    test('legendary eagle is 60%', () {
      expect(
        service.catchChance(
          rarity: PokemonRarity.legendary,
          score: GolfScore.eagle,
        ),
        60,
      );
    });
  });
}
