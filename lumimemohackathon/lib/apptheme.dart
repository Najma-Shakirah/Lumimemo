import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette — warm purple & deep slate
  static const Color primary = Color.fromARGB(255, 159, 24, 231);
  static const Color primaryDark = Color.fromARGB(255, 209, 140, 242);
  static const Color background = Color(0xFF0F1117);
  static const Color surface = Color(0xFF1A1D27);
  static const Color surfaceAlt = Color(0xFF242736);
  static const Color textPrimary = Color(0xFFF5F0E8);
  static const Color textSecondary = Color(0xFF9B97A0);
  static const Color error = Color(0xFFE05C5C);
  static const Color success = Color(0xFF5CC8A0);

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: primaryDark,
          surface: surface,
          error: error,
        ),
        
        textTheme: TextTheme(
          displayLarge: GoogleFonts.dmSerifDisplay(
              textStyle: const TextStyle(color: textPrimary, fontSize: 32)),
          displayMedium: GoogleFonts.dmSerifDisplay(
              textStyle: const TextStyle(color: textPrimary, fontSize: 26)),
          displaySmall: GoogleFonts.dmSerifDisplay(
              textStyle: const TextStyle(color: textPrimary, fontSize: 22)),
          headlineMedium: GoogleFonts.dmSerifDisplay(
              textStyle: const TextStyle(color: textPrimary, fontSize: 20)),
          headlineSmall: GoogleFonts.dmSerifDisplay(
              textStyle: const TextStyle(color: textPrimary, fontSize: 18)),
          bodyLarge: GoogleFonts.dmSans(
              textStyle: const TextStyle(color: textPrimary, fontSize: 16)),
          bodyMedium: GoogleFonts.dmSans(
              textStyle: const TextStyle(color: textSecondary, fontSize: 14)),
          bodySmall: GoogleFonts.dmSans(
              textStyle: const TextStyle(color: textSecondary, fontSize: 12)),
          labelLarge: GoogleFonts.dmSans(
              textStyle: const TextStyle(
                  color: background,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
          labelMedium: GoogleFonts.dmSans(
              textStyle: const TextStyle(color: textSecondary, fontSize: 13)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceAlt,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          hintStyle:
              GoogleFonts.dmSans(color: textSecondary, fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: error, width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: background,
            padding: const EdgeInsets.symmetric(
                horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
        ),
      );
}