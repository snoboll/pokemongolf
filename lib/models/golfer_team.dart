import 'package:flutter/material.dart';

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

Color teamColor(GolferTeam? team) => team?.color ?? npcAmber;
