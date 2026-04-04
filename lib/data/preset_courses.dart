import '../models/golf_course.dart';

const GolfCourse orestadCourse = GolfCourse(
  id: 'orestad',
  name: 'Örestad',
  isPreset: true,
  parts: <CoursePart>[
    CoursePart(
      name: 'Yellow',
      pars: <int>[4, 3, 4, 3, 4, 5, 4, 4, 4],
      greenCoords: <({double lat, double lng})>[
        (lat: 55.691210, lng: 13.069258),
        (lat: 55.691678, lng: 13.070934),
        (lat: 55.694409, lng: 13.070982),
        (lat: 55.695727, lng: 13.073491),
        (lat: 55.699582, lng: 13.076975),
        (lat: 55.696577, lng: 13.072639),
        (lat: 55.693877, lng: 13.068456),
        (lat: 55.691476, lng: 13.069990),
        (lat: 55.693798, lng: 13.065204),
      ],
    ),
    CoursePart(
      name: 'Red',
      pars: <int>[4, 3, 4, 5, 4, 3, 4, 5, 4],
      greenCoords: <({double lat, double lng})>[
        (lat: 55.696913, lng: 13.060952),
        (lat: 55.697892, lng: 13.059323),
        (lat: 55.700234, lng: 13.061782),
        (lat: 55.701203, lng: 13.068148),
        (lat: 55.697836, lng: 13.070600),
        (lat: 55.697246, lng: 13.068633),
        (lat: 55.700329, lng: 13.068304),
        (lat: 55.697581, lng: 13.063821),
        (lat: 55.695155, lng: 13.066070),
      ],
    ),
    CoursePart(
      name: 'Blue',
      pars: <int>[5, 3, 4, 4, 4, 3, 5, 4, 4],
      greenCoords: <({double lat, double lng})>[
        (lat: 55.697336, lng: 13.072029),
        (lat: 55.698217, lng: 13.071827),
        (lat: 55.700161, lng: 13.076234),
        (lat: 55.698009, lng: 13.079743),
        (lat: 55.696133, lng: 13.075653),
        (lat: 55.695267, lng: 13.074012),
        (lat: 55.698768, lng: 13.078589),
        (lat: 55.696419, lng: 13.074334),
        (lat: 55.694345, lng: 13.066531),
      ],
    ),
  ],
);

const GolfCourse falsterboCourse = GolfCourse(
  id: 'falsterbo',
  name: 'Falsterbo GK',
  isPreset: true,
  pars: <int>[4, 3, 5, 4, 4, 3, 4, 3, 4, 4, 3, 4, 5, 3, 5, 4, 4, 5],
);

const GolfCourse barsebackMasters = GolfCourse(
  id: 'barseback-masters',
  name: 'Barsebäck Masters',
  isPreset: true,
  pars: <int>[4, 4, 4, 3, 5, 4, 4, 3, 5, 4, 4, 5, 4, 4, 3, 5, 4, 4],
);

const GolfCourse barsebackOcean = GolfCourse(
  id: 'barseback-ocean',
  name: 'Barsebäck Ocean',
  isPreset: true,
  pars: <int>[4, 4, 4, 3, 5, 4, 4, 3, 5, 4, 4, 5, 4, 4, 3, 5, 4, 4],
);

const GolfCourse pgaNationalLinks = GolfCourse(
  id: 'pga-national-links',
  name: 'PGA National Links',
  isPreset: true,
  pars: <int>[4, 5, 4, 4, 3, 4, 3, 5, 4, 4, 5, 4, 3, 4, 5, 4, 3, 4],
);

const GolfCourse pgaNationalLakes = GolfCourse(
  id: 'pga-national-lakes',
  name: 'PGA National Lakes',
  isPreset: true,
  pars: <int>[5, 4, 4, 3, 4, 3, 4, 5, 4, 4, 5, 4, 4, 4, 3, 4, 3, 5],
);

const GolfCourse ljunghusenCourse = GolfCourse(
  id: 'ljunghusen',
  name: 'Ljunghusen GK',
  isPreset: true,
  pars: <int>[4, 4, 4, 3, 4, 5, 4, 4, 3, 4, 3, 5, 4, 5, 4, 3, 4, 5],
);

const GolfCourse flommenCourse = GolfCourse(
  id: 'flommen',
  name: 'Flommen GK',
  isPreset: true,
  pars: <int>[3, 4, 5, 4, 5, 4, 3, 4, 4, 3, 4, 5, 4, 3, 5, 5, 3, 4],
);

const GolfCourse malmoBurlovCourse = GolfCourse(
  id: 'malmo-burlov',
  name: 'Malmö Burlöv GK',
  isPreset: true,
  pars: <int>[4, 5, 4, 3, 4, 3, 4, 4, 4, 4, 4, 4, 3, 5, 4, 4, 3, 5],
);


