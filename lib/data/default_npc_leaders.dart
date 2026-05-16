import '../models/battle_models.dart';
import '../models/course_leader.dart';

class _Npc {
  const _Npc(this.name, this.hcp, this.dex, this.sprite);
  final String name;
  final int hcp;
  final List<int> dex;
  final String sprite;
}

const String _m = 'assets/golfers/male/transparent_bg';
const String _f = 'assets/golfers/female/transparent_bg';

// Course leaders — ranked by HCP, assigned to courses in sorted order
const List<_Npc> _courseLeaderNpcs = [
  // Club Pros (HCP 24 → 10)
  _Npc('Bunkerboy Cliff', 24, [
    26,
    67,
    27,
  ], '$_m/bunkerdigger.png'), // Ground: Tristlie, Zepestance, Horchunk★
  _Npc('Fisherman Marina', 22, [
    34,
    37,
    122,
  ], '$_f/fisher.png'), // Water: Splish, Komindo, Fairwhayle★
  _Npc('Hotshot Bolt', 20, [
    52,
    53,
    64,
  ], '$_m/hotshot.png'), // Electric: Zapwedge, Greeninreg, Elektrindor★
  _Npc('Greenkeeper Lily', 18, [
    10,
    2,
    78,
  ], '$_f/greenkeeper.png'), // Grass: Roughrat, Fairwyn, Lawnshangle★
  _Npc('Slicer Vince', 16, [
    59,
    120,
    121,
  ], '$_m/slicer.png'), // Dark: Spinbite, Trigglett, Gigatilt★
  _Npc('Psych Selene', 14, [
    73,
    100,
    74,
  ], '$_f/psycher.png'), // Psychic: OBwan, Alsquare, Proveewan★
  _Npc('Flyer Ashton', 12, [
    94,
    111,
    77,
  ], '$_m/flyer.png'), // Flying: Chipin, Bogibardi, Profsoorfisk★
  _Npc('Club Manager Don', 10, [
    20,
    76,
    123,
  ], '$_m/manager.png'), // Normal: Stimpee, Peboll, Foreplayer★
  // Scratch Golfers (HCP 8 → 5)
  _Npc('Ace Golfer Freja', 8, [
    104,
    105,
    131,
  ], '$_f/ace.png'), // Ghost: Gubbchip, Bumpandran, Waggler★
  _Npc('Longdriver Titan', 7, [
    69,
    70,
    124,
  ], '$_m/longdriver.png'), // Fighting: Shankey, Socketfeil, Punnchad★
  _Npc('Psych Morrigan', 6, [
    102,
    109,
    103,
  ], '$_f/psycher.png'), // Psychic+: Jossi, Muligandalf, Suooja★
  _Npc('Ace Golfer Drake', 5, [
    85,
    86,
    87,
  ], '$_m/ace.png'), // Dragon: Rangewhelp, Yardrake, Carryhazard★
  // Tour Pros (HCP 4 → 0)
  _Npc('Ace Golfer Niko', 4, [
    62,
    98,
    63,
  ], '$_m/ace.png'), // Ice: Seet, Gripslip, Menstanado★
  _Npc('Club Manager Birch', 2, [
    89,
    58,
    80,
  ], '$_m/manager.png'), // Grass/dark: Pangdrayv, Tigerwudz, Smashfakdurr★
  _Npc('Ace Golfer Blaze', 0, [
    3,
    9,
    6,
  ], '$_m/ace.png'), // Starters: Teelord, Hookodile, Emberdie★
];

