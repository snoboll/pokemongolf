import '../models/bogeybeast_type.dart';
import 'first_gen_bogeybeasts.dart';

const Map<BogeybeastType, String> _typeToTag = <BogeybeastType, String>{
  BogeybeastType.bug: 'Roughrunner',
  BogeybeastType.water: 'Fisherman',
  BogeybeastType.rock: 'Bunkerboy',
  BogeybeastType.ground: 'Bunkerboy',
  BogeybeastType.fighting: 'Longdriver',
  BogeybeastType.flying: 'Flyer',
  BogeybeastType.fire: 'Fader',
  BogeybeastType.poison: 'Hooker',
  BogeybeastType.psychic: 'Psych',
  BogeybeastType.ghost: 'Psych',
  BogeybeastType.grass: 'Drawer',
  BogeybeastType.normal: 'Chipper',
  BogeybeastType.dragon: 'Ace Golfer',
  BogeybeastType.ice: 'Ace Golfer',
  BogeybeastType.electric: 'Hotshot',
};

/// Returns the golfer class tag for a set of caught dex numbers,
/// based on the most common type across all caught Bogeybeast.
String? golferTagForCaughtDex(Set<int> caughtDexNumbers) {
  if (caughtDexNumbers.isEmpty) return null;

  final Map<BogeybeastType, int> counts = <BogeybeastType, int>{};
  for (final int dex in caughtDexNumbers) {
    for (final p in firstGenBogeybeast) {
      if (p.dexNumber == dex) {
        for (final BogeybeastType type in p.types) {
          counts[type] = (counts[type] ?? 0) + 1;
        }
        break;
      }
    }
  }

  if (counts.isEmpty) return null;

  final List<MapEntry<BogeybeastType, int>> sorted = counts.entries.toList()
    ..sort((MapEntry<BogeybeastType, int> a, MapEntry<BogeybeastType, int> b) =>
        b.value.compareTo(a.value));

  for (final MapEntry<BogeybeastType, int> entry in sorted) {
    final String? tag = _typeToTag[entry.key];
    if (tag != null) return tag;
  }

  return null;
}
