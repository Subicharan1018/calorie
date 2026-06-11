class WeightLog {
  final String id;
  final DateTime date;
  final double weightKg;
  final String? note;

  const WeightLog({
    required this.id,
    required this.date,
    required this.weightKg,
    this.note,
  });

  factory WeightLog.fromJson(Map<String, dynamic> json) {
    final DateTime date = DateTime.tryParse(json['logged_at'] as String? ?? '') ?? DateTime.now();
    return WeightLog(
      id: (json['id'] ?? '').toString(),
      date: date,
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0.0,
      note: json['note'] as String?,
    );
  }
}
