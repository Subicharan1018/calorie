class Recipe {
  final String id;
  final String englishName;
  final String tamilName;
  final int kcalPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final bool isAiGenerated;
  final List<String> matchedVegetableNames;
  final List<String> ingredientIds;
  final bool isICMR;

  // Micronutrients
  final double iron; // mg
  final double calcium; // mg
  final double phosphorus; // mg
  final double vitaminC; // mg
  final double thiamin; // mg
  final double riboflavin; // mg
  final double fibre; // g
  final double zinc; // mg
  final double folate; // mcg

  const Recipe({
    required this.id,
    required this.englishName,
    required this.tamilName,
    required this.kcalPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.isAiGenerated,
    required this.matchedVegetableNames,
    this.ingredientIds = const [],
    this.isICMR = false,
    this.iron = 0.0,
    this.calcium = 0.0,
    this.phosphorus = 0.0,
    this.vitaminC = 0.0,
    this.thiamin = 0.0,
    this.riboflavin = 0.0,
    this.fibre = 0.0,
    this.zinc = 0.0,
    this.folate = 0.0,
  });
}
