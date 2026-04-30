import 'package:flutter/material.dart';

import '../app.dart';
import '../data/golfer_tags.dart';
import '../models/golfer_team.dart';
import '../state/bogeybeasts_golf_store.dart';
import '../widgets/white_bg_image.dart';
import 'history_screen.dart';
import 'my_bag_screen.dart';

const List<({String asset, String label})> _availableSprites = [
  (asset: 'assets/golfers/male/transparent_bg/ace.png',          label: 'Ace ♂'),
  (asset: 'assets/golfers/female/transparent_bg/ace.png',        label: 'Ace ♀'),
  (asset: 'assets/golfers/male/transparent_bg/chipper.png',      label: 'Chipper ♂'),
  (asset: 'assets/golfers/female/transparent_bg/chipper.png',    label: 'Chipper ♀'),
  (asset: 'assets/golfers/male/transparent_bg/drawer.png',       label: 'Drawer ♂'),
  (asset: 'assets/golfers/female/transparent_bg/drawer.png',     label: 'Drawer ♀'),
  (asset: 'assets/golfers/male/transparent_bg/slicer.png',       label: 'Slicer ♂'),
  (asset: 'assets/golfers/female/transparent_bg/slicer.png',     label: 'Slicer ♀'),
  (asset: 'assets/golfers/male/transparent_bg/hooker.png',       label: 'Hooker ♂'),
  (asset: 'assets/golfers/female/transparent_bg/hooker.png',     label: 'Hooker ♀'),
  (asset: 'assets/golfers/male/transparent_bg/flyer.png',        label: 'Flyer ♂'),
  (asset: 'assets/golfers/female/transparent_bg/flyer.png',      label: 'Flyer ♀'),
  (asset: 'assets/golfers/male/transparent_bg/fisher.png',       label: 'Fisher ♂'),
  (asset: 'assets/golfers/female/transparent_bg/fisher.png',     label: 'Fisher ♀'),
  (asset: 'assets/golfers/male/transparent_bg/longdriver.png',   label: 'Longdriver ♂'),
  (asset: 'assets/golfers/female/transparent_bg/longdriver.png', label: 'Longdriver ♀'),
  (asset: 'assets/golfers/male/transparent_bg/hotshot.png',      label: 'Hotshot ♂'),
  (asset: 'assets/golfers/female/transparent_bg/hotshot.png',    label: 'Hotshot ♀'),
  (asset: 'assets/golfers/male/transparent_bg/roughrunner.png',  label: 'Roughrunner ♂'),
  (asset: 'assets/golfers/female/transparent_bg/roughrunner.png',label: 'Roughrunner ♀'),
  (asset: 'assets/golfers/male/transparent_bg/bunkerdigger.png', label: 'Bunkerboy ♂'),
  (asset: 'assets/golfers/female/transparent_bg/bunkerdigger.png',label: 'Bunkerboy ♀'),
  (asset: 'assets/golfers/male/transparent_bg/greenkeeper.png',  label: 'Greenkeeper ♂'),
  (asset: 'assets/golfers/female/transparent_bg/greenkeeper.png',label: 'Greenkeeper ♀'),
  (asset: 'assets/golfers/male/transparent_bg/psycher.png',      label: 'Psych ♂'),
  (asset: 'assets/golfers/female/transparent_bg/psycher.png',    label: 'Psych ♀'),
  (asset: 'assets/golfers/male/transparent_bg/manager.png',      label: 'Manager ♂'),
  (asset: 'assets/golfers/female/transparent_bg/manager.png',    label: 'Manager ♀'),
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
                  children: [
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
                      clipBehavior: Clip.antiAlias,
                      child: store.golferSprite != null
                          ? WhiteBgImage(
                              asset: store.golferSprite!,
                              width: 96,
                              height: 96,
                              placeholder: Icon(
                                Icons.sports_golf_rounded,
                                size: 48,
                                color: accentColor,
                              ),
                            )
                          : Icon(
                              Icons.sports_golf_rounded,
                              size: 48,
                              color: accentColor,
                            ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, size: 13,
                            color: theme.colorScheme.primary.withValues(alpha: 0.6)),
                        const SizedBox(width: 4),
                        Text(
                          store.golferSprite != null ? 'Change avatar' : 'Choose avatar',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary.withValues(alpha: 0.6),
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
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SpritePicker(current: store.golferSprite),
    ).then((selected) {
      if (selected != null) {
        store.setGolferSprite(selected.isEmpty ? null : selected);
      }
    });
  }
}

class _SpritePicker extends StatelessWidget {
  const _SpritePicker({this.current});
  final String? current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      expand: false,
      builder: (ctx, scroll) => Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 4),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('Choose Avatar',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: GridView.builder(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: _availableSprites.length,
              itemBuilder: (ctx, i) {
                final entry = _availableSprites[i];
                final isSelected = current == entry.asset;
                return GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(entry.asset),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? theme.colorScheme.primary.withValues(alpha: 0.12)
                              : theme.colorScheme.surfaceContainerHighest,
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                            width: isSelected ? 2.5 : 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: WhiteBgImage(
                          asset: entry.asset,
                          width: 64,
                          height: 64,
                          placeholder: const Icon(Icons.sports_golf_rounded),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: isSelected ? FontWeight.w700 : null,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
