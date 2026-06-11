import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kalori/core/models/weight_log.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/features/trends/providers/trends_provider.dart';
import 'package:kalori/l10n/app_strings.dart';

class WeightLogSheet extends ConsumerStatefulWidget {
  const WeightLogSheet({super.key});

  @override
  ConsumerState<WeightLogSheet> createState() => _WeightLogSheetState();
}

class _WeightLogSheetState extends ConsumerState<WeightLogSheet> {
  late double _weight;

  @override
  void initState() {
    super.initState();
    final history = ref.read(trendsProvider).value?.weightHistory ?? [];
    _weight = history.isNotEmpty ? history.last.weightKg : 70.0;
  }

  void _onSave() {
    HapticFeedback.mediumImpact();
    final log = WeightLog(
      id: DateTime.now().toIso8601String(),
      date: DateTime.now(),
      weightKg: _weight,
    );
    ref.read(trendsProvider.notifier).addWeightLog(log);
    
    // Show a floating confirmation SnackBar
    final s = AppStrings.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          s.isTamil
              ? 'எடை வெற்றிகரமாகப் பதிவு செய்யப்பட்டது'
              : 'Weight logged successfully',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);
    final history = ref.watch(trendsProvider).value?.weightHistory ?? [];
    
    String lastLoggedText = s.isTamil ? 'முந்தைய பதிவுகள் இல்லை' : 'No previous logs';
    if (history.isNotEmpty) {
      final lastLog = history.last;
      final daysAgo = DateTime.now().difference(lastLog.date).inDays;
      final String timeAgoText;
      if (daysAgo == 0) {
        timeAgoText = s.isTamil ? 'இன்று' : 'today';
      } else if (daysAgo == 1) {
        timeAgoText = s.isTamil ? 'நேற்று' : 'yesterday';
      } else {
        timeAgoText = s.isTamil ? '$daysAgo நாட்களுக்கு முன்பு' : '$daysAgo days ago';
      }
      
      lastLoggedText = s.isTamil
          ? 'கடைசி பதிவு: ${lastLog.weightKg} கி.கி ($timeAgoText)'
          : 'Last logged: ${lastLog.weightKg} kg ($timeAgoText)';
    }

    final localeStr = s.locale.toString();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('EEEE, d MMMM', localeStr).format(DateTime.now()),
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                s.isTamil ? 'உங்களது எடையை பதிவு செய்யவும்' : 'Log your weight',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _weight.toStringAsFixed(1),
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    s.isTamil ? 'கி.கி' : 'kg',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _weight,
                min: 30,
                max: 150,
                divisions: (150 - 30) * 10, // 0.1kg increments
                onChanged: (val) {
                  setState(() => _weight = (val * 10).round() / 10);
                },
              ),
              
              const SizedBox(height: AppSpacing.md),
              Text(
                lastLoggedText,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              FilledButton(
                onPressed: _onSave,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                ),
                child: Text(s.isTamil ? 'எடையை சேமிக்கவும்' : 'Save Weight', style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
