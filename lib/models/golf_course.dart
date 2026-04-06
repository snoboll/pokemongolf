/// GPS point for the green (and future tee / hazard geometry).
class GreenCenter {
  const GreenCenter({required this.lat, required this.lng});

  final double lat;
  final double lng;

  ({double lat, double lng}) get asRecord => (lat: lat, lng: lng);
}

/// One hole on a course. [greenCenter] is optional for user-created courses
/// until coordinates are added; catalog entries should set it when known.
class CourseHole {
  const CourseHole({
    required this.par,
    this.greenCenter,
    this.meta,
  });

  final int par;
  final GreenCenter? greenCenter;

  /// Extra per-hole fields (yardage, tee id, map tile, etc.) without migrations.
  final Map<String, Object?>? meta;
}

/// A named nine or eighteen (e.g. Örestad Yellow). Single-loop courses use one
/// loop, often with an empty name.
class CourseLoop {
  const CourseLoop({required this.name, required this.holes});

  final String name;
  final List<CourseHole> holes;

  int get holeCount => holes.length;
}

class GolfCourse {
  const GolfCourse({
    required this.id,
    required this.name,
    required this.loops,
    this.isPreset = false,
    this.lat,
    this.lng,
  });

  final String id;
  final String name;
  final List<CourseLoop> loops;
  final bool isPreset;
  final double? lat;
  final double? lng;

  bool get hasMultipleLoops => loops.length > 1;

  bool get isSingleLoop => loops.length == 1;

  /// All holes in order (every loop concatenated).
  List<int> get flatPars =>
      loops.expand((CourseLoop l) => l.holes.map((CourseHole h) => h.par)).toList(growable: false);

  List<int> parsForLoops(List<CourseLoop> selected) => selected
      .expand((CourseLoop l) => l.holes.map((CourseHole h) => h.par))
      .toList(growable: false);

  /// Aligns with [parsForLoops] — null when that hole has no green yet.
  List<({double lat, double lng})?> greensNullableForLoops(List<CourseLoop> selected) =>
      selected
          .expand(
            (CourseLoop l) => l.holes.map(
              (CourseHole h) => h.greenCenter?.asRecord,
            ),
          )
          .toList(growable: false);

  List<({double lat, double lng})?>? get singleLoopNullableGreens {
    if (!isSingleLoop) return null;
    final List<({double lat, double lng})?> list = loops.first.holes
        .map((CourseHole h) => h.greenCenter?.asRecord)
        .toList(growable: false);
    if (list.every((({double lat, double lng})? e) => e == null)) {
      return null;
    }
    return list;
  }

  /// Built from [catalog_courses.layout] in Supabase.
  ///
  /// Preferred shape:
  /// ```json
  /// { "loops": [ { "name": "Yellow", "holes": [ { "par": 4, "green": { "lat": 0, "lng": 0 } } ] } ] }
  /// ```
  ///
  /// Legacy `pars` / `parts`+`greens` layouts are still accepted and normalized
  /// into [loops] + [CourseHole] lists.
  factory GolfCourse.fromCatalogRow({
    required String id,
    required String name,
    required Map<String, dynamic> layout,
    double? lat,
    double? lng,
  }) {
    final List<dynamic>? loopsJson = layout['loops'] as List<dynamic>?;
    if (loopsJson != null && loopsJson.isNotEmpty) {
      return GolfCourse(
        id: id,
        name: name,
        loops: loopsJson.map(_parseLoop).toList(growable: false),
        isPreset: true,
        lat: lat,
        lng: lng,
      );
    }

    final List<dynamic>? partsJson = layout['parts'] as List<dynamic>?;
    if (partsJson != null && partsJson.isNotEmpty) {
      final List<CourseLoop> loops = partsJson.map((dynamic raw) {
        final Map<String, dynamic> m = Map<String, dynamic>.from(raw as Map);
        final List<int> pars =
            (m['pars'] as List<dynamic>).map((e) => (e as num).toInt()).toList();
        final List<dynamic>? greensRaw = m['greens'] as List<dynamic>?;
        final List<CourseHole> holes = <CourseHole>[];
        for (int i = 0; i < pars.length; i++) {
          GreenCenter? gc;
          if (greensRaw != null && i < greensRaw.length) {
            final dynamic g = greensRaw[i];
            if (g != null) {
              final List<dynamic> pair = g as List<dynamic>;
              gc = GreenCenter(
                lat: (pair[0] as num).toDouble(),
                lng: (pair[1] as num).toDouble(),
              );
            }
          }
          holes.add(CourseHole(par: pars[i], greenCenter: gc));
        }
        return CourseLoop(name: m['name'] as String, holes: holes);
      }).toList();
      return GolfCourse(id: id, name: name, loops: loops, isPreset: true, lat: lat, lng: lng);
    }

    final List<dynamic>? parsJson = layout['pars'] as List<dynamic>?;
    if (parsJson == null || parsJson.isEmpty) {
      throw FormatException('Catalog course $id: layout missing pars, parts, or loops');
    }
    final List<CourseHole> holes = parsJson
        .map((dynamic e) => CourseHole(par: (e as num).toInt()))
        .toList(growable: false);
    return GolfCourse(
      id: id,
      name: name,
      loops: <CourseLoop>[CourseLoop(name: '', holes: holes)],
      isPreset: true,
      lat: lat,
      lng: lng,
    );
  }
}

CourseLoop _parseLoop(dynamic raw) {
  final Map<String, dynamic> m = Map<String, dynamic>.from(raw as Map);
  final List<dynamic> holesJson = m['holes'] as List<dynamic>;
  return CourseLoop(
    name: m['name'] as String? ?? '',
    holes: holesJson.map(_parseHole).toList(growable: false),
  );
}

CourseHole _parseHole(dynamic raw) {
  final Map<String, dynamic> m = Map<String, dynamic>.from(raw as Map);
  final int par = (m['par'] as num).toInt();
  GreenCenter? gc;
  final Object? g = m['green'];
  if (g != null) {
    final Map<String, dynamic> gm = Map<String, dynamic>.from(g as Map);
    gc = GreenCenter(
      lat: (gm['lat'] as num).toDouble(),
      lng: (gm['lng'] as num).toDouble(),
    );
  }
  Map<String, Object?>? meta;
  final Object? metaRaw = m['meta'];
  if (metaRaw is Map) {
    meta = Map<String, Object?>.from(metaRaw);
  }
  return CourseHole(par: par, greenCenter: gc, meta: meta);
}
