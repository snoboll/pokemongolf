import '../models/bogeybeast_rarity.dart';
import '../models/bogeybeast_species.dart';
import '../models/bogeybeast_type.dart';

typedef _P = BogeybeastType;

const List<List<BogeybeastType>> _types = <List<BogeybeastType>>[
  [_P.grass, _P.poison],     // 1  Bulbasaur
  [_P.grass, _P.poison],     // 2  Ivysaur
  [_P.grass, _P.poison],     // 3  Venusaur
  [_P.fire],                  // 4  Charmander
  [_P.fire],                  // 5  Charmeleon
  [_P.fire, _P.flying],      // 6  Charizard
  [_P.water],                 // 7  Squirtle
  [_P.water],                 // 8  Wartortle
  [_P.water],                 // 9  Blastoise
  [_P.bug],                   // 10 Caterpie
  [_P.bug],                   // 11 Metapod
  [_P.bug, _P.flying],       // 12 Butterfree
  [_P.bug, _P.poison],       // 13 Weedle
  [_P.bug, _P.poison],       // 14 Kakuna
  [_P.bug, _P.poison],       // 15 Beedrill
  [_P.normal, _P.flying],    // 16 Pidgey
  [_P.normal, _P.flying],    // 17 Pidgeotto
  [_P.normal, _P.flying],    // 18 Pidgeot
  [_P.normal],                // 19 Rattata
  [_P.normal],                // 20 Raticate
  [_P.normal, _P.flying],    // 21 Spearow
  [_P.normal, _P.flying],    // 22 Fearow
  [_P.poison],                // 23 Ekans
  [_P.poison],                // 24 Arbok
  [_P.electric],              // 25 Pikachu
  [_P.electric],              // 26 Raichu
  [_P.ground],                // 27 Sandshrew
  [_P.ground],                // 28 Sandslash
  [_P.poison],                // 29 Nidoran F
  [_P.poison],                // 30 Nidorina
  [_P.poison, _P.ground],    // 31 Nidoqueen
  [_P.poison],                // 32 Nidoran M
  [_P.poison],                // 33 Nidorino
  [_P.poison, _P.ground],    // 34 Nidoking
  [_P.fairy],                 // 35 Clefairy
  [_P.fairy],                 // 36 Clefable
  [_P.fire],                  // 37 Vulpix
  [_P.fire],                  // 38 Ninetales
  [_P.normal, _P.fairy],     // 39 Jigglypuff
  [_P.normal, _P.fairy],     // 40 Wigglytuff
  [_P.poison, _P.flying],    // 41 Zubat
  [_P.poison, _P.flying],    // 42 Golbat
  [_P.grass, _P.poison],     // 43 Oddish
  [_P.grass, _P.poison],     // 44 Gloom
  [_P.grass, _P.poison],     // 45 Vileplume
  [_P.bug, _P.grass],        // 46 Paras
  [_P.bug, _P.grass],        // 47 Parasect
  [_P.bug, _P.poison],       // 48 Venonat
  [_P.bug, _P.poison],       // 49 Venomoth
  [_P.ground],                // 50 Diglett
  [_P.ground],                // 51 Dugtrio
  [_P.normal],                // 52 Meowth
  [_P.normal],                // 53 Persian
  [_P.water],                 // 54 Psyduck
  [_P.water],                 // 55 Golduck
  [_P.fighting],              // 56 Mankey
  [_P.fighting],              // 57 Primeape
  [_P.fire],                  // 58 Growlithe
  [_P.fire],                  // 59 Arcanine
  [_P.water],                 // 60 Poliwag
  [_P.water],                 // 61 Poliwhirl
  [_P.water, _P.fighting],   // 62 Poliwrath
  [_P.psychic],               // 63 Abra
  [_P.psychic],               // 64 Kadabra
  [_P.psychic],               // 65 Alakazam
  [_P.fighting],              // 66 Machop
  [_P.fighting],              // 67 Machoke
  [_P.fighting],              // 68 Machamp
  [_P.grass, _P.poison],     // 69 Bellsprout
  [_P.grass, _P.poison],     // 70 Weepinbell
  [_P.grass, _P.poison],     // 71 Victreebel
  [_P.water, _P.poison],     // 72 Tentacool
  [_P.water, _P.poison],     // 73 Tentacruel
  [_P.rock, _P.ground],      // 74 Geodude
  [_P.rock, _P.ground],      // 75 Graveler
  [_P.rock, _P.ground],      // 76 Golem
  [_P.fire],                  // 77 Ponyta
  [_P.fire],                  // 78 Rapidash
  [_P.water, _P.psychic],    // 79 Slowpoke
  [_P.water, _P.psychic],    // 80 Slowbro
  [_P.electric],              // 81 Magnemite
  [_P.electric],              // 82 Magneton
  [_P.normal, _P.flying],    // 83 Farfetch'd
  [_P.normal, _P.flying],    // 84 Doduo
  [_P.normal, _P.flying],    // 85 Dodrio
  [_P.water],                 // 86 Seel
  [_P.water, _P.ice],        // 87 Dewgong
  [_P.poison],                // 88 Grimer
  [_P.poison],                // 89 Muk
  [_P.water],                 // 90 Shellder
  [_P.water, _P.ice],        // 91 Cloyster
  [_P.ghost, _P.poison],     // 92 Gastly
  [_P.ghost, _P.poison],     // 93 Haunter
  [_P.ghost, _P.poison],     // 94 Gengar
  [_P.rock, _P.ground],      // 95 Onix
  [_P.psychic],               // 96 Drowzee
  [_P.psychic],               // 97 Hypno
  [_P.water],                 // 98 Krabby
  [_P.water],                 // 99 Kingler
  [_P.electric],              // 100 Voltorb
  [_P.electric],              // 101 Electrode
  [_P.grass, _P.psychic],    // 102 Exeggcute
  [_P.grass, _P.psychic],    // 103 Exeggutor
  [_P.ground],                // 104 Cubone
  [_P.ground],                // 105 Marowak
  [_P.fighting],              // 106 Hitmonlee
  [_P.fighting],              // 107 Hitmonchan
  [_P.normal],                // 108 Lickitung
  [_P.poison],                // 109 Koffing
  [_P.poison],                // 110 Weezing
  [_P.ground, _P.rock],      // 111 Rhyhorn
  [_P.ground, _P.rock],      // 112 Rhydon
  [_P.normal],                // 113 Chansey
  [_P.grass],                 // 114 Tangela
  [_P.normal],                // 115 Kangaskhan
  [_P.water],                 // 116 Horsea
  [_P.water],                 // 117 Seadra
  [_P.water],                 // 118 Goldeen
  [_P.water],                 // 119 Seaking
  [_P.water],                 // 120 Staryu
  [_P.water, _P.psychic],    // 121 Starmie
  [_P.psychic, _P.fairy],    // 122 Mr. Mime
  [_P.bug, _P.flying],       // 123 Scyther
  [_P.ice, _P.psychic],      // 124 Jynx
  [_P.electric],              // 125 Electabuzz
  [_P.fire],                  // 126 Magmar
  [_P.bug],                   // 127 Pinsir
  [_P.normal],                // 128 Tauros
  [_P.water],                 // 129 Magikarp
  [_P.water, _P.flying],     // 130 Gyarados
  [_P.water, _P.ice],        // 131 Lapras
  [_P.normal],                // 132 Ditto
  [_P.normal],                // 133 Eevee
  [_P.water],                 // 134 Vaporeon
  [_P.electric],              // 135 Jolteon
  [_P.fire],                  // 136 Flareon
  [_P.normal],                // 137 Porygon
  [_P.rock, _P.water],       // 138 Omanyte
  [_P.rock, _P.water],       // 139 Omastar
  [_P.rock, _P.water],       // 140 Kabuto
  [_P.rock, _P.water],       // 141 Kabutops
  [_P.rock, _P.flying],      // 142 Aerodactyl
  [_P.normal],                // 143 Snorlax
  [_P.ice, _P.flying],       // 144 Articuno
  [_P.electric, _P.flying],  // 145 Zapdos
  [_P.fire, _P.flying],      // 146 Moltres
  [_P.dragon],                // 147 Dratini
  [_P.dragon],                // 148 Dragonair
  [_P.dragon, _P.flying],    // 149 Dragonite
  [_P.psychic],               // 150 Mewtwo
  [_P.psychic],               // 151 Mew
];

