import 'package:flutter/material.dart';

class AppColorScheme {
  static const Color primary = Color(0xFF6C3FA3); // Approx oklch(0.533 0.125 294.3)
  static const Color accent = Color(0xFFD66045);  // Terracotta
  static const Color bg = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F6F9);
  static const Color ink = Color(0xFF141118);
  static const Color muted = Color(0xFF59555D);

  static const ColorScheme light = ColorScheme.light(
    primary: primary,
    onPrimary: Colors.white,
    secondary: accent,
    onSecondary: Colors.white,
    surface: bg,
    onSurface: ink,
    surfaceContainer: surface,
    outline: muted,
    error: Color(0xFFBA1A1A),
    onError: Colors.white,
  );

  static const ColorScheme dark = ColorScheme.dark(
    primary: Color(0xFFD0BCFF),
    onPrimary: Color(0xFF381E72),
    secondary: Color(0xFFFFB4A1),
    onSecondary: Color(0xFF5E1700),
    surface: Color(0xFF141218),
    onSurface: Color(0xFFE6E0E9),
    surfaceContainer: Color(0xFF2B2930),
    outline: Color(0xFF938F99),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
  );
}
