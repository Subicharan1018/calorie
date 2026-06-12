import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/features/trends/providers/trends_provider.dart';
import 'package:kalori/features/trends/widgets/calorie_trend_chart.dart';
import 'package:kalori/features/trends/widgets/weight_progress_chart.dart';
import 'package:kalori/features/trends/widgets/weight_log_sheet.dart';
import 'package:kalori/shared/widgets/app_scaffold.dart';
import 'package:kalori/shared/widgets/friendly_error.dart';
import 'package:kalori/l10n/app_strings.dart';

class TrendsScreen extends ConsumerWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);
    final stateAsync = ref.watch(trendsProvider);

    return AppScaffold(
      title: s.trends,
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => FriendlyErrorView(
          error: err,
          onRetry: () => ref.invalidate(trendsProvider),
        ),
        data: (state) {
          String weightStat = s.isTamil ? 'கூடுதல் எடை தரவை பதிவு செய்க' : 'Log more weight data';
          if (state.weightHistory.length >= 2) {
            final first = state.weightHistory.first;
            final last = state.weightHistory.last;
            final diff = last.weightKg - first.weightKg;
            final days = last.date.difference(first.date).inDays;
            if (diff < 0) {
              weightStat = s.isTamil
                  ? '${diff.abs().toStringAsFixed(1)} கி.கி குறைந்துள்ளது ($days நாட்களில்)'
                  : 'Lost ${diff.abs().toStringAsFixed(1)} kg in $days days';
            } else if (diff > 0) {
              weightStat = s.isTamil
                  ? '${diff.toStringAsFixed(1)} கி.கி அதிகரித்துள்ளது ($days நாட்களில்)'
                  : 'Gained ${diff.toStringAsFixed(1)} kg in $days days';
            } else {
              weightStat = s.isTamil
                  ? 'அதே எடை பராமரிக்கப்படுகிறது ($days நாட்களாக)'
                  : 'Maintained weight over $days days';
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                
                // Section A — Calorie Trend
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(s.calorieTrend, style: theme.textTheme.titleLarge),
                ),
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Card(
                    elevation: AppElevation.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: CalorieTrendChart(logs: state.last7Days),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Section B — Weight Progress
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(s.weightProgress, style: theme.textTheme.titleLarge),
                ),
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Card(
                    elevation: AppElevation.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          WeightProgressChart(history: state.weightHistory, goalWeight: state.goalWeight),
                          const SizedBox(height: AppSpacing.lg),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(AppRadius.button),
                            ),
                            child: Text(
                              weightStat,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const WeightLogSheet(),
          );
        },
        icon: const Icon(Icons.monitor_weight),
        label: Text(s.logWeight),
      ),
    );
  }
}
