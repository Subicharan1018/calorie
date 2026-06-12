import 'package:flutter/material.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/l10n/app_strings.dart';

/// Heuristic: does this error look like a connectivity problem rather than a
/// server/logic one? Used only to pick a friendlier message — never shown raw.
bool _looksLikeNetwork(Object error) {
  final e = error.toString().toLowerCase();
  return e.contains('socket') ||
      e.contains('connection') ||
      e.contains('timed out') ||
      e.contains('timeout') ||
      e.contains('network') ||
      e.contains('handshake') ||
      e.contains('failed host') ||
      e.contains('unreachable');
}

/// A localized, empathetic error state. Replaces raw `$err` interpolation so
/// users never see a stack-trace fragment (PRODUCT: "Action-Oriented Empathy").
///
/// Use [compact] inside cards/sheets where vertical space is tight.
class FriendlyErrorView extends StatelessWidget {
  final Object? error;
  final VoidCallback? onRetry;
  final bool compact;

  const FriendlyErrorView({
    super.key,
    this.error,
    this.onRetry,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);
    final message =
        (error != null && _looksLikeNetwork(error!)) ? s.networkError : s.couldntLoad;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_off_rounded,
          size: compact ? 28 : 40,
          color: theme.colorScheme.outline,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(s.retryButton),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48), // 48dp touch target
            ),
          ),
        ],
      ],
    );

    return Semantics(
      label: message,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: compact ? content : Center(child: content),
      ),
    );
  }
}
