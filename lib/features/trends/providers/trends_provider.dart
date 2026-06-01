import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalori/core/models/weight_log.dart';

class DailyCalorieLog {
  final DateTime date;
  final int consumedKcal;
  final int targetKcal;

  const DailyCalorieLog({
    required this.date,
    required this.consumedKcal,
    required this.targetKcal,
  });
}

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
    final now = DateTime.now();
    return TrendsState(
      goalWeight: 65.0,
      last7Days: List.generate(7, (i) {
        final daysAgo = 6 - i;
        final date = now.subtract(Duration(days: daysAgo));
        // Mock data: some under target, some over
        final consumed = [1900, 2150, 1850, 2400, 2050, 1950, 2100][i];
        return DailyCalorieLog(date: date, consumedKcal: consumed, targetKcal: 2100);
      }),
      weightHistory: [
        WeightLog(id: '1', date: now.subtract(const Duration(days: 14)), weightKg: 73.6),
        WeightLog(id: '2', date: now.subtract(const Duration(days: 10)), weightKg: 73.2),
        WeightLog(id: '3', date: now.subtract(const Duration(days: 7)), weightKg: 72.8),
        WeightLog(id: '4', date: now.subtract(const Duration(days: 3)), weightKg: 72.4),
      ],
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
