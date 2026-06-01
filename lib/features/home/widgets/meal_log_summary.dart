import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalori/core/models/meal_log.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/shared/widgets/empty_state.dart';
import 'package:kalori/shared/widgets/tamil_english_label.dart';

class MealLogSummaryList extends ConsumerWidget {
  final List<MealLog> meals;
  final Function(String id) onDelete;

  const MealLogSummaryList({
    super.key,
    required this.meals,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (meals.isEmpty) {
      return const EmptyState(
        headline: 'No meals logged yet',
        subtext: 'Tap the + button to log your first meal today.',
        illustration: Icon(Icons.restaurant, size: 64, color: Colors.grey),
      );
    }

    final theme = Theme.of(context);
    final groupedMeals = <MealType, List<MealLog>>{};
    for (final meal in meals) {
      groupedMeals.putIfAbsent(meal.mealType, () => []).add(meal);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: MealType.values.where((type) => groupedMeals.containsKey(type)).map((type) {
        final typeMeals = groupedMeals[type]!;
        final typeTotal = typeMeals.fold(0, (sum, m) => sum + m.kcal);

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Card(
            elevation: AppElevation.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getMealTypeName(type),
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        '$typeTotal kcal',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: typeMeals.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                  itemBuilder: (context, index) {
                    final meal = typeMeals[index];
                    return Dismissible(
                      key: ValueKey(meal.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => onDelete(meal.id),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        color: theme.colorScheme.error,
                        child: Icon(Icons.delete, color: theme.colorScheme.onError),
                      ),
                      child: ListTile(
                        title: meal.tamilName != null
                            ? TamilEnglishLabel(
                                englishText: meal.recipeName,
                                tamilText: meal.tamilName!,
                              )
                            : Text(meal.recipeName),
                        subtitle: Text('${meal.quantityGrams}g'),
                        trailing: Text(
                          '${meal.kcal} kcal',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getMealTypeName(MealType type) {
    switch (type) {
      case MealType.breakfast: return 'Breakfast · காலை உணவு';
      case MealType.lunch: return 'Lunch · மதிய உணவு';
      case MealType.snack: return 'Snack · சிற்றுண்டி';
      case MealType.dinner: return 'Dinner · இரவு உணவு';
    }
  }
}
