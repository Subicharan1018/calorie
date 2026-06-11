class RecommendationItem {
  final String itemType;
  final String itemId;
  final String itemName;
  final String? foodGroup;
  final String mealSlot;
  final double? suggestedG;
  final double? suggestedServings;
  final String? addresses;
  final String? topNutrient;
  final double? energyKcal;
  final double? protein;
  final double? carb;
  final double? fat;
  final double? fibre;
  final double score;
  final bool isPrimary;
  final String reason;

  const RecommendationItem({
    required this.itemType,
    required this.itemId,
    required this.itemName,
    this.foodGroup,
    required this.mealSlot,
    this.suggestedG,
    this.suggestedServings,
    this.addresses,
    this.topNutrient,
    this.energyKcal,
    this.protein,
    this.carb,
    this.fat,
    this.fibre,
    required this.score,
    required this.isPrimary,
    required this.reason,
  });

  bool get isRecipe => itemType == 'recipe';
  bool get isIngredient => itemType == 'ingredient';

  String portionDisplay(bool isTamil) {
    if (isRecipe) {
      final val = suggestedServings ?? 1.0;
      return isTamil
          ? '${val.toStringAsFixed(1)} பரிமாறல்'
          : '${val.toStringAsFixed(1)} servings';
    } else {
      final val = suggestedG ?? 100.0;
      return isTamil ? '${val.toInt()} கிராம்' : '${val.toInt()}g';
    }
  }

  // A local translation helper for standard ingredients and reasons if needed
  String getDisplayName(bool isTamil) {
    if (!isTamil) return itemName;

    // Simple Tamil translations for food items and meal types
    final Map<String, String> translations = {
      'quinoa': 'குயினோவா (Quinoa)',
      'oats, rolled': 'ஓட்ஸ் (Oats)',
      'masala oats upma': 'மசாலா ஓட்ஸ் உப்புமா',
      'dal tadka with rice': 'தால் தட்கா மற்றும் சாதம்',
      'rajma chawal': 'ராஜ்மா சாவல்',
      'mixed vegetable khichdi': 'காய்கறி கிச்சடி',
      'fish curry (coastal style)': 'மீன் குழம்பு',
      'chana masala': 'சென்னா மசாலா',
      'sprouts chaat': 'முளைகட்டிய பயறு சாட்',
      'black gram, whole': 'முழு உளுந்து',
      'red gram, whole': 'முழு துவரம் பருப்பு',
      'wheat flour, atta': 'கோதுமை மாவு (ஆட்டா)',
      'wheat, whole': 'முழு கோதுமை',
      'maize, dry': 'சோளம்',
      'dates, dry, pale brown': 'பேரீச்சம்பழம்',
      'sapota': 'சப்போட்டா',
      'linseeds': 'ஆளிவிதை (Linseeds)',
      'gingelly seeds, brown': 'எள் (Brown Sesame)',
      'milk, whole, buffalo': 'எருமைப் பால்',
    };
    final lowerName = itemName.toLowerCase();
    if (translations.containsKey(lowerName)) {
      return translations[lowerName]!;
    }
    return itemName;
  }

  String getReasonDisplay(bool isTamil) {
    if (!isTamil) return reason;
    
    // Convert reasons like "Rich in Protein, Fibre · Not eaten recently · Vegetarian" to Tamil
    // Let's replace words in a simple map
    String localReason = reason;
    final Map<String, String> dictionary = {
      'rich in': 'நிறைந்தது:',
      'protein': 'புரதம்',
      'fibre': 'நார்ச்சத்து',
      'iron': 'இரும்புச்சத்து',
      'calcium': 'கால்சியம்',
      'vitamin b6': 'வைட்டமின் பி6',
      'vitamin b12': 'வைட்டமின் பி12',
      'not eaten recently': 'சமீபத்தில் உட்கொள்ளப்படவில்லை',
      'vegetarian': 'சைவம்',
    };

    dictionary.forEach((eng, tam) {
      localReason = localReason.replaceAll(RegExp(eng, caseSensitive: false), tam);
    });
    return localReason;
  }

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    return RecommendationItem(
      itemType: json['item_type'] as String? ?? 'ingredient',
      itemId: (json['item_id'] ?? '').toString(),
      itemName: json['item_name'] as String? ?? '',
      foodGroup: json['food_group'] as String?,
      mealSlot: json['meal_slot'] as String? ?? 'breakfast',
      suggestedG: (json['suggested_g'] as num?)?.toDouble(),
      suggestedServings: (json['suggested_servings'] as num?)?.toDouble(),
      addresses: json['addresses'] as String?,
      topNutrient: json['top_nutrient'] as String?,
      energyKcal: (json['energy_kcal'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      carb: (json['carb'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      fibre: (json['fibre'] as num?)?.toDouble(),
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      isPrimary: json['is_primary'] as bool? ?? false,
      reason: json['reason'] as String? ?? '',
    );
  }
}
