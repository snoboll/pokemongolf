import '../models/bogeybeast_rarity.dart';
import '../models/bogeybeast_species.dart';
import '../models/bogeybeast_type.dart';

typedef _P = BogeybeastType;

const List<List<BogeybeastType>> _types = <List<BogeybeastType>>[
  [_P.grass],                 // 1   Puttling
  [_P.grass],                 // 2   Fairwyn
  [_P.grass, _P.poison],     // 3   Teelord
  [_P.fire],                  // 4   Bogferno
  [_P.fire],                  // 5   Parablaze
  [_P.fire, _P.flying],      // 6   Emberdie
  [_P.water],                 // 7   Droptooth
  [_P.water],                 // 8   Bladogator
  [_P.water],                 // 9   Hookodile
  [_P.grass],                 // 10  Roughrat
  [_P.grass],                 // 11  Growdent
  [_P.flying, _P.ice],       // 12  Crisprdi
  [_P.flying, _P.ice],       // 13  Chilleagle
  [_P.flying, _P.ice],       // 14  Albafrosst
  [_P.normal],                // 15  Babydraw
  [_P.normal],                // 16  Snaphook
  [_P.normal],                // 17  Tinyfade
  [_P.normal],                // 18  Bautaslice
  [_P.normal],                // 19  Tappin
  [_P.normal],                // 20  Stimpee
  [_P.bug],                   // 21  Missuno
  [_P.bug],                   // 22  Adidos
  [_P.bug, _P.poison],       // 23  Titliestres
  [_P.poison, _P.flying],    // 24  Owtofbouns
  [_P.poison, _P.flying],    // 25  Strekathol
  [_P.ground],                // 26  Tristlie
  [_P.ground],                // 27  Horchunk
  [_P.rock],                  // 28  Stenfan
  [_P.rock],                  // 29  Sabakloba
  [_P.ground],                // 30  Bongker
  [_P.rock],                  // 31  Naynayron
  [_P.rock],                  // 32  Sevenayron
  [_P.rock],                  // 33  Fayvayron
  [_P.water],                 // 34  Splish
  [_P.water, _P.ice],        // 35  Plooms
  [_P.water, _P.grass],      // 36  Pinnhai
  [_P.water],                 // 37  Komindo
  [_P.water, _P.electric],   // 38  Denharvi
  [_P.fire],                  // 39  Laypup
  [_P.water, _P.poison],     // 40  Stingler
  [_P.water, _P.poison],     // 41  Stungyard
  [_P.bug, _P.poison],       // 42  Bugbag
  [_P.bug, _P.poison],       // 43  Acicart
  [_P.bug, _P.poison],       // 44  Toxicaddie
  [_P.ice],                   // 45  Bogistragl
  [_P.ice],                   // 46  Bawrapawr
  [_P.fire, _P.flying],      // 47  Lipowlt
  [_P.fire, _P.flying],      // 48  Lagphoot
  [_P.electric, _P.ground],  // 49  Rongclub
  [_P.electric, _P.fire],    // 50  Hotstreek
  [_P.electric, _P.fire],    // 51  Holeoblaze
  [_P.electric],              // 52  Zapwedge
  [_P.electric],              // 53  Greeninreg
  [_P.electric, _P.flying],  // 54  Skaiad
  [_P.electric, _P.flying],  // 55  Skaimarx
  [_P.grass, _P.dark],       // 56  Secondcat
  [_P.grass, _P.dark],       // 57  Frincheetah
  [_P.grass, _P.dark],       // 58  Tigerwudz
  [_P.dark],                  // 59  Spinbite
  [_P.dragon],                // 60  Kortosne
  [_P.dragon],                // 61  Longorak
  [_P.ice],                   // 62  Seet
  [_P.ice, _P.flying],       // 63  Menstanado
  [_P.electric],              // 64  Elektrindor
  [_P.electric],              // 65  Voltrakman
  [_P.flying],                // 66  Undulathon
  [_P.ground],                // 67  Zepestance
  [_P.grass, _P.ground],     // 68  Rovtchip
  [_P.fighting, _P.ice],     // 69  Shankey
  [_P.fighting, _P.ice],     // 70  Socketfeil
  [_P.ground],                // 71  Dumduff
  [_P.ground],                // 72  Deevot
  [_P.psychic],               // 73  OBwan
  [_P.psychic],               // 74  Proveewan
  [_P.psychic, _P.dragon],   // 75  Holinwangenobi
  [_P.water],                 // 76  Peboll
  [_P.water],                 // 77  Profesorfisk
  [_P.grass, _P.fighting],   // 78  Lawnshangle
  [_P.grass, _P.fighting],   // 79  Spinrayt
  [_P.grass, _P.fighting],   // 80  Smashfakdurr
  [_P.psychic],               // 81  Jinx
  [_P.ghost, _P.poison],     // 82  Skobra
  [_P.ghost, _P.poison],     // 83  Skrixon
  [_P.ghost, _P.poison],     // 84  Skullaway
  [_P.dragon],                // 85  Rangewhelp
  [_P.dragon],                // 86  Yardrake
  [_P.dragon],                // 87  Carryhazard
  [_P.grass, _P.ground],     // 88  Ofdedeck
  [_P.grass, _P.ground],     // 89  Pangdrayv
  [_P.ground, _P.dragon],    // 90  Drayvagreen
  [_P.bug, _P.fighting],     // 91  Teetaim
  [_P.bug, _P.fighting],     // 92  Penaltee
  [_P.bug, _P.fighting],     // 93  Teeboxer
  [_P.flying],                // 94  Chipin
  [_P.flying, _P.rock],      // 95  Flopshot
  [_P.rock, _P.psychic],     // 96  Clarva
  [_P.rock, _P.psychic],     // 97  Denneclar
  [_P.ice, _P.normal],       // 98  Gripslip
  [_P.fire, _P.water],       // 99  Skrambell
  [_P.psychic],               // 100 Alsquare
  [_P.psychic],               // 101 Doormee
  [_P.psychic],               // 102 Jossi
  [_P.psychic, _P.flying],   // 103 Suooja
  [_P.ghost],                 // 104 Chipamboo
  [_P.ghost],                 // 105 Bumpandarun
  [_P.ghost, _P.dark],       // 106 Upandawn
  [_P.dark, _P.poison],      // 107 Grinfee
  [_P.psychic, _P.grass],    // 108 Bladagast
  [_P.psychic, _P.grass],    // 109 Mulligandalf
  [_P.flying],                // 110 Strekstrek
  [_P.flying],                // 111 Bogibardi
  [_P.ghost, _P.fighting],   // 112 Ritebreak
  [_P.ground],                // 113 Linkskors
  [_P.rock],                  // 114 Thindit
  [_P.rock],                  // 115 Fuooor
  [_P.fire, _P.psychic],     // 116 Fringeputt
  [_P.fire, _P.psychic],     // 117 Indahowl
  [_P.bug, _P.ground],       // 118 Plugfuk
  [_P.grass, _P.fighting],   // 119 Legdog
  [_P.dark],                  // 120 Trigglett
  [_P.dark],                  // 121 Gigatilt
  [_P.water],                 // 122 Fairwhayle
  [_P.poison],                // 123 Schneschlug
  [_P.electric, _P.poison],  // 124 Eelonmask
  [_P.normal],                // 125 Flatpitch
  [_P.fire],                  // 126 Pyrepitch
  [_P.water],                 // 127 Tidepitch
  [_P.electric],              // 128 Elepitch
  [_P.grass],                 // 129 Grovepitch
  [_P.ice, _P.grass],        // 130 Wintergreenor
  [_P.ghost],                 // 131 Waggler
  [_P.ghost, _P.fighting],   // 132 Proofswing
  [_P.ground],                // 133 Sandstroke
  [_P.electric],              // 134 Fahndoh
  [_P.electric],              // 135 Yewlachit
  [_P.psychic, _P.ice],      // 136 Owberg
  [_P.dragon, _P.rock],      // 137 Roary
  [_P.water, _P.psychic],    // 138 Shefflor
  [_P.fire, _P.dark],        // 139 Braizon
  [_P.fire, _P.bug],         // 140 Hee-Oh
  [_P.electric, _P.bug],     // 141 Shee-Oh
  [_P.ghost],                 // 142 Bogeyman
  [_P.grass, _P.flying],     // 143 Saintandrose
  [_P.dark],                  // 144 Frontanine
  [_P.dark],                  // 145 Bakanine
  [_P.normal],                // 146 Touritslag
  [_P.dragon, _P.flying],    // 147 Yuessowpen
  [_P.dark, _P.flying],      // 148 Deeowpen
  [_P.dragon, _P.dark],      // 149 Pegeaychamp
  [_P.dragon, _P.electric],  // 150 Agustamastr
  [_P.flying],                // 151 Kuondor
];