const List<String> _bogeybeastNames = <String>[
  'Bulbasaur',
  'Ivysaur',
  'Venusaur',
  'Charmander',
  'Charmeleon',
  'Charizard',
  'Squirtle',
  'Wartortle',
  'Blastoise',
  'Caterpie',
  'Metapod',
  'Butterfree',
  'Weedle',
  'Kakuna',
  'Beedrill',
  'Pidgey',
  'Pidgeotto',
  'Pidgeot',
  'Rattata',
  'Raticate',
  'Spearow',
  'Fearow',
  'Ekans',
  'Arbok',
  'Pikachu',
  'Raichu',
  'Sandshrew',
  'Sandslash',
  'Nidoran F',
  'Nidorina',
  'Nidoqueen',
  'Nidoran M',
  'Nidorino',
  'Nidoking',
  'Clefairy',
  'Clefable',
  'Vulpix',
  'Ninetales',
  'Jigglypuff',
  'Wigglytuff',
  'Zubat',
  'Golbat',
  'Oddish',
  'Gloom',
  'Vileplume',
  'Paras',
  'Parasect',
  'Venonat',
  'Venomoth',
  'Diglett',
  'Dugtrio',
  'Meowth',
  'Persian',
  'Psyduck',
  'Golduck',
  'Mankey',
  'Primeape',
  'Growlithe',
  'Arcanine',
  'Poliwag',
  'Poliwhirl',
  'Poliwrath',
  'Abra',
  'Kadabra',
  'Alakazam',
  'Machop',
  'Machoke',
  'Machamp',
  'Bellsprout',
  'Weepinbell',
  'Victreebel',
  'Tentacool',
  'Tentacruel',
  'Geodude',
  'Graveler',
  'Golem',
  'Ponyta',
  'Rapidash',
  'Slowpoke',
  'Slowbro',
  'Magnemite',
  'Magneton',
  'Farfetchd',
  'Doduo',
  'Dodrio',
  'Seel',
  'Dewgong',
  'Grimer',
  'Muk',
  'Shellder',
  'Cloyster',
  'Gastly',
  'Haunter',
  'Gengar',
  'Onix',
  'Drowzee',
  'Hypno',
  'Krabby',
  'Kingler',
  'Voltorb',
  'Electrode',
  'Exeggcute',
  'Exeggutor',
  'Cubone',
  'Marowak',
  'Hitmonlee',
  'Hitmonchan',
  'Lickitung',
  'Koffing',
  'Weezing',
  'Rhyhorn',
  'Rhydon',
  'Chansey',
  'Tangela',
  'Kangaskhan',
  'Horsea',
  'Seadra',
  'Goldeen',
  'Seaking',
  'Staryu',
  'Starmie',
  'Mr. Mime',
  'Scyther',
  'Jynx',
  'Electabuzz',
  'Magmar',
  'Pinsir',
  'Tauros',
  'Magikarp',
  'Gyarados',
  'Lapras',
  'Ditto',
  'Eevee',
  'Vaporeon',
  'Jolteon',
  'Flareon',
  'Porygon',
  'Omanyte',
  'Omastar',
  'Kabuto',
  'Kabutops',
  'Aerodactyl',
  'Snorlax',
  'Articuno',
  'Zapdos',
  'Moltres',
  'Dratini',
  'Dragonair',
  'Dragonite',
  'Mewtwo',
  'Mew',
];

