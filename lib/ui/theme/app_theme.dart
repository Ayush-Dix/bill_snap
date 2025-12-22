import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- THE PALETTE ---
class AppColors {
  // Light Mode Colors
  static const Color lightCanvas = Color(0xFFF4F2EE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightInk = Color(0xFF1C1C1E);
  static const Color lightAccent = Color(0xFFFF6B35); // Burnt Orange
  static const Color lightHighlight = Color(0xFFD4E157); // Acid Lime

  // Dark Mode Colors ("Carbon Copy" Theme)
  static const Color darkCanvas = Color(0xFF121212); // Matte Charcoal
  static const Color darkSurface = Color(0xFF1E1E1E); // Dark Grey Card
  static const Color darkInk = Color(0xFFE0E0E0); // Chalk White
  static const Color darkAccent = Color(0xFFFF8A5B); // Lighter Orange
  static const Color darkBorder = Color(0xFF333333); // Subtle grey border
}

class AppTheme {
  // --- SHARED TEXT STYLES ---
  static TextTheme _buildTextTheme(Color inkColor) {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: inkColor,
        letterSpacing: -0.5,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: inkColor,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: inkColor,
      ),
      bodyLarge: GoogleFonts.poppins(fontSize: 16, color: inkColor),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: inkColor.withOpacity(0.7),
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: inkColor.withOpacity(0.6),
      ),
      // Poppins for all text including numbers
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: inkColor,
      ),
    );
  }

  // --- LIGHT THEME ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightCanvas,

      textTheme: _buildTextTheme(AppColors.lightInk),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightInk,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.lightInk,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.lightInk.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightInk,
        foregroundColor: AppColors.lightHighlight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }

  // --- DARK THEME ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkCanvas,

      textTheme: _buildTextTheme(AppColors.darkInk),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkInk,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.darkInk,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // Lighter border in dark mode to define edges
          side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkAccent,
          foregroundColor: AppColors.darkCanvas, // Dark text on bright button
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightHighlight, // Lime Button
        foregroundColor: AppColors.darkCanvas, // Dark Icon
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }
}
