import '../models/golf_course.dart';

const GolfCourse orestadCourse = GolfCourse(
  id: 'orestad',
  name: 'Örestad',
  isPreset: true,
  parts: <CoursePart>[
    CoursePart(
      name: 'Yellow',
      pars: <int>[4, 3, 4, 3, 4, 5, 4, 4, 4],
    ),
    CoursePart(
      name: 'Red',
      pars: <int>[4, 3, 4, 5, 4, 3, 4, 5, 4],
    ),
    CoursePart(
      name: 'Blue',
      pars: <int>[5, 3, 4, 4, 4, 3, 5, 4, 4],
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
