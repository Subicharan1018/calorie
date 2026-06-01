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
  });
}
