import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/core/theme/color_scheme.dart';
import 'package:kalori/features/home/providers/dashboard_provider.dart';
import 'package:kalori/features/home/widgets/deficit_ring.dart';
import 'package:kalori/features/home/widgets/meal_log_summary.dart';
import 'package:kalori/features/home/widgets/micronutrient_snapshot.dart';
import 'package:kalori/features/home/widgets/food_recommendations.dart';
import 'package:kalori/shared/widgets/app_scaffold.dart';
import 'package:kalori/shared/widgets/stat_chip.dart';
import 'package:kalori/shared/widgets/friendly_error.dart';
import 'package:intl/intl.dart';
import 'package:kalori/l10n/app_strings.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardProvider);
    final today = DateTime.now();
    final s = AppStrings.of(context);
    // Let chip rows grow with the user's text scale (tested up to 1.3×).
    final textScale = MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.6);
    final formatter = DateFormat('EEEE, d MMM');
    
    final Map<int, String> tamilDays = {
      1: 'திங்கள்',
      2: 'செவ்வாய்',
      3: 'புதன்',
      4: 'வியாழன்',
      5: 'வெள்ளி',
      6: 'சனி',
      7: 'ஞாயிறு',
    };
    final tamilDay = tamilDays[today.weekday] ?? '';

    return AppScaffold(
      title: 'Kalori',
      subtitle: s.isTamil
          ? '$tamilDay, ${today.day} ${DateFormat('MMM').format(today)}'
          : formatter.format(today),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => FriendlyErrorView(
          error: err,
          onRetry: () => ref.invalidate(dashboardProvider),
        ),
        data: (summary) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                // Section A — Hero Deficit Ring
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: DeficitRingWidget(summary: summary),
                ),
                // Macros summary below ring
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatChip(label: s.carbs, value: '${summary.consumedCarbs.toInt()}g', color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: AppSpacing.sm),
                    StatChip(label: s.protein, value: '${summary.consumedProtein.toInt()}g', color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(width: AppSpacing.sm),
                    StatChip(label: s.fat, value: '${summary.consumedFat.toInt()}g', color: AppColorScheme.macroFat),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                
                // Section C — Quick Actions
                SizedBox(
                  height: 40.0 * textScale,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    children: [
                      _QuickActionChip(label: s.breakfast.split(' · ').first, onTap: () => context.go('/log')),
                      const SizedBox(width: AppSpacing.sm),
                      _QuickActionChip(label: s.lunch.split(' · ').first, onTap: () => context.go('/log')),
                      const SizedBox(width: AppSpacing.sm),
                      _QuickActionChip(label: s.snack.split(' · ').first, onTap: () => context.go('/log')),
                      const SizedBox(width: AppSpacing.sm),
                      _QuickActionChip(label: s.dinner.split(' · ').first, onTap: () => context.go('/log')),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                
                // Section B — Meal Log Summary
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: MealLogSummaryList(
                    meals: summary.meals,
                    onDelete: (id) => ref.read(dashboardProvider.notifier).deleteMeal(id),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Section E — Recommendations
                const FoodRecommendationsWidget(),
                const SizedBox(height: AppSpacing.lg),
                
                // Section D — Micronutrients
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: MicronutrientSnapshot(),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
            ),
            builder: (context) {
              final s = AppStrings.of(context);
              final theme = Theme.of(context);
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(Icons.restaurant, color: theme.colorScheme.onPrimaryContainer),
                      ),
                      title: Text(s.isTamil ? 'உணவு வகையை பதிவுசெய்' : 'Log Vegetable Meal'),
                      subtitle: Text(s.isTamil ? 'காய்கறிகளைத் தேர்ந்தெடுத்து உணவு வகைகளைப் பரிந்துரைக்கச் செய்யவும்' : 'Search local vegetables & suggest recipes'),
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/log');
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        child: Icon(Icons.qr_code_scanner, color: theme.colorScheme.onSecondaryContainer),
                      ),
                      title: Text(s.scanBarcode),
                      subtitle: Text(s.isTamil ? 'பார்கோடு ஸ்கேன் செய்து உணவைச் சேர்க்கவும்' : 'Scan packaged products and log quickly'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/scanner');
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
