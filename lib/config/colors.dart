import 'package:flutter/material.dart';

/// Paleta de colores profesional para BetFlix - MEJORADA
/// Colores vistosos y atractivos sin blancos
class BetFlixColors {
  // Colores principales vibrantes
  static const Color primaryBlue = Color(0xFF003B7A); // Azul oscuro profesional
  static const Color accentRed = Color(0xFFE41E3F); // Rojo vibrante
  static const Color goldYellow = Color(0xFFFFD700); // Oro/Amarillo
  
  // Colores secundarios vistosos - SIN BLANCOS
  static const Color purpleVibrant = Color(0xFF7B2CBF); // Púrpura vibrante
  static const Color pinkBright = Color(0xFFFF006E); // Rosa brillante
  static const Color cyanBright = Color(0xFF00D9FF); // Cian brillante
  static const Color greenLime = Color(0xFF39FF14); // Verde lima
  static const Color orangeVibrant = Color(0xFFFF8C00); // Naranja vibrante

  // Variaciones del azul principal
  static const Color primaryBlueDark = Color(0xFF002156);
  static const Color primaryBlueLight = Color(0xFF0052A3);
  static const Color primaryBlueLighter = Color(0xFF1A6FBF);

  // Colores neutros mejorados - Sin blancos
  static const Color darkGrey = Color(0xFF1A1A1A);
  static const Color grey = Color(0xFF6B7280);
  static const Color lightGrey = Color(0xFF2A2A2A); // Gris oscuro en vez de claro
  static const Color almostWhite = Color(0xFFF0F0F0); // Muy claro pero no blanco puro
  static const Color white = Color(0xFFFFFFFF); // Blanco puro
  static const Color black = Color(0xFF000000);

  // Colores de estado mejorados
  static const Color success = Color(0xFF10B981); // Verde para victorias
  static const Color warning = Color(0xFFF59E0B); // Naranja para advertencias
  static const Color error = Color(0xFFEF4444); // Rojo para errores
  static const Color info = Color(0xFF3B82F6); // Azul claro para información

  // Fondos vistosos
  static const Color background = Color(0xFF0F0F1E); // Azul marino oscuro
  static const Color surfaceLight = Color(0xFF1A1A2E); // Gris-azul oscuro
  static const Color surfaceDark = Color(0xFF16213E); // Azul marino más oscuro

  // Bordes
  static const Color borderLight = Color(0xFF3A4A6A);
  static const Color borderDark = Color(0xFF2A3A5A);

  // Gradientes vistosos
  static const List<Color> primaryGradient = [primaryBlue, primaryBlueDark];
  static const List<Color> successGradient = [success, Color(0xFF059669)];
  static const List<Color> premiumGradient = [goldYellow, Color(0xFFFFA500)];
  static const LinearGradient purpleGradientLinear = LinearGradient(
    colors: [purpleVibrant, pinkBright],
  );
  static const LinearGradient vibrantGradientLinear = LinearGradient(
    colors: [cyanBright, primaryBlueLight],
  );
  static const LinearGradient hotGradientLinear = LinearGradient(
    colors: [accentRed, orangeVibrant],
  );
  
  // También dejamos las versiones como listas para compatibilidad
  static const List<Color> purpleGradient = [purpleVibrant, pinkBright];
  static const List<Color> vibrantGradient = [cyanBright, primaryBlueLight];
  static const List<Color> hotGradient = [accentRed, orangeVibrant];
}
