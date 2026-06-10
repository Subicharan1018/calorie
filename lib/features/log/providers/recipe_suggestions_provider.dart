import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalori/features/log/models/recipe.dart';
import 'package:kalori/features/log/providers/vegetable_search_provider.dart';
import 'package:kalori/mock/mock_data.dart';

final recipeSuggestionsProvider = FutureProvider.autoDispose<List<Recipe>>((ref) async {
  final selected = ref.watch(selectedVegetablesProvider);
  
  // Simulate AI/Network latency (3.5 seconds)
  await Future.delayed(const Duration(milliseconds: 3500));
  
  if (selected.isEmpty) return [];

  final selectedNames = selected.map((v) => v.englishName.toLowerCase()).toSet();
  final matched = mockRecipes.where((recipe) {
    return recipe.matchedVegetableNames.any((name) => selectedNames.contains(name.toLowerCase()));
  }).toList();

  if (matched.isEmpty) {
    // Fallback: AI generated recipes from mock database
    return mockRecipes.where((r) => r.isAiGenerated).toList();
  }

  return matched;
});
