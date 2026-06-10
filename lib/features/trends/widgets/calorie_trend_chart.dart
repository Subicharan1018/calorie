import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kalori/core/models/daily_calorie_log.dart';
import 'package:intl/intl.dart';
import 'package:kalori/l10n/app_strings.dart';

class CalorieTrendChart extends StatelessWidget {
  final List<DailyCalorieLog> logs;

  const CalorieTrendChart({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);
    if (logs.isEmpty) return const SizedBox.shrink();

    final target = logs.first.targetKcal.toDouble();
    final maxY = (target * 1.5).ceilToDouble();

    // Tamil weekdays short labels mapping
    final Map<int, String> tamilShortDays = {
      1: 'தி', // Mon
      2: 'செ', // Tue
      3: 'பு', // Wed
      4: 'வி', // Thu
      5: 'வெ', // Fri
      6: 'ச',  // Sat
      7: 'ஞ',  // Sun
    };

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
                final diffText = diff > 0 
                    ? (s.isTamil ? '+$diff கலோரி' : '+$diff kcal') 
                    : (s.isTamil ? '$diff கலோரி' : '$diff kcal');
                return BarTooltipItem(
                  s.isTamil 
                      ? '${log.consumedKcal} கலோரி\n$diffText'
                      : '${log.consumedKcal} kcal\n$diffText',
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
                  final dayLabel = s.isTamil 
                      ? (tamilShortDays[date.weekday] ?? '') 
                      : DateFormat('E').format(date).substring(0, 1);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      dayLabel,
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline, fontWeight: FontWeight.bold),
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
            
            Color barColor = theme.colorScheme.primary; // under target
            if (consumed > target) {
              if (consumed <= target * 1.1) {
                barColor = theme.colorScheme.secondary; // 0-10% over
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
