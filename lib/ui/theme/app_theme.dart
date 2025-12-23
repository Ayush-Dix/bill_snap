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

  // Semantic Colors (used in both themes)
  static const Color error = Color(0xFFEF4444); // Red
  static const Color success = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B); // Orange/Amber
  static const Color info = Color(0xFF6366F1); // Indigo/Blue

  // Neutral Grays for Light Mode
  static const Color lightGray100 = Color(0xFFF5F5F5);
  static const Color lightGray200 = Color(0xFFEEEEEE);
  static const Color lightGray300 = Color(0xFFE0E0E0);
  static const Color lightGray400 = Color(0xFFBDBDBD);
  static const Color lightGray500 = Color(0xFF9E9E9E);
  static const Color lightGray600 = Color(0xFF757575);
  static const Color lightGray700 = Color(0xFF616161);
  static const Color lightGray800 = Color(0xFF424242);

  // Neutral Grays for Dark Mode
  static const Color darkGray200 = Color(0xFF2A2A2A);
  static const Color darkGray300 = Color(0xFF3A3A3A);
  static const Color darkGray400 = Color(0xFF5A5A5A);
  static const Color darkGray500 = Color(0xFF7A7A7A);
  static const Color darkGray600 = Color(0xFF9A9A9A);
  static const Color darkGray700 = Color(0xFFBABABA);
  static const Color darkGray800 = Color(0xFFDADADA);

  // Status Colors for Light Mode
  static const Color lightSuccessBg = Color(0xFFDCFCE7); // green.shade50
  static const Color lightSuccessText = Color(0xFF166534); // green.shade700
  static const Color lightErrorBg = Color(0xFFFEE2E2); // red.shade100
  static const Color lightErrorText = Color(0xFFB91C1C); // red.shade700

  // Status Colors for Dark Mode
  static const Color darkSuccessBg = Color(0xFF14532D); // green.shade900
  static const Color darkSuccessText = Color(0xFF4ADE80); // green.shade400
  static const Color darkErrorBg = Color(0xFF7F1D1D); // red.shade900
  static const Color darkErrorText = Color(0xFFF87171); // red.shade400
  
  // Participant Avatar Colors
  static const List<Color> avatarColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF10B981), // Green
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFF8B5CF6), // Purple
    Color(0xFF06B6D4), // Cyan
  ];
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
