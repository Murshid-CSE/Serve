import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';

/// Material 3 dark theme for Community Care Hub.
///
/// Mirrors [LightTheme] component styling but adapted for dark surfaces.
/// Uses the same Poppins + Inter typographic hierarchy with lighter text
/// colors for optimal readability on dark backgrounds.
class DarkTheme {
  DarkTheme._();

  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.onPrimaryContainer,
      primaryContainer: AppColors.darkPrimaryContainer,
      onPrimaryContainer: AppColors.darkOnPrimaryContainer,
      secondary: AppColors.darkSecondary,
      onSecondary: AppColors.onSecondaryContainer,
      secondaryContainer: AppColors.darkSecondaryContainer,
      onSecondaryContainer: AppColors.secondaryContainer,
      tertiary: AppColors.darkTertiary,
      onTertiary: AppColors.onTertiaryContainer,
      tertiaryContainer: AppColors.darkTertiaryContainer,
      onTertiaryContainer: AppColors.tertiaryContainer,
      error: AppColors.darkError,
      onError: AppColors.onErrorContainer,
      errorContainer: AppColors.darkErrorContainer,
      onErrorContainer: AppColors.errorContainer,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
      surfaceContainerLowest: const Color(0xFF0B100D),
      surfaceContainerLow: const Color(0xFF151B18),
      surfaceContainer: AppColors.darkSurfaceContainer,
      surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
      surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
      onSurfaceVariant: AppColors.darkOnSurfaceVariant,
      outline: AppColors.darkOutline,
      outlineVariant: AppColors.darkOutlineVariant,
      shadow: AppColors.shadow,
      scrim: AppColors.scrim,
    );

    final poppinsTextTheme = GoogleFonts.poppinsTextTheme();
    final interTextTheme = GoogleFonts.interTextTheme();

    final textTheme = TextTheme(
      // Display — Poppins
      displayLarge: poppinsTextTheme.displayLarge?.copyWith(
        color: AppColors.darkOnSurface,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displayMedium: poppinsTextTheme.displayMedium?.copyWith(
        color: AppColors.darkOnSurface,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      displaySmall: poppinsTextTheme.displaySmall?.copyWith(
        color: AppColors.darkOnSurface,
        fontWeight: FontWeight.w600,
      ),

      // Headline — Poppins
      headlineLarge: poppinsTextTheme.headlineLarge?.copyWith(
        color: AppColors.darkOnSurface,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      headlineMedium: poppinsTextTheme.headlineMedium?.copyWith(
        color: AppColors.darkOnSurface,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: poppinsTextTheme.headlineSmall?.copyWith(
        color: AppColors.darkOnSurface,
        fontWeight: FontWeight.w600,
      ),

      // Title — Poppins
      titleLarge: poppinsTextTheme.titleLarge?.copyWith(
        color: AppColors.darkOnSurface,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      titleMedium: poppinsTextTheme.titleMedium?.copyWith(
        color: AppColors.darkOnSurface,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      titleSmall: poppinsTextTheme.titleSmall?.copyWith(
        color: AppColors.darkOnSurface,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),

      // Body — Inter
      bodyLarge: interTextTheme.bodyLarge?.copyWith(
        color: AppColors.darkOnSurface,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      bodyMedium: interTextTheme.bodyMedium?.copyWith(
        color: AppColors.darkOnSurface,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.5,
      ),
      bodySmall: interTextTheme.bodySmall?.copyWith(
        color: AppColors.darkOnSurfaceVariant,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.4,
      ),

      // Label — Inter
      labelLarge: interTextTheme.labelLarge?.copyWith(
        color: AppColors.darkOnSurface,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: interTextTheme.labelMedium?.copyWith(
        color: AppColors.darkOnSurfaceVariant,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: interTextTheme.labelSmall?.copyWith(
        color: AppColors.darkOnSurfaceVariant,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,

      // ─── AppBar ─────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.darkPrimary,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.darkSurfaceContainer,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: poppinsTextTheme.titleLarge?.copyWith(
          color: AppColors.darkOnSurface,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.darkOnSurface,
          size: 24,
        ),
      ),

      // ─── Card ───────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black54,
        surfaceTintColor: Colors.transparent,
        color: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // ─── ElevatedButton ─────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          shadowColor: Colors.black54,
          backgroundColor: AppColors.darkSurfaceContainerHigh,
          foregroundColor: AppColors.darkPrimary,
          surfaceTintColor: AppColors.darkPrimaryContainer,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: interTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // ─── FilledButton ───────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: interTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // ─── OutlinedButton ─────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
          textStyle: interTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // ─── TextButton ────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: interTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // ─── InputDecoration ────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceContainerHigh,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkOutlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkOutlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkError, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkError, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.darkOutlineVariant.withValues(alpha: 0.5),
          ),
        ),
        hintStyle: interTextTheme.bodyMedium?.copyWith(
          color: AppColors.neutral500,
        ),
        labelStyle: interTextTheme.bodyMedium?.copyWith(
          color: AppColors.darkOnSurfaceVariant,
        ),
        errorStyle: interTextTheme.bodySmall?.copyWith(
          color: AppColors.darkError,
        ),
        prefixIconColor: AppColors.darkOnSurfaceVariant,
        suffixIconColor: AppColors.darkOnSurfaceVariant,
      ),

      // ─── BottomNavigationBar ────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurfaceContainer,
        selectedItemColor: AppColors.darkPrimary,
        unselectedItemColor: AppColors.neutral500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: interTextTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: interTextTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        showUnselectedLabels: true,
      ),

      // ─── NavigationBar (Material 3) ─────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurfaceContainer,
        indicatorColor: AppColors.darkPrimaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.darkPrimary, size: 24);
          }
          return const IconThemeData(color: AppColors.neutral500, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          final base = interTextTheme.labelSmall;
          if (states.contains(WidgetState.selected)) {
            return base?.copyWith(
              color: AppColors.darkPrimary,
              fontWeight: FontWeight.w600,
            );
          }
          return base?.copyWith(
            color: AppColors.neutral500,
            fontWeight: FontWeight.w500,
          );
        }),
      ),

      // ─── NavigationRail ─────────────────────────────────────────────
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.darkSurfaceContainer,
        indicatorColor: AppColors.darkPrimaryContainer,
        selectedIconTheme: const IconThemeData(color: AppColors.darkPrimary),
        unselectedIconTheme: const IconThemeData(color: AppColors.neutral500),
        selectedLabelTextStyle: interTextTheme.labelSmall?.copyWith(
          color: AppColors.darkPrimary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: interTextTheme.labelSmall?.copyWith(
          color: AppColors.neutral500,
        ),
      ),

      // ─── FloatingActionButton ───────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.onPrimaryContainer,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 8,
        highlightElevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 24),
        extendedTextStyle: interTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.onPrimaryContainer,
        ),
      ),

      // ─── Chip ───────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceContainerHigh,
        selectedColor: AppColors.darkPrimaryContainer,
        disabledColor: AppColors.darkSurfaceContainerHighest,
        surfaceTintColor: Colors.transparent,
        side: const BorderSide(color: AppColors.darkOutlineVariant, width: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelStyle: interTextTheme.labelMedium?.copyWith(
          color: AppColors.darkOnSurface,
        ),
        secondaryLabelStyle: interTextTheme.labelMedium?.copyWith(
          color: AppColors.darkPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        showCheckmark: true,
        checkmarkColor: AppColors.darkPrimary,
      ),

      // ─── SnackBar ──────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurfaceContainerHighest,
        contentTextStyle: interTextTheme.bodyMedium?.copyWith(
          color: AppColors.darkOnSurface,
        ),
        actionTextColor: AppColors.darkPrimary,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // ─── BottomSheet ────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        modalElevation: 8,
        showDragHandle: true,
        dragHandleColor: AppColors.neutral600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(maxWidth: 640),
      ),

      // ─── Dialog ─────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: poppinsTextTheme.titleLarge?.copyWith(
          color: AppColors.darkOnSurface,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: interTextTheme.bodyMedium?.copyWith(
          color: AppColors.darkOnSurfaceVariant,
          height: 1.5,
        ),
      ),

      // ─── Divider ────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.darkOutlineVariant,
        thickness: 1,
        space: 1,
      ),

      // ─── ListTile ──────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        iconColor: AppColors.darkOnSurfaceVariant,
        titleTextStyle: interTextTheme.bodyLarge?.copyWith(
          color: AppColors.darkOnSurface,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: interTextTheme.bodySmall?.copyWith(
          color: AppColors.darkOnSurfaceVariant,
        ),
      ),

      // ─── TabBar ─────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.darkPrimary,
        unselectedLabelColor: AppColors.neutral500,
        indicatorColor: AppColors.darkPrimary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.darkOutlineVariant,
        labelStyle: interTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: interTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),

      // ─── Switch ─────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkPrimary;
          }
          return AppColors.neutral500;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkPrimaryContainer;
          }
          return AppColors.darkSurfaceContainerHighest;
        }),
      ),

      // ─── Checkbox ───────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkPrimary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.onPrimaryContainer),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: const BorderSide(color: AppColors.darkOutline, width: 1.5),
      ),

      // ─── Radio ──────────────────────────────────────────────────────
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkPrimary;
          }
          return AppColors.darkOutline;
        }),
      ),

      // ─── ProgressIndicator ──────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.darkPrimary,
        linearTrackColor: AppColors.darkPrimaryContainer,
        circularTrackColor: AppColors.darkPrimaryContainer,
      ),

      // ─── Tooltip ────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: interTextTheme.bodySmall?.copyWith(
          color: AppColors.darkOnSurface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // ─── Badge ──────────────────────────────────────────────────────
      badgeTheme: const BadgeThemeData(
        backgroundColor: AppColors.darkError,
        textColor: AppColors.onErrorContainer,
      ),

      // ─── Page Transitions ──────────────────────────────────────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
