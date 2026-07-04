import 'package:flutter/material.dart';
import 'package:community_care_hub/core/theme/light_theme.dart';
import 'package:community_care_hub/core/theme/dark_theme.dart';

/// Provides unified access to the app's light and dark [ThemeData].
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
///   themeMode: ThemeMode.system,
/// )
/// ```
class AppTheme {
  AppTheme._();

  /// The Material 3 light theme with Poppins + Inter typography.
  static ThemeData get lightTheme => LightTheme.theme;

  /// The Material 3 dark theme with adapted surfaces and colors.
  static ThemeData get darkTheme => DarkTheme.theme;
}
