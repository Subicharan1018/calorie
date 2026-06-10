import 'package:flutter/material.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/l10n/app_strings.dart';

class MicronutrientSnapshot extends StatelessWidget {
  const MicronutrientSnapshot({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);
    
    return Card(
      elevation: AppElevation.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: ExpansionTile(
        title: Text(s.micronutrients),
        subtitle: Text('${s.iron.split(' (').first}, ${s.calcium.split(' (').first}, ${s.vitaminC.split(' (').first}, ${s.fibre.split(' (').first}'),
        childrenPadding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildBar(context, s.iron, 0.4),
          const SizedBox(height: AppSpacing.sm),
          _buildBar(context, s.calcium, 0.8),
          const SizedBox(height: AppSpacing.sm),
          _buildBar(context, s.vitaminC, 1.0),
          const SizedBox(height: AppSpacing.sm),
          _buildBar(context, s.fibre, 0.6),
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
            progress >= 1.0 ? theme.colorScheme.secondary : theme.colorScheme.primary,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
