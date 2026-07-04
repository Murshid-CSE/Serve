import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // PRIMARY — Deep humanitarian red (blood + urgency + care)
  static const Color primary = Color(0xFFD32F2F);
  static const Color primaryDark = Color(0xFFB71C1C);
  static const Color primaryLight = Color(0xFFEF5350);
  static const Color primarySurface = Color(0xFFFFEBEE);
  static const Color primaryContainer = Color(0xFFFFEBEE);
  static const Color onPrimaryContainer = Color(0xFFB71C1C);
  static const Color outline = Color(0xFFBDBDBD);
  static const Color outlineVariant = Color(0xFFE0E0E0);
  static const Color error = Color(0xFFFF1744);
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color tertiaryContainer = Color(0xFFE0F2F1);
  static const Color onTertiaryContainer = Color(0xFF004D40);
  static const Color background = Color(0xFFFFFFFF);
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);
  static const Color onSecondaryContainer = Color(0xFFE65100);
  static const Color secondaryContainer = Color(0xFFFFF3E0);

  // SECONDARY — Warm food amber
  static const Color secondary = Color(0xFFF57C00);
  static const Color secondaryDark = Color(0xFFE65100);
  static const Color secondaryLight = Color(0xFFFFB74D);
  static const Color secondarySurface = Color(0xFFFFF3E0);

  // TERTIARY — Volunteer teal
  static const Color tertiary = Color(0xFF00796B);
  static const Color tertiaryDark = Color(0xFF004D40);
  static const Color tertiaryLight = Color(0xFF26A69A);
  static const Color tertiarySurface = Color(0xFFE0F2F1);

  // EMERGENCY — Bright alert
  static const Color emergency = Color(0xFFFF1744);
  static const Color emergencyDark = Color(0xFFD50000);
  static const Color emergencyLight = Color(0xFFFF5252);
  static const Color emergencySurface = Color(0xFFFFEBEE);

  // SUCCESS / COMPLETED
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFF4CAF50);
  static const Color successSurface = Color(0xFFE8F5E9);

  // WARNING
  static const Color warning = Color(0xFFF9A825);
  static const Color warningSurface = Color(0xFFFFFDE7);

  // INFO
  static const Color info = Color(0xFF1565C0);
  static const Color infoLight = Color(0xFF42A5F5);
  static const Color infoSurface = Color(0xFFE3F2FD);

  // SURFACE
  static const Color surface = Color(0xFFFAFAFA);
  static const Color onSurface = Color(0xFF212121);
  static const Color onSurfaceVariant = Color(0xFF757575);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceContainer = Color(0xFFF5F5F5);
  static const Color surfaceContainerHigh = Color(0xFFEEEEEE);
  static const Color surfaceContainerHighest = Color(0xFFE0E0E0);
  static const Color surfaceContainerDark = Color(0xFF2C2C2C);

  // NEUTRAL
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // MODULE COLORS
  static const Color foodModule = Color(0xFFF57C00);
  static const Color bloodModule = Color(0xFFD32F2F);
  static const Color volunteerModule = Color(0xFF00796B);
  static const Color emergencyModule = Color(0xFFFF1744);

  // MODULE GRADIENTS
  static const List<Color> foodGradient = [
    Color(0xFFF57C00),
    Color(0xFFFFB74D),
  ];
  static const List<Color> bloodGradient = [
    Color(0xFFD32F2F),
    Color(0xFFEF5350),
  ];
  static const List<Color> volunteerGradient = [
    Color(0xFF00796B),
    Color(0xFF26A69A),
  ];
  static const List<Color> emergencyGradient = [
    Color(0xFFFF1744),
    Color(0xFFFF5252),
  ];
  static const List<Color> heroGradient = [
    Color(0xFFD32F2F),
    Color(0xFFB71C1C),
    Color(0xFF880E4F),
  ];

  // STATUS COLORS
  static const Color statusPending = Color(0xFFF57C00);
  static const Color statusActive = Color(0xFF1565C0);
  static const Color statusCompleted = Color(0xFF2E7D32);
  static const Color statusExpired = Color(0xFF9E9E9E);
  static const Color statusCancelled = Color(0xFF757575);

  // DARK THEME SPECIFIC
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceContainer = Color(0xFF2C2C2C);
  static const Color darkCard = Color(0xFF252525);
  static const Color darkOutline = Color(0xFF757575);
  static const Color darkPrimary = Color(0xFFEF5350);
  static const Color darkPrimaryContainer = Color(0xFF880E4F);
  static const Color darkSurfaceContainerHighest = Color(0xFF424242);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkError = Color(0xFFFF5252);
  static const Color onErrorContainer = Color(0xFFFFEBEE);
  static const Color darkOnSurfaceVariant = Color(0xFFBDBDBD);
  static const Color darkSurfaceContainerHigh = Color(0xFF424242);
  static const Color darkOutlineVariant = Color(0xFF616161);
  static const Color darkOnPrimaryContainer = Color(0xFFFFEBEE);
  static const Color darkSecondary = Color(0xFFFFB74D);
  static const Color darkSecondaryContainer = Color(0xFFE65100);
  static const Color darkTertiary = Color(0xFF26A69A);
  static const Color darkTertiaryContainer = Color(0xFF004D40);
  static const Color darkErrorContainer = Color(0xFFD50000);
}
