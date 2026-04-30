import 'package:flutter/material.dart';

/// Displays a golfer asset image with a fallback placeholder.
class WhiteBgImage extends StatelessWidget {
  const WhiteBgImage({
    super.key,
    required this.asset,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.placeholder,
  });

  final String asset;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => SizedBox(
        width: width,
        height: height,
        child: placeholder ?? const SizedBox.shrink(),
      ),
    );
  }
}
