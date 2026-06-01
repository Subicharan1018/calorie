import 'package:flutter/material.dart';
import 'package:kalori/core/theme/spacing.dart';

class EmptyState extends StatelessWidget {
  final String headline;
  final String subtext;
  final Widget illustration;
  final String? ctaText;
  final VoidCallback? onCtaPressed;

  const EmptyState({
    super.key,
    required this.headline,
    required this.subtext,
    required this.illustration,
    this.ctaText,
    this.onCtaPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '$headline. $subtext',
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            illustration,
            const SizedBox(height: AppSpacing.lg),
            Text(
              headline,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtext,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            if (ctaText != null && onCtaPressed != null) ...[
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: onCtaPressed,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48), // 48dp touch target
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
                child: Text(ctaText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