const List<String> _bogeybeastNames = <String>[
  'Puttling',       // 1
  'Fairwyn',        // 2
  'Teelord',        // 3
  'Bogferno',       // 4
  'Parablaze',      // 5
  'Emberdie',       // 6
  'Droptooth',      // 7
  'Bladogator',     // 8
  'Hookodile',      // 9
  'Roughrat',       // 10
  'Growdent',       // 11
  'Crisprdi',       // 12
  'Chilleagle',     // 13
  'Albafrosst',     // 14
  'Babydraw',       // 15
  'Snaphook',       // 16
  'Tinyfade',       // 17
  'Bautaslice',     // 18
  'Tappin',         // 19
  'Stimpee',        // 20
  'Missuno',        // 21
  'Adidos',         // 22
  'Titliestres',    // 23
  'Owtofbouns',     // 24
  'Strekathol',     // 25
  'Tristlie',       // 26
  'Horchunk',       // 27
  'Stenfan',        // 28
  'Sabakloba',      // 29
  'Bongker',        // 30
  'Naynayron',      // 31
  'Sevenayron',     // 32
  'Fayvayron',      // 33
  'Splish',         // 34
  'Plooms',         // 35
  'Pinnhai',        // 36
  'Komindo',        // 37
  'Denharvi',       // 38
  'Laypup',         // 39
  'Stingler',       // 40
  'Stungyard',      // 41
  'Bugbag',         // 42
  'Acicart',        // 43
  'Toxicaddie',     // 44
  'Bogistragl',     // 45
  'Bawrapawr',      // 46
  'Lipowlt',        // 47
  'Lagphoot',       // 48
  'Rongclub',       // 49
  'Hotstreek',      // 50
  'Holeoblaze',     // 51
  'Zapwedge',       // 52
  'Greeninreg',     // 53
  'Skaiad',         // 54
  'Skaimarx',       // 55
  'Secondcat',      // 56
  'Frincheetah',    // 57
  'Tigerwudz',      // 58
  'Spinbite',       // 59
  'Kortosne',       // 60
  'Longorak',       // 61
  'Seet',           // 62
  'Menstanado',     // 63
  'Elektrindor',    // 64
  'Voltrakman',     // 65
  'Undulathon',     // 66
  'Zepestance',     // 67
  'Rovtchip',       // 68
  'Shankey',        // 69
  'Socketfeil',     // 70
  'Dumduff',        // 71
  'Deevot',         // 72
  'OBwan',          // 73
  'Proveewan',      // 74
  'Holinwangenobi', // 75
  'Peboll',         // 76
  'Profesorfisk',   // 77
  'Lawnshangle',    // 78
  'Spinrayt',       // 79
  'Smashfakdurr',   // 80
  'Jinx',           // 81
  'Skobra',         // 82
  'Skrixon',        // 83
  'Skullaway',      // 84
  'Rangewhelp',     // 85
  'Yardrake',       // 86
  'Carryhazard',    // 87
  'Ofdedeck',       // 88
  'Pangdrayv',      // 89
  'Drayvagreen',    // 90
  'Teetaim',        // 91
  'Penaltee',       // 92
  'Teeboxer',       // 93
  'Chipin',         // 94
  'Flopshot',       // 95
  'Clarva',         // 96
  'Denneclar',      // 97
  'Gripslip',       // 98
  'Skrambell',      // 99
  'Alsquare',       // 100
  'Doormee',        // 101
  'Jossi',          // 102
  'Suooja',         // 103
  'Chipamboo',      // 104
  'Bumpandarun',    // 105
  'Upandawn',       // 106
  'Grinfee',        // 107
  'Bladagast',      // 108
  'Mulligandalf',   // 109
  'Strekstrek',     // 110
  'Bogibardi',      // 111
  'Ritebreak',      // 112
  'Linkskors',      // 113
  'Thindit',        // 114
  'Fuooor',         // 115
  'Fringeputt',     // 116
  'Indahowl',       // 117
  'Plugfuk',        // 118
  'Legdog',         // 119
  'Trigglett',      // 120
  'Gigatilt',       // 121
  'Fairwhayle',     // 122
  'Schneschlug',    // 123
  'Eelonmask',      // 124
  'Flatpitch',      // 125
  'Pyrepitch',      // 126
  'Tidepitch',      // 127
  'Elepitch',       // 128
  'Grovepitch',     // 129
  'Wintergreenor',  // 130
  'Waggler',        // 131
  'Proofswing',     // 132
  'Sandstroke',     // 133
  'Fahndoh',        // 134
  'Yewlachit',      // 135
  'Owberg',         // 136
  'Roary',          // 137
  'Shefflor',       // 138
  'Braizon',        // 139
  'Hee-Oh',         // 140
  'Shee-Oh',        // 141
  'Bogeyman',       // 142
  'Saintandrose',   // 143
  'Frontanine',     // 144
  'Bakanine',       // 145
  'Touritslag',     // 146
  'Yuessowpen',     // 147
  'Deeowpen',       // 148
  'Pegeaychamp',    // 149
  'Agustamastr',    // 150
  'Kuondor',        // 151
];

const Set<int> _legendaryDexNumbers = <int>{147, 148, 149, 150, 151};

const Set<int> _epicDexNumbers = <int>{
  3, 6, 9, 14, 75, 80, 84, 87, 90, 106, 126, 127, 128, 129,
  136, 137, 138, 139, 140, 141, 143, 145,
};

const Set<int> _rareDexNumbers = <int>{
  2, 5, 8, 23, 25, 27, 29, 33, 35, 41, 44, 46, 51, 58, 68,
  81, 93, 97, 99, 101, 103, 112, 115, 117, 121, 122, 124,
  130, 132, 135, 142, 144, 146,
};

const Set<int> _uncommonDexNumbers = <int>{
  1, 4, 7, 11, 13, 16, 18, 19, 20, 22, 26, 28, 30, 32, 36,
  38, 39, 43, 45, 48, 49, 50, 53, 55, 57, 59, 61, 63, 65,
  66, 67, 70, 71, 74, 76, 79, 83, 86, 89, 92, 95, 98, 100,
  102, 105, 107, 109, 111, 113, 118, 119, 123, 125, 133, 134,
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