const Set<int> _legendaryDexNumbers = <int>{144, 145, 146, 150, 151};

const Set<int> _epicDexNumbers = <int>{
  6, 9, 18, 31, 34, 38, 45, 59, 65, 68, 71, 73, 76, 80, 89, 91, 94,
  103, 110, 112, 115, 121, 123, 124, 125, 126, 127, 128, 130, 131,
  134, 135, 136, 137, 139, 141, 142, 143, 149,
};

const Set<int> _rareDexNumbers = <int>{
  3, 5, 8, 12, 15, 17, 22, 24, 26, 28, 36, 40, 42, 47, 49, 51, 53,
  55, 57, 62, 64, 67, 70, 75, 78, 82, 85, 87, 93, 97, 99, 101, 105,
  107, 108, 113, 117, 119, 132, 138, 140, 147, 148,
};

const Set<int> _uncommonDexNumbers = <int>{
  1, 2, 4, 7, 25, 29, 30, 32, 33, 35, 37, 39, 54, 58, 63, 72, 77,
  79, 81, 86, 92, 95, 96, 104, 109, 111, 114, 116, 133,
};

final List<BogeybeastSpecies> firstGenBogeybeast = List<BogeybeastSpecies>.unmodifiable(
  List<BogeybeastSpecies>.generate(
    _bogeybeastNames.length,
    (int index) {
      final int dexNumber = index + 1;
      return BogeybeastSpecies(
        dexNumber: dexNumber,
        name: _bogeybeastNames[index],
        rarity: _rarityForDexNumber(dexNumber),
        types: _types[index],
      );
    },
  ),
);

BogeybeastRarity _rarityForDexNumber(int dexNumber) {
  if (_legendaryDexNumbers.contains(dexNumber)) {
    return BogeybeastRarity.legendary;
  }
  if (_epicDexNumbers.contains(dexNumber)) {
    return BogeybeastRarity.epic;
  }
  if (_rareDexNumbers.contains(dexNumber)) {
    return BogeybeastRarity.rare;
  }
  if (_uncommonDexNumbers.contains(dexNumber)) {
    return BogeybeastRarity.uncommon;
  }
  return BogeybeastRarity.common;
}
