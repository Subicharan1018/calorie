import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalori/features/log/models/vegetable.dart';

// Mock DB
const _mockVegetables = [
  Vegetable(id: '1', englishName: 'Drumstick', tamilName: 'முருங்கைக்காய் (Murungakkai)', category: 'Gourd', kcalPer100g: 37),
  Vegetable(id: '2', englishName: 'Ash Gourd', tamilName: 'நீர் பூசணி (Neer Poosani)', category: 'Gourd', kcalPer100g: 13),
  Vegetable(id: '3', englishName: 'Raw Banana', tamilName: 'வாழைக்காய் (Vazhakkai)', category: 'Root', kcalPer100g: 116),
  Vegetable(id: '4', englishName: 'Broad Beans', tamilName: 'அவரைக்காய் (Avarakkai)', category: 'Legume', kcalPer100g: 34),
  Vegetable(id: '5', englishName: 'Amaranth Leaves', tamilName: 'அரைக்கீரை (Arai Keerai)', category: 'Leafy Green', kcalPer100g: 23),
  Vegetable(id: '6', englishName: 'Lady\'s Finger', tamilName: 'வெண்டைக்காய் (Vendaikkai)', category: 'Gourd', kcalPer100g: 33),
];

final vegetableSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedVegetablesProvider = StateProvider<List<Vegetable>>((ref) => []);

final searchResultsProvider = Provider<List<Vegetable>>((ref) {
  final query = ref.watch(vegetableSearchQueryProvider).toLowerCase();
  final selected = ref.watch(selectedVegetablesProvider);
  
  if (query.isEmpty) return _mockVegetables.where((v) => !selected.contains(v)).toList();
  
  return _mockVegetables.where((v) {
    if (selected.contains(v)) return false;
    return v.englishName.toLowerCase().contains(query) || v.tamilName.toLowerCase().contains(query);
  }).toList();
});
