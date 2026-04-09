class Club {
  const Club({
    this.id,
    required this.name,
    this.carryDistance,
    this.totalDistance,
  });

  final String? id;
  final String name;
  final int? carryDistance;
  final int? totalDistance;

  static List<Club> get defaults => const <Club>[
    Club(name: 'Driver'),
    Club(name: '5i'),
    Club(name: '6i'),
    Club(name: '7i'),
    Club(name: '8i'),
    Club(name: '9i'),
  ];
}
