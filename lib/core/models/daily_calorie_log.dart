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
