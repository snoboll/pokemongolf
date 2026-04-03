import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_golf/data/first_gen_pokemon.dart';
import 'package:pokemon_golf/services/encounter_service.dart';

void main() {
  group('EncounterService', () {
    final EncounterService service = EncounterService(random: Random(1));

    test('totalEncounterWeight is 100', () {
      expect(service.totalEncounterWeight, 100);
    });

    test('generated encounters come from the first 151 catalog', () {
      final encounter = service.generateEncounter();
      final matchingPokemon = firstGenPokemon.where(
        (pokemon) => pokemon.dexNumber == encounter.dexNumber,
      );

      expect(matchingPokemon, isNotEmpty);
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
