/// Gen 1 evolution chains.
/// Each entry is a list of stages; each stage is a list of dex numbers
/// (branching evolutions like Eevee have multiple dex numbers in one stage).
///
/// Single-stage Bogeybeasts are not included — callers get null and skip the section.
const Map<int, List<List<int>>> _chains = {
  // Bulbasaur line
  1: [[1], [2], [3]],
  2: [[1], [2], [3]],
  3: [[1], [2], [3]],
  // Charmander line
  4: [[4], [5], [6]],
  5: [[4], [5], [6]],
  6: [[4], [5], [6]],
  // Squirtle line
  7: [[7], [8], [9]],
  8: [[7], [8], [9]],
  9: [[7], [8], [9]],
  // Caterpie line
  10: [[10], [11], [12]],
  11: [[10], [11], [12]],
  12: [[10], [11], [12]],
  // Weedle line
  13: [[13], [14], [15]],
  14: [[13], [14], [15]],
  15: [[13], [14], [15]],
  // Pidgey line
  16: [[16], [17], [18]],
  17: [[16], [17], [18]],
  18: [[16], [17], [18]],
  // Rattata line
  19: [[19], [20]],
  20: [[19], [20]],
  // Spearow line
  21: [[21], [22]],
  22: [[21], [22]],
  // Ekans line
  23: [[23], [24]],
  24: [[23], [24]],
  // Bogeybeast #25 line
  25: [[25], [26]],
  26: [[25], [26]],
  // Sandshrew line
  27: [[27], [28]],
  28: [[27], [28]],
  // Nidoran F line
  29: [[29], [30], [31]],
  30: [[29], [30], [31]],
  31: [[29], [30], [31]],
  // Nidoran M line
  32: [[32], [33], [34]],
  33: [[32], [33], [34]],
  34: [[32], [33], [34]],
  // Clefairy line
  35: [[35], [36]],
  36: [[35], [36]],
  // Vulpix line
  37: [[37], [38]],
  38: [[37], [38]],
  // Jigglypuff line
  39: [[39], [40]],
  40: [[39], [40]],
  // Zubat line
  41: [[41], [42]],
  42: [[41], [42]],
  // Oddish line
  43: [[43], [44], [45]],
  44: [[43], [44], [45]],
  45: [[43], [44], [45]],
  // Paras line
  46: [[46], [47]],
  47: [[46], [47]],
  // Venonat line
  48: [[48], [49]],
  49: [[48], [49]],
  // Diglett line
  50: [[50], [51]],
  51: [[50], [51]],
  // Meowth line
  52: [[52], [53]],
  53: [[52], [53]],
  // Psyduck line
  54: [[54], [55]],
  55: [[54], [55]],
  // Mankey line
  56: [[56], [57]],
  57: [[56], [57]],
  // Growlithe line
  58: [[58], [59]],
  59: [[58], [59]],
  // Poliwag line
  60: [[60], [61], [62]],
  61: [[60], [61], [62]],
  62: [[60], [61], [62]],
  // Abra line
  63: [[63], [64], [65]],
  64: [[63], [64], [65]],
  65: [[63], [64], [65]],
  // Machop line
  66: [[66], [67], [68]],
  67: [[66], [67], [68]],
  68: [[66], [67], [68]],
  // Bellsprout line
  69: [[69], [70], [71]],
  70: [[69], [70], [71]],
  71: [[69], [70], [71]],
  // Tentacool line
  72: [[72], [73]],
  73: [[72], [73]],
  // Geodude line
  74: [[74], [75], [76]],
  75: [[74], [75], [76]],
  76: [[74], [75], [76]],
  // Ponyta line
  77: [[77], [78]],
  78: [[77], [78]],
  // Slowpoke line
  79: [[79], [80]],
  80: [[79], [80]],
  // Magnemite line
  81: [[81], [82]],
  82: [[81], [82]],
  // Doduo line
  84: [[84], [85]],
  85: [[84], [85]],
  // Seel line
  86: [[86], [87]],
  87: [[86], [87]],
  // Grimer line
  88: [[88], [89]],
  89: [[88], [89]],
  // Shellder line
  90: [[90], [91]],
  91: [[90], [91]],
  // Gastly line
  92: [[92], [93], [94]],
  93: [[92], [93], [94]],
  94: [[92], [93], [94]],
  // Drowzee line
  96: [[96], [97]],
  97: [[96], [97]],
  // Krabby line
  98: [[98], [99]],
  99: [[98], [99]],
  // Voltorb line
  100: [[100], [101]],
  101: [[100], [101]],
  // Exeggcute line
  102: [[102], [103]],
  103: [[102], [103]],
  // Cubone line
  104: [[104], [105]],
  105: [[104], [105]],
  // Koffing line
  109: [[109], [110]],
  110: [[109], [110]],
  // Rhyhorn line
  111: [[111], [112]],
  112: [[111], [112]],
  // Horsea line
  116: [[116], [117]],
  117: [[116], [117]],
  // Goldeen line
  118: [[118], [119]],
  119: [[118], [119]],
  // Staryu line
  120: [[120], [121]],
  121: [[120], [121]],
  // Magikarp line
  129: [[129], [130]],
  130: [[129], [130]],
  // Eevee line (branching)
  133: [[133], [134, 135, 136]],
  134: [[133], [134, 135, 136]],
  135: [[133], [134, 135, 136]],
  136: [[133], [134, 135, 136]],
  // Omanyte line
  138: [[138], [139]],
  139: [[138], [139]],
  // Kabuto line
  140: [[140], [141]],
  141: [[140], [141]],
  // Dratini line
  147: [[147], [148], [149]],
  148: [[147], [148], [149]],
  149: [[147], [148], [149]],
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
