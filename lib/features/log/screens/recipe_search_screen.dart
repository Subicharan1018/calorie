import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/core/theme/color_scheme.dart';
import 'package:kalori/shared/widgets/app_scaffold.dart';
import 'package:kalori/shared/widgets/empty_state.dart';
import 'package:kalori/shared/widgets/friendly_error.dart';
import 'package:kalori/shared/widgets/tamil_english_label.dart';
import 'package:kalori/widgets/illustrations/empty_kolam_illustration.dart';
import 'package:kalori/features/log/models/recipe.dart';
import 'package:kalori/features/log/providers/recipe_name_search_provider.dart';
import 'package:kalori/features/log/widgets/recipe_detail_sheet.dart';
import 'package:kalori/l10n/app_strings.dart';

/// Search recipes by name (or ingredient) via the backend `/recipes?q=` endpoint.
/// This is the only place a user can find a dish like "Chana Sundal" by typing
/// its name — the vegetable flow only matches by ingredient code.
class RecipeSearchScreen extends ConsumerStatefulWidget {
  const RecipeSearchScreen({super.key});

  @override
  ConsumerState<RecipeSearchScreen> createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends ConsumerState<RecipeSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        ref.read(recipeNameQueryProvider.notifier).state = value;
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);
    final query = ref.watch(recipeNameQueryProvider);
    final resultsAsync = ref.watch(recipeNameSearchProvider);

    return AppScaffold(
      title: s.searchRecipesTitle,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              decoration: InputDecoration(
                hintText: s.searchRecipesHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: s.isTamil ? 'அழி' : 'Clear',
                        onPressed: () {
                          _controller.clear();
                          _debounce?.cancel();
                          ref.read(recipeNameQueryProvider.notifier).state = '';
                        },
                      ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: query.trim().isEmpty
                ? EmptyState(
                    headline: s.searchRecipesStartHeadline,
                    subtext: s.searchRecipesStartSub,
                    illustration: const EmptyKolamIllustration(size: 120),
                  )
                : resultsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => FriendlyErrorView(
                      error: err,
                      onRetry: () => ref.invalidate(recipeNameSearchProvider),
                    ),
                    data: (recipes) {
                      if (recipes.isEmpty) {
                        return EmptyState(
                          headline: s.searchRecipesEmptyHeadline,
                          subtext: s.searchRecipesEmptySub,
                          illustration: Icon(Icons.search_off,
                              size: 64, color: theme.colorScheme.outline),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                        itemCount: recipes.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) =>
                            _RecipeResultCard(recipe: recipes[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _RecipeResultCard extends StatelessWidget {
  final Recipe recipe;
  const _RecipeResultCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);

    return Card(
      elevation: AppElevation.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => RecipeDetailSheet(recipe: recipe),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TamilEnglishLabel(
                      englishText: recipe.englishName,
                      tamilText: recipe.tamilName,
                      englishStyle: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        _MacroDot(
                            color: theme.colorScheme.primary,
                            label:
                                '${s.carbs.substring(0, 1)}: ${recipe.carbsPer100g.toStringAsFixed(1)}g'),
                        const SizedBox(width: AppSpacing.sm),
                        _MacroDot(
                            color: theme.colorScheme.secondary,
                            label:
                                '${s.protein.substring(0, 1)}: ${recipe.proteinPer100g.toStringAsFixed(1)}g'),
                        const SizedBox(width: AppSpacing.sm),
                        _MacroDot(
                            color: AppColorScheme.macroFat,
                            label:
                                '${s.fat.substring(0, 1)}: ${recipe.fatPer100g.toStringAsFixed(1)}g'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                s.isTamil
                    ? '${recipe.kcalPer100g} கலோரி/100கி'
                    : '${recipe.kcalPer100g} kcal/100g',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroDot extends StatelessWidget {
  final Color color;
  final String label;
  const _MacroDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
