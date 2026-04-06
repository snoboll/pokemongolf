import 'package:flutter/material.dart';

class PokeballCaughtBadge extends StatelessWidget {
  const PokeballCaughtBadge({super.key, required this.caught});
  final bool caught;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (caught) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Icon(Icons.catching_pokemon, size: 18,
            color: theme.colorScheme.primary),
      );
    }
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.7),
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Icon(Icons.catching_pokemon, size: 18,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.25)),
    );
  }
}

ColorFilter grayscaleColorFilter(double amount) {
  final double sr = 0.2126 * amount;
  final double sg = 0.7152 * amount;
  final double sb = 0.0722 * amount;
  final double c = 1.0 - amount;
  return ColorFilter.matrix(<double>[
    sr + c, sg,     sb,     0, 0,
    sr,     sg + c, sb,     0, 0,
    sr,     sg,     sb + c, 0, 0,
    0,      0,      0,      1, 0,
  ]);
}