// Generic golfer classes (may repeat across courses)
const List<_Npc> _golfers = [
  _Npc('Chipper Joey', 34, [19, 20, 53], '$_m/chipper.png'), // Normal+Electric
  _Npc('Chipper Ben', 32, [
    21,
    22,
    23,
  ], '$_m/chipper.png'), // Bug: Missuno, Adidos, Titliestres
  _Npc('Roughrunner Rick', 36, [
    15,
    10,
    11,
  ], '$_m/roughrunner.png'), // Normal+Grass: Babydraw, Roughrat, Growdent
  _Npc('Roughrunner Doug', 35, [
    10,
    21,
    22,
  ], '$_m/roughrunner.png'), // Grass+Bug rough-terrain mix
  _Npc('Fisherman Ralph', 30, [
    34,
    37,
    40,
  ], '$_m/fisher.png'), // Water: Splish, Komindo, Stingler
  _Npc('Fisherman Hubert', 28, [
    7,
    34,
    99,
  ], '$_m/fisher.png'), // Water: Droptooth, Splish, Skrambell
  _Npc('Longdriver Kiyo', 22, [
    69,
    78,
    79,
  ], '$_m/longdriver.png'), // Fighting: Shankey, Lawnshangle, Spinrayt
  _Npc('Longdriver Koichi', 24, [
    91,
    70,
    79,
  ], '$_m/longdriver.png'), // Fighting: Teetaim, Socketfeil, Spinrayt
  _Npc('Flyer Hank', 26, [
    66,
    94,
    111,
  ], '$_m/flyer.png'), // Flying: Undulathon, Chipin, Bogibardi
  _Npc('Flyer Perry', 24, [
    94,
    66,
    110,
  ], '$_m/flyer.png'), // Flying: Chipin, Undulathon, Strekstrek
  _Npc('Bunkerboy Marcos', 28, [
    71,
    72,
    113,
  ], '$_m/bunkerdigger.png'), // Ground: Dumduff, Deevot, Linkskors
  _Npc('Bunkerboy Lenny', 30, [
    27,
    113,
    114,
  ], '$_m/bunkerdigger.png'), // Ground/Rock: Horchunk, Linkskors, Thindit
  _Npc('Drawer Robin', 32, [
    35,
    36,
    37,
  ], '$_m/drawer.png'), // Water: Plooms, Pinnhai, Komindo
  _Npc('Drawer Haley', 30, [
    34,
    38,
    41,
  ], '$_f/drawer.png'), // Water: Splish, Denharvi, Stungyard
  _Npc('Slicer Edmond', 26, [
    59,
    120,
    56,
  ], '$_m/slicer.png'), // Dark: Spinbite, Trigglett, Secondcat
  _Npc('Hotshot Stan', 28, [
    50,
    51,
    128,
  ], '$_m/hotshot.png'), // Elec/Fire: Hotstreek, Holeoblaze, Elepitch
  _Npc('Club Manager Taylor', 22, [
    76,
    101,
    123,
  ], '$_m/manager.png'), // Normal mix: Peboll, Doormee, Foreplayer
  _Npc('Psych Hope', 26, [
    73,
    100,
    108,
  ], '$_f/psycher.png'), // Psychic: OBwan, Alsquare, Bladagast
  _Npc('Ace Golfer Jake', 18, [
    134,
    135,
    136,
  ], '$_m/ace.png'), // Electric mix: Fittnylle, Yewlachit, Owberg
  _Npc('Ace Golfer Lola', 16, [
    62,
    45,
    63,
  ], '$_f/ace.png'), // Ice: Seet, Bogistragl, Menstanado
  _Npc('Ace Golfer Sam', 14, [
    28,
    114,
    115,
  ], '$_m/ace.png'), // Rock: Stenfan, Thindit, Fuooor
  _Npc('Ace Golfer Gwen', 12, [
    82,
    83,
    84,
  ], '$_f/ace.png'), // Ghost/Poison: Skobra, Skrixon, Skullaway
  _Npc('Slicer Blade', 20, [
    59,
    107,
    120,
  ], '$_m/slicer.png'), // Dark: Spinbite, Grinfee, Trigglett
];

final List<_Npc> _fillerPool = _golfers;

CourseLeader _npcToLeader(String courseId, _Npc npc) {
  return CourseLeader(
    courseId: courseId,
    leaderName: npc.name,
    hcp: npc.hcp,
    team: npc.dex.map(BattleBogeybeast.fromDexNumber).toList(),
    isNpc: true,
    golferSprite: npc.sprite,
  );
}

/// Builds a deterministic mapping so each course leader appears on exactly one
/// course. Remaining courses get hookers or generic golfers.
Map<String, CourseLeader> buildDefaultLeaders(List<String> courseIds) {
  final sorted = List<String>.from(courseIds)..sort();
  final result = <String, CourseLeader>{};

  // Assign course leaders 1:1 to the first N sorted courses
  for (int i = 0; i < sorted.length && i < _courseLeaderNpcs.length; i++) {
    result[sorted[i]] = _npcToLeader(sorted[i], _courseLeaderNpcs[i]);
  }

  // Fill remaining courses from the filler pool
  for (int i = _courseLeaderNpcs.length; i < sorted.length; i++) {
    final idx = (i - _courseLeaderNpcs.length) % _fillerPool.length;
    result[sorted[i]] = _npcToLeader(sorted[i], _fillerPool[idx]);
  }

  return result;
}

/// Single-course fallback when the full course list isn't available yet.
CourseLeader defaultNpcForCourse(String courseId) {
  final idx = courseId.hashCode.abs() % _fillerPool.length;
  return _npcToLeader(courseId, _fillerPool[idx]);
}
