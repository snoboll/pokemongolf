class CoursePart {
  const CoursePart({required this.name, required this.pars});

  final String name;
  final List<int> pars;

  int get holeCount => pars.length;
}

class GolfCourse {
  const GolfCourse({
    required this.id,
    required this.name,
    this.parts,
    this.pars,
    this.isPreset = false,
  });

  final String id;
  final String name;
  final List<CoursePart>? parts;
  final List<int>? pars;
  final bool isPreset;

  bool get hasParts => parts != null && parts!.isNotEmpty;

  List<int> parsForParts(List<CoursePart> selectedParts) {
    return selectedParts.expand((p) => p.pars).toList(growable: false);
  }
}
