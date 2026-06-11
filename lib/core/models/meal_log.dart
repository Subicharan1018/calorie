import 'package:kalori/l10n/app_strings.dart';

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

  // New fields from API
  final int? recipeId;
  final String? ingredientCode;
  final double? servingsEaten;
  final double? fibreG;
  final String? loggedAt;

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
    this.recipeId,
    this.ingredientCode,
    this.servingsEaten,
    this.fibreG,
    this.loggedAt,
  });

  String portionDisplay(AppStrings s) {
    if (servingsEaten != null && servingsEaten! > 0) {
      return s.isTamil
          ? '${servingsEaten!.toStringAsFixed(1)} பரிமாறல்'
          : '${servingsEaten!.toStringAsFixed(1)} servings';
    }
    return s.isTamil ? '$quantityGrams கிராம்' : '${quantityGrams}g';
  }

  factory MealLog.fromJson(Map<String, dynamic> json) {
    final String typeStr = json['meal_type'] as String? ?? 'snack';
    final MealType type = MealType.values.firstWhere(
      (e) => e.name == typeStr.toLowerCase(),
      orElse: () => MealType.snack,
    );

    final String name = json['recipe_name'] as String? ?? json['ingredient_name'] as String? ?? '';

    final nameLower = name.toLowerCase();
    String? tamil;
    final Map<String, String> translations = {
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
      'aashirvaad multigrain atta': 'ஆசீர்வாத் மல்டிகிரைன் ஆட்டா',
      'amul butter': 'அமுல் வெண்ணெய்',
      'britannia marie gold': 'பிரிட்டானியா மேரி கோல்ட்',
    };
    if (translations.containsKey(nameLower)) {
      tamil = translations[nameLower];
    }

    return MealLog(
      id: (json['id'] ?? '').toString(),
      recipeName: name,
      tamilName: tamil,
      quantityGrams: ((json['quantity_g'] as num?)?.toDouble() ?? 0.0).toInt(),
      kcal: ((json['energy_kcal'] as num?)?.toDouble() ?? 0.0).toInt(),
      proteinG: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbsG: (json['carb'] as num?)?.toDouble() ?? 0.0,
      fatG: (json['fat'] as num?)?.toDouble() ?? 0.0,
      mealType: type,
      recipeId: json['recipe_id'] as int?,
      ingredientCode: json['ingredient_code'] as String?,
      servingsEaten: (json['servings_eaten'] as num?)?.toDouble(),
      fibreG: (json['fibre'] as num?)?.toDouble(),
      loggedAt: json['logged_at'] as String?,
    );
  }
}
