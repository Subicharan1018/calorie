import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalori/features/log/models/ingredient.dart';
import 'package:kalori/api/api_client.dart';

final vegetableSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedVegetablesProvider = StateProvider<List<Ingredient>>((ref) => []);

final searchResultsProvider = FutureProvider.autoDispose<List<Ingredient>>((ref) async {
  final query = ref.watch(vegetableSearchQueryProvider);
  final selected = ref.watch(selectedVegetablesProvider);
  final selectedCodes = selected.map((v) => v.code).toSet();

  if (query.trim().isEmpty) {
    // Return empty list initially.
    return <Ingredient>[];
  }

  final results = await ApiClient.searchIngredients(query);
  final ingredients = results.map((e) => Ingredient.fromJson(e as Map<String, dynamic>)).toList();
  
  // Filter out already selected items
  return ingredients.where((i) => !selectedCodes.contains(i.code)).toList();
});
