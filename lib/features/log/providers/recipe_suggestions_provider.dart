import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalori/features/log/models/recipe.dart';
import 'package:kalori/features/log/providers/vegetable_search_provider.dart';

final recipeSuggestionsProvider = FutureProvider.autoDispose<List<Recipe>>((ref) async {
  final selected = ref.watch(selectedVegetablesProvider);
  
  // Simulate AI/Network latency (3 seconds)
  await Future.delayed(const Duration(seconds: 3));
  
  if (selected.isEmpty) return [];

  return [
    Recipe(
      id: '1',
      englishName: 'Sambar',
      tamilName: 'சாம்பார்',
      kcalPer100g: 78,
      proteinPer100g: 3.5,
      carbsPer100g: 11.2,
      fatPer100g: 2.1,
      isAiGenerated: false,
      matchedVegetableNames: selected.map((v) => v.englishName).toList(),
    ),
    Recipe(
      id: '2',
      englishName: 'Kootu',
      tamilName: 'கூட்டு',
      kcalPer100g: 95,
      proteinPer100g: 4.1,
      carbsPer100g: 12.0,
      fatPer100g: 3.8,
      isAiGenerated: true,
      matchedVegetableNames: selected.map((v) => v.englishName).take(2).toList(),
    ),
    Recipe(
      id: '3',
      englishName: 'Poriyal',
      tamilName: 'பொரியல்',
      kcalPer100g: 110,
      proteinPer100g: 2.5,
      carbsPer100g: 14.0,
      fatPer100g: 6.0,
      isAiGenerated: false,
      matchedVegetableNames: selected.map((v) => v.englishName).toList(),
    ),
  ];
});
