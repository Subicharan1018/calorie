import 'meal_log.dart';

class DailySummary {
  final int targetKcal;
  final List<MealLog> meals;

  const DailySummary({
    required this.targetKcal,
    required this.meals,
  });

  int get consumedKcal => meals.fold(0, (sum, m) => sum + m.kcal);
  double get consumedProtein => meals.fold(0.0, (sum, m) => sum + m.proteinG);
  double get consumedCarbs => meals.fold(0.0, (sum, m) => sum + m.carbsG);
  double get consumedFat => meals.fold(0.0, (sum, m) => sum + m.fatG);
  
  // Base targets (40C/30P/30F approx split of TDEE)
  double get targetProtein => (targetKcal * 0.3) / 4;
  double get targetCarbs => (targetKcal * 0.4) / 4;
  double get targetFat => (targetKcal * 0.3) / 9;
}
