import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kalori/core/models/weight_log.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/features/trends/providers/trends_provider.dart';

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
    final history = ref.read(trendsProvider).weightHistory;
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
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final history = ref.watch(trendsProvider).weightHistory;
    
    String lastLoggedText = 'No previous logs';
    if (history.isNotEmpty) {
      final lastLog = history.last;
      final daysAgo = DateTime.now().difference(lastLog.date).inDays;
      final timeAgoText = daysAgo == 0 ? 'today' : daysAgo == 1 ? 'yesterday' : '$daysAgo days ago';
      lastLoggedText = 'Last logged: ${lastLog.weightKg} kg ($timeAgoText)';
    }

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
                DateFormat('EEEE, d MMMM').format(DateTime.now()),
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Log your weight',
                style: theme.textTheme.titleLarge,
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
                    'kg',
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
                child: const Text('Save Weight', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
