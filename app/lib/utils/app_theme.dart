import 'package:flutter/material.dart';

/// App theme configuration for Lunanul
class AppTheme {
  // Enhanced color palette - calming purples, deep blues, soft golds
  static const Color primaryPurple = Color(0xFF6B46C1);
  static const Color deepBlue = Color(0xFF1E3A8A);
  static const Color softGold = Color(0xFFF59E0B);
  static const Color lightLavender = Color(0xFFF8FAFC);
  static const Color darkGray = Color(0xFF374151);

  // Additional tranquil colors
  static const Color mysticPurple = Color(0xFF8B5CF6);
  static const Color twilightBlue = Color(0xFF3730A3);
  static const Color moonlightSilver = Color(0xFFE2E8F0);
  static const Color stardustGold = Color(0xFFFBBF24);
  static const Color serenityGreen = Color(0xFF10B981);
  static const Color cosmicIndigo = Color(0xFF4338CA);

  // Semantic colors
  static const Color successColor = serenityGreen;
  static const Color warningColor = stardustGold;
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = mysticPurple;

  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Secondary',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPurple,
        brightness: Brightness.light,
        primary: primaryPurple,
        secondary: softGold,
        surface: lightLavender,
        onSurface: darkGray,
      ),
      useMaterial3: true,

      // Typography with generous spacing
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
          height: 1.2,
          fontFamily: "Primary",
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.25,
          height: 1.3,
          fontFamily: "Primary",
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.3,
          fontFamily: "Primary",
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.4,
          fontFamily: "Primary",
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          height: 1.5,
          fontFamily: "Primary",
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.15,
          height: 1.5,
          fontFamily: "Secondary",
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.4,
          fontFamily: "Secondary",
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.4,
          fontFamily: "Accent",
        ),
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: darkGray,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: darkGray,
          letterSpacing: 0.15,
          fontFamily: 'Primary',
        ),
      ),

      // Bottom navigation theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedItemColor: primaryPurple,
        unselectedItemColor: darkGray,
        backgroundColor: Colors.white,
        selectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: "Primary",
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          fontFamily: "Primary",
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      fontFamily: 'Secondary',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPurple,
        brightness: Brightness.dark,
        primary: primaryPurple,
        secondary: softGold,
      ),
      useMaterial3: true,

      // Typography with generous spacing (same as light theme)
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
          height: 1.2,
          fontFamily: "Primary",
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.25,
          height: 1.3,
          fontFamily: "Primary",
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.3,
          fontFamily: "Primary",
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.4,
          fontFamily: "Primary",
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          height: 1.5,
          fontFamily: "Primary",
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.15,
          height: 1.5,
          fontFamily: "Secondary",
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.4,
          fontFamily: "Secondary",
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.4,
          fontFamily: "Accent",
        ),
      ),

      // App bar theme for dark mode
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          fontFamily: 'Primary',
        ),
      ),

      // Bottom navigation theme for dark mode
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: "Primary",
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          fontFamily: "Primary",
        ),
      ),

      // Elevated button theme for dark mode
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }

  // Animation durations for consistent timing
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const Duration extraLongAnimation = Duration(milliseconds: 800);

  // Common border radius values
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(16));
  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(12),
  );
  static const BorderRadius dialogRadius = BorderRadius.all(
    Radius.circular(20),
  );
  static const BorderRadius chipRadius = BorderRadius.all(Radius.circular(20));

  // Spacing constants for consistent layout
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Elevation levels
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationVeryHigh = 16.0;
}
