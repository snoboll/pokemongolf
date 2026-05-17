/// Battle stats for all 151 Bogeybeast.
/// offense and defense are 1–10 scales.
/// hp is a 1–10 HP pool scale (hpMax = hp * 10).
///
/// Stats are based on rarity, evolution stage, and type character.
library;

const Map<int, ({int offense, int defense, int hp})> bogeybeastBattleStats = {
  // ── Starter lines ─────────────────────────────────────────────────────
  // Puttling → Fairwyn → Teelord (Grass → Grass/Poison)
  1:   (offense: 3,  defense: 4,  hp: 3),
  2:   (offense: 5,  defense: 5,  hp: 4),
  3:   (offense: 7,  defense: 7,  hp: 5),
  // Bogferno → Blazepar → Emberdie (Fire → Fire/Flying)
  4:   (offense: 4,  defense: 3,  hp: 3),
  5:   (offense: 6,  defense: 4,  hp: 4),
  6:   (offense: 8,  defense: 6,  hp: 5),
  // Droptooth → Bladogator → Hookodile (Water)
  7:   (offense: 3,  defense: 4,  hp: 3),
  8:   (offense: 5,  defense: 6,  hp: 4),
  9:   (offense: 7,  defense: 8,  hp: 5),

  // ── Common / Uncommon lines ───────────────────────────────────────────
  // Roughrat → Growdent (Grass)
  10:  (offense: 2,  defense: 2,  hp: 2),
  11:  (offense: 4,  defense: 4,  hp: 3),
  // Crisprdie → Chilleagle → Albafrosst (Flying/Ice)
  12:  (offense: 2,  defense: 2,  hp: 2),
  13:  (offense: 4,  defense: 3,  hp: 3),
  14:  (offense: 6,  defense: 5,  hp: 4),
  // Babydraw → Snaphook (Normal)
  15:  (offense: 2,  defense: 2,  hp: 2),
  16:  (offense: 5,  defense: 4,  hp: 3),
  // Tinyfade → Bautaslice (Normal)
  17:  (offense: 2,  defense: 2,  hp: 2),
  18:  (offense: 5,  defense: 5,  hp: 3),
  // Tappin (Normal, standalone common)
  19:  (offense: 3,  defense: 2,  hp: 2),
  // Stimpee (Normal, standalone common)
  20:  (offense: 2,  defense: 3,  hp: 2),
  // Missuno → Adidos → Titliestres (Bug → Bug/Poison)
  21:  (offense: 2,  defense: 1,  hp: 2),
  22:  (offense: 3,  defense: 3,  hp: 2),
  23:  (offense: 5,  defense: 5,  hp: 4),
  // Owtofbouns → Strekathol (Poison/Flying)
  24:  (offense: 3,  defense: 2,  hp: 2),
  25:  (offense: 5,  defense: 4,  hp: 4),
  // Tristlie → Horchunk (Ground)
  26:  (offense: 3,  defense: 5,  hp: 3),
  27:  (offense: 5,  defense: 7,  hp: 5),
  // Stenfan → Sabakloba (Rock)
  28:  (offense: 3,  defense: 6,  hp: 3),
  29:  (offense: 5,  defense: 8,  hp: 5),
  // Bongker (Ground, standalone uncommon)
  30:  (offense: 4,  defense: 5,  hp: 4),
  // Naynayron → Sevenayron → Fayvayron (Rock)
  31:  (offense: 2,  defense: 4,  hp: 2),
  32:  (offense: 4,  defense: 6,  hp: 3),
  33:  (offense: 6,  defense: 8,  hp: 5),
  // Splish → Plooms (Water → Water/Ice)
  34:  (offense: 2,  defense: 2,  hp: 2),
  35:  (offense: 6,  defense: 6,  hp: 5),
  // Pinnhai (Water/Grass, standalone uncommon)
  36:  (offense: 4,  defense: 5,  hp: 4),
  // Komindo → Denharvi (Water → Water/Electric)
  37:  (offense: 3,  defense: 3,  hp: 2),
  38:  (offense: 6,  defense: 4,  hp: 4),
  // Laypup (Fire, standalone common)
  39:  (offense: 4,  defense: 2,  hp: 2),
  // Stingler → Stungyard (Water/Poison)
  40:  (offense: 3,  defense: 3,  hp: 2),
  41:  (offense: 5,  defense: 5,  hp: 4),
  // Bugbag → Acicart → Toxicaddie (Bug/Poison)
  42:  (offense: 2,  defense: 2,  hp: 2),
  43:  (offense: 4,  defense: 4,  hp: 3),
  44:  (offense: 6,  defense: 6,  hp: 5),
  // Bogistragl → Bawrapawr (Ice)
  45:  (offense: 4,  defense: 4,  hp: 3),
  46:  (offense: 6,  defense: 7,  hp: 5),
  // Lipowlt → Lagphoot (Fire/Flying)
  47:  (offense: 3,  defense: 2,  hp: 2),
  48:  (offense: 5,  defense: 4,  hp: 4),
  // Rongclub (Electric/Ground, standalone uncommon)
  49:  (offense: 5,  defense: 5,  hp: 3),
  // Hotstreek → Holeoblaze (Electric/Fire)
  50:  (offense: 5,  defense: 3,  hp: 3),
  51:  (offense: 7,  defense: 5,  hp: 5),
  // Zapwedge → Greeninreg (Electric)
  52:  (offense: 3,  defense: 2,  hp: 2),
  53:  (offense: 5,  defense: 4,  hp: 4),
  // Skaiad → Skaimarx (Electric/Flying)
  54:  (offense: 4,  defense: 2,  hp: 2),
  55:  (offense: 6,  defense: 4,  hp: 4),
  // Secondcat → Frincheetah → Tigerwudz (Grass/Dark)
  56:  (offense: 3,  defense: 2,  hp: 2),
  57:  (offense: 5,  defense: 4,  hp: 3),
  58:  (offense: 7,  defense: 6,  hp: 5),
  // Spinbite (Dark, standalone uncommon)
  59:  (offense: 6,  defense: 3,  hp: 3),
  // Kortosne → Longorak (Dragon)
  60:  (offense: 3,  defense: 3,  hp: 3),
  61:  (offense: 6,  defense: 5,  hp: 4),
  // Seet → Menstanado (Ice → Ice/Flying)
  62:  (offense: 2,  defense: 3,  hp: 2),
  63:  (offense: 5,  defense: 5,  hp: 4),
  // Elektrindor → Voltrakman (Electric)
  64:  (offense: 3,  defense: 3,  hp: 2),
  65:  (offense: 6,  defense: 5,  hp: 4),
  // Undulathon (Flying, standalone uncommon)
  66:  (offense: 5,  defense: 4,  hp: 4),
  // Zepestance → Rovtchip (Ground → Grass/Ground)
  67:  (offense: 4,  defense: 5,  hp: 3),
  68:  (offense: 6,  defense: 7,  hp: 5),
  // Shankey → Socketfeil (Fighting/Ice)
  69:  (offense: 4,  defense: 3,  hp: 2),
  70:  (offense: 6,  defense: 5,  hp: 4),
  // Dumduff → Deevot (Ground)
  71:  (offense: 2,  defense: 3,  hp: 2),
  72:  (offense: 4,  defense: 6,  hp: 3),
  // OBwan → Proveewan → Holinwangenobi (Psychic → Psychic/Dragon)
  73:  (offense: 5,  defense: 3,  hp: 3),
  74:  (offense: 7,  defense: 5,  hp: 5),
  75:  (offense: 9,  defense: 7,  hp: 6),
  // Peboll → Profesorfisk (Water → Water/Flying)
  76:  (offense: 2,  defense: 3,  hp: 2),
  77:  (offense: 5,  defense: 4,  hp: 4),
  // Lawnshangle → Spinrayt → Smashfakdurr (Grass/Fighting)
  78:  (offense: 4,  defense: 3,  hp: 2),
  79:  (offense: 7,  defense: 5,  hp: 5),
  80:  (offense: 9,  defense: 6,  hp: 6),
  // Jinx (Psychic, standalone rare)
  81:  (offense: 7,  defense: 4,  hp: 5),
  // Skobra → Skrixon → Skullaway (Ghost/Poison)
  82:  (offense: 4,  defense: 3,  hp: 3),
  83:  (offense: 7,  defense: 5,  hp: 5),
  84:  (offense: 9,  defense: 6,  hp: 6),
  // Rangewhelp → Yardrake → Carryhazard (Dragon)
  85:  (offense: 4,  defense: 3,  hp: 3),
  86:  (offense: 7,  defense: 5,  hp: 5),
  87:  (offense: 9,  defense: 7,  hp: 6),
  // Ofdedeck → Pangdrayv → Drayvagreen (Grass/Ground → Ground/Dragon)
  88:  (offense: 2,  defense: 3,  hp: 2),
  89:  (offense: 5,  defense: 5,  hp: 4),
  90:  (offense: 8,  defense: 7,  hp: 5),
  // Teetaim → Penaltee → Teeboxer (Bug/Fighting)
  91:  (offense: 3,  defense: 2,  hp: 2),
  92:  (offense: 5,  defense: 4,  hp: 3),
  93:  (offense: 6,  defense: 5,  hp: 4),
  // Chipin → Flopshot (Flying → Flying/Rock)
  94:  (offense: 2,  defense: 2,  hp: 2),
  95:  (offense: 5,  defense: 5,  hp: 4),
  // Clarva → Denneclar (Rock/Psychic)
  96:  (offense: 4,  defense: 5,  hp: 3),
  97:  (offense: 7,  defense: 6,  hp: 5),
  // Gripslip (Ice/Normal, standalone uncommon)
  98:  (offense: 4,  defense: 5,  hp: 4),
  // Skrambell (Fire/Water, standalone rare)
  99:  (offense: 7,  defense: 6,  hp: 5),
  // Alsquare → Doormee (Psychic)
  100: (offense: 4,  defense: 4,  hp: 3),
  101: (offense: 7,  defense: 5,  hp: 5),
  // Jossi → Suooja (Psychic → Psychic/Flying)
  102: (offense: 4,  defense: 3,  hp: 3),
  103: (offense: 6,  defense: 5,  hp: 4),
  // Chipamboo → Bumpandarun → Upandawn (Ghost → Ghost/Dark)
  104: (offense: 3,  defense: 2,  hp: 2),
  105: (offense: 5,  defense: 4,  hp: 4),
  106: (offense: 8,  defense: 7,  hp: 6),
  // Grinfee (Dark/Poison, standalone common)
  107: (offense: 4,  defense: 2,  hp: 2),
  // Bladagast → Muligandalf (Psychic → Psychic/Grass)
  108: (offense: 3,  defense: 3,  hp: 2),
  109: (offense: 5,  defense: 5,  hp: 4),
  // Strekstrek → Bogibardi (Flying)
  110: (offense: 3,  defense: 2,  hp: 2),
  111: (offense: 5,  defense: 4,  hp: 4),
  // Ritebreak (Ghost/Fighting, standalone rare)
  112: (offense: 6,  defense: 5,  hp: 4),
  // Linkskors (Ground, standalone uncommon)
  113: (offense: 4,  defense: 6,  hp: 4),
  // Thindit → Fuooor (Rock)
  114: (offense: 2,  defense: 3,  hp: 2),
  115: (offense: 4,  defense: 6,  hp: 4),
  // Fringeputt → Indahowl (Fire/Psychic)
  116: (offense: 3,  defense: 3,  hp: 2),
  117: (offense: 7,  defense: 6,  hp: 5),
  // Plugfuk (Bug/Ground, standalone uncommon)
  118: (offense: 5,  defense: 4,  hp: 3),
  // Legdog (Grass/Fighting, standalone common)
  119: (offense: 4,  defense: 3,  hp: 2),
  // Trigglett → Gigatilt (Dark)
  120: (offense: 3,  defense: 2,  hp: 2),
  121: (offense: 7,  defense: 5,  hp: 5),
  // Fairwhayle (Water, standalone rare)
  122: (offense: 5,  defense: 6,  hp: 7),
  // Schneschlug (Poison, standalone uncommon)
  123: (offense: 5,  defense: 4,  hp: 4),
  // Eelonmask (Electric/Poison, standalone rare)
  124: (offense: 6,  defense: 4,  hp: 3),
  // Flatpitch → Pyrepitch / Tidepitch / Elepitch / Grovepitch (Normal → branching)
  125: (offense: 4,  defense: 4,  hp: 4),
  126: (offense: 7,  defense: 5,  hp: 5),
  127: (offense: 5,  defense: 7,  hp: 5),
  128: (offense: 6,  defense: 6,  hp: 5),
  // Grovepitch (Grass, epic)
  129: (offense: 7,  defense: 5,  hp: 5),
  // Wintergreenor (Ice/Grass, standalone rare)
  130: (offense: 6,  defense: 5,  hp: 4),
  // Waggler → Proofswing (Ghost → Ghost/Fighting)
  131: (offense: 4,  defense: 4,  hp: 4),
  132: (offense: 7,  defense: 6,  hp: 5),
  // Sandstroke (Ground, standalone rare)
  133: (offense: 6,  defense: 7,  hp: 5),
  // Fahndoh → Yewlachit (Electric)
  134: (offense: 6,  defense: 5,  hp: 5),
  135: (offense: 7,  defense: 6,  hp: 5),
  // Owberg (Psychic/Ice, epic)
  136: (offense: 8,  defense: 7,  hp: 6),
  // Roary (Dragon/Rock, epic)
  137: (offense: 8,  defense: 7,  hp: 6),
  // Shefflor (Water/Psychic, epic)
  138: (offense: 7,  defense: 7,  hp: 5),
  // Braizon (Fire/Dark, standalone rare)
  139: (offense: 8,  defense: 5,  hp: 5),
  // Hee-Oh (Fire/Bug, epic)
  140: (offense: 8,  defense: 6,  hp: 7),
  // Shee-Oh (Electric/Bug, epic)
  141: (offense: 6,  defense: 8,  hp: 7),
  // Bogeyman (Ghost, standalone rare)
  142: (offense: 7,  defense: 5,  hp: 6),
  // Saintandrose (Grass/Flying, epic)
  143: (offense: 7,  defense: 6,  hp: 5),
  // Frontanine (Dark, rare)
  144: (offense: 9,  defense: 6,  hp: 6),
  // Bakanine (Dark, epic)
  145: (offense: 8,  defense: 7,  hp: 6),

  // ── Common filler ─────────────────────────────────────────────────────
  // Touritslag (Normal, standalone rare)
  146: (offense: 5,  defense: 4,  hp: 4),

  // ── Legendaries ───────────────────────────────────────────────────────
  // Yuessowpen (Dragon/Flying)
  147: (offense: 9,  defense: 7,  hp: 7),
  // Deeowpen (Dark/Flying)
  148: (offense: 8,  defense: 8,  hp: 7),
  // Pegeaychamp (Dragon/Dark)
  149: (offense: 10, defense: 8,  hp: 7),
  // Agustamastr (Dragon/Electric)
  150: (offense: 10, defense: 7,  hp: 8),
  // Kuondor (Flying)
  151: (offense: 9,  defense: 9,  hp: 7),
};

/// hpMax for a battle Bogeybeast derived from its hp tier.
int battleHpMax(int hpTier) => hpTier * 10;
