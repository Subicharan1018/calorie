import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalori/core/models/meal_log.dart';
import 'package:kalori/core/models/daily_summary.dart';

class DashboardNotifier extends Notifier<DailySummary> {
  @override
  DailySummary build() {
    return const DailySummary(
      targetKcal: 2100, // Hardcoded for Phase 4 rendering
      meals: [
        MealLog(
          id: '1',
          recipeName: 'Idli with Sambar',
          tamilName: 'இட்லி சாம்பார்',
          quantityGrams: 250,
          kcal: 320,
          proteinG: 12.0,
          carbsG: 60.0,
          fatG: 4.0,
          mealType: MealType.breakfast,
        ),
      ],
    );
  }

  void addMeal(MealLog meal) {
    state = DailySummary(
      targetKcal: state.targetKcal,
      meals: [...state.meals, meal],
    );
  }

  void deleteMeal(String id) {
    state = DailySummary(
      targetKcal: state.targetKcal,
      meals: state.meals.where((m) => m.id != id).toList(),
    );
  }
}

final dashboardProvider = NotifierProvider<DashboardNotifier, DailySummary>(() {
  return DashboardNotifier();
});
