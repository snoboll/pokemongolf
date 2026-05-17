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

const Map<int, String> _flavorText = <int, String>{
  1: 'Puttling is a sprout-tailed cub that toddles across the practice green, '
      'patting stray balls toward the hole with its tiny paws. Where it naps, '
      'the grass always grows a little greener.',
  2: 'Fairwyn keeps the fairway immaculate, brushing dew from the turf with '
      'its leafy tail. Golfers who treat it kindly often find their lie has '
      'improved while they weren\'t looking.',
  3: 'Teelord reigns over the first tee like ancient woodland royalty. The '
      'blossoms wreathing its branches release a faint pollen that steadies '
      'the nerves of any golfer brave enough to bow before it.',
  4: 'Bogferno smolders with the frustration of a thousand missed putts. Its '
      'rocky hide cracks with inner fire, and the rough wilts to ash wherever '
      'this little furnace stamps its feet.',
  5: 'Parablaze burns hottest when a round goes wrong. It hurls cinders down '
      'the fairway in looping arcs, and the scorch marks it leaves are said '
      'to trace the perfect line to the pin.',
  6: 'Emberdie spreads vast wings of living flame and circles doomed shots '
      'from above. When it folds those wings and dives, a double bogey is '
      'all but written on the card.',
  7: 'Droptooth is a pond-dwelling hatchling that chomps happily at golf '
      'balls mistaken for eggs. It splashes through every water hazard, '
      'utterly delighted by the trouble it causes.',
  8: 'Bladogator sharpens the fin on its tail against tee markers until it '
      'gleams like a wedge. It guards the water hazards and dares golfers to '
      'come fish out their ball.',
  9: 'Hookodile is an armored terror of the deep hazard, plated like a knight '
      'and twice as patient. It drags slicing shots beneath the surface and '
      'is rumored never to surrender a ball it has claimed.',
  10: 'Roughrat thrives in the tall grass where balls go to vanish. It '
      'hoards them in leafy burrows, and a chewed, grass-stained ball is the '
      'unmistakable mark of its mischief.',
  11: 'Growdent gnaws through saplings to shape the rough exactly as it likes '
      'it — thick, tangled, and merciless. Course keepers and golfers alike '
      'consider it a worthy adversary.',
  12: 'Crisprdi is a fledgling of frost and feather, fluttering low over '
      'frozen ponds. Its cheerful chirp carries a chill that stiffens the '
      'fingers of anyone lining up a putt nearby.',
  13: 'Chilleagle soars on wings of pure frost, every feather rimed with ice. '
      'It circles high above the fairway and reads the wind better than any '
      'caddie, screeching once when a shot is destined to find the green.',
  15: 'Babydraw never goes anywhere without its crayons. The little cub '
      'scribbles loops and swirls on every scorecard it finds, and golfers '
      'swear a putt traced by Babydraw curves gently into the cup.',
  14: 'Albafrosst is a phoenix reborn not in fire but in ice, its wings '
      'trailing glittering snow. When it crosses the sky, the whole course '
      'falls silent and the greens turn glass-slick with frost.',
  16: 'Snaphook is a salt-crusted bear inked head to paw with anchors and old '
      'sailor tattoos. It drags its tangle of ropes through the rough, and '
      'any ball it snags is yanked hard and low toward the trees.',
  17: 'Tinyfade is a sparky little critter whose tail flicks balls into a '
      'soft, dependable fade. Beginners cherish it, since its gentle curve '
      'rarely strays far from the short grass.',
  18: 'Bautaslice is what Tinyfade becomes when patience runs out. Its fan '
      'of bladed tails carves the air with a vicious curve, sending shots '
      'screaming far right of where anyone aimed.',
  19: 'Tappin is a tidy little fox that nudges balls the last few inches '
      'into the cup. It refuses to let a putt linger on the lip and will '
      'pat it home whether you asked for help or not.',
  20: 'Stimpee measures the speed of every green by rolling across it on '
      'its striped tail. The bandana it wears is a badge of office — no '
      'putt is official until Stimpee has had its say.',
  21: 'Missuno is a plump grub that inches along the fairway, chewing tee '
      'pegs and dreaming of wings. It is the first stage of a proud line '
      'of course-keeping insects.',
  22: 'Adidos has shed its grubby youth for a sleek, winged warrior\'s form. '
      'It patrols the bug-line\'s territory at speed, striped and armored, '
      'darting between hazards faster than the eye can follow.',
  23: 'Titliestres is the apex of the Missuno line — a venom-tailed elite '
      'clad in royal armor. Golfers who disturb its nest learn that the '
      'rough has defenders far fiercer than tall grass.',
  24: 'Owtofbouns flutters just past the white stakes, a winged imp of pure '
      'mischief. Any ball that drifts into its territory is whisked away '
      'with a giggle, never to be played again.',
  25: 'Strekathol is the grim elder of the out-of-bounds line, an owl that '
      'tallies stroke and distance with cold precision. Where it roosts, '
      'penalties are counted twice and forgiven never.',
  26: 'Tristlie is a stout, plated digger that loves loose dirt. It tumbles '
      'through the fairway carving little craters, blissfully unaware that '
      'golfers call its handiwork a divot.',
  27: 'Horchunk is Tristlie grown huge and powerful, hurling clods of turf '
      'with every stride. A single charge can leave a fairway pocked like '
      'a battlefield — and the groundskeeper despairing.',
  28: 'Stenfan is a bull of solid stone that stands immovable in the sand. '
      'Golfers who find their ball beside it know the bunker has chosen a '
      'champion to guard the escape.',
  29: 'Sabakloba is Stenfan hardened by countless buried lies, its cracked '
      'hide glowing with the heat of a thousand failed escapes. It rules '
      'the deepest bunkers as their unyielding lord.',
  30: 'Bongker is a craggy golem that makes its home in the bunkers, packed '
      'from sun-baked sand and stubbornness. It cheerfully buries any ball '
      'that drops in, certain it has done the golfer a favor.',
  31: 'Naynayron is the lightest of the iron line, a nimble stone figure '
      'built for high, soft approaches. It is the first forged of three '
      'and the easiest to swing into action.',
  32: 'Sevenayron is the dependable middle of the iron line, broader and '
      'more armored than Naynayron. Golfers reach for it when the shot '
      'demands both distance and control.',
  33: 'Fayvayron is the heaviest forged of the iron line, a towering slab '
      'of layered stone. It launches shots low and far, and only the '
      'strongest swings can rouse it from its stance.',
  34: 'Splish is a playful droplet of a creature that dances on the surface '
      'of every water hazard. It hops after errant balls, delighted by the '
      'splash each one makes as it lands.',
  35: 'Plooms is Splish swollen into a cresting wave, half ice and half '
      'spray. It surges over the bank to reclaim any ball that dares the '
      'water, dragging it down with a frosty roar.',
  36: 'Pinnhai is a shark of waterlogged driftwood and creeping reeds, '
      'cruising the lake margins. It surfaces only to judge a shot, and a '
      'ball it deems pin-high is spared the depths.',
  37: 'Komindo is a sleek, finned lizard that basks at the edge of the '
      'water hazard. Harmless and curious, it trails golfers along the '
      'bank, waiting to grow into something far less friendly.',
  38: 'Denharvi is Komindo charged with the storms that gather over open '
      'water. Its crest crackles with current, and it guards the hazard '
      'with a jolt for anyone who wades in after a ball.',
  39: 'Laypup is a bright-burning pup that bounds along the fairway leaving '
      'tiny scorch marks. It loves to fetch, though the balls it returns '
      'are always a little warm and a little singed.',
  40: 'Stingler is a small blue scorpion that hides in the reeds of the '
      'water hazard. Its glowing tail-bead drips a mild venom, more a '
      'nuisance to golfers than a true danger.',
  41: 'Stungyard is Stingler grown into a winged terror of the wetland '
      'holes. The venom in its raised tail can swell a hand stiff, ending '
      'many a promising round at the water\'s edge.',
  42: 'Bugbag is a hollow golf bag given buzzing life, clubs rattling like '
      'a chitinous shell. It scuttles after groups on insect legs, eager '
      'to carry — and quietly pilfer — their gear.',
  43: 'Acicart is Bugbag fused with an abandoned golf cart, a venomous '
      'half-machine that rolls the cart paths uninvited. Its toxic exhaust '
      'wilts the rough it trundles through.',
  44: 'Toxicaddie is the dreaded final form of the Bugbag line — a bristling '
      'mech of clubs, blades, and dripping venom. It offers its services '
      'as a caddie, and no golfer has ever dared decline.',
  45: 'Bogistragl is a cub of clear blue ice that pads across frozen greens '
      'on soft, frosty paws. It hugs any ball it finds, leaving it pleasantly '
      'chilled and slightly slippery.',
  46: 'Bawrapawr is Bogistragl grown into a towering bear of jagged ice. '
      'Its roar frosts the pin solid, and the greens around its den stay '
      'glassy and treacherous all season.',
  47: 'Lipowlt is a fluffy owl wreathed in gentle flame, hooting softly as '
      'it watches twilight rounds. The little fire on its tail never quite '
      'goes out, even in the rain.',
  48: 'Lagphoot is Lipowlt risen into a blazing phoenix of the night sky. '
      'It soars on burning wings above the back nine, and golfers say its '
      'cry means a long, scorching round still lies ahead.',
  49: 'Rongclub is a stubborn koala that lugs a bone-shaped cudgel '
      'everywhere it goes. It hands golfers whichever club it pleases — '
      'almost always the wrong one for the shot.',
  50: 'Hotstreek burns with restless energy, flame and spark chasing each '
      'other across its body. It runs the fairway in a blur, igniting a '
      'birdie streak in any golfer bold enough to follow.',
  51: 'Holeoblaze is Hotstreek erupted into a living inferno of fire and '
      'lightning. When it strides onto a hole, the flag itself seems to '
      'catch alight — a sign the pin is there for the taking.',
  52: 'Zapwedge is a cheery, lightning-marked sprite shaped like a lofted '
      'wedge. It zaps balls high into the air with a crackle, dropping them '
      'soft and spinning onto the green.',
  53: 'Greeninreg is Zapwedge grown sharp and proud, planting its little '
      'flag wherever a shot finds the putting surface. Its electric-green '
      'glow is a golfer\'s badge for a green hit in regulation.',
  54: 'Skaiad is a downy yellow chick crackling with static, forever staring '
      'up at the open sky. It flutters after high shots, cheering each one '
      'that climbs toward the clouds.',
  55: 'Skaimarx is Skaiad grown into a stern, storm-feathered eagle, forever '
      'lecturing the flock on the proper redistribution of fairway. It '
      'rules the high air and judges every lofted shot from above.',
  56: 'Secondcat prowls the second cut of rough, a lean green stalker that '
      'blends into the longer grass. It bats stray balls deeper into cover, '
      'purring at the trouble it makes.',
  57: 'Frincheetah is Secondcat at full sprint, a leaf-dappled blur tearing '
      'along the fringe. Nothing crosses its stretch of rough faster, and '
      'few balls escape its swift, leafy paws.',
  58: 'Tigerwudz is the apex of its line — a legendary green tiger that '
      'stalks the deepest woods off the fairway. Golfers speak its name in '
      'hushed awe, for it has mastered every shot the trees can offer.',
  59: 'Spinbite is a shadow-furred predator that pounces on shots cursed '
      'with wild sidespin. It drags slices and hooks alike into the dark, '
      'feeding on every golfer\'s worst tendencies.',
  60: 'Kortosne is a stubby green dragon with stubby little wings, content '
      'to keep its flights short and safe. It hoards balls hit just past '
      'the ladies\' tees and guards them jealously.',
  61: 'Longorak is Kortosne stretched long and powerful, its great wings '
      'built for distance. When it takes to the air, the carry seems to go '
      'on forever — and so does the search for the ball.',
  62: 'Seet is a small frost-dragon that sheds glittering sleet wherever it '
      'pads. The greens it crosses turn slick and slow, much to the dismay '
      'of every putter that follows.',
  63: 'Menstanado is Seet whipped into a whirling storm-dragon of ice and '
      'wind. It spins down the fairway as a living squall, hurling shots '
      'off line with every freezing gust.',
  64: 'Elektrindor is a boxy little automaton humming with raw current, a '
      'spark-plug heart in a metal shell. It zaps golf carts back to life '
      'and waits patiently to be upgraded.',
  65: 'Voltrakman is Elektrindor rebuilt into a thundering battle-mech. Its '
      'piston fists strike with the force of a long drive, and lightning '
      'arcs from every joint as it stomps the cart paths.',
  66: 'Undulathon is a rainbow-winged phoenix that rides the updrafts in '
      'long, rolling waves. Golfers who glimpse its undulating flight take '
      'it as a sign of fast, flowing greens ahead.',
  67: 'Zepestance is a sun-baked lizard that plants its feet in the dirt '
      'and refuses to budge. It teaches young Bogeybeasts that a solid '
      'stance comes before any good swing.',
  68: 'Zepestance becomes Rovtchip once roots and turf take hold across its '
      'back. Grown and grounded, it chips loose clods toward the green, '
      'every shot springing from that same rooted stance.',
  69: 'Shankey is a jittery ice-fighter that throws punches off the heel of '
      'its fist. Its blows fly sharply sideways, and golfers near it feel '
      'an unwelcome chill creep into their swing.',
  70: 'Socketfeil is Shankey hardened into a towering brawler of frost. The '
      'shank it once feared it now wields as a weapon, sending everything '
      'careening off the hosel with icy force.',
  71: 'Dumduff is a shaggy brown ape that thumps the turf instead of the '
      'ball, scattering grass with every clumsy swing. It means well, but '
      'it has never made clean contact in its life.',
  72: 'Deevot is Dumduff grown huge and even heavier-handed. Each mighty '
      'blow tears a fresh divot the size of a doormat, leaving fairways '
      'pocked wherever this giant has practiced.',
  73: 'OBwan is a young fox-mage learning to sense balls lost beyond the '
      'white stakes. It bows humbly before each shot, murmuring that the '
      'penalty is strong with this one.',
  74: 'Proveewan is OBwan come into its powers, a robed sage who reads the '
      'provisional ball before it is even struck. Few escape its quiet '
      'judgement on what lies out of bounds.',
  75: 'Holinwangenobi is the grand master of the out-of-bounds line, a '
      'dragon-sage wreathed in psychic light. It alone can guide a ball '
      'home from the farthest reaches of the lost.',
  76: 'Peboll is a round, beaming little fish that bobs in every pond on '
      'the course. Smooth and pale as a polished stone, it loves nothing '
      'more than being skipped across the water.',
  77: 'Profesorfisk is Peboll grown wise and bespectacled, forever poring '
      'over its waterlogged rulebook. It will happily explain the local '
      'rules to any golfer fishing in its pond.',
  78: 'Lawnshangle is a scrappy grass-sprite with fists of woven turf. It '
      'wrestles overgrown patches of fairway into shape, training hard to '
      'become a true course-keeping champion.',
  79: 'Spinrayt is Lawnshangle grown bark-skinned and broad, putting a '
      'fierce rightward spin on everything it strikes. Its punches curve '
      'just as a sliced shot does.',
  80: 'Smashfakdurr is the towering final form of the Lawnshangle line, '
      'all timber muscle and crushing fists. Every blow it lands is pure '
      'smash factor — maximum power transferred in a single strike.',
  81: 'Jinx is an impish psychic cat that toys with a golfer\'s focus. A '
      'flick of its starry paw is enough to send a sure putt sliding wide '
      'at the very last roll.',
  82: 'Skobra is a wispy ghost-serpent that haunts the scorecard. It coils '
      'around bad numbers and whispers them back, making sure no golfer '
      'forgets a single dropped shot.',
  83: 'Skrixon is Skobra grown venomous and skull-crowned, its hood marked '
      'with grim warnings. It strikes at fragile rounds, and the scores it '
      'poisons rarely recover.',
  84: 'Skullaway is the dread final form of the Skobra line, a spectral '
      'cobra crowned with a glowing skull. When it rears up, an entire '
      'round can be wiped away in a single haunted stroke.',
  85: 'Rangewhelp is a tiny dragon hatched on the driving range, gleefully '
      'pouncing on bucket after bucket of practice balls. It dreams of one '
      'day carrying a shot the full length of the field.',
  86: 'Yardrake is Rangewhelp fledged into a winged drake that measures '
      'every hole in precise yardage. It glides the fairway like a living '
      'rangefinder, calling distances no caddie could match.',
  87: 'Carryhazard is the mighty final form of the Rangewhelp line, an '
      'armored dragon built to fly shots clear over any trouble. With it '
      'aloft, no water or bunker is too far to carry.',
  88: 'Ofdedeck is a humble lizard that strikes every shot cleanly off the '
      'bare ground, no tee required. It takes quiet pride in playing the '
      'ball exactly as it lies.',
  89: 'Pangdrayv is Ofdedeck grown sleek and powerful, vine-muscled and '
      'pinned low for a piercing drive. It launches balls on a flat, '
      'searing trajectory straight down the deck.',
  90: 'Drayvagreen is the golden final form of the Ofdedeck line, a radiant '
      'dragon that aims for the green from the tee. Golfers who befriend it '
      'dream only of driving the par fours.',
  91: 'Teetaim is an eager grub that laces on tiny boxing gloves at the '
      'first tee. It bounces and shadow-boxes the morning away, impatient '
      'for its round to begin.',
  92: 'Penaltee is Teetaim grown into a sharp-jabbing insect brawler. It '
      'punishes every rules slip in the tee box, throwing a flurry of '
      'blows for each stroke a golfer tries to skip.',
  93: 'Teeboxer is the final form of the Teetaim line — a striped referee '
      'of the tee box who enforces order with iron gloves. No golfer tees '
      'up out of turn while Teeboxer is watching.',
  94: 'Chipin is a soft-gliding squirrel that drops out of the trees and '
      'lands without a sound. It loves to nudge greenside shots straight '
      'into the cup for a tidy little hole-out.',
  95: 'Flopshot is Chipin grown bold, a stone-winged glider that flings '
      'itself sky-high before floating gently down. It teaches golfers the '
      'art of the towering shot that lands soft and still.',
  96: 'Clarva is a crystal-shelled cub glittering with psychic light. It '
      'rolls slowly across the green, and putts that pass it seem to bend '
      'gently toward the hole.',
  97: 'Clarva sheds its small shell to become Denneclar, a sleek crystal '
      'beast bristling with mind-reading spires. It senses the break of '
      'every green long before a golfer can.',
  98: 'Gripslip is a frost-slicked lizard that can never quite hold on. '
      'Its icy claws lose their grip mid-swing, and the wild shots that '
      'follow are entirely its doing.',
  99: 'Skrambell is a clanging bell-creature of fire and water, ringing out '
      'to rally a team. Where it chimes, golfers pick up one another\'s '
      'best shots and scramble toward a shared score.',
  100: 'Alsquare is a calm, eye-marked cube that keeps every match in '
      'perfect balance. While it floats nearby, no player leads and none '
      'trails — the contest stays dead even.',
  101: 'Doormee is Alsquare opened into a glowing psychic gateway. It marks '
      'the moment a match cannot be lost, only won or halved, and golfers '
      'feel its quiet pressure on every closing hole.',
  102: 'Jossi is a serene little mystic that hums softly over the greens, '
      'trailing stars. Its gentle blessing settles a golfer\'s nerves just '
      'before a knee-knocking putt.',
  103: 'Suooja is Jossi grown strong and radiant, a winged guardian of the '
      'putting surface. It shields golfers from doubt, and putts struck in '
      'its presence roll with unshakable confidence.',
  104: 'Chipamboo is a wispy panda cub of bamboo and mist. It bumbles '
      'around the greenside, gently rolling chips along the turf rather '
      'than lofting them into the air.',
  105: 'Bumpandarun is Chipamboo grown surer of paw, a ghostly panda that '
      'plays every greenside shot low and running. It bumps the ball into '
      'the slope and lets it scurry toward the pin.',
  106: 'Upandawn is the masterful final form of the Chipamboo line, a '
      'shadow-armored panda warrior of the short game. Whatever trouble it '
      'finds near the green, it always gets up and down.',
  107: 'Grinfee is a sly green goblin that lurks by the clubhouse gate, '
      'cackling as it counts coins. No Bogeybeast steps onto its course '
      'until the green fee has been paid in full.',
  108: 'Bladagast is a young leaf-mage that toddles the fairway with a twig '
      'for a staff. It practices small green-reading spells, dreaming of '
      'the great course-wizard it will one day become.',
  109: 'Mulligandalf is the grand old wizard of the Bladagast line, white-'
      'bearded and endlessly forgiving. With a tap of its staff it grants '
      'a single shot again — you shall not count that stroke.',
  110: 'Strekstrek is a russet bird that flies the course in long, even '
      'stretches. It marks the steady pace of a round, gliding from tee '
      'to green without ever rushing.',
  111: 'Bogibardi is Strekstrek risen into a proud phoenix of the back nine. '
      'It soars in sweeping arcs above the closing holes, and golfers take '
      'its cry as a call to finish strong.',
  112: 'Ritebreak is a fierce spirit-warrior that haunts the trickiest '
      'greens. It shoves a putt the exact wrong way, turning a read that '
      'looked right into a heartbreaking lip-out.',
  113: 'Linkskors is a golden idol awakened from an ancient seaside course. '
      'Its glowing core keeps the score of every links round ever played, '
      'and it blesses those who respect the old ways.',
  114: 'Thindit is a stone scorpion that skitters across hard, dry ground. '
      'It scratches only the thinnest of marks in the turf, proud that it '
      'never digs a proper divot.',
  115: 'Fuooor is Thindit grown into a molten, armored centipede that '
      'erupts from the rough. Golfers shout a warning the instant it '
      'surfaces — its blazing charge spares nothing in its path.',
  116: 'Fringeputt is a small fire-fox that pads the fringe of every green. '
      'It noses balls off the collar and onto the smooth surface, purring '
      'as it tidies up the short grass.',
  117: 'Indahowl is Fringeputt grown into a blazing wolf that howls when a '
      'putt drops. Its cry echoes across the course, announcing to all '
      'that another ball has found the hole.',
  118: 'Plugfuk is a burrowing beetle that buries balls deep in soft turf '
      'and bunker faces. The dreaded plugged lie is its handiwork, and it '
      'delights in every golfer\'s muffled groan.',
  119: 'Legdog is a shaggy green brawler that bounds along the fairway on '
      'powerful legs. It hounds a wayward shot relentlessly, fists raised, '
      'until the ball is wrestled back into play.',
  120: 'Trigglett is a twitchy shadow-cat with a hair-trigger temper. The '
      'smallest bad bounce sets it hissing, and its dark mood spreads '
      'quickly to any golfer nearby.',
  121: 'Gigatilt is Trigglett consumed by rage, a steaming beast of pure '
      'frustration. When it appears, a golfer\'s round spirals out of '
      'control — one bad hole tilting into many.',
  122: 'Fairwhayle is a vast, gentle whale that glides through the largest '
      'water hazards. It surfaces to spare balls struck boldly down the '
      'middle, ushering them safely back to the fairway.',
  123: 'Schneschlug is a sluggish purple creature that oozes across the '
      'green at a maddening crawl. Groups stuck behind it learn the true '
      'meaning of slow play.',
  124: 'Eelonmask is a crackling electric eel obsessed with launching '
      'things ever farther. It charges balls with a jolt and rockets them '
      'skyward, promising distance no club could ever match.',
  125: 'Flatpitch is a friendly brown pup that scampers across level '
      'ground. Calm and adaptable, it can grow toward fire, water, or '
      'lightning depending on the course it calls home.',
  126: 'Pyrepitch is the fire-born form of Flatpitch, a blazing ram raised '
      'on sun-scorched links. It stamps cinders into the turf, and the '
      'fairways it roams stay parched and fast.',
  127: 'Tidepitch is the water-born form of Flatpitch, a flowing ram of '
      'mist and spray raised beside the hazards. It keeps the greens soft '
      'and the lakes brimming wherever it grazes.',
  128: 'Elepitch is the storm-born form of Flatpitch, a crackling ram '
      'raised under open skies. Lightning dances along its horns, and the '
      'air hums whenever it gallops the fairway.',
  129: 'Grovepitch is the leaf-born form of Flatpitch, a verdant ram raised '
      'in the wooded holes. Flowers and vines trail from its horns, and '
      'the rough thrives lush and green in its wake.',
  130: 'Wintergreenor is a frost-antlered stag that wanders the course '
      'between seasons. Where it treads, the greens stay tinted with '
      'evergreen even as the first snow settles in.',
  131: 'Waggler is a wobbly ghost that drifts above the ball, swaying back '
      'and forth without ever committing. It is all nervous waggle and no '
      'swing, forever rehearsing the shot it dares not take.',
  132: 'Proofswing is Waggler grown decisive, a spirit-fighter that has '
      'finally pulled the trigger. Its motion is pure and repeatable — the '
      'flawless swing every golfer chases.',
  133: 'Sandstroke is a swirling spirit of bunker sand that rises whenever '
      'a ball plugs in the trap. It counts each splashing escape attempt, '
      'one grim stroke at a time.',
  134: 'Fahndoh is a sparky little critter that yelps a shrill warning '
      'whenever a shot flies off line. Golfers have learned that when '
      'Fahndoh cries out, it is wise to duck.',
  135: 'Yewlachit is Fahndoh grown into a storm-maned beast that crackles '
      'with warning. Its thunderous bark carries across three fairways, '
      'scattering anyone in a wayward shot\'s path.',
  136: 'Owberg is a drifting crag of psychic ice, most of its bulk hidden '
      'beneath the frost. Golfers who misjudge its size find far more '
      'trouble below the surface than above.',
  137: 'Roary is a stone-maned dragon-lion that lets loose a quaking roar '
      'from the highest tee. Its cry rolls across the course like thunder, '
      'and bold golfers roar right back.',
  138: 'Shefflor is an armored guardian of the water holes, plated and '
      'crowned with psychic sigils. Calm and unshakable, it shepherds '
      'steady shots across the hazard to safety.',
  139: 'Braizon is a brazen panther wreathed in dark fire, prowling the '
      'course after dusk. It blazes a fearless line at every flag, scorning '
      'the safe and sensible play.',
  140: 'Hee-Oh is a moth of living flame that drifts above the sunbaked '
      'holes. Golfers whisper that catching sight of its embered wings '
      'brings a streak of good fortune.',
  141: 'Shee-Oh is Hee-Oh\'s storm-born twin, a shimmering insect crackling '
      'with electric light. Where one brings warm luck, the other brings a '
      'sudden, charged turn of fate.',
  142: 'Bogeyman is the shadow that stalks every scorecard, a creeping '
      'dread that feeds on dropped shots. No golfer is ever truly free of '
      'it — one over par, and it is already at their heels.',
  143: 'Saintandrose is a serene, rose-staffed monarch of the old seaside '
      'links. It blesses those who honour the ancient home of the game, '
      'guiding their shots along time-worn fairways.',
  144: 'Frontanine is a swift dark beast that owns the opening holes. It '
      'sets the tone of a round early, and golfers it favours come off '
      'the turn already in the lead.',
  145: 'Bakanine is Frontanine\'s shadowy counterpart, ruler of the closing '
      'holes. It tests the nerve of every golfer down the stretch, deciding '
      'rounds on the long way home.',
  146: 'Touritslag is a golden lion-warrior built like a seasoned tour pro. '
      'It plays with unhurried, professional patience, never letting a '
      'slow group or a bad break rush its game.',
  147: 'Yuessowpen is a legendary dragon of the great national championship, '
      'its wings barred in bold red and blue. It haunts the most punishing '
      'courses, where only the truly tested may stand before it.',
  148: 'Deeowpen is the legendary storm-phoenix of the oldest championship '
      'of all. It rides the coastal gales above the links, and only golfers '
      'who can tame the wind ever earn its respect.',
  149: 'Pegeaychamp is a legendary dragon forged for the fiercest of the '
      'professional majors. Armored and relentless, it yields only to the '
      'golfer who can match its iron will down every hole.',
  150: 'Agustamastr is the legendary green-and-gold dragon of the most '
      'hallowed course of spring. It guards the blossoming fairways, and '
      'its blessing is the most coveted prize in all the game.',
  151: 'Kuondor is the rarest legend of the skies — a radiant phoenix named '
      'for the four-under miracle almost no golfer will ever record. To '
      'simply glimpse it is the achievement of a lifetime.',
};

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
        flavorText: _flavorText[dexNumber],
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
