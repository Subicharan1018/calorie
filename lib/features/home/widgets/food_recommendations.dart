import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/core/theme/color_scheme.dart';
import 'package:kalori/l10n/app_strings.dart';
import 'package:kalori/core/models/recommendation_item.dart';
import 'package:kalori/features/home/providers/recommendations_provider.dart';
import 'package:kalori/features/home/providers/dashboard_provider.dart';
import 'package:kalori/api/api_client.dart';
import 'package:kalori/shared/widgets/friendly_error.dart';
import 'package:kalori/widgets/error_toast.dart';

class FoodRecommendationsWidget extends ConsumerStatefulWidget {
  const FoodRecommendationsWidget({super.key});

  @override
  ConsumerState<FoodRecommendationsWidget> createState() => _FoodRecommendationsWidgetState();
}

class _FoodRecommendationsWidgetState extends ConsumerState<FoodRecommendationsWidget> {
  String _activeSlot = 'breakfast';

  @override
  void initState() {
    super.initState();
    // Default to the current time of day's slot
    final hour = DateTime.now().hour;
    if (hour < 11) {
      _activeSlot = 'breakfast';
    } else if (hour < 16) {
      _activeSlot = 'lunch';
    } else if (hour < 19) {
      _activeSlot = 'snack';
    } else {
      _activeSlot = 'dinner';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);
    final recsAsync = ref.watch(recommendationsProvider);
    final gapsAsync = ref.watch(nutrientGapsProvider);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Yesterday's Gaps Alert Card ──────────────────────────────────────────
        gapsAsync.when(
          data: (gaps) {
            if (gaps == null) return const SizedBox.shrink();
            final deficits = <String>[];
            if (gaps.gapProtein < -2.0) deficits.add(s.protein);
            if (gaps.gapFibre < -1.0) deficits.add(s.fibre.split(' (').first);
            if (gaps.gapCalcium < -20.0) deficits.add(s.calcium.split(' (').first);
            if (gaps.gapIron < -0.5) deficits.add(s.iron.split(' (').first);
            if (gaps.gapVitc < -2.0) deficits.add(s.vitaminC.split(' (').first);

            if (deficits.isEmpty) return const SizedBox.shrink();

            final gapCard = Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.tips_and_updates, color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.isTamil ? 'நேற்றைய பற்றாக்குறை எச்சரிக்கை' : 'Yesterday\'s Nutrient Gaps',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.isTamil
                              ? 'நேற்று உங்களிடம் ${deficits.join(", ")} பற்றாக்குறை இருந்தது. அதை ஈடுசெய்ய கீழே உள்ள பரிந்துரைகளைச் சாப்பிடவும்.'
                              : 'You were low on ${deficits.join(", ")} yesterday. Try these smart options to fill the gaps!',
                          style: theme.textTheme.bodySmall?.copyWith(height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
            return reduceMotion
                ? gapCard
                : gapCard.animate().fade(duration: 400.ms).slideY(begin: 0.1);
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        const SizedBox(height: AppSpacing.md),

        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.isTamil ? 'உங்களுக்கான உணவுப் பரிந்துரைகள்' : 'Personalized Recommendations',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: s.isTamil ? 'புதிப்பி' : 'Refresh recommendations',
                onPressed: () => ref.read(recommendationsProvider.notifier).forceRefresh(),
              ),
            ],
          ),
        ),

