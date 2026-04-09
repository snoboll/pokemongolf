import 'package:flutter/material.dart';

import '../app.dart';
import '../data/trainer_tags.dart';
import '../state/pokemon_golf_store.dart';
import 'history_screen.dart';
import 'my_bag_screen.dart';

const List<({String asset, String label})> _availableSprites = [
  (asset: 'assets/trainers/red-lgpe.png',           label: 'Red'),
  (asset: 'assets/trainers/blue-lgpe.png',          label: 'Blue'),
  (asset: 'assets/trainers/ethan.png',              label: 'Ethan'),
  (asset: 'assets/trainers/dawn.png',               label: 'Dawn'),
  (asset: 'assets/trainers/brendan-rs.png',         label: 'Brendan'),
  (asset: 'assets/trainers/acetrainer.png',         label: 'Ace Trainer'),
  (asset: 'assets/trainers/acetrainer-gen1.png',    label: 'Ace Trainer ♂'),
  (asset: 'assets/trainers/acetrainerf-gen1.png',   label: 'Ace Trainer ♀'),
  (asset: 'assets/trainers/youngster-gen1.png',     label: 'Youngster'),
  (asset: 'assets/trainers/lass-gen1.png',          label: 'Lass'),
  (asset: 'assets/trainers/bugcatcher-gen1.png',    label: 'Bug Catcher'),
  (asset: 'assets/trainers/fisherman-gen1.png',     label: 'Fisherman'),
  (asset: 'assets/trainers/hiker-gen1.png',         label: 'Hiker'),
  (asset: 'assets/trainers/blackbelt-gen1.png',     label: 'Black Belt'),
  (asset: 'assets/trainers/birdkeeper-gen1.png',    label: 'Bird Keeper'),
  (asset: 'assets/trainers/sailor-gen1.png',        label: 'Sailor'),
  (asset: 'assets/trainers/camper.png',             label: 'Camper'),
  (asset: 'assets/trainers/gambler-gen1.png',       label: 'Gambler'),
  (asset: 'assets/trainers/scientist-gen1.png',     label: 'Scientist'),
  (asset: 'assets/trainers/channeler-gen1.png',     label: 'Channeler'),
  (asset: 'assets/trainers/teamrocket.png',         label: 'Team Rocket'),
];

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PokemonGolfScope.of(context);
    final theme = Theme.of(context);
    final String? tag = trainerTagForCaughtDex(store.caughtDexNumbers);

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
                        color: theme.colorScheme.primary.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: store.trainerSprite != null
                          ? ClipOval(
                              child: OverflowBox(
                                maxWidth: 96 * 1.4,
                                maxHeight: 96 * 1.4,
                                child: Image.asset(
                                  store.trainerSprite!,
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
                          store.trainerSprite != null ? 'Change avatar' : 'Choose avatar',
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
            if (store.trainerName != null)
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      store.trainerName!,
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
              child: Text(
                'HCP ${store.playerHcp}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 28),
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

  void _showSpritePicker(BuildContext context, PokemonGolfStore store) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SpritePicker(
        current: store.trainerSprite,
        onSelected: (sprite) {
          store.setTrainerSprite(sprite);
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
            'Choose your Trainer',
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