const GolfCourse abbekasCourse = GolfCourse(
  id: 'abbekas',
  name: 'Abbekås GK',
  isPreset: true,
  pars: <int>[4, 4, 3, 4, 5, 3, 5, 4, 3, 4, 4, 5, 4, 3, 4, 4, 5, 4],
);

const GolfCourse lillaVikCourse = GolfCourse(
  id: 'lilla-vik',
  name: 'Lilla Vik',
  isPreset: true,
  pars: <int>[4, 5, 3, 5, 4, 4, 3, 4, 4, 5, 4, 4, 4, 3, 4, 3, 5, 4],
);

const GolfCourse djupadalCourse = GolfCourse(
  id: 'djupadal',
  name: 'Djupadal',
  isPreset: true,
  pars: <int>[5, 4, 3, 4, 3, 4, 3, 4, 5, 4, 3, 5, 4, 4, 3, 4, 4, 5],
);

const GolfCourse romeleAsenCourse = GolfCourse(
  id: 'romeleasen',
  name: 'Romeleåsen GK',
  isPreset: true,
  pars: <int>[4, 3, 4, 5, 4, 4, 5, 4, 3, 4, 5, 3, 4, 4, 4, 4, 3, 5],
);


const GolfCourse bokskogenCourse = GolfCourse(
  id: 'bokskogen',
  name: 'Bokskogen GK',
  isPreset: true,
  pars: <int>[4, 5, 4, 3, 4, 4, 3, 4, 3, 5, 4, 3, 4, 4, 3, 5, 4, 5],
);

const GolfCourse landskronaCourse = GolfCourse(
  id: 'landskrona',
  name: 'Landskrona GK',
  isPreset: true,
  pars: <int>[4, 3, 5, 3, 5, 3, 4, 5, 5, 4, 4, 3, 5, 3, 5, 4, 4, 3],
);

const GolfCourse tegelbergaCourse = GolfCourse(
  id: 'tegelberga',
  name: 'Tegelberga GK',
  isPreset: true,
  pars: <int>[4, 5, 3, 5, 3, 5, 4, 5, 4, 3, 4, 3, 4, 3, 4, 4, 3, 5],
);

const GolfCourse vasatorpCourse = GolfCourse(
  id: 'vasatorp',
  name: 'Vasatorp Classic',
  isPreset: true,
  pars: <int>[5, 4, 4, 3, 5, 4, 3, 4, 4, 4, 5, 4, 4, 3, 4, 4, 3, 5],
);

const GolfCourse eslovCourse = GolfCourse(
  id: 'eslov',
  name: 'Eslöv GK',
  isPreset: true,
  pars: <int>[5, 3, 5, 3, 4, 4, 3, 4, 4, 3, 5, 4, 3, 4, 4, 4, 4, 4],
);

const GolfCourse lundAkademiskaCourse = GolfCourse(
  id: 'lund-akademiska',
  name: 'Lunds Akademiska GK',
  isPreset: true,
  pars: <int>[4, 3, 4, 5, 4, 3, 4, 4, 5, 5, 4, 5, 3, 4, 4, 3, 4, 4],
);

const GolfCourse soderasenCourse = GolfCourse(
  id: 'soderasen',
  name: 'Söderåsen GK',
  isPreset: true,
  pars: <int>[4, 4, 3, 4, 5, 3, 4, 5, 3, 4, 4, 5, 3, 5, 3, 4, 4, 4],
);

const GolfCourse bedingeCourse = GolfCourse(
  id: 'bedinge',
  name: 'Bedinge GK',
  isPreset: true,
  pars: <int>[4, 4, 4, 3, 4, 5, 3, 4, 5, 3, 4, 4, 3, 5, 4, 4, 3, 4],
);

const GolfCourse tomelillaCourse = GolfCourse(
  id: 'tomelilla',
  name: 'Tomelilla GK',
  isPreset: true,
  pars: <int>[5, 4, 3, 5, 4, 4, 4, 3, 5, 5, 4, 4, 4, 3, 4, 5, 3, 4],
);

const GolfCourse helsingborgCourse = GolfCourse(
  id: 'helsingborg',
  name: 'Helsingborg GK',
  isPreset: true,
  pars: <int>[4, 3, 5, 3, 4, 4, 4, 3, 4, 4, 3, 5, 3, 4, 4, 4, 3, 4],
);

const List<GolfCourse> presetCourses = <GolfCourse>[
  orestadCourse,
  falsterboCourse,
  barsebackMasters,
  barsebackOcean,
  pgaNationalLinks,
  pgaNationalLakes,
  ljunghusenCourse,
  flommenCourse,
  malmoBurlovCourse,
  abbekasCourse,
  lillaVikCourse,
  djupadalCourse,
  romeleAsenCourse,
  bokskogenCourse,
  landskronaCourse,
  tegelbergaCourse,
  vasatorpCourse,
  eslovCourse,
  lundAkademiskaCourse,
  soderasenCourse,
  bedingeCourse,
  tomelillaCourse,
  helsingborgCourse,
];
