/// Bogeybeast evolution chains.
/// Each entry is a list of stages; each stage is a list of dex numbers
/// (branching evolutions like Flatpitch have multiple dex numbers in one stage).
///
/// Single-stage Bogeybeasts are not included — callers get null and skip the section.
const Map<int, List<List<int>>> _chains = {
  // Puttling → Fairwyn → Teelord
  1: [[1], [2], [3]],
  2: [[1], [2], [3]],
  3: [[1], [2], [3]],
  // Bogferno → Blazepar → Emberdie
  4: [[4], [5], [6]],
  5: [[4], [5], [6]],
  6: [[4], [5], [6]],
  // Droptooth → Bladogator → Hookodile
  7: [[7], [8], [9]],
  8: [[7], [8], [9]],
  9: [[7], [8], [9]],
  // Roughrat → Growdent
  10: [[10], [11]],
  11: [[10], [11]],
  // Crisprdie → Chilleagle → Albafrosst
  12: [[12], [13], [14]],
  13: [[12], [13], [14]],
  14: [[12], [13], [14]],
  // Babydraw → Snaphook
  15: [[15], [16]],
  16: [[15], [16]],
  // Tinyfade → Bautaslice
  17: [[17], [18]],
  18: [[17], [18]],
  // Missuno → Adidos → Titliestres
  21: [[21], [22], [23]],
  22: [[21], [22], [23]],
  23: [[21], [22], [23]],
  // Owtofbouns → Strekathol
  24: [[24], [25]],
  25: [[24], [25]],
  // Tristlie → Horchunk
  26: [[26], [27]],
  27: [[26], [27]],
  // Stenfan → Sabakloba
  28: [[28], [29]],
  29: [[28], [29]],
  // Naynayron → Sevenayron → Fayvayron
  31: [[31], [32], [33]],
  32: [[31], [32], [33]],
  33: [[31], [32], [33]],
  // Splish → Plooms
  34: [[34], [35]],
  35: [[34], [35]],
  // Komindo → Denharvi
  37: [[37], [38]],
  38: [[37], [38]],
  // Stingler → Stungyard
  40: [[40], [41]],
  41: [[40], [41]],
  // Bugbag → Acicart → Toxicaddie
  42: [[42], [43], [44]],
  43: [[42], [43], [44]],
  44: [[42], [43], [44]],
  // Bogistragl → Bawrapawr
  45: [[45], [46]],
  46: [[45], [46]],
  // Lipowlt → Lagphoot
  47: [[47], [48]],
  48: [[47], [48]],
  // Hotstreek → Holeoblaze
  50: [[50], [51]],
  51: [[50], [51]],
  // Zapwedge → Greeninreg
  52: [[52], [53]],
  53: [[52], [53]],
  // Skaiad → Skaimarx
  54: [[54], [55]],
  55: [[54], [55]],
  // Secondcat → Frincheetah → Tigerwudz
  56: [[56], [57], [58]],
  57: [[56], [57], [58]],
  58: [[56], [57], [58]],
  // Kortosne → Longorak
  60: [[60], [61]],
  61: [[60], [61]],
  // Seet → Menstanado
  62: [[62], [63]],
  63: [[62], [63]],
  // Elektrindor → Voltrakman
  64: [[64], [65]],
  65: [[64], [65]],
  // Zepestance → Rovtchip
  67: [[67], [68]],
  68: [[67], [68]],
  // Shankey → Socketfeil
  69: [[69], [70]],
  70: [[69], [70]],
  // Dumduff → Deevot
  71: [[71], [72]],
  72: [[71], [72]],
  // OBwan → Proveewan → Holinwangenobi
  73: [[73], [74], [75]],
  74: [[73], [74], [75]],
  75: [[73], [74], [75]],
  // Peboll → Profsoorfisk
  76: [[76], [77]],
  77: [[76], [77]],
  // Lawnshangle → Spinrayt → Smashfakdurr
  78: [[78], [79], [80]],
  79: [[78], [79], [80]],
  80: [[78], [79], [80]],
  // Skobra → Skrixon → Skullaway
  82: [[82], [83], [84]],
  83: [[82], [83], [84]],
  84: [[82], [83], [84]],
  // Rangewhelp → Yardrake → Carryhazard
  85: [[85], [86], [87]],
  86: [[85], [86], [87]],
  87: [[85], [86], [87]],
  // Ofdedeck → Pangdrayv → Drayvagreen
  88: [[88], [89], [90]],
  89: [[88], [89], [90]],
  90: [[88], [89], [90]],
  // Teetaim → Penaltee → Teeboxer
  91: [[91], [92], [93]],
  92: [[91], [92], [93]],
  93: [[91], [92], [93]],
  // Chipin → Flopshot
  94: [[94], [95]],
  95: [[94], [95]],
  // Clarva → Denneclar
  96: [[96], [97]],
  97: [[96], [97]],
  // Alsquare → Doormee
  100: [[100], [101]],
  101: [[100], [101]],
  // Jossi → Suooja
  102: [[102], [103]],
  103: [[102], [103]],
  // Gubbchip → Bumpandran → Upandawn
  104: [[104], [105], [106]],
  105: [[104], [105], [106]],
  106: [[104], [105], [106]],
  // Bladagast → Muligandalf
  108: [[108], [109]],
  109: [[108], [109]],
  // Strekstrek → Bogibardi
  110: [[110], [111]],
  111: [[110], [111]],
  // Thindit → Fuooor
  114: [[114], [115]],
  115: [[114], [115]],
  // Lagpoot → Indaahowl
  116: [[116], [117]],
  117: [[116], [117]],
  // Trigglett → Gigatilt
  120: [[120], [121]],
  121: [[120], [121]],
  // Flatpitch → Pyrepitch / Tidepitch / Elepitch (branching)
  125: [[125], [126, 127, 128]],
  126: [[125], [126, 127, 128]],
  127: [[125], [126, 127, 128]],
  128: [[125], [126, 127, 128]],
  // Waggler → Proofswing
  131: [[131], [132]],
  132: [[131], [132]],
  // Fittnylle → Yewlachit
  134: [[134], [135]],
  135: [[134], [135]],
};

/// Returns the evolution chain stages for [dexNumber], or null if it has none.
List<List<int>>? evolutionChainFor(int dexNumber) => _chains[dexNumber];

/// Returns the possible next-stage dex numbers for [dexNumber],
/// or null if [dexNumber] has no chain or is already at the final stage.
List<int>? nextEvolutionTargets(int dexNumber) {
  final chain = _chains[dexNumber];
  if (chain == null) return null;
  for (int i = 0; i < chain.length - 1; i++) {
    if (chain[i].contains(dexNumber)) return chain[i + 1];
  }
  return null;
}
