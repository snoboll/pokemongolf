import '../models/battle_models.dart';
import '../models/course_leader.dart';

class _Npc {
  const _Npc(this.name, this.hcp, this.dex, this.sprite);
  final String name;
  final int hcp;
  final List<int> dex;
  final String sprite;
}

// Gym Leaders + Elite Four — each must appear on exactly one course
const List<_Npc> _gymLeaders = [
  // Gym Leaders (HCP 24 → 10)
  _Npc('Brock',        24, [50, 74, 95],    'assets/golfers/brock-lgpe.png'),
  _Npc('Misty',        22, [54, 120, 121],   'assets/golfers/misty-lgpe.png'),
  _Npc('Lt. Surge',    20, [100, 25, 26],    'assets/golfers/ltsurge.png'),
  _Npc('Erika',        18, [71, 114, 45],    'assets/golfers/erika-lgpe.png'),
  _Npc('Koga',         16, [109, 89, 110],   'assets/golfers/koga-lgpe.png'),
  _Npc('Sabrina',      14, [64, 122, 65],    'assets/golfers/sabrina-lgpe.png'),
  _Npc('Blaine',       12, [77, 78, 59],     'assets/golfers/blaine-lgpe.png'),
  _Npc('Giovanni',     10, [111, 31, 34],    'assets/golfers/giovanni-lgpe.png'),
  // Elite Four (HCP 8 → 5)
  _Npc('Lorelei',       8, [87, 91, 131],   'assets/golfers/lorelei-lgpe.png'),   // Dewgong, Cloyster, Lapras
  _Npc('Bruno',         7, [57, 68, 106],   'assets/golfers/bruno.png'),           // Primeape, Machamp, Hitmonlee
  _Npc('Agatha',        6, [93, 94, 110],   'assets/golfers/agatha-lgpe.png'),     // Haunter, Gengar, Weezing
  _Npc('Lance',         5, [130, 142, 149], 'assets/golfers/lance-lgpe.png'),      // Gyarados, Aerodactyl, Dragonite
  // Champions (HCP 4 → 0)
  _Npc('Gary',          4, [28, 65, 103],    'assets/golfers/blue-lgpe.png'),
  _Npc('Prof. Oak',     2, [128, 59, 130],   'assets/golfers/oak.png'),
  _Npc('Red',           0, [3, 9, 6],        'assets/golfers/red-lgpe.png'),
];

// Team Rocket
const List<_Npc> _teamRocket = [
  _Npc('Jessie',  15, [23, 24, 52],   'assets/golfers/teamrocket.png'),
  _Npc('James',   15, [109, 110, 52], 'assets/golfers/teamrocket.png'),
];

// Generic golfer classes (may repeat across courses)
const List<_Npc> _golfers = [
  _Npc('Youngster Joey',    34, [19, 20, 53],    'assets/golfers/youngster-gen1.png'),
  _Npc('Youngster Ben',     32, [21, 29, 30],    'assets/golfers/youngster-gen1.png'),
  _Npc('Bug Catcher Rick',  36, [10, 12, 15],    'assets/golfers/bugcatcher-gen1.png'),
  _Npc('Bug Catcher Doug',  35, [13, 46, 49],    'assets/golfers/bugcatcher-gen1.png'),
  _Npc('Fisherman Ralph',   30, [118, 119, 129], 'assets/golfers/fisherman-gen1.png'),
  _Npc('Fisherman Hubert',  28, [72, 99, 117],   'assets/golfers/fisherman-gen1.png'),
  _Npc('Blackbelt Kiyo',    22, [56, 57, 68],    'assets/golfers/blackbelt-gen1.png'),
  _Npc('Blackbelt Koichi',  24, [66, 67, 106],   'assets/golfers/blackbelt-gen1.png'),
  _Npc('Bird Keeper Hank',  26, [16, 17, 18],    'assets/golfers/birdkeeper-gen1.png'),
  _Npc('Bird Keeper Perry', 24, [21, 22, 85],    'assets/golfers/birdkeeper-gen1.png'),
  _Npc('Hiker Marcos',      28, [74, 75, 76],    'assets/golfers/hiker-gen1.png'),
  _Npc('Hiker Lenny',       30, [104, 105, 95],  'assets/golfers/hiker-gen1.png'),
  _Npc('Lass Robin',        32, [35, 36, 39],    'assets/golfers/lass-gen1.png'),
  _Npc('Lass Haley',        30, [37, 38, 113],   'assets/golfers/lass-gen1.png'),
  _Npc('Sailor Edmond',     26, [66, 67, 73],    'assets/golfers/sailor-gen1.png'),
  _Npc('Gambler Stan',      28, [100, 101, 137], 'assets/golfers/gambler-gen1.png'),
  _Npc('Scientist Taylor',  22, [81, 82, 101],   'assets/golfers/scientist-gen1.png'),
  _Npc('Channeler Hope',    26, [92, 93, 94],    'assets/golfers/channeler-gen1.png'),
  _Npc('Ace Golfer Jake',  18, [134, 135, 136], 'assets/golfers/acegolfer-gen1.png'),
  _Npc('Ace Golfer Lola',  16, [131, 62, 76],   'assets/golfers/acegolferf-gen1.png'),
  _Npc('Ace Golfer Sam',   14, [115, 123, 127], 'assets/golfers/acegolfer-gen1.png'),
  _Npc('Ace Golfer Gwen',  12, [148, 139, 91],  'assets/golfers/acegolferf-gen1.png'),
];

final List<_Npc> _fillerPool = [..._teamRocket, ..._golfers];

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

/// Builds a deterministic mapping so each gym leader appears on exactly one
/// course. Remaining courses get Team Rocket or generic golfers.
Map<String, CourseLeader> buildDefaultLeaders(List<String> courseIds) {
  final sorted = List<String>.from(courseIds)..sort();
  final result = <String, CourseLeader>{};

  // Assign gym leaders 1:1 to the first N sorted courses
  for (int i = 0; i < sorted.length && i < _gymLeaders.length; i++) {
    result[sorted[i]] = _npcToLeader(sorted[i], _gymLeaders[i]);
  }

  // Fill remaining courses from the filler pool
  for (int i = _gymLeaders.length; i < sorted.length; i++) {
    final idx = (i - _gymLeaders.length) % _fillerPool.length;
    result[sorted[i]] = _npcToLeader(sorted[i], _fillerPool[idx]);
  }

  return result;
}

/// Single-course fallback when the full course list isn't available yet.
CourseLeader defaultNpcForCourse(String courseId) {
  final idx = courseId.hashCode.abs() % _fillerPool.length;
  return _npcToLeader(courseId, _fillerPool[idx]);
}
