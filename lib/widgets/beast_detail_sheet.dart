import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app.dart';
import '../data/bogeybeast_battle_stats.dart';
import '../data/evolution_chains.dart';
import '../data/first_gen_bogeybeasts.dart';
import '../models/bogeybeast_rarity.dart';
import '../models/bogeybeast_species.dart';
import '../models/bogeybeast_type.dart';
import 'bogeybeast_art.dart';

void showBeastDetailSheet(BuildContext context, BogeybeastSpecies beast, {VoidCallback? onRelease}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => BeastDetailSheet(bogeybeast: beast, onRelease: onRelease),
  );
}

class BeastDetailSheet extends StatelessWidget {
  const BeastDetailSheet({super.key, required this.bogeybeast, this.onRelease});

  final BogeybeastSpecies bogeybeast;
  final VoidCallback? onRelease;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = bogeybeastBattleStats[bogeybeast.dexNumber];
    final chain = evolutionChainFor(bogeybeast.dexNumber);
    final store = BogeybeastGolfScope.of(context);
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + safeBottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '#${bogeybeast.paddedDexNumber}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Text(bogeybeast.name,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              BeastRarityBadge(rarity: bogeybeast.rarity),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: bogeybeast.types.map((t) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: BeastTypeChip(type: t),
            )).toList(),
          ),
          if (bogeybeast.flavorText != null) ...[
            const SizedBox(height: 12),
            Text(
              bogeybeast.flavorText!,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.4,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ],
          if (chain != null) ...[
            const SizedBox(height: 12),
            BeastEvolutionChain(
              chain: chain,
              currentDex: bogeybeast.dexNumber,
              caughtDex: store.caughtDexNumbers,
              seenDex: store.seenDexNumbers,
              allSpecies: firstGenBogeybeast,
            ),
          ],
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 4,
                  child: Center(
                    child: BogeybeastArt(assetPath: bogeybeast.assetPath, height: 160),
                  ),
                ),
                if (stats != null)
                  Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 180,
                          child: BeastStatsDiamondChart(
                            hp: stats.hp,
                            attack: stats.offense,
                            defense: stats.defense,
                            theme: theme,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            BeastStatLabel(label: 'HP',  value: stats.hp,      color: const Color(0xFFEF5350)),
                            BeastStatLabel(label: 'Atk', value: stats.offense,  color: const Color(0xFFFF9800)),
                            BeastStatLabel(label: 'Def', value: stats.defense,  color: const Color(0xFF42A5F5)),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (onRelease != null) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRelease,
              icon: Icon(Icons.remove_circle_outline, color: theme.colorScheme.error),
              label: Text('Release', style: TextStyle(color: theme.colorScheme.error)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class BeastStatLabel extends StatelessWidget {
  const BeastStatLabel({super.key, required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text('$value / 10',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: color)),
        Text(label,
            style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
      ],
    );
  }
}

class BeastRarityBadge extends StatelessWidget {
  const BeastRarityBadge({super.key, required this.rarity});
  final BogeybeastRarity rarity;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (rarity) {
      BogeybeastRarity.common    => ('Common',    const Color(0xFF9E9E9E)),
      BogeybeastRarity.uncommon  => ('Uncommon',  const Color(0xFF26A69A)),
      BogeybeastRarity.rare      => ('Rare',      const Color(0xFF1E88E5)),
      BogeybeastRarity.epic      => ('Epic',      const Color(0xFF8E24AA)),
      BogeybeastRarity.legendary => ('Legendary', const Color(0xFFFFB300)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class BeastTypeChip extends StatelessWidget {
  const BeastTypeChip({super.key, required this.type});
  final BogeybeastType type;

  static Color color(BogeybeastType t) => switch (t) {
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
    BogeybeastType.dark     => const Color(0xFF90A4AE),
    BogeybeastType.fairy    => const Color(0xFFF8BBD0),
    BogeybeastType.normal   => const Color(0xFF9E9E9E),
  };

  @override
  Widget build(BuildContext context) {
    final c = color(type);
    final name = type.name[0].toUpperCase() + type.name.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.withValues(alpha: 0.5)),
      ),
      child: Text(name,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c)),
    );
  }
}

