class Ingredient {
  final String code;
  final String name;
  final String grup;
  final double energyKcal;
  final double protein;
  final double carb;
  final double fat;
  final double fibre;
  final double calcium;
  final double iron;
  final double vitc;

  const Ingredient({
    required this.code,
    required this.name,
    required this.grup,
    required this.energyKcal,
    required this.protein,
    required this.carb,
    required this.fat,
    required this.fibre,
    required this.calcium,
    required this.iron,
    required this.vitc,
  });

  String get id => code;
  String get englishName => name;
  String get tamilName => name;
  String get category => grup;
  int get kcalPer100g => energyKcal.toInt();

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      grup: json['grup'] as String? ?? '',
      energyKcal: (json['energy_kcal'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carb: (json['carb'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      fibre: (json['fibre'] as num?)?.toDouble() ?? 0.0,
      calcium: (json['calcium'] as num?)?.toDouble() ?? 0.0,
      iron: (json['iron'] as num?)?.toDouble() ?? 0.0,
      vitc: (json['vitc'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'grup': grup,
      'energy_kcal': energyKcal,
      'protein': protein,
      'carb': carb,
      'fat': fat,
      'fibre': fibre,
      'calcium': calcium,
      'iron': iron,
      'vitc': vitc,
    };
  }
}
