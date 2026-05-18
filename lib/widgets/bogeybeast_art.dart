import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Luminance-preserving hue-rotation color matrix, used to recolor shiny
/// Bogeybeast art without needing separate sprites.
List<double> _hueRotationMatrix(double degrees) {
  final double rad = degrees * math.pi / 180.0;
  final double c = math.cos(rad);
  final double s = math.sin(rad);
  return <double>[
    0.213 + c * 0.787 - s * 0.213,
    0.715 - c * 0.715 - s * 0.715,
    0.072 - c * 0.072 + s * 0.928,
    0, 0,
    0.213 - c * 0.213 + s * 0.143,
    0.715 + c * 0.285 + s * 0.140,
    0.072 - c * 0.072 - s * 0.283,
    0, 0,
    0.213 - c * 0.213 - s * 0.787,
    0.715 - c * 0.715 + s * 0.715,
    0.072 + c * 0.928 + s * 0.072,
    0, 0,
    0, 0, 0, 1, 0,
  ];
}

final ColorFilter _shinyColorFilter =
    ColorFilter.matrix(_hueRotationMatrix(150));

class BogeybeastArt extends StatelessWidget {
  const BogeybeastArt({
    super.key,
    required this.assetPath,
    this.height = 200,
    this.fit = BoxFit.contain,
    this.shiny = false,
  });

  final String assetPath;
  final double height;
  final BoxFit fit;
  final bool shiny;

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      assetPath,
      fit: fit,
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) {
        return Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 36,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        );
      },
    );

    if (!shiny) {
      return SizedBox(height: height, child: image);
    }

    final double sparkleSize = (height * 0.18).clamp(14.0, 28.0);
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: _shinyColorFilter,
              child: image,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Icon(
              Icons.auto_awesome,
              size: sparkleSize,
              color: const Color(0xFFFFD54F),
              shadows: const <Shadow>[
                Shadow(color: Color(0x99000000), blurRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
