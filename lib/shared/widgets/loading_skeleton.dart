import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:kalori/core/theme/spacing.dart';

class LoadingSkeleton extends StatelessWidget {
  final bool isList;
  final int count;

  const LoadingSkeleton({
    super.key,
    this.isList = true,
    this.count = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: isList
          ? ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: count,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, __) => _buildCard(context),
            )
          : _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Card(
      elevation: AppElevation.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Bone.text(words: 2),
            SizedBox(height: AppSpacing.sm),
            Bone.text(words: 4),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Bone.icon(),
                SizedBox(width: AppSpacing.sm),
                Bone.icon(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
