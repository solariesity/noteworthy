import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData dark(Color seedColor) => _build(Brightness.dark, seedColor);

  static ThemeData _build(Brightness brightness, Color seedColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: GoogleFonts.notoSansTextTheme().copyWith(
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
        titleLarge: GoogleFonts.notoSans(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        bodyLarge: GoogleFonts.notoSans(
          fontSize: 16,
          height: 1.6,
          color: colorScheme.onSurface,
        ),
        bodyMedium: GoogleFonts.notoSans(
          fontSize: 14,
          height: 1.5,
          color: colorScheme.onSurfaceVariant,
        ),
        bodySmall: GoogleFonts.notoSans(
          fontSize: 12,
          height: 1.4,
          color: colorScheme.onSurfaceVariant,
        ),
        labelLarge: GoogleFonts.notoSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: colorScheme.surfaceContainerLow,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.4)),
      ),
    );
  }
}
