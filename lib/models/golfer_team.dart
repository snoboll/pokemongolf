import 'package:flutter/material.dart';

import 'battle_models.dart';
import 'bogeybeast_type.dart';

enum GolferTeam {
  hazard('Team Hazard', Color(0xFFE53935), 'hazard', Icons.warning_rounded),
  socket('Team Socket', Color(0xFF1E88E5), 'socket', Icons.bolt),
  green('Team Green', Color(0xFF43A047), 'green', Icons.eco);

  const GolferTeam(this.label, this.color, this.dbValue, this.icon);

  final String label;
  final Color color;
  final String dbValue;
  final IconData icon;

  static GolferTeam? fromDb(String? value) {
    if (value == null) return null;
    for (final t in values) {
      if (t.dbValue == value) return t;
    }
    return null;
  }
}

const Color npcAmber = Color(0xFFFFD700);

Color teamColor(GolferTeam? team, {List<BattleBogeybeast>? beasts}) {
  if (team != null) return team.color;
  if (beasts != null && beasts.isNotEmpty) return _dominantTypeColor(beasts);
  return npcAmber;
}

Color _dominantTypeColor(List<BattleBogeybeast> beasts) {
  final counts = <BogeybeastType, int>{};
  for (final b in beasts) {
    for (final t in b.types) {
      counts[t] = (counts[t] ?? 0) + 1;
    }
  }
  if (counts.isEmpty) return npcAmber;
  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return sorted.first.key.color;
}
