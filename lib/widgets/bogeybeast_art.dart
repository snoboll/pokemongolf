import 'package:flutter/material.dart';

class BogeybeastArt extends StatelessWidget {
  const BogeybeastArt({
    super.key,
    required this.assetPath,
    this.height = 200,
    this.fit = BoxFit.contain,
  });

  final String assetPath;
  final double height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Image.asset(
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
      ),
    );
  }
}
