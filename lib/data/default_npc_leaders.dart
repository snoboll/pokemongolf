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
  _Npc('Brock',        24, [50, 74, 95],    'assets/trainers/brock-lgpe.png'),
  _Npc('Misty',        22, [54, 120, 121],   'assets/trainers/misty-lgpe.png'),
  _Npc('Lt. Surge',    20, [100, 25, 26],    'assets/trainers/ltsurge.png'),
  _Npc('Erika',        18, [71, 114, 45],    'assets/trainers/erika-lgpe.png'),
  _Npc('Koga',         16, [109, 89, 110],   'assets/trainers/koga-lgpe.png'),
  _Npc('Sabrina',      14, [64, 122, 65],    'assets/trainers/sabrina-lgpe.png'),
  _Npc('Blaine',       12, [77, 78, 59],     'assets/trainers/blaine-lgpe.png'),
  _Npc('Giovanni',     10, [111, 31, 34],    'assets/trainers/giovanni-lgpe.png'),
  // Elite Four (HCP 8 → 5)
  _Npc('Lorelei',       8, [87, 91, 131],   'assets/trainers/lorelei-lgpe.png'),
  _Npc('Bruno',         7, [57, 68, 106],   'assets/trainers/bruno.png'),
  _Npc('Agatha',        6, [93, 94, 110],   'assets/trainers/agatha-lgpe.png'),
  _Npc('Lance',         5, [130, 142, 149], 'assets/trainers/lance-lgpe.png'),
  // Champions (HCP 4 → 0)
  _Npc('Gary',          4, [28, 65, 103],    'assets/trainers/blue-lgpe.png'),
  _Npc('Prof. Oak',     2, [128, 59, 130],   'assets/trainers/oak.png'),
  _Npc('Red',           0, [3, 9, 6],        'assets/trainers/red-lgpe.png'),
];

// Team Rocket
const List<_Npc> _teamRocket = [
  _Npc('Jessie',  15, [23, 24, 52],   'assets/trainers/teamrocket.png'),
  _Npc('James',   15, [109, 110, 52], 'assets/trainers/teamrocket.png'),
];

// Generic golfer classes (may repeat across courses)
const List<_Npc> _golfers = [
  _Npc('Chipper Joey',       34, [19, 20, 53],    'assets/trainers/youngster-gen1.png'),
  _Npc('Chipper Ben',        32, [21, 29, 30],    'assets/trainers/youngster-gen1.png'),
  _Npc('Roughrunner Rick',   36, [10, 12, 15],    'assets/trainers/bugcatcher-gen1.png'),
  _Npc('Roughrunner Doug',   35, [13, 46, 49],    'assets/trainers/bugcatcher-gen1.png'),
  _Npc('Fisherman Ralph',    30, [118, 119, 129], 'assets/trainers/fisherman-gen1.png'),
  _Npc('Fisherman Hubert',   28, [72, 99, 117],   'assets/trainers/fisherman-gen1.png'),
  _Npc('Longdriver Kiyo',    22, [56, 57, 68],    'assets/trainers/blackbelt-gen1.png'),
  _Npc('Longdriver Koichi',  24, [66, 67, 106],   'assets/trainers/blackbelt-gen1.png'),
  _Npc('Flyer Hank',         26, [16, 17, 18],    'assets/trainers/birdkeeper-gen1.png'),
  _Npc('Flyer Perry',        24, [21, 22, 85],    'assets/trainers/birdkeeper-gen1.png'),
  _Npc('Bunkerboy Marcos',   28, [74, 75, 76],    'assets/trainers/hiker-gen1.png'),
  _Npc('Bunkerboy Lenny',    30, [104, 105, 95],  'assets/trainers/hiker-gen1.png'),
  _Npc('Drawer Robin',       32, [35, 36, 39],    'assets/trainers/lass-gen1.png'),
  _Npc('Drawer Haley',       30, [37, 38, 113],   'assets/trainers/lass-gen1.png'),
  _Npc('Slicer Edmond',      26, [66, 67, 73],    'assets/trainers/sailor-gen1.png'),
  _Npc('Hotshot Stan',       28, [100, 101, 137], 'assets/trainers/gambler-gen1.png'),
  _Npc('Club Manager Taylor', 22, [81, 82, 101],  'assets/trainers/scientist-gen1.png'),
  _Npc('Psych Hope',         26, [92, 93, 94],    'assets/trainers/channeler-gen1.png'),
  _Npc('Ace Golfer Jake',    18, [134, 135, 136], 'assets/trainers/acetrainer-gen1.png'),
  _Npc('Ace Golfer Lola',    16, [131, 62, 76],   'assets/trainers/acetrainerf-gen1.png'),
  _Npc('Ace Golfer Sam',     14, [115, 123, 127], 'assets/trainers/acetrainer-gen1.png'),
  _Npc('Ace Golfer Gwen',    12, [148, 139, 91],  'assets/trainers/acetrainerf-gen1.png'),
  _Npc('Bladelover',         20, [123, 141, 28],  'assets/trainers/acetrainer-gen1.png'),
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
