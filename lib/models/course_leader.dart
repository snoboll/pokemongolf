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
    this.golferSprite,
    this.golferTeam,
  });

  final String courseId;
  final String? userId;
  final String leaderName;
  final int hcp;
  final List<BattleBogeybeast> team;
  final bool isNpc;
  final DateTime? claimedAt;
  final String? golferSprite;
  final String? golferTeam;

  static CourseLeader fromJson(Map<String, dynamic> json) {
    List<BattleBogeybeast> parseTeam(dynamic raw) {
      if (raw == null) return [];
      return (raw as List<dynamic>)
          .map((e) => BattleBogeybeast.fromJson(Map<String, dynamic>.from(e as Map)))
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
      golferSprite: json['golfer_sprite'] as String?,
      golferTeam: json['golfer_team'] as String?,
    );
  }
}