        // Slot Selector
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: SizedBox(
            height: 40.0 * MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.6),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: [
                _buildSlotChip('breakfast', s.breakfast.split(' · ').first),
                const SizedBox(width: AppSpacing.sm),
                _buildSlotChip('lunch', s.lunch.split(' · ').first),
                const SizedBox(width: AppSpacing.sm),
                _buildSlotChip('snack', s.snack.split(' · ').first),
                const SizedBox(width: AppSpacing.sm),
                _buildSlotChip('dinner', s.dinner.split(' · ').first),
              ],
            ),
          ),
        ),

        // Recommendations List
        recsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => FriendlyErrorView(
            error: err,
            compact: true,
            onRetry: () => ref.read(recommendationsProvider.notifier).forceRefresh(),
          ),
          data: (recsState) {
            final list = recsState.slots[_activeSlot] ?? [];
            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Center(
                  child: Text(
                    s.isTamil ? 'இப்பகுதிக்கு பரிந்துரைகள் எதுவும் இல்லை' : 'No recommendations for this slot yet.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final item = list[index];
                return _buildRecCard(context, item);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSlotChip(String key, String label) {
    final theme = Theme.of(context);
    final isSelected = _activeSlot == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          setState(() {
            _activeSlot = key;
          });
        }
      },
      selectedColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildRecCard(BuildContext context, RecommendationItem item) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);

    // Get color for top nutrient badge
    Color badgeColor = theme.colorScheme.primary;
    final topNut = item.topNutrient?.toLowerCase() ?? '';
    if (topNut.contains('protein')) {
      badgeColor = theme.colorScheme.secondary;
    } else if (topNut.contains('fibre')) {
      badgeColor = AppColorScheme.nutrientFibre;
    } else if (topNut.contains('iron')) {
      badgeColor = AppColorScheme.nutrientIron;
    } else if (topNut.contains('calcium')) {
      badgeColor = AppColorScheme.nutrientCalcium;
    } else if (topNut.contains('vitc')) {
      badgeColor = AppColorScheme.nutrientVitC;
    }

    return Card(
      elevation: AppElevation.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.getDisplayName(s.isTamil),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            item.isRecipe ? Icons.restaurant_menu : Icons.spa,
                            size: 14,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.isRecipe
                                ? (s.isTamil ? 'உணவு வகை (Recipe)' : 'Recipe')
                                : (item.foodGroup ?? ''),
                            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Score Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                  ),
                  child: Text(
                    item.topNutrient != null
                        ? item.topNutrient!.toUpperCase()
                        : (s.isTamil ? 'பற்றாக்குறை' : 'GAP FILL'),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Pre-scaled Nutritional values
            Row(
              children: [
                _buildMacroText('${item.energyKcal?.toInt() ?? 0} kcal', isBold: true),
                _buildDivider(),
                _buildMacroText('${s.isTamil ? "அளவு" : "Qty"}: ${item.portionDisplay(s.isTamil)}'),
                if (item.protein != null && item.protein! > 0) ...[
                  _buildDivider(),
                  _buildMacroText('${s.protein.substring(0, 1)}: ${item.protein!.toStringAsFixed(1)}g'),
                ],
                if (item.fibre != null && item.fibre! > 0) ...[
                  _buildDivider(),
                  _buildMacroText('${s.fibre.substring(0, 1)}: ${item.fibre!.toStringAsFixed(1)}g'),
                ],
              ],
            ),

            const Divider(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: Text(
                    item.getReasonDisplay(s.isTamil),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Log Button
                OutlinedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
                      ),
                      builder: (_) => _QuickLogSheet(item: item, defaultMealSlot: _activeSlot),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(s.isTamil ? 'பதிவுசெய்' : 'Log'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroText(String text, {bool isBold = false}) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelMedium?.copyWith(
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildDivider() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text('|', style: TextStyle(color: theme.colorScheme.outlineVariant)),
    );
  }
}

// ── Quick Log Sheet Widget ───────────────────────────────────────────────────
class _QuickLogSheet extends ConsumerStatefulWidget {
  final RecommendationItem item;
  final String defaultMealSlot;

  const _QuickLogSheet({
    required this.item,
    required this.defaultMealSlot,
  });

  @override
  ConsumerState<_QuickLogSheet> createState() => _QuickLogSheetState();
}

class _QuickLogSheetState extends ConsumerState<_QuickLogSheet> {
  late double _quantity;
  late String _mealSlot;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _quantity = widget.item.isRecipe
        ? (widget.item.suggestedServings ?? 1.0)
        : (widget.item.suggestedG ?? 100.0);
    _mealSlot = widget.item.mealSlot;
  }

  void _onConfirm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.item.isRecipe) {
        await ApiClient.logRecipe(
          mealType: _mealSlot,
          recipeId: int.parse(widget.item.itemId),
          servingsEaten: _quantity,
        );
      } else {
        await ApiClient.logIngredient(
          mealType: _mealSlot,
          ingredientCode: widget.item.itemId,
          quantityG: _quantity,
        );
      }

      // Success! Invalidate today's meal logs summary to update the ring and list
      ref.invalidate(dashboardProvider);
      
      // Force refresh recommendations so they adjust to what we just ate
      await ref.read(recommendationsProvider.notifier).forceRefresh();

      if (mounted) {
        final s = AppStrings.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              s.isTamil
                  ? '${widget.item.getDisplayName(true)} வெற்றிகரமாகப் பதிவு செய்யப்பட்டது'
                  : '${widget.item.getDisplayName(false)} logged successfully',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ErrorToast.show(context, AppStrings.of(context).logFailed);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);

    // Dynamic calculations based on slider position
    final scale = widget.item.isRecipe
        ? _quantity / (widget.item.suggestedServings ?? 1.0)
        : _quantity / (widget.item.suggestedG ?? 100.0);

    final currentKcal = ((widget.item.energyKcal ?? 0) * scale).toInt();
    final currentProtein = ((widget.item.protein ?? 0) * scale).toStringAsFixed(1);
    final currentFibre = ((widget.item.fibre ?? 0) * scale).toStringAsFixed(1);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text(
                s.isTamil
                    ? 'பரிந்துரைக்கப்பட்ட உணவுப் பதிவு'
                    : 'Log Recommended Food',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.item.getDisplayName(s.isTamil),
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Quantity Selector
              Text(
                widget.item.isRecipe
                    ? (s.isTamil ? 'பரிமாறல்கள்: ${_quantity.toStringAsFixed(1)}' : 'Servings: ${_quantity.toStringAsFixed(1)}')
                    : (s.isTamil ? 'அளவு: ${_quantity.toInt()} கிராம்' : 'Quantity: ${_quantity.toInt()}g'),
                style: theme.textTheme.titleMedium,
              ),

              Slider(
                value: _quantity,
                min: widget.item.isRecipe ? 0.5 : 25.0,
                max: widget.item.isRecipe ? 4.0 : 400.0,
                divisions: widget.item.isRecipe ? 7 : 15,
                onChanged: _isLoading
                    ? null
                    : (val) {
                        setState(() {
                          _quantity = val;
                        });
                      },
              ),

              const SizedBox(height: AppSpacing.sm),
              Text(
                s.isTamil
                    ? 'மதிப்பு: $currentKcal கலோரி (புரதம்: $currentProteinகி · நார்ச்சத்து: $currentFibreகி)'
                    : 'Values: $currentKcal kcal (Protein: ${currentProtein}g · Fibre: ${currentFibre}g)',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Meal Slot Selector
              Text(
                s.isTamil ? 'சாப்பாட்டு வேளை' : 'Meal Slot',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),

              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'breakfast', label: Text(s.breakfast.split(' · ').first)),
                  ButtonSegment(value: 'lunch', label: Text(s.lunch.split(' · ').first)),
                  ButtonSegment(value: 'snack', label: Text(s.snack.split(' · ').first)),
                  ButtonSegment(value: 'dinner', label: Text(s.dinner.split(' · ').first)),
                ],
                selected: {_mealSlot},
                onSelectionChanged: _isLoading
                    ? null
                    : (val) => setState(() => _mealSlot = val.first),
                style: SegmentedButton.styleFrom(
                  textStyle: theme.textTheme.labelMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Log Button
              FilledButton(
                onPressed: _isLoading ? null : _onConfirm,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(s.isTamil ? 'பதிவை உறுதிசெய்' : 'Confirm Log', style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