class BeastStatsDiamondChart extends StatelessWidget {
  const BeastStatsDiamondChart({
    super.key,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.theme,
  });

  final int hp;
  final int attack;
  final int defense;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DiamondPainter(
        hp: hp / 10,
        attack: attack / 10,
        defense: defense / 10,
        gridColor: theme.colorScheme.onSurface.withValues(alpha: 0.25),
        hpColor: const Color(0xFFEF5350),
        attackColor: const Color(0xFFFF9800),
        defenseColor: const Color(0xFF42A5F5),
        fillColor: theme.colorScheme.primary.withValues(alpha: 0.18),
        strokeColor: theme.colorScheme.primary.withValues(alpha: 0.7),
      ),
      size: Size.infinite,
    );
  }
}

class DiamondPainter extends CustomPainter {
  DiamondPainter({
    required this.hp,
    required this.attack,
    required this.defense,
    required this.gridColor,
    required this.hpColor,
    required this.attackColor,
    required this.defenseColor,
    required this.fillColor,
    required this.strokeColor,
  });

  final double hp;
  final double attack;
  final double defense;
  final Color gridColor;
  final Color hpColor;
  final Color attackColor;
  final Color defenseColor;
  final Color fillColor;
  final Color strokeColor;

  static const double _s60 = 0.8660254;
  static const double _c60 = 0.5;

  Offset _hp(Offset c, double r, double t)  => c + Offset(0,         -r * t);
  Offset _atk(Offset c, double r, double t) => c + Offset(-_s60 * r * t,  _c60 * r * t);
  Offset _def(Offset c, double r, double t) => c + Offset( _s60 * r * t,  _c60 * r * t);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) * 0.36;

    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final t in [0.33, 0.66, 1.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(_hp(c, r, t).dx,  _hp(c, r, t).dy)
          ..lineTo(_atk(c, r, t).dx, _atk(c, r, t).dy)
          ..lineTo(_def(c, r, t).dx, _def(c, r, t).dy)
          ..close(),
        gridPaint,
      );
    }
    for (final pt in [_hp(c, r, 1), _atk(c, r, 1), _def(c, r, 1)]) {
      canvas.drawLine(c, pt, gridPaint);
    }

    final hpPt  = _hp(c, r, hp);
    final atkPt = _atk(c, r, attack);
    final defPt = _def(c, r, defense);

    final poly = Path()
      ..moveTo(hpPt.dx,  hpPt.dy)
      ..lineTo(atkPt.dx, atkPt.dy)
      ..lineTo(defPt.dx, defPt.dy)
      ..close();

    canvas.drawPath(poly, Paint()..color = fillColor);
    canvas.drawPath(poly,
        Paint()..color = strokeColor..style = PaintingStyle.stroke..strokeWidth = 2.0);

    void dot(Offset pt, Color col) {
      canvas.drawCircle(pt, 5.5, Paint()..color = col.withValues(alpha: 0.25));
      canvas.drawCircle(pt, 3.5, Paint()..color = col);
    }
    dot(hpPt, hpColor);
    dot(atkPt, attackColor);
    dot(defPt, defenseColor);

    void label(String text, Offset anchor, Color col, {bool left = false, bool right = false}) {
      final tp = TextPainter(
        text: TextSpan(text: text,
            style: TextStyle(color: col, fontSize: 12, fontWeight: FontWeight.w700)),
        textDirection: TextDirection.ltr,
      )..layout();
      double dx, dy;
      if (right)      { dx = anchor.dx + 10; dy = anchor.dy - tp.height / 2; }
      else if (left)  { dx = anchor.dx - tp.width - 10; dy = anchor.dy - tp.height / 2; }
      else            { dx = anchor.dx - tp.width / 2;  dy = anchor.dy - tp.height - 8; }
      tp.paint(canvas, Offset(dx, dy));
    }

    label('HP',      _hp(c, r, 1),  hpColor);
    label('Attack',  _atk(c, r, 1), attackColor,  left: true);
    label('Defense', _def(c, r, 1), defenseColor, right: true);
  }

  @override
  bool shouldRepaint(DiamondPainter old) =>
      old.hp != hp || old.attack != attack || old.defense != defense;
}

