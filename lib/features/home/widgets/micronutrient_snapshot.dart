import 'package:flutter/material.dart';
import 'package:kalori/core/theme/spacing.dart';

class MicronutrientSnapshot extends StatelessWidget {
  const MicronutrientSnapshot({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: AppElevation.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: ExpansionTile(
        title: const Text('Micronutrients'),
        subtitle: const Text('Iron, Calcium, Vitamin C, Fibre'),
        childrenPadding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildBar(context, 'Iron · இரும்பு', 0.4),
          const SizedBox(height: AppSpacing.sm),
          _buildBar(context, 'Calcium · கால்சியம்', 0.8),
          const SizedBox(height: AppSpacing.sm),
          _buildBar(context, 'Vitamin C', 1.0),
          const SizedBox(height: AppSpacing.sm),
          _buildBar(context, 'Fibre · நார்சத்து', 0.6),
        ],
      ),
    );
  }

  Widget _buildBar(BuildContext context, String label, double progress) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.labelMedium),
            Text('${(progress * 100).toInt()}%', style: theme.textTheme.labelMedium),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation(
            progress >= 1.0 ? Colors.green : theme.colorScheme.primary,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
