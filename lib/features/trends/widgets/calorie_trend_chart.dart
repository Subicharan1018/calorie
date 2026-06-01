import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kalori/features/trends/providers/trends_provider.dart';
import 'package:intl/intl.dart';

class CalorieTrendChart extends StatelessWidget {
  final List<DailyCalorieLog> logs;

  const CalorieTrendChart({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (logs.isEmpty) return const SizedBox.shrink();

    final target = logs.first.targetKcal.toDouble();
    final maxY = (target * 1.5).ceilToDouble();

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => theme.colorScheme.surfaceContainer,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final log = logs[groupIndex];
                final diff = log.consumedKcal - log.targetKcal;
                final diffText = diff > 0 ? '+$diff kcal' : '$diff kcal';
                return BarTooltipItem(
                  '${log.consumedKcal} kcal\n$diffText',
                  theme.textTheme.labelMedium!.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 || value.toInt() >= logs.length) return const SizedBox.shrink();
                  final date = logs[value.toInt()].date;
                  final formatter = DateFormat('E');
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      formatter.format(date).substring(0, 1), // M, T, W, etc
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: target,
            getDrawingHorizontalLine: (value) {
              if (value == target) {
                return FlLine(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                );
              }
              return const FlLine(color: Colors.transparent);
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(logs.length, (index) {
            final log = logs[index];
            final consumed = log.consumedKcal.toDouble();
            
            Color barColor = Colors.green; // under target
            if (consumed > target) {
              if (consumed <= target * 1.1) {
                barColor = Colors.amber; // 0-10% over
              } else {
                barColor = theme.colorScheme.error; // >10% over
              }
            }

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: consumed,
                  color: barColor,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
