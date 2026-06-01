import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalori/core/models/meal_log.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/features/home/providers/dashboard_provider.dart';
import 'package:kalori/features/log/models/recipe.dart';

class MealLogQuantitySheet extends ConsumerStatefulWidget {
  final Recipe recipe;
  final int initialGrams;

  const MealLogQuantitySheet({
    super.key,
    required this.recipe,
    required this.initialGrams,
  });

  @override
  ConsumerState<MealLogQuantitySheet> createState() => _MealLogQuantitySheetState();
}

class _MealLogQuantitySheetState extends ConsumerState<MealLogQuantitySheet> {
  late double _grams;
  MealType _mealType = MealType.lunch;

  @override
  void initState() {
    super.initState();
    _grams = widget.initialGrams.toDouble();
  }

  void _onConfirm() {
    HapticFeedback.mediumImpact();
    final multiplier = _grams / 100;
    final log = MealLog(
      id: DateTime.now().toIso8601String(),
      recipeName: widget.recipe.englishName,
      tamilName: widget.recipe.tamilName,
      quantityGrams: _grams.toInt(),
      kcal: (widget.recipe.kcalPer100g * multiplier).toInt(),
      proteinG: widget.recipe.proteinPer100g * multiplier,
      carbsG: widget.recipe.carbsPer100g * multiplier,
      fatG: widget.recipe.fatPer100g * multiplier,
      mealType: _mealType,
    );

    ref.read(dashboardProvider.notifier).addMeal(log);

    context.go('/home'); // Close sheet and go home
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final multiplier = _grams / 100;
    final currentKcal = (widget.recipe.kcalPer100g * multiplier).toInt();
    final currentProtein = (widget.recipe.proteinPer100g * multiplier).toStringAsFixed(1);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Log ${widget.recipe.englishName}',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),

              Text('Quantity: ${_grams.toInt()}g', style: theme.textTheme.titleMedium),
              Slider(
                value: _grams,
                min: 50,
                max: 500,
                divisions: 18, // 25g increments
                onChanged: (val) {
                  setState(() {
                    _grams = (val / 25).round() * 25.0; // snap to 25
                  });
                },
              ),
              const SizedBox(height: AppSpacing.sm),

              Text(
                'Logging ${_grams.toInt()}g = $currentKcal kcal · ${currentProtein}g protein',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text('Meal Type', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<MealType>(
                segments: const [
                  ButtonSegment(value: MealType.breakfast, label: Text('Breakfast')),
                  ButtonSegment(value: MealType.lunch, label: Text('Lunch')),
                  ButtonSegment(value: MealType.snack, label: Text('Snack')),
                  ButtonSegment(value: MealType.dinner, label: Text('Dinner')),
                ],
                selected: {_mealType},
                onSelectionChanged: (val) => setState(() => _mealType = val.first),
                style: SegmentedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              FilledButton(
                onPressed: _onConfirm,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                ),
                child: const Text('Confirm Log', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
