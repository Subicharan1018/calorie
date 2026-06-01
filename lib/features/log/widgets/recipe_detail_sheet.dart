import 'package:flutter/material.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/features/log/models/recipe.dart';
import 'package:kalori/shared/widgets/stat_chip.dart';
import 'package:kalori/features/log/widgets/meal_log_quantity_sheet.dart';

class RecipeDetailSheet extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailSheet({super.key, required this.recipe});

  @override
  State<RecipeDetailSheet> createState() => _RecipeDetailSheetState();
}

class _RecipeDetailSheetState extends State<RecipeDetailSheet> {
  int _servingGrams = 100;

  void _onLogMeal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => MealLogQuantitySheet(
        recipe: widget.recipe,
        initialGrams: _servingGrams,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final multiplier = _servingGrams / 100;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  children: [
                    Text(
                      widget.recipe.englishName,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.recipe.tamilName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Source Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: widget.recipe.isAiGenerated 
                            ? Colors.amber.withValues(alpha: 0.1) 
                            : Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                        border: Border.all(
                          color: widget.recipe.isAiGenerated 
                              ? Colors.amber.withValues(alpha: 0.3) 
                              : Colors.green.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.recipe.isAiGenerated ? Icons.warning_amber : Icons.verified,
                            size: 16,
                            color: widget.recipe.isAiGenerated ? Colors.amber[800] : Colors.green[800],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.recipe.isAiGenerated 
                                ? 'AI-generated, verify before use' 
                                : 'ICMR-NIN verified',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: widget.recipe.isAiGenerated ? Colors.amber[900] : Colors.green[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Serving Size Stepper
                    Text('Serving Size', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 100, label: Text('100g')),
                        ButtonSegment(value: 150, label: Text('150g')),
                        ButtonSegment(value: 200, label: Text('200g')),
                        ButtonSegment(value: 250, label: Text('250g')),
                      ],
                      selected: {_servingGrams},
                      onSelectionChanged: (val) => setState(() => _servingGrams = val.first),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Macro breakdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _BigMacroStat(label: 'Calories', value: '${(widget.recipe.kcalPer100g * multiplier).toInt()}', color: theme.colorScheme.onSurface),
                        _BigMacroStat(label: 'Protein', value: '${(widget.recipe.proteinPer100g * multiplier).toStringAsFixed(1)}g', color: theme.colorScheme.secondary),
                        _BigMacroStat(label: 'Carbs', value: '${(widget.recipe.carbsPer100g * multiplier).toStringAsFixed(1)}g', color: theme.colorScheme.primary),
                        _BigMacroStat(label: 'Fat', value: '${(widget.recipe.fatPer100g * multiplier).toStringAsFixed(1)}g', color: Colors.amber[700]!),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Ingredients
                    Text('Ingredients (per 100g)', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.recipe.matchedVegetableNames.map((veg) => StatChip(label: veg, value: '≈30g')).toList(),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ICMR Nutrition Table (Collapsible)
                    const ExpansionTile(
                      title: Text('Full Nutrition Data'),
                      tilePadding: EdgeInsets.zero,
                      children: [
                        _NutritionRow(label: 'Iron', value: '1.2mg', percent: 0.15),
                        _NutritionRow(label: 'Calcium', value: '45mg', percent: 0.05),
                        _NutritionRow(label: 'Phosphorus', value: '80mg', percent: 0.11),
                        _NutritionRow(label: 'Vitamin C', value: '12mg', percent: 0.20),
                        _NutritionRow(label: 'Fibre', value: '3.4g', percent: 0.13),
                      ],
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: FilledButton(
                  onPressed: _onLogMeal,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                  ),
                  child: const Text('Log This Meal', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BigMacroStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BigMacroStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final String label;
  final String value;
  final double percent;

  const _NutritionRow({required this.label, required this.value, required this.percent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 48,
            child: Text(value, textAlign: TextAlign.right, style: theme.textTheme.labelMedium),
          ),
        ],
      ),
    );
  }
}
