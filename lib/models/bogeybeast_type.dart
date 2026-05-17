import 'package:flutter/material.dart';

enum BogeybeastType {
  normal,
  fire,
  water,
  grass,
  electric,
  ice,
  fighting,
  poison,
  ground,
  flying,
  psychic,
  bug,
  rock,
  ghost,
  dragon,
  dark,
  fairy;

  Color get color => switch (this) {
        BogeybeastType.fire => const Color(0xFFFF6B35),
        BogeybeastType.water => const Color(0xFF4FC3F7),
        BogeybeastType.grass => const Color(0xFF66BB6A),
        BogeybeastType.electric => const Color(0xFFFFD700),
        BogeybeastType.ice => const Color(0xFF80DEEA),
        BogeybeastType.fighting => const Color(0xFFEF5350),
        BogeybeastType.poison => const Color(0xFFAB47BC),
        BogeybeastType.ground => const Color(0xFFD4A853),
        BogeybeastType.flying => const Color(0xFF90CAF9),
        BogeybeastType.psychic => const Color(0xFFF48FB1),
        BogeybeastType.bug => const Color(0xFFA5D6A7),
        BogeybeastType.rock => const Color(0xFFBCAAA4),
        BogeybeastType.ghost => const Color(0xFF9575CD),
        BogeybeastType.dragon => const Color(0xFF7986CB),
        BogeybeastType.dark => const Color(0xFF5D4037),
        BogeybeastType.fairy => const Color(0xFFF8BBD0),
        BogeybeastType.normal => const Color(0xFF9E9E9E),
      };
}
