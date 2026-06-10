import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surfaceContainer;
    final highlightColor = theme.colorScheme.surfaceContainerLowest;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: 80,
        height: 32,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
