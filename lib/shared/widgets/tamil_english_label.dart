import 'package:flutter/material.dart';
import 'package:kalori/core/theme/spacing.dart';

class TamilEnglishLabel extends StatelessWidget {
  final String englishText;
  final String tamilText;
  final TextStyle? englishStyle;
  final TextStyle? tamilStyle;

  const TamilEnglishLabel({
    super.key,
    required this.englishText,
    required this.tamilText,
    this.englishStyle,
    this.tamilStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$englishText. $tamilText',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            englishText,
            style: englishStyle ?? theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs / 2),
          Text(
            tamilText,
            style: tamilStyle ?? theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
