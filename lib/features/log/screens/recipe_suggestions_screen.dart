import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/shared/widgets/app_scaffold.dart';
import 'package:kalori/shared/widgets/empty_state.dart';
import 'package:kalori/shared/widgets/tamil_english_label.dart';
import 'package:kalori/features/log/providers/recipe_suggestions_provider.dart';
import 'package:kalori/features/log/providers/vegetable_search_provider.dart';
import 'package:kalori/features/log/widgets/recipe_detail_sheet.dart';
import 'package:kalori/widgets/skeletons/recipe_card_skeleton.dart';
import 'package:kalori/widgets/illustrations/empty_kolam_illustration.dart';
import 'package:kalori/l10n/app_strings.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RecipeSuggestionsScreen extends ConsumerStatefulWidget {
  const RecipeSuggestionsScreen({super.key});

  @override
  ConsumerState<RecipeSuggestionsScreen> createState() => _RecipeSuggestionsScreenState();
}

class _RecipeSuggestionsScreenState extends ConsumerState<RecipeSuggestionsScreen> {
  String _sortBy = 'best'; // 'best', 'kcal', 'protein'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);
    final suggestionsAsync = ref.watch(recipeSuggestionsProvider);
    final selectedCount = ref.watch(selectedVegetablesProvider).length;

    return AppScaffold(
      title: s.isTamil ? 'காய்கறிகளுக்கான சமையல் குறிப்புகள்' : 'Recipes for your vegetables',
      subtitle: s.isTamil ? '$selectedCount காய்கறிகள் தேர்வுசெய்யப்பட்டன' : '$selectedCount vegetables matched',
      body: suggestionsAsync.when(
        loading: () => const _LoadingView(),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text('${s.apiError}: $err', style: TextStyle(color: theme.colorScheme.error)),
          ),
        ),
        data: (recipes) {
          if (recipes.isEmpty) {
            return EmptyState(
              headline: s.emptyRecipesHeadline,
              subtext: s.emptyRecipesSub,
              illustration: const EmptyKolamIllustration(size: 140),
            );
          }

          // Apply local sorting logic
          final sortedRecipes = List.of(recipes);
          if (_sortBy == 'kcal') {
            sortedRecipes.sort((a, b) => a.kcalPer100g.compareTo(b.kcalPer100g));
          } else if (_sortBy == 'protein') {
            sortedRecipes.sort((a, b) => b.proteinPer100g.compareTo(a.proteinPer100g));
          }

          final aiCount = sortedRecipes.where((r) => r.isAiGenerated).length;

          return Column(
            children: [
              // Sorting filters bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      s.isTamil
                          ? 'மொத்தம்: ${sortedRecipes.length} சமையல் குறிப்புகள் · $aiCount AI'
                          : 'Showing ${sortedRecipes.length} recipes · $aiCount from AI',
                      style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline),
                    ),
                    const Icon(Icons.sort, size: 20),
                  ],
                ),
              ),
              
              // Sort selection row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    _SortChip(
                      label: s.bestMatch,
                      isSelected: _sortBy == 'best',
                      onSelected: () => setState(() => _sortBy = 'best'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _SortChip(
                      label: s.lowestCal,
                      isSelected: _sortBy == 'kcal',
                      onSelected: () => setState(() => _sortBy = 'kcal'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _SortChip(
                      label: s.bestProtein,
                      isSelected: _sortBy == 'protein',
                      onSelected: () => setState(() => _sortBy = 'protein'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  itemCount: sortedRecipes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final recipe = sortedRecipes[index];
                    return Card(
                      elevation: AppElevation.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            builder: (_) => RecipeDetailSheet(recipe: recipe),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Expanded(
                                      child: TamilEnglishLabel(
                                        englishText: recipe.englishName,
                                        tamilText: recipe.tamilName,
                                        englishStyle: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  Text(
                                    s.isTamil
                                        ? '${recipe.kcalPer100g} கலோரி/100கி'
                                        : '${recipe.kcalPer100g} kcal/100g',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              if (recipe.isAiGenerated) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE49E22).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    s.isTamil ? 'AI பரிந்துரைத்தது' : 'AI Suggested',
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF7A4A00), fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                children: [
                                  _MacroDot(color: theme.colorScheme.primary, label: '${s.carbs.substring(0, 1)}: ${recipe.carbsPer100g.toStringAsFixed(1)}g'),
                                  const SizedBox(width: AppSpacing.sm),
                                  _MacroDot(color: theme.colorScheme.secondary, label: '${s.protein.substring(0, 1)}: ${recipe.proteinPer100g.toStringAsFixed(1)}g'),
                                  const SizedBox(width: AppSpacing.sm),
                                  _MacroDot(color: const Color(0xFFD47A22), label: '${s.fat.substring(0, 1)}: ${recipe.fatPer100g.toStringAsFixed(1)}g'),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: recipe.matchedVegetableNames.map((name) {
                                  String displayName = name;
                                  if (s.isTamil) {
                                    final Map<String, String> vegTranslations = {
                                      'drumstick': 'முருங்கைக்காய்',
                                      'raw banana': 'வாழைக்காய்',
                                      'ash gourd': 'சாம்பல் பூசணி',
                                      'banana flower': 'வாழைப்பூ',
                                      'yam': 'சேனைக்கிழங்கு',
                                      'snake gourd': 'புடலங்காய்',
                                      'cluster beans': 'கொத்தவரங்காய்',
                                      'brinjal': 'கத்திரிக்காய்',
                                      'spinach': 'பசலைக்கீரை',
                                      'bitter gourd': 'பாகற்காய்',
                                      'carrot': 'கேரட்',
                                      'ladies finger': 'வெண்டைக்காய்',
                                      'potato': 'உருளைக்கிழங்கு',
                                      'broad beans': 'அவரைக்காய்',
                                      'tapioca': 'மரவள்ளிக்கிழங்கு',
                                      'cabbage': 'முட்டைக்கோஸ்',
                                      'beetroot': 'பீட்ரூட்',
                                      'ridge gourd': 'பீர்க்கங்காய்',
                                      'ivy gourd': 'கோவைக்காய்',
                                      'bottle gourd': 'சுரைக்காய்',
                                    };
                                    displayName = vegTranslations[name.toLowerCase()] ?? name;
                                  }
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainer,
                                      borderRadius: BorderRadius.circular(AppRadius.chip),
                                    ),
                                    child: Text(displayName, style: theme.textTheme.labelSmall),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fade(delay: (40 * index).ms).slideY(begin: 0.1, duration: 300.ms, curve: Curves.easeOutCubic);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _SortChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.zero,
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
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _LoadingView extends StatefulWidget {
  const _LoadingView();

  @override
  State<_LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<_LoadingView> {
  bool _isParsing = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _isParsing = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);
    return Column(
      children: [
        const LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            _isParsing ? s.parsingRecipes : s.aiGenerating,
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, __) => const RecipeCardSkeleton(),
          ),
        ),
      ],
    );
  }
}
