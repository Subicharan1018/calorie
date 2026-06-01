enum MealType { breakfast, lunch, snack, dinner }

class MealLog {
  final String id;
  final String recipeName;
  final String? tamilName;
  final int quantityGrams;
  final int kcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final MealType mealType;

  const MealLog({
    required this.id,
    required this.recipeName,
    this.tamilName,
    required this.quantityGrams,
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.mealType,
  });
}
