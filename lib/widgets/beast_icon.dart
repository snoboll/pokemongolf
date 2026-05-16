import 'package:flutter/material.dart';

class BeastIcon extends StatelessWidget {
  const BeastIcon({super.key, this.size = 24});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/goodlogo_no_bg.png',
      width: size,
      height: size,
    );
  }
}

class DexIcon extends StatelessWidget {
  const DexIcon({super.key, this.size = 24});
  final double size;

  @override
  Widget build(BuildContext context) {
    final color =
        IconTheme.of(context).color ?? Theme.of(context).colorScheme.primary;

    return Icon(Icons.menu_book_rounded, size: size, color: color);
  }
}
