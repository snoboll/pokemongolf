enum GolfScore {
  albatross,
  eagle,
  birdie,
  par,
  bogey,
  doubleBogey,
  tripleOrWorse,
}

extension GolfScoreX on GolfScore {
  String get label => switch (this) {
        GolfScore.albatross => 'Albatross',
        GolfScore.eagle => 'Eagle',
        GolfScore.birdie => 'Birdie',
        GolfScore.par => 'Par',
        GolfScore.bogey => 'Bogey',
        GolfScore.doubleBogey => 'Double Bogey',
        GolfScore.tripleOrWorse => 'Triple Bogey+',
      };

  int get relativeToPar => switch (this) {
        GolfScore.albatross => -3,
        GolfScore.eagle => -2,
        GolfScore.birdie => -1,
        GolfScore.par => 0,
        GolfScore.bogey => 1,
        GolfScore.doubleBogey => 2,
        GolfScore.tripleOrWorse => 3,
      };

  String get shortLabel {
    final score = relativeToPar;
    if (score == 0) {
      return 'E';
    }

    return score > 0 ? '+$score' : '$score';
  }
}

String formatScoreToPar(int score) {
  if (score == 0) {
    return 'Even';
  }

  return score > 0 ? '+$score' : '$score';
}

GolfScore scoreFromStrokes(int par, int strokes) {
  final int diff = strokes - par;
  if (diff <= -3) {
    return GolfScore.albatross;
  }

  return switch (diff) {
    -2 => GolfScore.eagle,
    -1 => GolfScore.birdie,
    0 => GolfScore.par,
    1 => GolfScore.bogey,
    2 => GolfScore.doubleBogey,
    _ => GolfScore.tripleOrWorse,
  };
}
