import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/shared/widgets/app_scaffold.dart';
import 'package:kalori/shared/widgets/empty_state.dart';
import 'package:kalori/shared/widgets/loading_skeleton.dart';
import 'package:kalori/shared/widgets/tamil_english_label.dart';
import 'package:kalori/features/log/providers/recipe_suggestions_provider.dart';
import 'package:kalori/features/log/providers/vegetable_search_provider.dart';
import 'package:kalori/features/log/widgets/recipe_detail_sheet.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RecipeSuggestionsScreen extends ConsumerWidget {
  const RecipeSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final suggestionsAsync = ref.watch(recipeSuggestionsProvider);
    final selectedCount = ref.watch(selectedVegetablesProvider).length;

    return AppScaffold(
      title: 'Recipes for your vegetables',
      subtitle: '$selectedCount vegetables matched',
      body: suggestionsAsync.when(
        loading: () => Column(
          children: [
            const LinearProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Asking AI for recipes...',
                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
              ),
            ),
            const Expanded(child: LoadingSkeleton(count: 4)),
          ],
        ),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (recipes) {
          if (recipes.isEmpty) {
            return const EmptyState(
              headline: 'No recipes found',
              subtext: 'AI could not generate a valid recipe for these vegetables.',
              illustration: Icon(Icons.search_off, size: 64, color: Colors.grey),
            );
          }

          final aiCount = recipes.where((r) => r.isAiGenerated).length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${recipes.length} recipes · $aiCount from AI',
                      style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline),
                    ),
                    const Icon(Icons.sort, size: 20),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  itemCount: recipes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return Card(
                      elevation: AppElevation.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            builder: (_) => RecipeDetailSheet(recipe: recipe),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: TamilEnglishLabel(
                                      englishText: recipe.englishName,
                                      tamilText: recipe.tamilName,
                                      englishStyle: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Text(
                                    '${recipe.kcalPer100g} kcal',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              if (recipe.isAiGenerated) ...[
                                const SizedBox(height: AppSpacing.sm),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('AI Suggested', style: TextStyle(fontSize: 10, color: Colors.brown)),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                children: [
                                  _MacroDot(color: theme.colorScheme.primary, label: 'C: ${recipe.carbsPer100g}g'),
                                  const SizedBox(width: AppSpacing.sm),
                                  _MacroDot(color: theme.colorScheme.secondary, label: 'P: ${recipe.proteinPer100g}g'),
                                  const SizedBox(width: AppSpacing.sm),
                                  _MacroDot(color: Colors.amber, label: 'F: ${recipe.fatPer100g}g'),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: recipe.matchedVegetableNames.map((name) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainer,
                                      borderRadius: BorderRadius.circular(AppRadius.chip),
                                    ),
                                    child: Text(name, style: theme.textTheme.labelSmall),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fade(delay: (40 * index).ms).slideY(begin: 0.1, duration: 300.ms, curve: Curves.easeOutCubic);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MacroDot extends StatelessWidget {
  final Color color;
  final String label;

  const _MacroDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
