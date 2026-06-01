import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/features/home/providers/dashboard_provider.dart';
import 'package:kalori/features/home/widgets/deficit_ring.dart';
import 'package:kalori/features/home/widgets/meal_log_summary.dart';
import 'package:kalori/features/home/widgets/micronutrient_snapshot.dart';
import 'package:kalori/shared/widgets/app_scaffold.dart';
import 'package:kalori/shared/widgets/stat_chip.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardProvider);
    final today = DateTime.now();
    final formatter = DateFormat('EEEE, d MMM');
    
    // Quick translation map for today's weekday in Tamil
    final Map<int, String> tamilDays = {
      1: 'திங்கள்', // Mon
      2: 'செவ்வாய்', // Tue
      3: 'புதன்', // Wed
      4: 'வியாழன்', // Thu
      5: 'வெள்ளி', // Fri
      6: 'சனி', // Sat
      7: 'ஞாயிறு', // Sun
    };
    final tamilDay = tamilDays[today.weekday] ?? '';

    return AppScaffold(
      title: 'Kalori',
      subtitle: '${formatter.format(today)} · $tamilDay',
      body: SingleChildScrollView(
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
                StatChip(label: 'Carbs', value: '${summary.consumedCarbs.toInt()}g', color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                StatChip(label: 'Protein', value: '${summary.consumedProtein.toInt()}g', color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: AppSpacing.sm),
                StatChip(label: 'Fat', value: '${summary.consumedFat.toInt()}g', color: Colors.amber),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Section C — Quick Actions
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: [
                  _QuickActionChip(label: 'Breakfast', onTap: () => context.go('/log')),
                  const SizedBox(width: AppSpacing.sm),
                  _QuickActionChip(label: 'Lunch', onTap: () => context.go('/log')),
                  const SizedBox(width: AppSpacing.sm),
                  _QuickActionChip(label: 'Snack', onTap: () => context.go('/log')),
                  const SizedBox(width: AppSpacing.sm),
                  _QuickActionChip(label: 'Dinner', onTap: () => context.go('/log')),
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
            
            // Section D — Micronutrients
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: MicronutrientSnapshot(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/log'),
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
