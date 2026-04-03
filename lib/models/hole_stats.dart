class HoleStats {
  const HoleStats({
    this.onePutt = false,
    this.bunker = false,
    this.water = false,
    this.rough = false,
  });

  final bool onePutt;
  final bool bunker;
  final bool water;
  final bool rough;

  HoleStats copyWith({bool? onePutt, bool? bunker, bool? water, bool? rough}) {
    return HoleStats(
      onePutt: onePutt ?? this.onePutt,
      bunker: bunker ?? this.bunker,
      water: water ?? this.water,
      rough: rough ?? this.rough,
    );
  }
}
