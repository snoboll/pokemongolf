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
        PokemonRarity.common => 41,
        PokemonRarity.uncommon => 28,
        PokemonRarity.rare => 18,
        PokemonRarity.epic => 8,
        PokemonRarity.legendary => 5,
      };

  Color get color => switch (this) {
        PokemonRarity.common => const Color(0xFF4CAF50),
        PokemonRarity.uncommon => const Color(0xFF26A69A),
        PokemonRarity.rare => const Color(0xFF1E88E5),
        PokemonRarity.epic => const Color(0xFF8E24AA),
        PokemonRarity.legendary => const Color(0xFFFFB300),
      };
}
