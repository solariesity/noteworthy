import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _bodyFontSize = 16.0;
  static const _smallFontSize = 14.0;
  static const _semiBold = FontWeight.w600;
  static const _bold = FontWeight.w700;

  static ThemeData theme(Color seedColor, Brightness brightness, {double fontScale = 1.0}) =>
      _build(brightness, seedColor, fontScale);

  static ThemeData _build(Brightness brightness, Color seedColor, double fontScale) {
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
          fontSize: 36 * fontScale,
          fontWeight: _bold,
          color: colorScheme.onSurface,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 28 * fontScale,
          fontWeight: _bold,
          color: colorScheme.onSurface,
        ),
        titleLarge: GoogleFonts.notoSans(
          fontSize: 22 * fontScale,
          fontWeight: _semiBold,
          color: colorScheme.onSurface,
        ),
        titleMedium: GoogleFonts.notoSans(
          fontSize: _bodyFontSize * fontScale,
          fontWeight: _semiBold,
          color: colorScheme.onSurface,
        ),
        bodyLarge: GoogleFonts.notoSans(
          fontSize: _bodyFontSize * fontScale,
          height: 1.6,
          color: colorScheme.onSurface,
        ),
        bodyMedium: GoogleFonts.notoSans(
          fontSize: _smallFontSize * fontScale,
          height: 1.5,
          color: colorScheme.onSurfaceVariant,
        ),
        bodySmall: GoogleFonts.notoSans(
          fontSize: 12 * fontScale,
          height: 1.4,
          color: colorScheme.onSurfaceVariant,
        ),
        labelLarge: GoogleFonts.notoSans(
          fontSize: _smallFontSize * fontScale,
          fontWeight: _semiBold,
          color: colorScheme.onSurface,
        ),
      ).apply(fontFamilyFallback: const ['Microsoft YaHei']),
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