class BeastEvolutionChain extends StatelessWidget {
  const BeastEvolutionChain({
    super.key,
    required this.chain,
    required this.currentDex,
    required this.caughtDex,
    required this.seenDex,
    required this.allSpecies,
  });

  final List<List<int>> chain;
  final int currentDex;
  final Set<int> caughtDex;
  final Set<int> seenDex;
  final List<BogeybeastSpecies> allSpecies;

  BogeybeastSpecies? _species(int dex) {
    try { return allSpecies.firstWhere((s) => s.dexNumber == dex); }
    catch (_) { return null; }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dim = theme.colorScheme.onSurface.withValues(alpha: 0.35);
    final List<Widget> stageWidgets = [];

    for (int i = 0; i < chain.length; i++) {
      if (i > 0) {
        stageWidgets.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.arrow_forward_ios_rounded, size: 12, color: dim),
        ));
      }
      final stage = chain[i];
      if (stage.length == 1) {
        stageWidgets.add(BeastEvoNode(
          dex: stage[0], species: _species(stage[0]),
          isCurrent: stage[0] == currentDex,
          isCaught: caughtDex.contains(stage[0]),
          isSeen: seenDex.contains(stage[0]),
          theme: theme,
        ));
      } else {
        stageWidgets.add(Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int j = 0; j < stage.length; j++) ...[
              if (j > 0) const SizedBox(height: 4),
              BeastEvoNode(
                dex: stage[j], species: _species(stage[j]),
                isCurrent: stage[j] == currentDex,
                isCaught: caughtDex.contains(stage[j]),
                isSeen: seenDex.contains(stage[j]),
                theme: theme,
              ),
            ],
          ],
        ));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: stageWidgets,
    );
  }
}

class BeastEvoNode extends StatelessWidget {
  const BeastEvoNode({
    super.key,
    required this.dex,
    required this.species,
    required this.isCurrent,
    required this.isCaught,
    required this.isSeen,
    required this.theme,
  });

  final int dex;
  final BogeybeastSpecies? species;
  final bool isCurrent;
  final bool isCaught;
  final bool isSeen;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final color = isCurrent
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final unknownColor = theme.colorScheme.onSurface.withValues(alpha: 0.35);
    final seenColor = theme.colorScheme.onSurface.withValues(alpha: 0.5);

    final assetPath = species?.assetPath ??
        'assets/bogeybeasts_imgs/${dex.toString().padLeft(3, '0')}.png';

    final Widget sprite;
    if (isCaught) {
      sprite = SizedBox(
        width: 44, height: 44,
        child: Image.asset(assetPath, fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(Icons.pets, size: 28, color: color)),
      );
    } else if (isSeen) {
      sprite = SizedBox(
        width: 44, height: 44,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0,      0,      0,      1, 0,
          ]),
          child: Image.asset(assetPath, fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(Icons.pets, size: 28, color: seenColor)),
        ),
      );
    } else {
      sprite = Icon(Icons.question_mark_rounded, size: 24, color: unknownColor);
    }

    final label = (isCaught || isSeen) ? (species?.name ?? '#$dex') : '???';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCurrent
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            border: Border.all(
              color: isCurrent
                  ? theme.colorScheme.primary.withValues(alpha: 0.5)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.25),
              width: isCurrent ? 1.5 : 1.0,
            ),
          ),
          child: Center(child: sprite),
        ),
        const SizedBox(height: 3),
        Text(label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isCaught ? color : isSeen ? seenColor : unknownColor,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}
