import 'package:flutter/material.dart';

enum BogeybeastRarity { common, uncommon, rare, epic, legendary }

extension BogeybeastRarityX on BogeybeastRarity {
  String get label => switch (this) {
        BogeybeastRarity.common => 'Common',
        BogeybeastRarity.uncommon => 'Uncommon',
        BogeybeastRarity.rare => 'Rare',
        BogeybeastRarity.epic => 'Epic',
        BogeybeastRarity.legendary => 'Legendary',
      };

  int get encounterWeight => switch (this) {
        BogeybeastRarity.common => 41,
        BogeybeastRarity.uncommon => 28,
        BogeybeastRarity.rare => 18,
        BogeybeastRarity.epic => 8,
        BogeybeastRarity.legendary => 5,
      };

  Color get color => switch (this) {
        BogeybeastRarity.common => const Color(0xFF4CAF50),
        BogeybeastRarity.uncommon => const Color(0xFF26A69A),
        BogeybeastRarity.rare => const Color(0xFF1E88E5),
        BogeybeastRarity.epic => const Color(0xFF8E24AA),
        BogeybeastRarity.legendary => const Color(0xFFFFB300),
      };
}
