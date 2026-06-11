import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalori/core/models/daily_summary.dart';
import 'package:kalori/api/api_client.dart';
import 'package:kalori/features/profile/providers/profile_provider.dart';

class DashboardNotifier extends AsyncNotifier<DailySummary> {
  @override
  Future<DailySummary> build() async {
    final profile = await ref.watch(profileProvider.future);
    final summaryMap = await ApiClient.getTodaySummary();
    return DailySummary.fromJson(summaryMap, profile.targetKcal);
  }

  Future<void> deleteMeal(String id) async {
    final logId = int.tryParse(id);
    if (logId == null) return;
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ApiClient.deleteLog(logId);
      final profile = await ref.read(profileProvider.future);
      final summaryMap = await ApiClient.getTodaySummary();
      return DailySummary.fromJson(summaryMap, profile.targetKcal);
    });
  }
}

final dashboardProvider = AsyncNotifierProvider<DashboardNotifier, DailySummary>(() {
  return DashboardNotifier();
});
