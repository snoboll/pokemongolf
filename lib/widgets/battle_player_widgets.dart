import 'package:flutter/material.dart';

import '../app.dart';
import '../models/battle_models.dart';
import '../services/supabase_service.dart';
import 'white_bg_image.dart';

class BattlePlayerAvatar extends StatelessWidget {
  const BattlePlayerAvatar({
    super.key,
    required this.name,
    this.userId,
    this.sprite,
    this.size = 44,
    this.isMe = false,
  });

  final String name;
  final String? userId;
  final String? sprite;
  final double size;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final store = BogeybeastGolfScope.of(context);
    final currentUserId = SupabaseService().currentUserId;
    final localSprite = userId != null && userId == currentUserId
        ? store.golferSprite
        : null;
    final resolvedSprite = sprite ?? localSprite;

    if (resolvedSprite != null) {
      return _AvatarFrame(
        size: size,
        isMe: isMe,
        child: WhiteBgImage(
          asset: resolvedSprite,
          width: size,
          height: size,
          placeholder: _FallbackAvatar(name: name, size: size),
        ),
      );
    }

    if (userId == null) {
      return _AvatarFrame(
        size: size,
        isMe: isMe,
        child: _FallbackAvatar(name: name, size: size),
      );
    }

    return FutureBuilder<String?>(
      future: SupabaseService().fetchGolferSpriteForUser(userId!),
      builder: (context, snapshot) {
        final fetchedSprite = snapshot.data;
        return _AvatarFrame(
          size: size,
          isMe: isMe,
          child: fetchedSprite == null
              ? _FallbackAvatar(name: name, size: size)
              : WhiteBgImage(
                  asset: fetchedSprite,
                  width: size,
                  height: size,
                  placeholder: _FallbackAvatar(name: name, size: size),
                ),
        );
      },
    );
  }
}

class BattleTeamPreview extends StatelessWidget {
  const BattleTeamPreview({
    super.key,
    required this.team,
    this.size = 34,
    this.showHp = false,
  });

  final List<BattleBogeybeast> team;
  final double size;
  final bool showHp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (team.isEmpty) {
      return Text(
        'No team yet',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: team
          .take(3)
          .map(
            (bogeybeast) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Opacity(
                opacity: bogeybeast.isAlive ? 1 : 0.38,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: size,
                      height: size,
                      padding: EdgeInsets.all(size * 0.08),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size * 0.22),
                        color: theme.colorScheme.surfaceContainerHighest,
                        border: Border.all(
                          color: bogeybeast.isAlive
                              ? theme.colorScheme.primary.withValues(
                                  alpha: 0.35,
                                )
                              : theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Image.asset(
                        bogeybeast.assetPath,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.pets, size: 18),
                      ),
                    ),
                    if (showHp) ...[
                      const SizedBox(height: 3),
                      SizedBox(
                        width: size,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: bogeybeast.hpPercent.clamp(0.0, 1.0),
                            minHeight: 3,
                            backgroundColor: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.45),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              bogeybeast.isAlive
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _AvatarFrame extends StatelessWidget {
  const _AvatarFrame({
    required this.size,
    required this.isMe,
    required this.child,
  });

  final double size;
  final bool isMe;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isMe ? theme.colorScheme.primary : const Color(0xFFFFD700);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({required this.name, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Center(
      child: Text(
        initial,
        style: TextStyle(fontSize: size * 0.42, fontWeight: FontWeight.w900),
      ),
    );
  }
}
