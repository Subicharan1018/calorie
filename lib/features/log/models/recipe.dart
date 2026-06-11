class RecipeIngredient {
  final String ingredientCode;
  final String ingredientName;
  final double quantityG;
  final String? notes;

  const RecipeIngredient({
    required this.ingredientCode,
    required this.ingredientName,
    required this.quantityG,
    this.notes,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      ingredientCode: json['ingredient_code'] as String? ?? '',
      ingredientName: json['ingredient_name'] as String? ?? '',
      quantityG: (json['quantity_g'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
    );
  }
}

class Recipe {
  final int apiId;
  final String name;
  final String description;
  final String cuisine;
  final String mealType;
  final int prepMins;
  final int cookMins;
  final int servings;
  final double energyKcal; // total
  final double protein; // total
  final double carb; // total
  final double fat; // total
  final double fibreTotal; // total
  final bool isAi;
  final List<RecipeIngredient> ingredients;

  // Micronutrients
  final double iron;
  final double calcium;
  final double phosphorus;
  final double vitaminC;
  final double thiamin;
  final double riboflavin;
  final double zinc;
  final double folate;

  const Recipe({
    required this.apiId,
    required this.name,
    required this.description,
    required this.cuisine,
    required this.mealType,
    required this.prepMins,
    required this.cookMins,
    required this.servings,
    required this.energyKcal,
    required this.protein,
    required this.carb,
    required this.fat,
    required this.fibreTotal,
    required this.isAi,
    required this.ingredients,
    this.iron = 0.0,
    this.calcium = 0.0,
    this.phosphorus = 0.0,
    this.vitaminC = 0.0,
    this.thiamin = 0.0,
    this.riboflavin = 0.0,
    this.zinc = 0.0,
    this.folate = 0.0,
  });

  String get id => apiId.toString();
  String get englishName => name;
  bool get isAiGenerated => isAi;
  bool get isICMR => !isAi;

  static const Map<String, String> _tamilTranslations = {
    'drumstick sambar': 'முருங்கைக்காய் சாம்பார்',
    'raw banana kootu': 'வாழைக்காய் கூட்டு',
    'ash gourd poriyal': 'சாம்பல் பூசணி பொரியல்',
    'banana flower vadai': 'வாழைப்பூ வடை',
    'yam kuzhambu': 'சேனை குழம்பு',
    'snake gourd kootu': 'புடலங்காய் கூட்டு',
    'brinjal poriyal': 'கத்திரிக்காய் பொரியல்',
    'ladies finger fry': 'வெண்டைக்காய் வறுவல்',
    'spinach kootu': 'கீரை கூட்டு',
    'bitter gourd pitlai': 'பாகற்காய் பிட்லை',
    'ridge gourd thogayal': 'பீர்க்கங்காய் துவையல்',
    'ivy gourd fry': 'கோவைக்காய் வறுவல்',
  };

  String get tamilName => _tamilTranslations[name.toLowerCase()] ?? name;

  double get totalWeightG => ingredients.fold(0.0, (sum, i) => sum + i.quantityG);
  double get gramsPerServing => totalWeightG > 0 ? (totalWeightG / servings) : 200.0;

  int get kcalPer100g => totalWeightG > 0
      ? ((energyKcal / totalWeightG) * 100).toInt()
      : ((energyKcal / (servings * 200)) * 100).toInt();

  double get proteinPer100g => totalWeightG > 0
      ? (protein / totalWeightG) * 100
      : (protein / (servings * 200)) * 100;

  double get carbsPer100g => totalWeightG > 0
      ? (carb / totalWeightG) * 100
      : (carb / (servings * 200)) * 100;

  double get fatPer100g => totalWeightG > 0
      ? (fat / totalWeightG) * 100
      : (fat / (servings * 200)) * 100;

  double get fibre => totalWeightG > 0
      ? (fibreTotal / totalWeightG) * 100
      : (fibreTotal / (servings * 200)) * 100;

  List<String> get matchedVegetableNames =>
      ingredients.map((i) => i.ingredientName).toList();

  factory Recipe.fromJson(Map<String, dynamic> json) {
    var rawIngredients = json['ingredients'] as List<dynamic>? ?? [];
    var ingredientsList = rawIngredients
        .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
        .toList();

    return Recipe(
      apiId: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      cuisine: json['cuisine'] as String? ?? '',
      mealType: json['meal_type'] as String? ?? '',
      prepMins: json['prep_mins'] as int? ?? 0,
      cookMins: json['cook_mins'] as int? ?? 0,
      servings: json['servings'] as int? ?? 1,
      energyKcal: (json['energy_kcal'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carb: (json['carb'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      fibreTotal: (json['fibre'] as num?)?.toDouble() ?? 0.0,
      isAi: json['is_ai'] as bool? ?? false,
      ingredients: ingredientsList,
      iron: (json['iron'] as num?)?.toDouble() ?? 0.0,
      calcium: (json['calcium'] as num?)?.toDouble() ?? 0.0,
      phosphorus: (json['phosphorus'] as num?)?.toDouble() ?? 0.0,
      vitaminC: (json['vitc'] as num?)?.toDouble() ?? 0.0,
      thiamin: (json['thiamine'] as num?)?.toDouble() ?? 0.0,
      riboflavin: (json['riboflavin'] as num?)?.toDouble() ?? 0.0,
      zinc: (json['zinc'] as num?)?.toDouble() ?? 0.0,
      folate: (json['folate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
