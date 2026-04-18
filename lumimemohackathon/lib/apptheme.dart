import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette — warm amber & deep slate
  static const Color primary = Color.fromARGB(255, 56, 0, 86);       // warm amber
  static const Color primaryDark = Color.fromARGB(255, 209, 140, 242);
  static const Color background = Color.fromARGB(255, 229, 158, 255);    // deep navy-black
  static const Color surface = Color(0xFF1A1D27);       // card surface
  static const Color surfaceAlt = Color(0xFF242736);    // elevated surface
  static const Color textPrimary = Color(0xFFF5F0E8);   // warm white
  static const Color textSecondary = Color(0xFF9B97A0); // muted
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
        textTheme: GoogleFonts.dmSerifDisplayTextTheme().copyWith(
          bodyLarge: GoogleFonts.dmSans(color: textPrimary, fontSize: 16),
          bodyMedium: GoogleFonts.dmSans(color: textSecondary, fontSize: 14),
          labelLarge: GoogleFonts.dmSans(
              color: background, fontWeight: FontWeight.w600, fontSize: 15),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceAlt,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          hintStyle: GoogleFonts.dmSans(color: textSecondary, fontSize: 14),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
        ),
      );
}