import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalori/features/log/models/vegetable.dart';
import 'package:kalori/mock/mock_data.dart';

final vegetableSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedVegetablesProvider = StateProvider<List<Vegetable>>((ref) => []);

final searchResultsProvider = Provider<List<Vegetable>>((ref) {
  final query = ref.watch(vegetableSearchQueryProvider).toLowerCase();
  final selected = ref.watch(selectedVegetablesProvider);
  final selectedIds = selected.map((v) => v.id).toSet();
  
  if (query.isEmpty) {
    return mockVegetables.where((v) => !selectedIds.contains(v.id)).toList();
  }
  
  return mockVegetables.where((v) {
    if (selectedIds.contains(v.id)) return false;
    return v.englishName.toLowerCase().contains(query) || v.tamilName.toLowerCase().contains(query);
  }).toList();
});
