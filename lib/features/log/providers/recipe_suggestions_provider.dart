import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalori/features/log/models/recipe.dart';
import 'package:kalori/features/log/providers/vegetable_search_provider.dart';
import 'package:kalori/api/api_client.dart';

final recipeSuggestionsProvider = FutureProvider.autoDispose<List<Recipe>>((ref) async {
  final selected = ref.watch(selectedVegetablesProvider);
  if (selected.isEmpty) return [];

  final codes = selected.map((v) => v.code).join(',');
  final results = await ApiClient.getRecipes(ingredients: codes);
  
  return results.map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList();
});
