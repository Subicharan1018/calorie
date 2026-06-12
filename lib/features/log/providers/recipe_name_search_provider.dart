import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalori/features/log/models/recipe.dart';
import 'package:kalori/api/api_client.dart';

/// The current recipe-name search query (e.g. "chana", "sundal").
final recipeNameQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Searches recipes by name via `/recipes?q=`. The backend tokenises the query
/// and also matches ingredient names, so "sundal", "chana sundal" and reversed
/// word order all resolve. Returns [] for an empty query.
final recipeNameSearchProvider =
    FutureProvider.autoDispose<List<Recipe>>((ref) async {
  final query = ref.watch(recipeNameQueryProvider).trim();
  if (query.isEmpty) return [];

  final results = await ApiClient.getRecipes(q: query, limit: 30);
  return results
      .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
      .toList();
});
