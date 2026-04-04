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

const List<GolfCourse> presetCourses = <GolfCourse>[
  orestadCourse,
];
