class NutrientGaps {
  final String gapDate;
  final String? message;

  // Gaps (in target/RDA units: kcal for energy, g for protein/fat/fibre, mg for minerals/vitamins)
  final double gapEnergyKcal;
  final double gapProtein;
  final double gapFat;
  final double gapFibre;
  final double gapCalcium;
  final double gapIron;
  final double gapVitc;
  final double gapSodium;

  // Actuals (stored as grams in the DB except energy which is kcal)
  final double actualEnergyKcal;
  final double actualProtein;
  final double actualFat;
  final double actualCarb;
  final double actualFibre;
  final double actualCalcium; // in grams
  final double actualIron;    // in grams
  final double actualVitc;    // in grams
  final double actualSodium;  // in grams

  const NutrientGaps({
    required this.gapDate,
    this.message,
    required this.gapEnergyKcal,
    required this.gapProtein,
    required this.gapFat,
    required this.gapFibre,
    required this.gapCalcium,
    required this.gapIron,
    required this.gapVitc,
    required this.gapSodium,
    required this.actualEnergyKcal,
    required this.actualProtein,
    required this.actualFat,
    required this.actualCarb,
    required this.actualFibre,
    required this.actualCalcium,
    required this.actualIron,
    required this.actualVitc,
    required this.actualSodium,
  });

  // Display quantities in common units (mg for calcium, iron, vitc, sodium; g for protein, fibre, carb, fat)
  double get displayActualProtein => actualProtein;
  double get displayActualFibre => actualFibre;
  double get displayActualCalcium => actualCalcium * 1000;
  double get displayActualIron => actualIron * 1000;
  double get displayActualVitc => actualVitc * 1000;
  double get displayActualSodium => actualSodium * 1000;

  // RDA Targets (RDA = actual - gap, converting to display units)
  double get rdaProtein => (actualProtein - gapProtein).clamp(0, double.infinity);
  double get rdaFibre => (actualFibre - gapFibre).clamp(0, double.infinity);
  double get rdaCalcium => (displayActualCalcium - gapCalcium).clamp(0, double.infinity);
  double get rdaIron => (displayActualIron - gapIron).clamp(0, double.infinity);
  double get rdaVitc => (displayActualVitc - gapVitc).clamp(0, double.infinity);
  double get rdaSodium => 2000.0; // Standard daily limit is 2000 mg

  // Progress Ratios (0.0 to 1.0+)
  double get proteinProgress => rdaProtein > 0 ? (displayActualProtein / rdaProtein).clamp(0.0, 1.0) : 0.0;
  double get fibreProgress => rdaFibre > 0 ? (displayActualFibre / rdaFibre).clamp(0.0, 1.0) : 0.0;
  double get calciumProgress => rdaCalcium > 0 ? (displayActualCalcium / rdaCalcium).clamp(0.0, 1.0) : 0.0;
  double get ironProgress => rdaIron > 0 ? (displayActualIron / rdaIron).clamp(0.0, 1.0) : 0.0;
  double get vitcProgress => rdaVitc > 0 ? (displayActualVitc / rdaVitc).clamp(0.0, 1.0) : 0.0;

  factory NutrientGaps.fromJson(Map<String, dynamic> json) {
    return NutrientGaps(
      gapDate: json['gap_date'] as String? ?? '',
      message: json['message'] as String?,
      gapEnergyKcal: (json['gap_energy_kcal'] as num?)?.toDouble() ?? 0.0,
      gapProtein: (json['gap_protein'] as num?)?.toDouble() ?? 0.0,
      gapFat: (json['gap_fat'] as num?)?.toDouble() ?? 0.0,
      gapFibre: (json['gap_fibre'] as num?)?.toDouble() ?? 0.0,
      gapCalcium: (json['gap_calcium'] as num?)?.toDouble() ?? 0.0,
      gapIron: (json['gap_iron'] as num?)?.toDouble() ?? 0.0,
      gapVitc: (json['gap_vitc'] as num?)?.toDouble() ?? 0.0,
      gapSodium: (json['gap_sodium'] as num?)?.toDouble() ?? 0.0,
      actualEnergyKcal: (json['actual_energy_kcal'] as num?)?.toDouble() ?? 0.0,
      actualProtein: (json['actual_protein'] as num?)?.toDouble() ?? 0.0,
      actualFat: (json['actual_fat'] as num?)?.toDouble() ?? 0.0,
      actualCarb: (json['actual_carb'] as num?)?.toDouble() ?? 0.0,
      actualFibre: (json['actual_fibre'] as num?)?.toDouble() ?? 0.0,
      actualCalcium: (json['actual_calcium'] as num?)?.toDouble() ?? 0.0,
      actualIron: (json['actual_iron'] as num?)?.toDouble() ?? 0.0,
      actualVitc: (json['actual_vitc'] as num?)?.toDouble() ?? 0.0,
      actualSodium: (json['actual_sodium'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
