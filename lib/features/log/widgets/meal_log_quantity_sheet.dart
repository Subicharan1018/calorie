import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalori/core/models/meal_log.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/features/home/providers/dashboard_provider.dart';
import 'package:kalori/features/log/models/recipe.dart';
import 'package:kalori/l10n/app_strings.dart';

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

    // Show a floating confirmation toast or SnackBar
    final s = AppStrings.of(context);
    final String recipeDisplay = s.isTamil ? widget.recipe.tamilName : widget.recipe.englishName;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          s.isTamil
              ? '$recipeDisplay வெற்றிகரமாகப் பதிவு செய்யப்பட்டது'
              : '$recipeDisplay logged successfully',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.go('/home'); // Close sheet and go home
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);
    final multiplier = _grams / 100;
    final currentKcal = (widget.recipe.kcalPer100g * multiplier).toInt();
    final currentProtein = (widget.recipe.proteinPer100g * multiplier).toStringAsFixed(1);
    final currentCarbs = (widget.recipe.carbsPer100g * multiplier).toStringAsFixed(1);
    final currentFat = (widget.recipe.fatPer100g * multiplier).toStringAsFixed(1);

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
                s.isTamil ? 'உணவுப் பதிவு: ${widget.recipe.tamilName}' : 'Log ${widget.recipe.englishName}',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text(
                s.isTamil ? 'அளவு: ${_grams.toInt()} கிராம்' : 'Quantity: ${_grams.toInt()}g',
                style: theme.textTheme.titleMedium,
              ),
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
                s.isTamil
                    ? 'பதிவுசெய்யப்படும் அளவு: ${_grams.toInt()}கி = $currentKcal கலோரி\n(கார்ப்ஸ்: $currentCarbsகி · புரதம்: $currentProteinகி · கொழுப்பு: $currentFatகி)'
                    : 'Logging ${_grams.toInt()}g = $currentKcal kcal\n(Carbs: ${currentCarbs}g · Protein: ${currentProtein}g · Fat: ${currentFat}g)',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, height: 1.4),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text(s.isTamil ? 'உணவு வகை' : 'Meal Type', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<MealType>(
                segments: [
                  ButtonSegment(value: MealType.breakfast, label: Text(s.breakfast.split(' · ').first)),
                  ButtonSegment(value: MealType.lunch, label: Text(s.lunch.split(' · ').first)),
                  ButtonSegment(value: MealType.snack, label: Text(s.snack.split(' · ').first)),
                  ButtonSegment(value: MealType.dinner, label: Text(s.dinner.split(' · ').first)),
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
                child: Text(s.isTamil ? 'பதிவை உறுதிசெய்' : 'Confirm Log', style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
