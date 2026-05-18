import 'package:flutter/material.dart';

import '../app.dart';
import '../models/golfer_team.dart';
import '../services/supabase_service.dart';

void showTeamGolfersSheet(BuildContext context, GolferTeam team) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => TeamGolfersSheet(team: team),
  );
}

class _Member {
  _Member(this.name, this.sprite, this.courses);
  final String name;
  final String? sprite;
  final int courses;
}

class TeamGolfersSheet extends StatefulWidget {
  const TeamGolfersSheet({super.key, required this.team});

  final GolferTeam team;

  @override
  State<TeamGolfersSheet> createState() => _TeamGolfersSheetState();
}

class _TeamGolfersSheetState extends State<TeamGolfersSheet> {
  List<GolferProfile>? _golfers;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final golfers = await SupabaseService().fetchAllGolfers();
      if (mounted) setState(() => _golfers = golfers);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final team = widget.team;
    final store = BogeybeastGolfScope.of(context);
    final safeBottom = MediaQuery.of(context).padding.bottom;

    // Courses held per golfer, from loaded course leaders.
    final Map<String, int> courseCounts = <String, int>{};
    for (final leader in store.courseLeaders.values) {
      final uid = leader.userId;
      if (uid != null) {
        courseCounts[uid] = (courseCounts[uid] ?? 0) + 1;
      }
    }

    final List<_Member>? members = _golfers == null
        ? null
        : (_golfers!
            .where((g) => g.golferTeam == team.dbValue)
            .map((g) => _Member(
                  g.golferName,
                  g.golferSprite,
                  courseCounts[g.userId] ?? 0,
                ))
            .toList()
          ..sort((a, b) => b.courses.compareTo(a.courses)));

    final int totalCourses = members == null
        ? 0
        : members.fold(0, (int s, _Member m) => s + m.courses);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + safeBottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: team.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(child: TeamEmblem(team: team, size: 19)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  team.label,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: team.color,
                  ),
                ),
              ),
              if (members != null)
                Text(
                  '${members.length} ${members.length == 1 ? 'member' : 'members'} · $totalCourses',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_failed)
            _message(theme, 'Could not load team members.')
          else if (members == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (members.isEmpty)
            _message(theme, 'No golfers have joined ${team.label} yet.')
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: members.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, index) => _MemberRow(
                  rank: index + 1,
                  member: members[index],
                  color: team.color,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _message(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.rank,
    required this.member,
    required this.color,
  });

  final int rank;
  final _Member member;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        SizedBox(
          width: 22,
          child: Text(
            '$rank',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          clipBehavior: Clip.antiAlias,
          child: member.sprite != null
              ? Image.asset(
                  member.sprite!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Icon(Icons.person, size: 18, color: color),
                )
              : Icon(Icons.person, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            member.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Icon(Icons.shield_rounded, size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          '${member.courses}',
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
