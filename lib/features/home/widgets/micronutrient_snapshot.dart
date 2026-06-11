import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/l10n/app_strings.dart';
import 'package:kalori/features/home/providers/recommendations_provider.dart';

class MicronutrientSnapshot extends ConsumerWidget {
  const MicronutrientSnapshot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);
    final gapsAsync = ref.watch(nutrientGapsProvider);
    
    return Card(
      elevation: AppElevation.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: gapsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (err, _) => Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text('${s.apiError}: $err', style: TextStyle(color: theme.colorScheme.error)),
        ),
        data: (gaps) {
          if (gaps == null) {
            return ExpansionTile(
              title: Text(s.micronutrients),
              subtitle: Text(s.isTamil ? 'நேற்றைய தரவு இல்லை' : 'No logs from yesterday'),
              childrenPadding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(
                    s.isTamil
                        ? 'நேற்றைய நுண்ணூட்டச்சத்துக்களைக் கணக்கிட, தயவுசெய்து தொடர்ந்து உணவுகளைப் பதிவுசெய்யவும்.'
                        : 'No meal logs found from yesterday. Keep logging meals daily to see your micronutrient progress here!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                  ),
                ),
              ],
            );
          }

          return ExpansionTile(
            title: Text(s.isTamil ? 'நுண்ணூட்டச்சத்துக்கள் (நேற்று)' : '${s.micronutrients} (Yesterday)'),
            subtitle: Text('${s.iron.split(' (').first}, ${s.calcium.split(' (').first}, ${s.vitaminC.split(' (').first}, ${s.fibre.split(' (').first}'),
            childrenPadding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _buildBar(context, s.iron, gaps.ironProgress, '${(gaps.displayActualIron).toStringAsFixed(1)}mg / ${(gaps.rdaIron).toStringAsFixed(1)}mg'),
              const SizedBox(height: AppSpacing.sm),
              _buildBar(context, s.calcium, gaps.calciumProgress, '${(gaps.displayActualCalcium).toStringAsFixed(0)}mg / ${(gaps.rdaCalcium).toStringAsFixed(0)}mg'),
              const SizedBox(height: AppSpacing.sm),
              _buildBar(context, s.vitaminC, gaps.vitcProgress, '${(gaps.displayActualVitc).toStringAsFixed(1)}mg / ${(gaps.rdaVitc).toStringAsFixed(1)}mg'),
              const SizedBox(height: AppSpacing.sm),
              _buildBar(context, s.fibre, gaps.fibreProgress, '${(gaps.displayActualFibre).toStringAsFixed(1)}g / ${(gaps.rdaFibre).toStringAsFixed(1)}g'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBar(BuildContext context, String label, double progress, String details) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.labelMedium),
            Text(details, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(
                  progress >= 1.0 ? theme.colorScheme.secondary : theme.colorScheme.primary,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text('${(progress * 100).toInt()}%', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
