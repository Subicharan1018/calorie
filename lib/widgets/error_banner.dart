import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kalori/core/theme/spacing.dart';

class ErrorBanner extends StatefulWidget {
  final String message;
  final String retryText;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ErrorBanner({
    super.key,
    required this.message,
    required this.retryText,
    this.onRetry,
    this.onDismiss,
  });

  @override
  State<ErrorBanner> createState() => _ErrorBannerState();
}

class _ErrorBannerState extends State<ErrorBanner> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    // Auto-dismiss after 8 seconds
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() => _visible = false);
        if (widget.onDismiss != null) {
          widget.onDismiss!();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Semantics(
      label: 'Error: ${widget.message}',
      child: Material(
        color: theme.colorScheme.errorContainer,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  widget.message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (widget.onRetry != null) ...[
                const SizedBox(width: AppSpacing.sm),
                TextButton(
                  onPressed: widget.onRetry,
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onErrorContainer,
                    minimumSize: const Size(48, 48),
                  ),
                  child: Text(widget.retryText),
                ),
              ],
            ],
          ),
        ),
      )
      .animate()
      .slideY(begin: -1.0, end: 0.0, duration: 280.ms, curve: Curves.easeOutCubic)
      .fadeIn(duration: 280.ms),
    );
  }
}
