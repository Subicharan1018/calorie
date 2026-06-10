class Vegetable {
  final String id;
  final String englishName;
  final String tamilName;
  final String category;
  final int kcalPer100g;
  final String? icmrCode;

  const Vegetable({
    required this.id,
    required this.englishName,
    required this.tamilName,
    required this.category,
    required this.kcalPer100g,
    this.icmrCode,
  });
}
