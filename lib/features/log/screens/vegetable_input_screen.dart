import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/shared/widgets/app_scaffold.dart';
import 'package:kalori/shared/widgets/empty_state.dart';
import 'package:kalori/shared/widgets/tamil_english_label.dart';
import 'package:kalori/features/log/providers/vegetable_search_provider.dart';

class VegetableInputScreen extends ConsumerWidget {
  const VegetableInputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final searchResults = ref.watch(searchResultsProvider);
    final selectedVegetables = ref.watch(selectedVegetablesProvider);

    return AppScaffold(
      title: 'What vegetables do you have?',
      subtitle: 'We\'ll find South Indian recipes that match',
      body: Column(
        children: [
          // Sticky top Search Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search in English or Tamil...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => ref.read(vegetableSearchQueryProvider.notifier).state = val,
            ),
          ),
          
          // Selected Vegetables Chip Row
          if (selectedVegetables.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: selectedVegetables.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final veg = selectedVegetables[index];
                  return Chip(
                    label: Text(veg.englishName),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      ref.read(selectedVegetablesProvider.notifier).update((state) {
                        return state.where((v) => v.id != veg.id).toList();
                      });
                    },
                  ).animate().scale(duration: 180.ms, curve: Curves.easeOutCubic);
                },
              ),
            ),
          
          const Divider(height: AppSpacing.lg),

          // Search Results List
          Expanded(
            child: searchResults.isEmpty && ref.watch(vegetableSearchQueryProvider).isEmpty
                ? const EmptyState(
                    headline: 'Start searching',
                    subtext: 'Search for a vegetable to add it to your kitchen list.',
                    illustration: Icon(Icons.shopping_basket, size: 64, color: Colors.grey),
                  )
                : searchResults.isEmpty
                    ? const EmptyState(
                        headline: 'No results found',
                        subtext: 'Try searching by the vegetable\'s common name.',
                        illustration: Icon(Icons.search_off, size: 64, color: Colors.grey),
                      )
                    : ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final veg = searchResults[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.surfaceContainer,
                              child: const Icon(Icons.grass, size: 16),
                            ),
                            title: TamilEnglishLabel(
                              englishText: veg.englishName,
                              tamilText: veg.tamilName,
                            ),
                            trailing: Text(
                              '${veg.kcalPer100g} kcal/100g',
                              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                            ),
                            onTap: () {
                              ref.read(selectedVegetablesProvider.notifier).update((state) => [...state, veg]);
                              ref.read(vegetableSearchQueryProvider.notifier).state = ''; // clear search
                            },
                          );
                        },
                      ),
          ),
          
          // Sticky Bottom Bar
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${selectedVegetables.length} selected',
                  style: theme.textTheme.titleMedium,
                ),
                FilledButton(
                  onPressed: selectedVegetables.isEmpty ? null : () => context.push('/log/recipes'),
                  child: const Text('Find Recipes →'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
