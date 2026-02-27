import 'package:flutter/material.dart';

/// Konfigurasi tema aplikasi (Light & Dark)
class AppTheme {
  // ===== LIGHT THEME =====
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color scheme based on Indigo
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F46E5), // Indigo
      brightness: Brightness.light,
      surface: Colors.white,
      surfaceDim: const Color(0xFFF3F4F6), // Light gray
    ),

    // Scaffold and background colors
    scaffoldBackgroundColor: Colors.grey[50],
    canvasColor: Colors.white,

    // App Bar
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF4F46E5),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Card theme
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Input decoration (TextFields)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFF4F46E5),
          width: 2,
        ),
      ),
      labelStyle: const TextStyle(color: Colors.grey),
      hintStyle: TextStyle(color: Colors.grey[400]),
    ),

    // Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Text themes
    textTheme: TextTheme(
      displayLarge: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
      ),
      displayMedium: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
      ),
      displaySmall: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
      ),
      headlineMedium: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.grey[800],
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.grey[700],
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        color: Colors.grey[500],
        fontWeight: FontWeight.w500,
      ),
    ),

    // Floating action button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF4F46E5),
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Bottom sheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
  );

  // ===== DARK THEME =====
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Color scheme for dark
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF818CF8), // Lighter indigo for dark mode
      brightness: Brightness.dark,
      surface: const Color(0xFF1F2937),
      surfaceDim: const Color(0xFF111827),
    ),

    // Scaffold and background colors
    scaffoldBackgroundColor: const Color(0xFF111827),
    canvasColor: const Color(0xFF1F2937),

    // App Bar
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1F2937),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Card theme
    cardTheme: CardTheme(
      color: const Color(0xFF1F2937),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF374151),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF4B5563)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF4B5563)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFF818CF8),
          width: 2,
        ),
      ),
      labelStyle: TextStyle(color: Colors.grey[400]),
      hintStyle: TextStyle(color: Colors.grey[500]),
    ),

    // Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF818CF8),
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Text themes
    textTheme: TextTheme(
      displayLarge: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displayMedium: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displaySmall: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE5E7EB),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.grey[200],
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.grey[300],
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Colors.grey[400],
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        color: Colors.grey[500],
        fontWeight: FontWeight.w500,
      ),
    ),

    // Floating action button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF818CF8),
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Bottom sheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF1F2937),
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
  );
}
