import 'package:flutter/material.dart';
import 'colors.dart';

/// Tema profesional para BetFlix
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Esquema de colores
      colorScheme: ColorScheme.light(
        primary: BetFlixColors.primaryBlue,
        secondary: BetFlixColors.accentRed,
        tertiary: BetFlixColors.goldYellow,
        surface: BetFlixColors.surfaceLight,
        background: BetFlixColors.background,
        error: BetFlixColors.error,
        outline: BetFlixColors.borderLight,
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: BetFlixColors.primaryBlue,
        foregroundColor: BetFlixColors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: BetFlixColors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1A1A2E),
        selectedItemColor: BetFlixColors.pinkBright,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),

      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BetFlixColors.primaryBlue,
          foregroundColor: BetFlixColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BetFlixColors.primaryBlue,
          side: const BorderSide(
            color: BetFlixColors.primaryBlue,
            width: 2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BetFlixColors.primaryBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A2E),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(0),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BetFlixColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: BetFlixColors.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: BetFlixColors.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: BetFlixColors.primaryBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: BetFlixColors.error,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: TextStyle(
          color: BetFlixColors.grey,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelStyle: const TextStyle(
          color: BetFlixColors.primaryBlue,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Estilos de texto
      textTheme: TextTheme(
        // Títulos grandes
        displayLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: BetFlixColors.darkGrey,
          letterSpacing: -0.5,
        ),
        displayMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: BetFlixColors.darkGrey,
          letterSpacing: -0.5,
        ),
        displaySmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: BetFlixColors.darkGrey,
        ),

        // Heads
        headlineLarge: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: BetFlixColors.darkGrey,
        ),
        headlineMedium: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: BetFlixColors.darkGrey,
        ),
        headlineSmall: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: BetFlixColors.darkGrey,
        ),

        // Titles
        titleLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: BetFlixColors.darkGrey,
        ),
        titleMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: BetFlixColors.darkGrey,
        ),
        titleSmall: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: BetFlixColors.grey,
        ),

        // Body
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: BetFlixColors.darkGrey,
          height: 1.5,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: BetFlixColors.darkGrey,
          height: 1.5,
        ),
        bodySmall: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: BetFlixColors.grey,
          height: 1.4,
        ),

        // Labels
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
        labelMedium: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
        labelSmall: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),

      // Otros temas
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: BetFlixColors.background,
      dividerColor: BetFlixColors.borderLight,
      shadowColor: Colors.black12,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.dark(
        primary: BetFlixColors.cyanBright,
        secondary: BetFlixColors.pinkBright,
        tertiary: BetFlixColors.goldYellow,
        surface: BetFlixColors.surfaceCard,
        background: BetFlixColors.background,
        error: BetFlixColors.error,
        outline: BetFlixColors.borderLight,
      ),
      scaffoldBackgroundColor: BetFlixColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: BetFlixColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: BetFlixColors.borderLight.withOpacity(0.35)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BetFlixColors.pinkBright,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BetFlixColors.cyanBright,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: BetFlixColors.cyanBright.withOpacity(0.8), width: 1.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BetFlixColors.surfaceCardElevated,
        hintStyle: const TextStyle(color: Colors.white54),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: BetFlixColors.borderLight.withOpacity(0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: BetFlixColors.borderLight.withOpacity(0.45)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BetFlixColors.cyanBright, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: BetFlixColors.surfaceCardElevated,
        disabledColor: BetFlixColors.surfaceCard,
        selectedColor: BetFlixColors.cyanBright,
        secondarySelectedColor: BetFlixColors.pinkBright,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: BetFlixColors.surfaceCardElevated,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
        labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
      useMaterial3: true,
      brightness: Brightness.dark,
    );
  }
}

/// Estilos personalizados para componentes específicos
class BetFlixTextStyles {
  // Títulos
  static const TextStyle largeTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: BetFlixColors.darkGrey,
    letterSpacing: -0.5,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: BetFlixColors.darkGrey,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: BetFlixColors.darkGrey,
  );

  // Subtítulos
  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: BetFlixColors.grey,
  );

  // Monedas y puntos
  static const TextStyle coinAmount = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: BetFlixColors.goldYellow,
  );

  static const TextStyle smallCoinAmount = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: BetFlixColors.goldYellow,
  );

  // Botones
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // Etiquetas
  static const TextStyle badge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: BetFlixColors.white,
  );

  // Odds
  static const TextStyle odds = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: BetFlixColors.accentRed,
  );
}
