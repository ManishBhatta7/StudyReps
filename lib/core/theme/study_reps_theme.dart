import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// StudyReps Design System
///
/// Praktika-inspired dark, clean aesthetic:
/// - Dark navy backgrounds for immersive content
/// - Soft indigo/periwinkle accent colors
/// - Clean, minimal glassmorphism overlays
/// - Outfit font family for modern, bold typography
class StudyRepsTheme {
  StudyRepsTheme._();

  // ===================================
  // COLORS - Dark Navy & Indigo Theme
  // ===================================

  // Primary - Indigo/Periwinkle (clean, sophisticated)
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color primaryIndigoLight = Color(0xFF818CF8);
  static const Color primaryIndigoDark = Color(0xFF4F46E5);
  
  // Legacy alias for backwards compatibility
  static const Color primaryPurple = primaryIndigo;
  static const Color primaryPurpleLight = primaryIndigoLight;
  static const Color primaryPurpleDark = primaryIndigoDark;
  
  // Also keep teal alias
  static const Color primaryTeal = primaryIndigo;

  // Secondary - Soft Blue (signals progress)
  static const Color accentCyan = Color(0xFF38BDF8);
  static const Color accentCyanLight = Color(0xFF7DD3FC);
  static const Color accentCyanDark = Color(0xFF0EA5E9);

  // Success/Correct - Emerald Green
  static const Color successGreen = Color(0xFF10B981);
  static const Color successGreenLight = Color(0xFF34D399);

  // Error/Incorrect - Coral/Salmon Pink
  static const Color errorPink = Color(0xFFF472B6);
  static const Color errorPinkDark = Color(0xFFEC4899);

  // Backgrounds - Dark Navy/Slate
  static const Color bgPrimary = Color(0xFF0F172A);        // Dark navy
  static const Color bgSecondary = Color(0xFF1E293B);      // Slate card background
  static const Color bgTertiary = Color(0xFF334155);       // Elevated slate surfaces
  static const Color bgGlass = Color(0x33FFFFFF);          // Glass overlay

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);      // White
  static const Color textSecondary = Color(0xFF94A3B8);    // Muted slate
  static const Color textMuted = Color(0xFF64748B);        // Very muted

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFF334155);
  static const Color borderGlow = Color(0x666366F1);       // Indigo glow

  // Gradient Colors
  static const Color gradientStart = Color(0xFF6366F1);    // Indigo
  static const Color gradientMiddle = Color(0xFF818CF8);   // Light indigo
  static const Color gradientEnd = Color(0xFF38BDF8);      // Sky blue



  // ===================================
  // GRADIENTS
  // ===================================

  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [gradientStart, gradientMiddle],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get successGradient => const LinearGradient(
    colors: [successGreen, accentCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get lockGradient => const LinearGradient(
    colors: [Color(0x99000000), Color(0xDD000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ===================================
  // SHADOWS & GLOWS
  // ===================================

  static BoxShadow get primaryGlow => BoxShadow(
    color: primaryPurple.withOpacity(0.4),
    blurRadius: 20,
    spreadRadius: 2,
  );

  static BoxShadow get successGlow => BoxShadow(
    color: successGreen.withOpacity(0.4),
    blurRadius: 20,
    spreadRadius: 2,
  );

  // ===================================
  // TYPOGRAPHY
  // ===================================

  static TextTheme get _textTheme {
    return TextTheme(
      // Display - Bold, Statement
      displayLarge: GoogleFonts.outfit(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        letterSpacing: -1,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),

      // Headlines - Bold but Smaller
      headlineLarge: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),

      // Titles
      titleLarge: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleSmall: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),

      // Body - Readable
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMuted,
      ),

      // Labels
      labelLarge: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.5,
      ),
      labelMedium: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      labelSmall: GoogleFonts.outfit(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: textMuted,
        letterSpacing: 0.5,
      ),
    );
  }

  // ===================================
  // THEME DATA - Dark Mode Only
  // ===================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Colors
      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        onPrimary: textPrimary,
        secondary: accentCyan,
        onSecondary: bgPrimary,
        tertiary: errorPink,
        error: errorPink,
        surface: bgSecondary,
        onSurface: textPrimary,
        surfaceContainerHighest: bgTertiary,
        outline: borderSubtle,
      ),

      // Background
      scaffoldBackgroundColor: bgPrimary,

      // Typography
      textTheme: _textTheme,

      // App Bar - Transparent for video feed
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),

      // Card Theme - Glass Effect
      cardTheme: CardThemeData(
        color: bgSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderSubtle),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button - Gradient style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryPurple,
          side: const BorderSide(color: primaryPurple, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentCyan,
          textStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input Decoration - Glass style
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgTertiary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
        hintStyle: GoogleFonts.outfit(color: textMuted),
        labelStyle: GoogleFonts.outfit(color: textSecondary),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: bgSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: borderSubtle),
        ),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        contentTextStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: textSecondary,
        ),
      ),

      // Bottom Sheet - Glass
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: bgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        elevation: 0,
      ),

      // Navigation Bar - Minimal
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bgSecondary,
        indicatorColor: primaryPurple.withOpacity(0.2),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryPurple,
            );
          }
          return GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryPurple);
          }
          return const IconThemeData(color: textMuted);
        }),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgTertiary,
        contentTextStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderSubtle),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryPurple,
        linearTrackColor: borderSubtle,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: borderSubtle,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
    );
  }
}
