/// A rounded shimmering placeholder used during loading states.
///
/// [ShimmerBox] renders a rounded (16px) rectangle that animates a shimmer
/// sweep via the `shimmer` package. The base/highlight colors are derived from
/// the active [Theme]'s muted surface tones so the placeholder blends with the
/// light/dark palette without any hardcoded hex. Used by the Home loading grid
/// while questions are being parsed. (Req 3.1)
library;

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A rounded shimmering loading placeholder of a given size.
class ShimmerBox extends StatelessWidget {
  /// Placeholder width. Defaults to filling available width.
  final double? width;

  /// Placeholder height. Defaults to 80.
  final double height;

  /// Corner radius of the placeholder. Defaults to 16.
  final double borderRadius;

  /// Creates a shimmer placeholder.
  const ShimmerBox({
    super.key,
    this.width,
    this.height = 80,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Muted surface tones: a slightly elevated base with a brighter sweep.
    final baseColor = Color.alphaBlend(
      colorScheme.onSurface.withValues(alpha: 0.08),
      colorScheme.surface,
    );
    final highlightColor = Color.alphaBlend(
      colorScheme.onSurface.withValues(alpha: 0.16),
      colorScheme.surface,
    );

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
