import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:bogeybeasts/data/first_gen_bogeybeast.dart';
import 'package:bogeybeasts/services/encounter_service.dart';

void main() {
  group('EncounterService', () {
    final EncounterService service = EncounterService(random: Random(1));

    test('totalEncounterWeight is 100', () {
      expect(service.totalEncounterWeight, 100);
    });

    test('generated encounters come from the first 151 catalog', () {
      final encounter = service.generateEncounter();
      final matchingBogeybeast = firstGenBogeybeast.where(
        (bogeybeast) => bogeybeast.dexNumber == encounter.dexNumber,
      );

      expect(matchingBogeybeast, isNotEmpty);
    });

    test('encounters are generated deterministically with same seed', () {
      final s1 = EncounterService(random: Random(42));
      final s2 = EncounterService(random: Random(42));
      for (int i = 0; i < 20; i++) {
        expect(
          s1.generateEncounter().dexNumber,
          s2.generateEncounter().dexNumber,
        );
      }
    });
  });
}
