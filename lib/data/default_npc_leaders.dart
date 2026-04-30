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
const List<_Npc> _gymLeaders = [
  // Club Pros (HCP 24 → 10)
  _Npc('Bunkerboy Cliff',     24, [50, 74, 95],    '$_m/bunkerdigger.png'),
  _Npc('Fisherman Marina',    22, [54, 120, 121],   '$_f/fisher.png'),
  _Npc('Hotshot Bolt',        20, [100, 25, 26],    '$_m/hotshot.png'),
  _Npc('Greenkeeper Lily',    18, [71, 114, 45],    '$_f/greenkeeper.png'),
  _Npc('Slicer Vince',        16, [109, 89, 110],   '$_m/slicer.png'),
  _Npc('Psych Selene',        14, [64, 122, 65],    '$_f/psycher.png'),
  _Npc('Flyer Ashton',        12, [77, 78, 59],     '$_m/flyer.png'),
  _Npc('Club Manager Don',    10, [111, 31, 34],    '$_m/manager.png'),
  // Scratch Golfers (HCP 8 → 5)
  _Npc('Ace Golfer Freja',     8, [87, 91, 131],   '$_f/ace.png'),
  _Npc('Longdriver Titan',     7, [57, 68, 106],   '$_m/longdriver.png'),
  _Npc('Psych Morrigan',       6, [93, 94, 110],   '$_f/psycher.png'),
  _Npc('Ace Golfer Drake',     5, [130, 142, 149], '$_m/ace.png'),
  // Tour Pros (HCP 4 → 0)
  _Npc('Ace Golfer Niko',      4, [28, 65, 103],    '$_m/ace.png'),
  _Npc('Club Manager Birch',   2, [128, 59, 130],   '$_m/manager.png'),
  _Npc('Ace Golfer Blaze',     0, [3, 9, 6],        '$_m/ace.png'),
];

// Generic golfer classes (may repeat across courses)
const List<_Npc> _golfers = [
  _Npc('Chipper Joey',        34, [19, 20, 53],    '$_m/chipper.png'),
  _Npc('Chipper Ben',         32, [21, 29, 30],    '$_m/chipper.png'),
  _Npc('Roughrunner Rick',    36, [10, 12, 15],    '$_m/roughrunner.png'),
  _Npc('Roughrunner Doug',    35, [13, 46, 49],    '$_m/roughrunner.png'),
  _Npc('Fisherman Ralph',     30, [118, 119, 129], '$_m/fisher.png'),
  _Npc('Fisherman Hubert',    28, [72, 99, 117],   '$_m/fisher.png'),
  _Npc('Longdriver Kiyo',     22, [56, 57, 68],    '$_m/longdriver.png'),
  _Npc('Longdriver Koichi',   24, [66, 67, 106],   '$_m/longdriver.png'),
  _Npc('Flyer Hank',          26, [16, 17, 18],    '$_m/flyer.png'),
  _Npc('Flyer Perry',         24, [21, 22, 85],    '$_m/flyer.png'),
  _Npc('Bunkerboy Marcos',    28, [74, 75, 76],    '$_m/bunkerdigger.png'),
  _Npc('Bunkerboy Lenny',     30, [104, 105, 95],  '$_m/bunkerdigger.png'),
  _Npc('Drawer Robin',        32, [35, 36, 39],    '$_m/drawer.png'),
  _Npc('Drawer Haley',        30, [37, 38, 113],   '$_f/drawer.png'),
  _Npc('Slicer Edmond',       26, [66, 67, 73],    '$_m/slicer.png'),
  _Npc('Hotshot Stan',        28, [100, 101, 137], '$_m/hotshot.png'),
  _Npc('Club Manager Taylor', 22, [81, 82, 101],   '$_m/manager.png'),
  _Npc('Psych Hope',          26, [92, 93, 94],    '$_f/psycher.png'),
  _Npc('Ace Golfer Jake',     18, [134, 135, 136], '$_m/ace.png'),
  _Npc('Ace Golfer Lola',     16, [131, 62, 76],   '$_f/ace.png'),
  _Npc('Ace Golfer Sam',      14, [115, 123, 127], '$_m/ace.png'),
  _Npc('Ace Golfer Gwen',     12, [148, 139, 91],  '$_f/ace.png'),
  _Npc('Slicer Blade',        20, [123, 141, 28],  '$_m/slicer.png'),
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
