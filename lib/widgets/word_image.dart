import 'package:flutter/material.dart';

import '../core/utils/context_ext.dart';
import '../models/word.dart';

/// The picture for a word: a network image when [Word.imageUrl] is set,
/// otherwise its emoji on a tinted tile.
class WordImage extends StatelessWidget {
  const WordImage({super.key, required this.word, this.size = 48, this.color});

  final Word word;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.colors.primary;
    final radius = BorderRadius.circular(size * 0.28);
    final fallback = Center(
      child: Text(word.emoji, style: TextStyle(fontSize: size * 0.5)),
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: radius,
      ),
      clipBehavior: Clip.antiAlias,
      child: word.imageUrl == null
          ? fallback
          : Image.network(
              word.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : fallback,
            ),
    );
  }
}
