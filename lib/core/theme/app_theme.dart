import 'package:flutter/material.dart';
import 'package:kalori/core/theme/color_scheme.dart';
import 'package:kalori/core/theme/text_theme.dart';
import 'package:kalori/core/theme/spacing.dart';

class AppTheme {
  static ThemeData buildTheme({required bool isDark}) {
    final colorScheme = isDark ? AppColorScheme.dark : AppColorScheme.light;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTextTheme.build(colorScheme),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
