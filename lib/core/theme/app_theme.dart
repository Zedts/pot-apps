import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Centralized theme definition for POT Mobile.
/// Applies Plus Jakarta Sans typography and PotColors palette across the app.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: PotColors.bgCream,
      colorScheme: const ColorScheme.light(
        primary: PotColors.primaryRed,
        secondary: PotColors.accentRed,
        surface: PotColors.pureWhite,
        error: PotColors.accentRed,
      ),
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: PotColors.bgCream,
        foregroundColor: PotColors.textDark,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: PotColors.pureWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: PotColors.warmBorder),
        ),
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: PotColors.pureWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: PotColors.warmBorder),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: PotColors.warmBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
