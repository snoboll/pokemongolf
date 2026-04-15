import 'package:flutter_test/flutter_test.dart';
import 'package:bogeybeasts/models/golf_score.dart';
import 'package:bogeybeasts/models/bogeybeast_rarity.dart';
import 'package:bogeybeasts/services/catch_service.dart';

void main() {
  // Widget tests for BogeybeastGolfApp require Supabase to be initialized,
  // which needs network access. Keeping service-level unit tests here.

  group('CatchService sanity', () {
    final CatchService service = CatchService();

    test('common par is 100%', () {
      expect(
        service.catchChance(rarity: BogeybeastRarity.common, score: GolfScore.par),
        100,
      );
    });
  });
}
