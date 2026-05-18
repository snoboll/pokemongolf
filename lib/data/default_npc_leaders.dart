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
  // Expanded pool — more variety across the full course catalog.
  _Npc('Fisherman Cora', 27, [7, 8, 9], '$_f/fisher.png'),
  _Npc('Drawer Milo', 33, [122, 127, 76], '$_m/drawer.png'),
  _Npc('Slicer Greta', 24, [120, 121, 144], '$_f/slicer.png'),
  _Npc('Slicer Otto', 22, [59, 145, 148], '$_m/slicer.png'),
  _Npc('Hotshot Pia', 30, [4, 5, 39], '$_f/hotshot.png'),
  _Npc('Hotshot Rex', 26, [126, 116, 117], '$_m/hotshot.png'),
  _Npc('Flyer Nina', 28, [12, 13, 14], '$_f/flyer.png'),
  _Npc('Flyer Cole', 20, [54, 55, 103], '$_m/flyer.png'),
  _Npc('Bunkerboy Sven', 32, [30, 67, 133], '$_m/bunkerdigger.png'),
  _Npc('Bunkerboy Hilda', 34, [26, 27, 71], '$_f/bunkerdigger.png'),
  _Npc('Chipper Mae', 30, [17, 18, 19], '$_f/chipper.png'),
  _Npc('Chipper Wes', 28, [20, 125, 146], '$_m/chipper.png'),
  _Npc('Roughrunner Bo', 33, [10, 11, 68], '$_m/roughrunner.png'),
  _Npc('Roughrunner Tess', 31, [78, 79, 119], '$_f/roughrunner.png'),
  _Npc('Longdriver Bjorn', 23, [85, 86, 87], '$_m/longdriver.png'),
  _Npc('Longdriver Saga', 21, [60, 61, 137], '$_f/longdriver.png'),
  _Npc('Psych Iris', 27, [100, 101, 102], '$_f/psycher.png'),
  _Npc('Psych Albin', 25, [73, 74, 75], '$_m/psycher.png'),
  _Npc('Greenkeeper Tom', 29, [129, 130, 143], '$_m/greenkeeper.png'),
  _Npc('Greenkeeper Vera', 26, [2, 3, 108], '$_f/greenkeeper.png'),
  _Npc('Ace Golfer Mira', 16, [45, 46, 62], '$_f/ace.png'),
  _Npc('Ace Golfer Leo', 14, [82, 83, 84], '$_m/ace.png'),
  _Npc('Hooker Dane', 24, [24, 25, 107], '$_m/hooker.png'),
  _Npc('Hooker Elsa', 26, [42, 43, 44], '$_f/hooker.png'),
  _Npc('Club Manager Nora', 22, [98, 101, 146], '$_f/manager.png'),
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

/// Builds a deterministic mapping of NPC leaders to courses.
///
/// The first N sorted courses each get a unique ranked course-leader pro.
/// Remaining courses are mostly generic golfers, but roughly 1 in 8 gets a
/// repeated course-leader pro — so the pros recur, just more rarely.
Map<String, CourseLeader> buildDefaultLeaders(List<String> courseIds) {
  final sorted = List<String>.from(courseIds)..sort();
  final result = <String, CourseLeader>{};

  // Assign course leaders 1:1 to the first N sorted courses
  for (int i = 0; i < sorted.length && i < _courseLeaderNpcs.length; i++) {
    result[sorted[i]] = _npcToLeader(sorted[i], _courseLeaderNpcs[i]);
  }

  // Fill remaining courses: mostly filler golfers, occasionally a repeated pro.
  int fillerCount = 0;
  int proCount = 0;
  for (int i = _courseLeaderNpcs.length; i < sorted.length; i++) {
    final int rem = i - _courseLeaderNpcs.length;
    if (rem % 8 == 7) {
      result[sorted[i]] = _npcToLeader(
        sorted[i],
        _courseLeaderNpcs[proCount % _courseLeaderNpcs.length],
      );
      proCount++;
    } else {
      result[sorted[i]] =
          _npcToLeader(sorted[i], _fillerPool[fillerCount % _fillerPool.length]);
      fillerCount++;
    }
  }

  return result;
}

/// Single-course fallback when the full course list isn't available yet.
CourseLeader defaultNpcForCourse(String courseId) {
  final idx = courseId.hashCode.abs() % _fillerPool.length;
  return _npcToLeader(courseId, _fillerPool[idx]);
}
