import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kalori/core/models/weight_log.dart';
import 'package:kalori/core/models/daily_calorie_log.dart';
import 'package:kalori/core/models/meal_log.dart';
import 'package:kalori/api/api_client.dart';
import 'package:kalori/features/profile/providers/profile_provider.dart';

class TrendsState {
  final List<DailyCalorieLog> last7Days;
  final List<WeightLog> weightHistory;
  final double goalWeight;

  const TrendsState({
    required this.last7Days,
    required this.weightHistory,
    required this.goalWeight,
  });
}

class TrendsNotifier extends AsyncNotifier<TrendsState> {
  @override
  Future<TrendsState> build() async {
    final profile = await ref.watch(profileProvider.future);
    final targetKcal = profile.targetKcal;

    // Fetch weight history
    final weightData = await ApiClient.getWeightHistory(days: 90);
    final List<dynamic> weightLogsRaw = weightData['logs'] as List<dynamic>? ?? [];
    final weightHistory = weightLogsRaw.map((e) => WeightLog.fromJson(e as Map<String, dynamic>)).toList();

    // Fetch meal history (last 7 days)
    final mealHistoryRaw = await ApiClient.getMealHistory(days: 7);
    final mealHistory = mealHistoryRaw.map((e) => MealLog.fromJson(e as Map<String, dynamic>)).toList();

    final today = DateTime.now();
    final List<DailyCalorieLog> last7Days = [];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      final mealsOnDate = mealHistory.where((m) {
        if (m.loggedAt == null) return false;
        final loggedDateStr = m.loggedAt!.split('T').first;
        return loggedDateStr == dateStr;
      });

      final consumed = mealsOnDate.fold(0, (sum, m) => sum + m.kcal);

      last7Days.add(DailyCalorieLog(
        date: date,
        consumedKcal: consumed,
        targetKcal: targetKcal,
      ));
    }

    return TrendsState(
      goalWeight: 65.0,
      last7Days: last7Days,
      weightHistory: weightHistory..sort((a, b) => a.date.compareTo(b.date)),
    );
  }

  Future<void> addWeightLog(WeightLog log) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ApiClient.logWeight(log.weightKg, note: log.note);
      
      final profile = await ref.read(profileProvider.future);
      final targetKcal = profile.targetKcal;

      final weightData = await ApiClient.getWeightHistory(days: 90);
      final List<dynamic> weightLogsRaw = weightData['logs'] as List<dynamic>? ?? [];
      final weightHistory = weightLogsRaw.map((e) => WeightLog.fromJson(e as Map<String, dynamic>)).toList();

      final mealHistoryRaw = await ApiClient.getMealHistory(days: 7);
      final mealHistory = mealHistoryRaw.map((e) => MealLog.fromJson(e as Map<String, dynamic>)).toList();

      final today = DateTime.now();
      final List<DailyCalorieLog> last7Days = [];

      for (int i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        final dateStr = DateFormat('yyyy-MM-dd').format(date);

        final mealsOnDate = mealHistory.where((m) {
          if (m.loggedAt == null) return false;
          final loggedDateStr = m.loggedAt!.split('T').first;
          return loggedDateStr == dateStr;
        });

        final consumed = mealsOnDate.fold(0, (sum, m) => sum + m.kcal);

        last7Days.add(DailyCalorieLog(
          date: date,
          consumedKcal: consumed,
          targetKcal: targetKcal,
        ));
      }

      return TrendsState(
        goalWeight: 65.0,
        last7Days: last7Days,
        weightHistory: weightHistory..sort((a, b) => a.date.compareTo(b.date)),
      );
    });
  }
}

final trendsProvider = AsyncNotifierProvider<TrendsNotifier, TrendsState>(() => TrendsNotifier());
