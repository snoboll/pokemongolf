import '../models/battle_models.dart';

class CourseLeader {
  const CourseLeader({
    required this.courseId,
    this.userId,
    required this.leaderName,
    required this.hcp,
    required this.team,
    required this.isNpc,
    this.claimedAt,
    this.trainerSprite,
    this.trainerTeam,
  });

  final String courseId;
  final String? userId;
  final String leaderName;
  final int hcp;
  final List<BattlePokemon> team;
  final bool isNpc;
  final DateTime? claimedAt;
  final String? trainerSprite;
  final String? trainerTeam;

  static CourseLeader fromJson(Map<String, dynamic> json) {
    List<BattlePokemon> parseTeam(dynamic raw) {
      if (raw == null) return [];
      return (raw as List<dynamic>)
          .map((e) => BattlePokemon.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return CourseLeader(
      courseId: json['course_id'] as String,
      userId: json['user_id'] as String?,
      leaderName: json['leader_name'] as String,
      hcp: (json['hcp'] as num).toInt(),
      team: parseTeam(json['team']),
      isNpc: json['is_npc'] as bool? ?? false,
      claimedAt: json['claimed_at'] != null
          ? DateTime.parse(json['claimed_at'] as String)
          : null,
      trainerSprite: json['trainer_sprite'] as String?,
      trainerTeam: json['trainer_team'] as String?,
    );
  }
}
