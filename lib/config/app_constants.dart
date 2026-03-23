/// Constantes globales de la aplicación
class AppConstants {
  // Dimensiones
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  // Elevaciones
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;

  // Animaciones
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 400);
  static const Duration animationDurationLong = Duration(milliseconds: 600);

  // Aplicación
  static const String appName = 'BetFlix';
  static const String appVersion = '1.0.0';

  // URLs (para APIs futuras)
  static const String apiBaseUrl = 'https://api.betflix.com';
  static const String assetsPath = 'assets/';

  // Moneda
  static const String currencySymbol = '💰';
  static const String currencyCode = 'BFC'; // BetFlix Coins
  static const int initialCoins = 5000;
}
