import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_golf/models/golf_score.dart';
import 'package:pokemon_golf/models/pokemon_rarity.dart';
import 'package:pokemon_golf/services/catch_service.dart';

void main() {
  // Widget tests for PokemonGolfApp require Supabase to be initialized,
  // which needs network access. Keeping service-level unit tests here.

  group('CatchService sanity', () {
    final CatchService service = CatchService();

    test('common par is 100%', () {
      expect(
        service.catchChance(rarity: PokemonRarity.common, score: GolfScore.par),
        100,
      );
    });
  });
}
