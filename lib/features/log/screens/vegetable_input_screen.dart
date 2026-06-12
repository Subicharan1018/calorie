import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/shared/widgets/app_scaffold.dart';
import 'package:kalori/shared/widgets/empty_state.dart';
import 'package:kalori/shared/widgets/friendly_error.dart';
import 'package:kalori/shared/widgets/tamil_english_label.dart';
import 'package:kalori/features/log/providers/vegetable_search_provider.dart';
import 'package:kalori/l10n/app_strings.dart';

class VegetableInputScreen extends ConsumerWidget {
  const VegetableInputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);
    final searchResults = ref.watch(searchResultsProvider);
    final selectedVegetables = ref.watch(selectedVegetablesProvider);

    return AppScaffold(
      title: s.whatVegetablesDoYouHave,
      subtitle: s.wellFindRecipes,
      actions: [
        IconButton(
          icon: const Icon(Icons.menu_book_outlined),
          tooltip: s.searchRecipesTitle,
          onPressed: () => context.push('/log/search'),
        ),
      ],
      body: Column(
        children: [
          // Sticky top Search Bar Row with Scan Barcode button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: s.searchVegetables,
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
                const SizedBox(width: AppSpacing.sm),
                IconButton.outlined(
                  onPressed: () => context.push('/scanner'),
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                  icon: const Icon(Icons.qr_code_scanner),
                ),
              ],
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
                    label: Text(s.isTamil ? veg.tamilName.split(' (').first : veg.englishName),
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
            child: searchResults.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => FriendlyErrorView(
                error: err,
                onRetry: () => ref.invalidate(searchResultsProvider),
              ),
              data: (results) {
                if (results.isEmpty && ref.watch(vegetableSearchQueryProvider).isEmpty) {
                  return EmptyState(
                    headline: s.isTamil ? 'தேடத் தொடங்கவும்' : 'Start searching',
                    subtext: s.searchAndAddAbove,
                    illustration: Icon(Icons.shopping_basket, size: 64, color: theme.colorScheme.outline),
                  );
                }
                if (results.isEmpty) {
                  return EmptyState(
                    headline: s.isTamil ? 'முடிவுகள் எதுவும் இல்லை' : 'No results found',
                    subtext: s.emptySearchResult,
                    illustration: Icon(Icons.search_off, size: 64, color: theme.colorScheme.outline),
                  );
                }
                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final veg = results[index];
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
                        s.isTamil
                            ? '${veg.kcalPer100g} கலோரி/100கி'
                            : '${veg.kcalPer100g} kcal/100g',
                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                      onTap: () {
                        ref.read(selectedVegetablesProvider.notifier).update((state) => [...state, veg]);
                        ref.read(vegetableSearchQueryProvider.notifier).state = ''; // clear search
                      },
                    );
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
                  s.isTamil
                      ? '${selectedVegetables.length} தேர்ந்தெடுக்கப்பட்டுள்ளது'
                      : '${selectedVegetables.length} selected',
                  style: theme.textTheme.titleMedium,
                ),
                FilledButton(
                  onPressed: selectedVegetables.isEmpty ? null : () => context.push('/log/recipes'),
                  child: Text(s.findRecipes),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
