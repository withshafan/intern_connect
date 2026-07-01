import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.ink,
      colorScheme: const ColorScheme.light(
        primary: AppColors.foilAmber,
        secondary: AppColors.growTeal,
        surface: AppColors.ink,
        onSurface: AppColors.badgeCream,
        error: AppColors.signalCoral,
      ),
    );

    // Body/UI: Manrope
    final manropeTextTheme = GoogleFonts.manropeTextTheme(base.textTheme);

    // Display: Fraunces
    final displayStyle = GoogleFonts.fraunces(
      color: AppColors.badgeCream,
      fontWeight: FontWeight.w600,
    );

    // Utility: JetBrains Mono
    final utilityStyle = GoogleFonts.jetBrainsMono(
      letterSpacing: 0.5,
      color: AppColors.slate,
    );

    return base.copyWith(
      textTheme: manropeTextTheme.copyWith(
        displayLarge: displayStyle,
        displayMedium: displayStyle,
        displaySmall: displayStyle,
        headlineLarge: displayStyle,
        headlineMedium: displayStyle,
        headlineSmall: displayStyle,
        titleLarge: displayStyle,
        // Utility overrides
        labelSmall: utilityStyle.copyWith(fontSize: 10),
        labelMedium: utilityStyle.copyWith(fontSize: 12),
        labelLarge: utilityStyle.copyWith(fontSize: 14),
      ).apply(
        bodyColor: AppColors.badgeCream,
        displayColor: AppColors.badgeCream,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.badgeCream,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.foilAmber,
          foregroundColor: AppColors.ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.badgeCream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: AppColors.slate),
      ),
    );
  }
}
