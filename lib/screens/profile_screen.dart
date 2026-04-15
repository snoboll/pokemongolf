import 'package:flutter/material.dart';

import '../app.dart';
import '../data/golfer_tags.dart';
import '../models/golfer_team.dart';
import '../state/bogeybeasts_golf_store.dart';
import 'history_screen.dart';
import 'my_bag_screen.dart';

const List<({String asset, String label})> _availableSprites = [
  (asset: 'assets/trainers/red-lgpe.png',           label: 'Red'),
  (asset: 'assets/trainers/blue-lgpe.png',          label: 'Blue'),
  (asset: 'assets/trainers/ethan.png',              label: 'Ethan'),
  (asset: 'assets/trainers/dawn.png',               label: 'Dawn'),
  (asset: 'assets/trainers/brendan-rs.png',         label: 'Brendan'),
  (asset: 'assets/trainers/acetrainer.png',         label: 'Ace Golfer'),
  (asset: 'assets/trainers/acetrainer-gen1.png',    label: 'Ace Golfer ♂'),
  (asset: 'assets/trainers/acetrainerf-gen1.png',   label: 'Ace Golfer ♀'),
  (asset: 'assets/trainers/youngster-gen1.png',     label: 'Chipper'),
  (asset: 'assets/trainers/lass-gen1.png',          label: 'Drawer'),
  (asset: 'assets/trainers/bugcatcher-gen1.png',    label: 'Roughrunner'),
  (asset: 'assets/trainers/fisherman-gen1.png',     label: 'Fisherman'),
  (asset: 'assets/trainers/hiker-gen1.png',         label: 'Bunkerboy'),
  (asset: 'assets/trainers/blackbelt-gen1.png',     label: 'Longdriver'),
  (asset: 'assets/trainers/birdkeeper-gen1.png',    label: 'Flyer'),
  (asset: 'assets/trainers/sailor-gen1.png',        label: 'Slicer'),
  (asset: 'assets/trainers/camper.png',             label: 'Greenkeeper'),
  (asset: 'assets/trainers/gambler-gen1.png',       label: 'Hotshot'),
  (asset: 'assets/trainers/scientist-gen1.png',     label: 'Club Manager'),
  (asset: 'assets/trainers/channeler-gen1.png',     label: 'Psych'),
  (asset: 'assets/trainers/teamrocket.png',         label: 'Hooker'),
];

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = BogeybeastGolfScope.of(context);
    final theme = Theme.of(context);
    final String? tag = golferTagForCaughtDex(store.caughtDexNumbers);
    final GolferTeam? currentTeam = GolferTeam.fromDb(store.golferTeam);
    final Color accentColor = teamColor(currentTeam);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Profile',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () => _showSpritePicker(context, store),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.5),
                          width: 2.5,
                        ),
                      ),
                      child: store.golferSprite != null
                          ? ClipOval(
                              child: OverflowBox(
                                maxWidth: 96 * 1.4,
                                maxHeight: 96 * 1.4,
                                child: Image.asset(
                                  store.golferSprite!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.person,
                                    size: 48,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 48,
                              color: theme.colorScheme.primary,
                            ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.edit,
                          size: 14,
                          color: theme.colorScheme.primary.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          store.golferSprite != null ? 'Change avatar' : 'Choose avatar',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (store.golferName != null)
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      store.golferName!,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (tag != null) ...<Widget>[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Center(
              child: GestureDetector(
                onTap: () => _showHcpEditor(context, store),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'HCP ${store.playerHcpDisplay}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.edit,
                      size: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _TeamSelector(
                current: currentTeam,
                canChange: store.canChangeTeam,
                daysLeft: store.daysUntilTeamChange,
                onChanged: (team) => _confirmTeamChange(context, store, team),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: <Widget>[
                  _ProfileMenuCard(
                    icon: Icons.scoreboard,
                    title: 'Scorecards',
                    subtitle: '${store.completedRounds.length} rounds played',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const HistoryScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _ProfileMenuCard(
                    icon: Icons.sports_golf,
                    title: 'My Bag',
                    subtitle: '${store.clubs.length + 1} clubs',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const MyBagScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmTeamChange(
      BuildContext context, BogeybeastGolfStore store, GolferTeam? team) async {
    if (team == null) {
      // Leaving a team — still confirm
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Leave team?'),
          content: const Text(
              'You won\'t be able to join another team for 30 days.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Leave')),
          ],
        ),
      );
      if (confirmed == true) {
        store.setGolferTeam(null);
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: Text('Join ${team.label}?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: team.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(team.icon, color: team.color, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'You won\'t be able to switch teams for 30 days.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel')),
            FilledButton(
                style: FilledButton.styleFrom(backgroundColor: team.color),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Join')),
          ],
        );
      },
    );
    if (confirmed == true) {
      store.setGolferTeam(team.dbValue);
    }
  }

  void _showHcpEditor(BuildContext context, BogeybeastGolfStore store) {
    final controller = TextEditingController(
      text: store.playerHcpDisplay,
    );
    final isOverride = store.hcpOverride != null;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: const Text('Set Handicap'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'HCP (0.0–54.0)',
                  border: const OutlineInputBorder(),
                  suffixIcon: isOverride
                      ? IconButton(
                          icon: const Icon(Icons.restart_alt),
                          tooltip: 'Reset to auto',
                          onPressed: () {
                            store.setHcpOverride(null);
                            Navigator.of(ctx).pop();
                          },
                        )
                      : null,
                ),
              ),
              if (isOverride)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Manually set. Tap ↻ to return to auto-calculated.',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final val = double.tryParse(controller.text.replaceAll(',', '.'));
                if (val != null && val >= 0 && val <= 54) {
                  store.setHcpOverride((val * 10).round() / 10.0);
                }
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showSpritePicker(BuildContext context, BogeybeastGolfStore store) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SpritePicker(
        current: store.golferSprite,
        onSelected: (sprite) {
          store.setGolferSprite(sprite);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }
}

class _SpritePicker extends StatelessWidget {
  const _SpritePicker({required this.current, required this.onSelected});

  final String? current;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, controller) => Column(
        children: <Widget>[
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Choose your Golfer',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: _availableSprites.length,
              itemBuilder: (_, i) {
                final entry = _availableSprites[i];
                final isSelected = entry.asset == current;
                return GestureDetector(
                  onTap: () => onSelected(entry.asset),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.15)
                          : theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : const Color(0xFF243024),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 52,
                          height: 52,
                          child: OverflowBox(
                            maxWidth: 52 * 1.4,
                            maxHeight: 52 * 1.4,
                            child: Image.asset(
                              entry.asset,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.broken_image,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            entry.label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamSelector extends StatelessWidget {
  const _TeamSelector({
    required this.current,
    required this.canChange,
    required this.daysLeft,
    required this.onChanged,
  });

  final GolferTeam? current;
  final bool canChange;
  final int daysLeft;
  final ValueChanged<GolferTeam?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locked = !canChange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: <Widget>[
              Text(
                'Team',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (locked) ...<Widget>[
                const SizedBox(width: 8),
                Icon(Icons.lock_outline, size: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.35)),
                const SizedBox(width: 4),
                Text(
                  '$daysLeft days left',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                  ),
                ),
              ],
            ],
          ),
        ),
        Row(
          children: GolferTeam.values.map((team) {
            final selected = team == current;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: team != GolferTeam.values.last ? 8 : 0,
                ),
                child: GestureDetector(
                  onTap: locked && !selected ? null : () => onChanged(selected ? null : team),
                  child: Opacity(
                    opacity: locked && !selected ? 0.35 : 1.0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: selected
                            ? team.color.withValues(alpha: 0.15)
                            : theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? team.color
                              : const Color(0xFF243024),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: team.color.withValues(alpha: selected ? 0.3 : 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: team == GolferTeam.socket
                                  ? Text(
                                      'S',
                                      style: TextStyle(
                                        color: team.color,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        height: 1,
                                      ),
                                    )
                                  : Icon(team.icon, size: 24, color: team.color),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            team.label,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                              color: selected
                                  ? team.color
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  const _ProfileMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF243024)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
