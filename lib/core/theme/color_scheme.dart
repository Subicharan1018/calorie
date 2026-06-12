import 'package:flutter/material.dart';

class AppColorScheme {
  // Light Mode Colors (OKLCH-Derived Cardamom & Saffron)
  static const Color primary = Color(0xFF24441C);           // Cardamom Deep - oklch(0.35 0.075 140)
  static const Color accent = Color(0xFFE49E22);            // Saffron/Turmeric Gold - oklch(0.75 0.15 75)
  static const Color bg = Color(0xFFFFFFFF);                // Pure White Surface - oklch(1 0 0)
  static const Color surface = Color(0xFFF2F6F1);           // Soft Sage wash - oklch(0.97 0.008 140)
  static const Color ink = Color(0xFF070D06);               // Deep Forest Ink - oklch(0.15 0.02 140)
  static const Color muted = Color(0xFF515750);             // Sage Muted - oklch(0.45 0.015 140)

  // Dark Mode Colors (OKLCH-Derived)
  static const Color primaryDark = Color(0xFF93BB8B);       // Cardamom Light - oklch(0.75 0.08 140)
  static const Color accentDark = Color(0xFFEBB25F);        // Saffron Gold - oklch(0.8 0.12 75)
  static const Color bgDark = Color(0xFF0E120D);            // Deep Charcoal-Sage - oklch(0.07 0.005 140)
  static const Color surfaceDark = Color(0xFF181C17);       // Medium Charcoal-Sage - oklch(0.12 0.007 140)
  static const Color inkDark = Color(0xFFE6E9E5);           // Bone - oklch(0.93 0.005 140)
  static const Color mutedDark = Color(0xFF8C918B);         // Lichen - oklch(0.65 0.01 140)

  // ── Macro & nutrient accents ───────────────────────────────────────────────
  // Earthen tones tuned to the cardamom/saffron identity (no stock-Material
  // swatches). Single source of truth; widgets must not hardcode these hexes.
  static const Color macroFat       = Color(0xFFD47A22);    // Warm terracotta — fat (carbs=primary, protein=accent)
  static const Color nutrientFibre  = Color(0xFF3F6B33);    // Deep cardamom green
  static const Color nutrientIron   = Color(0xFFA8472A);    // Rust (was stock deep-orange)
  static const Color nutrientCalcium= Color(0xFF6E4B86);    // Muted plum (was neon purple)
  static const Color nutrientVitC   = Color(0xFFCB7A12);    // Deep saffron-orange

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
    primary: primaryDark,
    onPrimary: Color(0xFF070D06), // Deep Forest Ink for contrast on light green
    secondary: accentDark,
    onSecondary: Color(0xFF070D06), // Deep Forest Ink for contrast on gold
    surface: bgDark,
    onSurface: inkDark,
    surfaceContainer: surfaceDark,
    outline: mutedDark,
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
  );
}
