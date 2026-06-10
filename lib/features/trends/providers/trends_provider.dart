import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalori/core/models/weight_log.dart';
import 'package:kalori/core/models/daily_calorie_log.dart';
import 'package:kalori/mock/mock_data.dart';

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

class TrendsNotifier extends Notifier<TrendsState> {
  @override
  TrendsState build() {
    // Convert mockCalorieTrend (from mock_data.dart) to the DailyCalorieLog here
    final convertedTrend = mockCalorieTrend.map((log) => DailyCalorieLog(
      date: log.date,
      consumedKcal: log.consumedKcal,
      targetKcal: log.targetKcal,
    )).toList();

    return TrendsState(
      goalWeight: 65.0,
      last7Days: convertedTrend,
      weightHistory: List.from(mockWeightLogs),
    );
  }

  void addWeightLog(WeightLog log) {
    state = TrendsState(
      last7Days: state.last7Days,
      goalWeight: state.goalWeight,
      weightHistory: [...state.weightHistory, log]..sort((a, b) => a.date.compareTo(b.date)),
    );
  }
}

final trendsProvider = NotifierProvider<TrendsNotifier, TrendsState>(() => TrendsNotifier());
