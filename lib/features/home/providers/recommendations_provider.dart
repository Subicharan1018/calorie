import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalori/api/api_client.dart';
import 'package:kalori/core/models/nutrient_gaps.dart';
import 'package:kalori/core/models/recommendation_item.dart';

// Provider for nutrient gaps (defaults to yesterday)
final nutrientGapsProvider = FutureProvider.autoDispose<NutrientGaps?>((ref) async {
  try {
    final data = await ApiClient.getNutrientGaps();
    if (data == null || data['message'] != null) {
      return null;
    }
    return NutrientGaps.fromJson(data);
  } catch (_) {
    return null;
  }
});

class RecommendationsState {
  final String date;
  final Map<String, List<RecommendationItem>> slots;

  const RecommendationsState({required this.date, required this.slots});
}

class RecommendationsNotifier extends AsyncNotifier<RecommendationsState> {
  @override
  Future<RecommendationsState> build() async {
    final Map<String, dynamic> data = await ApiClient.getRecommendations();
    return _parse(data);
  }

  RecommendationsState _parse(Map<String, dynamic> data) {
    final date = data['date'] as String? ?? '';
    final slots = <String, List<RecommendationItem>>{};
    
    for (final slot in ['breakfast', 'lunch', 'dinner', 'snack']) {
      final list = data[slot] as List<dynamic>? ?? [];
      slots[slot] = list.map((e) => RecommendationItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    
    return RecommendationsState(date: date, slots: slots);
  }

  /// Recomputes recommendations on the backend (e.g. after a logging session)
  Future<void> forceRefresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final data = await ApiClient.refreshRecommendations();
      // Also trigger a refresh of yesterday's nutrient gaps since intake has changed
      ref.invalidate(nutrientGapsProvider);
      return _parse(data);
    });
  }
}

final recommendationsProvider = AsyncNotifierProvider<RecommendationsNotifier, RecommendationsState>(() {
  return RecommendationsNotifier();
});
