import 'package:flutter/material.dart';

enum PokemonRarity { common, uncommon, rare, epic, legendary }

extension PokemonRarityX on PokemonRarity {
  String get label => switch (this) {
        PokemonRarity.common => 'Common',
        PokemonRarity.uncommon => 'Uncommon',
        PokemonRarity.rare => 'Rare',
        PokemonRarity.epic => 'Epic',
        PokemonRarity.legendary => 'Legendary',
      };

  int get encounterWeight => switch (this) {
        PokemonRarity.common => 35,
        PokemonRarity.uncommon => 25,
        PokemonRarity.rare => 20,
        PokemonRarity.epic => 14,
        PokemonRarity.legendary => 6,
      };

  Color get color => switch (this) {
        PokemonRarity.common => const Color(0xFF4CAF50),
        PokemonRarity.uncommon => const Color(0xFF26A69A),
        PokemonRarity.rare => const Color(0xFF1E88E5),
        PokemonRarity.epic => const Color(0xFF8E24AA),
        PokemonRarity.legendary => const Color(0xFFFFB300),
      };
}
