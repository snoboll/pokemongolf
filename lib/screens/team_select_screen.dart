import 'package:flutter/material.dart';

import '../data/first_gen_bogeybeasts.dart';
import '../models/battle_models.dart';
import '../models/bogeybeast_species.dart';
import '../models/bogeybeast_type.dart';
import '../models/course_leader.dart';
import '../models/golfer_team.dart';

class TeamSelectScreen extends StatefulWidget {
  const TeamSelectScreen({
    super.key,
    required this.caughtDexNumbers,
    this.title = 'Pick your team',
    this.leader,
  });

  final Set<int> caughtDexNumbers;
  final String title;
  final CourseLeader? leader;

  @override
  State<TeamSelectScreen> createState() => _TeamSelectScreenState();
}

class _TeamSelectScreenState extends State<TeamSelectScreen> {
  final List<int> _selectedDex = [];
  String _search = '';

  static const int _maxTeamSize = 3;

  List<BogeybeastSpecies> get _filtered {
    final q = _search.toLowerCase();
    return firstGenBogeybeast.where((p) {
      if (!widget.caughtDexNumbers.contains(p.dexNumber)) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.dexNumber.toString().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canConfirm = _selectedDex.length == _maxTeamSize;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(
            onPressed: canConfirm
                ? () => Navigator.of(context).pop(
                      _selectedDex.map(BattleBogeybeast.fromDexNumber).toList(),
                    )
                : null,
            child: Text(
              'Done (${_selectedDex.length}/$_maxTeamSize)',
              style: TextStyle(
                color: canConfirm
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // vs gym leader banner — always visible when challenging a leader
          if (widget.leader != null)
            _VsLeaderBanner(leader: widget.leader!),

          // Selected team preview — always visible so the layout doesn't jump
          Container(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text('Team: ',
                    style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                for (final dex in _selectedDex)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _MiniBogeybeastChip(
                      dex: dex,
                      onRemove: () => setState(() => _selectedDex.remove(dex)),
                    ),
                  ),
                for (int i = _selectedDex.length; i < _maxTeamSize; i++)
                  Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(Icons.add,
                        size: 16,
                        color: theme.colorScheme.outlineVariant),
                  ),
              ],
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search Bogeybeast...',
                prefixIcon: Icon(Icons.search, size: 20),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),

          // List
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      widget.caughtDexNumbers.isEmpty
                          ? 'Catch some Bogeybeast first!'
                          : 'No Bogeybeast match your search.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final species = _filtered[i];
                      final isSelected =
                          _selectedDex.contains(species.dexNumber);
                      final isFull = _selectedDex.length >= _maxTeamSize;

                      return _BogeybeastSelectTile(
                        species:    species,
                        isSelected: isSelected,
                        disabled:   isFull && !isSelected,
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedDex.remove(species.dexNumber);
                            } else if (!isFull) {
                              _selectedDex.add(species.dexNumber);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── _VsLeaderBanner ──────────────────────────────────────────────────────────

class _VsLeaderBanner extends StatelessWidget {
  const _VsLeaderBanner({required this.leader});
  final CourseLeader leader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = teamColor(GolferTeam.fromDb(leader.golferTeam));

    return Container(
      width: double.infinity,
      color: color.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Sprite
          _LeaderSprite(sprite: leader.golferSprite, color: color),
          const SizedBox(width: 12),
          // Name + team beasts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  leader.leaderName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                if (leader.team.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      for (final b in leader.team.take(3))
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: Image.network(
                              b.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  Icon(Icons.pets, size: 20, color: color.withValues(alpha: 0.4)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Text(
            'vs',
            style: theme.textTheme.labelLarge?.copyWith(
              color: color.withValues(alpha: 0.4),
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderSprite extends StatelessWidget {
  const _LeaderSprite({required this.sprite, required this.color});
  final String? sprite;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (sprite != null) {
      return SizedBox(
        width: 40,
        height: 40,
        child: Image.network(
          sprite!,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() => Icon(Icons.shield_rounded, color: color, size: 36);
}

// ── _BogeybeastSelectTile ────────────────────────────────────────────────────────

class _BogeybeastSelectTile extends StatelessWidget {
  const _BogeybeastSelectTile({
    required this.species,
    required this.isSelected,
    required this.disabled,
    required this.onTap,
  });

  final BogeybeastSpecies species;
  final bool isSelected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Opacity(
      opacity: disabled ? 0.35 : 1.0,
      child: InkWell(
        onTap: disabled ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Sprite
              SizedBox(
                width: 48,
                height: 48,
                child: Image.network(
                  species.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.pets, size: 32),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '#${species.paddedDexNumber}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(species.name,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: species.types
                          .map((t) => Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: _TypeBadge(type: t),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              // Stats preview
              _StatsPill(dex: species.dexNumber),
              const SizedBox(width: 12),
              // Selection indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── _StatsPill ────────────────────────────────────────────────────────────────

class _StatsPill extends StatelessWidget {
  const _StatsPill({required this.dex});
  final int dex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = firstGenBogeybeast.firstWhere((s) => s.dexNumber == dex);
    // We only have access to the species here, stats are in bogeybeastBattleStats.
    // Import lazily to avoid bloat.
    // Show type as a small color dot instead.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.arrow_upward, size: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
        Text(
          _offenseLabel(p.dexNumber),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(width: 6),
        Icon(Icons.shield_outlined, size: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
        Text(
          _defenseLabel(p.dexNumber),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }

  String _offenseLabel(int dex) {
    // Import inline to avoid circular dep issues at top level.
    // ignore: implementation_imports
    final stats = _statsFor(dex);
    return '${stats.$1}';
  }

  String _defenseLabel(int dex) {
    final stats = _statsFor(dex);
    return '${stats.$2}';
  }

  (int, int) _statsFor(int dex) {
    // Inline lookup to avoid import issues in widget file.
    const offenses = <int, int>{
      1:3,2:5,3:7,4:3,5:5,6:8,7:3,8:5,9:7,10:1,11:1,12:4,13:1,14:1,15:6,
      16:2,17:4,18:6,19:3,20:6,21:3,22:6,23:3,24:5,25:5,26:7,27:3,28:6,
      29:3,30:4,31:7,32:3,33:5,34:7,35:3,36:5,37:3,38:6,39:3,40:5,41:2,
      42:5,43:3,44:4,45:6,46:3,47:5,48:3,49:5,50:4,51:7,52:3,53:6,54:4,
      55:6,56:5,57:7,58:5,59:8,60:2,61:4,62:6,63:7,64:9,65:10,66:5,67:7,
      68:9,69:4,70:6,71:8,72:3,73:6,74:4,75:6,76:7,77:5,78:7,79:3,80:7,
      81:4,82:7,83:4,84:6,85:8,86:2,87:5,88:4,89:6,90:3,91:6,92:6,93:8,
      94:9,95:2,96:4,97:6,98:6,99:9,100:4,101:6,102:4,103:9,104:4,105:7,
      106:8,107:7,108:3,109:4,110:6,111:5,112:8,113:1,114:4,115:6,116:4,
      117:6,118:4,119:6,120:5,121:8,122:6,123:8,124:7,125:7,126:7,127:8,
      128:7,129:1,130:9,131:7,132:5,133:4,134:7,135:8,136:9,137:5,138:4,
      139:7,140:5,141:8,142:8,143:7,144:8,145:9,146:9,147:4,148:6,149:10,
      150:10,151:8,
    };
    const defenses = <int, int>{
      1:4,2:5,3:7,4:3,5:4,6:6,7:5,8:6,9:8,10:2,11:4,12:4,13:2,14:4,15:3,
      16:3,17:4,18:5,19:2,20:4,21:2,22:4,23:3,24:5,25:3,26:5,27:5,28:7,
      29:3,30:5,31:7,32:2,33:4,34:6,35:4,36:6,37:3,38:6,39:2,40:3,41:3,
      42:5,43:4,44:5,45:6,46:3,47:6,48:3,49:4,50:1,51:2,52:2,53:4,54:3,
      55:5,56:2,57:4,58:3,59:6,60:3,61:5,62:7,63:1,64:2,65:2,66:4,67:5,
      68:6,69:2,70:3,71:5,72:5,73:7,74:6,75:7,76:8,77:4,78:5,79:5,80:8,
      81:4,82:6,83:4,84:2,85:4,86:4,87:6,88:4,89:6,90:7,91:10,92:1,93:2,
      94:3,95:10,96:4,97:6,98:5,99:7,100:4,101:5,102:4,103:6,104:6,105:7,
      106:4,107:7,108:5,109:7,110:9,111:6,112:8,113:8,114:7,115:6,116:4,
      117:6,118:4,119:5,120:4,121:7,122:6,123:6,124:3,125:6,126:5,127:7,
      128:7,129:1,130:7,131:7,132:5,133:4,134:7,135:5,136:6,137:5,138:7,
      139:8,140:7,141:7,142:5,143:7,144:8,145:8,146:7,147:4,148:6,149:8,
      150:9,151:8,
    };
    return (offenses[dex] ?? 5, defenses[dex] ?? 5);
  }
}

// ── _MiniBogeybeastChip ──────────────────────────────────────────────────────────

class _MiniBogeybeastChip extends StatelessWidget {
  const _MiniBogeybeastChip({required this.dex, required this.onRemove});
  final int dex;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final species = firstGenBogeybeast.firstWhere((p) => p.dexNumber == dex);

    return GestureDetector(
      onTap: onRemove,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primaryContainer,
        ),
        child: ClipOval(
          child: Image.network(
            species.imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.pets, size: 20),
          ),
        ),
      ),
    );
  }
}

// ── _TypeBadge ────────────────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final BogeybeastType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _typeColor(type).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _typeColor(type).withValues(alpha: 0.5), width: 0.5),
      ),
      child: Text(
        _typeName(type),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _typeColor(type),
        ),
      ),
    );
  }

  String _typeName(BogeybeastType t) {
    return t.name[0].toUpperCase() + t.name.substring(1);
  }

  Color _typeColor(BogeybeastType t) {
    return switch (t) {
      BogeybeastType.fire     => const Color(0xFFFF6B35),
      BogeybeastType.water    => const Color(0xFF4FC3F7),
      BogeybeastType.grass    => const Color(0xFF66BB6A),
      BogeybeastType.electric => const Color(0xFFFFD700),
      BogeybeastType.ice      => const Color(0xFF80DEEA),
      BogeybeastType.fighting => const Color(0xFFEF5350),
      BogeybeastType.poison   => const Color(0xFFAB47BC),
      BogeybeastType.ground   => const Color(0xFFD4A853),
      BogeybeastType.flying   => const Color(0xFF90CAF9),
      BogeybeastType.psychic  => const Color(0xFFF48FB1),
      BogeybeastType.bug      => const Color(0xFFA5D6A7),
      BogeybeastType.rock     => const Color(0xFFBCAAA4),
      BogeybeastType.ghost    => const Color(0xFF9575CD),
      BogeybeastType.dragon   => const Color(0xFF7986CB),
      BogeybeastType.fairy    => const Color(0xFFF8BBD0),
      BogeybeastType.normal   => const Color(0xFF9E9E9E),
    };
  }
}
