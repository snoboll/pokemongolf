import 'package:flutter/material.dart';

class PokemonArt extends StatelessWidget {
  const PokemonArt({
    super.key,
    required this.imageUrl,
    this.height = 200,
    this.fit = BoxFit.contain,
  });

  final String imageUrl;
  final double height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Image.network(
        imageUrl,
        fit: fit,
        loadingBuilder: (
          BuildContext context,
          Widget child,
          ImageChunkEvent? loadingProgress,
        ) {
          if (loadingProgress == null) {
            return child;
          }

          return Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
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
