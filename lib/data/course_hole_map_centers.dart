import '../models/hole_map_center.dart';

/// Google Maps satellite-style preview: green/course context per hole.
/// [kCoursePartHoleCenters] — courses with nine-hole loops (e.g. Örestad Yellow/Red/Blue).
/// Keys: preset [GolfCourse.id], then loop name as in [CourseLoop.name].
const Map<String, Map<String, List<HoleMapCenter?>>> kCoursePartHoleCenters =
    <String, Map<String, List<HoleMapCenter?>>>{
  'orestad': <String, List<HoleMapCenter?>>{
    'Yellow': <HoleMapCenter?>[
      const HoleMapCenter(55.692796, 13.067706),
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
    ],
  },
};

/// Single 18-hole layout: index `holeNumber - 1`.
const Map<String, List<HoleMapCenter?>> kCourseHoleCenters18 =
    <String, List<HoleMapCenter?>>{};

HoleMapCenter? holeMapCenterForRoundHole({
  required String? courseId,
  required int holeNumber,
  List<String>? partSequence,
}) {
  if (courseId == null || holeNumber < 1) {
    return null;
  }

  final Map<String, List<HoleMapCenter?>>? byPart =
      kCoursePartHoleCenters[courseId];
  if (byPart != null && partSequence != null && partSequence.isNotEmpty) {
    if (partSequence.length == 1) {
      final List<HoleMapCenter?>? holes = byPart[partSequence.first];
      if (holes == null || holeNumber > holes.length) return null;
      return holes[holeNumber - 1];
    }
    if (partSequence.length >= 2) {
      if (holeNumber <= 9) {
        final List<HoleMapCenter?>? holes = byPart[partSequence[0]];
        if (holes == null || holeNumber > holes.length) return null;
        return holes[holeNumber - 1];
      }
      final List<HoleMapCenter?>? holes = byPart[partSequence[1]];
      if (holes == null) return null;
      final int local = holeNumber - 9;
      if (local < 1 || local > holes.length) return null;
      return holes[local - 1];
    }
  }

  final List<HoleMapCenter?>? list18 = kCourseHoleCenters18[courseId];
  if (list18 != null && holeNumber <= list18.length) {
    return list18[holeNumber - 1];
  }

  return null;
}
