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
      cardColor: navySurface,
      dividerColor: Colors.white10,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: softIvory),
        actionsIconTheme: const IconThemeData(color: softIvory),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: softIvory,
        ),
      ),
      iconTheme: const IconThemeData(color: softIvory),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: softIvory,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: softIvory,
        ),
        bodyLarge: GoogleFonts.workSans(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: softIvory.withOpacity(0.9),
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.workSans(
          fontSize: 14,
          color: softIvory.withOpacity(0.7),
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
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: goldAccent,
          textStyle: GoogleFonts.workSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: softIvory,
      primaryColor: goldAccent,
      cardColor: Colors.white,
      dividerColor: Colors.black.withOpacity(0.05),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: navyBg),
        actionsIconTheme: const IconThemeData(color: navyBg),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: navyBg,
        ),
      ),
      iconTheme: const IconThemeData(color: navyBg),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: navyBg,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: navyBg,
        ),
        bodyLarge: GoogleFonts.workSans(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: navyBg.withOpacity(0.9),
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.workSans(
          fontSize: 14,
          color: navyBg.withOpacity(0.7),
        ),
        labelLarge: GoogleFonts.workSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: goldAccent,
          textStyle: GoogleFonts.workSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
