import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kalori/core/models/weight_log.dart';
import 'package:intl/intl.dart';
import 'package:kalori/l10n/app_strings.dart';

class WeightProgressChart extends StatelessWidget {
  final List<WeightLog> history;
  final double goalWeight;

  const WeightProgressChart({super.key, required this.history, required this.goalWeight});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final s = AppStrings.of(context);
    final minWeight = history.map((w) => w.weightKg).reduce((a, b) => a < b ? a : b);
    final maxWeight = history.map((w) => w.weightKg).reduce((a, b) => a > b ? a : b);
    
    // Expand Y-axis slightly
    final minY = (minWeight < goalWeight ? minWeight : goalWeight) - 2.0;
    final maxY = maxWeight + 2.0;

    // Linear regression for trend line
    final firstDate = history.first.date;
    final points = history.map((w) {
      final x = w.date.difference(firstDate).inDays.toDouble();
      return FlSpot(x, w.weightKg);
    }).toList();

    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    for (var p in points) {
      sumX += p.x;
      sumY += p.y;
      sumXY += p.x * p.y;
      sumX2 += p.x * p.x;
    }
    
    final n = points.length.toDouble();
    double m = 0;
    double b = points.isEmpty ? 0 : points.first.y;
    
    if (n > 1) {
      final denominator = (n * sumX2 - sumX * sumX);
      if (denominator != 0) {
        m = (n * sumXY - sumX * sumY) / denominator;
        b = (sumY - m * sumX) / n;
      }
    }

    final trendPoints = points.isEmpty ? <FlSpot>[] : [
      FlSpot(points.first.x, m * points.first.x + b),
      FlSpot(points.last.x, m * points.last.x + b),
    ];

    return AspectRatio(
      aspectRatio: 1.5,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2.0,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (points.isEmpty) return const SizedBox.shrink();
                  final date = firstDate.add(Duration(days: value.toInt()));
                  // Only show label if it aligns somewhat, simplify for UI
                  if (value % 5 != 0 && value != points.last.x) return const SizedBox.shrink();
                  final localeStr = s.locale.toString();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('d MMM', localeStr).format(date),
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline, fontWeight: FontWeight.bold),
                    ),
                  );
                },
                interval: 5,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(1),
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: goalWeight,
                color: theme.colorScheme.secondary,
                strokeWidth: 2,
                dashArray: [5, 5],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 8, bottom: 4),
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold),
                  labelResolver: (line) => s.isTamil ? 'இலக்கு ${line.y}கி.கி' : 'Goal ${line.y}kg',
                ),
              ),
            ],
          ),
          lineBarsData: [
            // Actual weight data points
            LineChartBarData(
              spots: points,
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
            // Trend line
            if (trendPoints.length > 1)
              LineChartBarData(
                spots: trendPoints,
                isCurved: false,
                color: theme.colorScheme.outline,
                barWidth: 2,
                dashArray: [4, 4],
                dotData: const FlDotData(show: false),
              ),
          ],
        ),
      ),
    );
  }
}
