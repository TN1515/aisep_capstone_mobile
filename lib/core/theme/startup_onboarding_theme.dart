import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StartupOnboardingTheme {
  // Colors
  static const Color navyBg = Color(0xFF0B1221);
  static const Color navySurface = Color(0xFF1A2333);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF3E7C5);
  static const Color softIvory = Color(0xFFF4F1E8);
  static const Color slateGray = Color(0xFF94A3B8);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: navyBg,
      primaryColor: goldAccent,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: softIvory,
          height: 1.2,
        ),
        bodyLarge: GoogleFonts.workSans(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: softIvory.withOpacity(0.8),
          height: 1.6,
        ),
        labelLarge: GoogleFonts.workSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: navyBg,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldAccent,
          foregroundColor: navyBg,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 8,
          shadowColor: goldAccent.withOpacity(0.3),
          textStyle: GoogleFonts.workSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: softIvory.withOpacity(0.7),
          textStyle: GoogleFonts.workSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
