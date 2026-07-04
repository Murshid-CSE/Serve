import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';

/// Material 3 light theme for Community Care Hub.
///
/// Uses Poppins for display/headline text and Inter for body/label text
/// to create a premium, highly readable typographic hierarchy.
class LightTheme {
  LightTheme._();

  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: AppColors.neutral50,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      shadow: AppColors.shadow,
      scrim: AppColors.scrim,
    );

    final poppinsTextTheme = GoogleFonts.poppinsTextTheme();
    final interTextTheme = GoogleFonts.interTextTheme();

    final textTheme = TextTheme(
      // Display — Poppins, bold, for hero/splash text
      displayLarge: poppinsTextTheme.displayLarge?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displayMedium: poppinsTextTheme.displayMedium?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      displaySmall: poppinsTextTheme.displaySmall?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w600,
      ),

      // Headline — Poppins, semibold, for section titles
      headlineLarge: poppinsTextTheme.headlineLarge?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      headlineMedium: poppinsTextTheme.headlineMedium?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: poppinsTextTheme.headlineSmall?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w600,
      ),

      // Title — Poppins, medium weight, for card/appbar titles
      titleLarge: poppinsTextTheme.titleLarge?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      titleMedium: poppinsTextTheme.titleMedium?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      titleSmall: poppinsTextTheme.titleSmall?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),

      // Body — Inter, for readability in paragraphs
      bodyLarge: interTextTheme.bodyLarge?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      bodyMedium: interTextTheme.bodyMedium?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.5,
      ),
      bodySmall: interTextTheme.bodySmall?.copyWith(
        color: AppColors.onSurfaceVariant,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.4,
      ),

      // Label — Inter, medium weight, for buttons/chips/captions
      labelLarge: interTextTheme.labelLarge?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: interTextTheme.labelMedium?.copyWith(
        color: AppColors.onSurfaceVariant,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: interTextTheme.labelSmall?.copyWith(
        color: AppColors.onSurfaceVariant,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,

      // ─── AppBar ─────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.primary,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.surfaceContainer,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: poppinsTextTheme.titleLarge?.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.onSurface,
          size: 24,
        ),
      ),

      // ─── Card ───────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: AppColors.shadow,
        surfaceTintColor: Colors.transparent,
        color: AppColors.surfaceContainer,
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
          shadowColor: AppColors.shadow,
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.primary,
          surfaceTintColor: AppColors.primaryContainer,
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
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: interTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // ─── TextButton ────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
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
        fillColor: AppColors.neutral100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        ),
        hintStyle: interTextTheme.bodyMedium?.copyWith(
          color: AppColors.neutral400,
        ),
        labelStyle: interTextTheme.bodyMedium?.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        errorStyle: interTextTheme.bodySmall?.copyWith(
          color: AppColors.error,
        ),
        prefixIconColor: AppColors.onSurfaceVariant,
        suffixIconColor: AppColors.onSurfaceVariant,
      ),

      // ─── BottomNavigationBar ────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainer,
        selectedItemColor: AppColors.primary,
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
        backgroundColor: AppColors.surfaceContainer,
        indicatorColor: AppColors.primaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.neutral500, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          final base = interTextTheme.labelSmall;
          if (states.contains(WidgetState.selected)) {
            return base?.copyWith(
              color: AppColors.primary,
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
        backgroundColor: AppColors.surfaceContainer,
        indicatorColor: AppColors.primaryContainer,
        selectedIconTheme: const IconThemeData(color: AppColors.primary),
        unselectedIconTheme: const IconThemeData(color: AppColors.neutral500),
        selectedLabelTextStyle: interTextTheme.labelSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: interTextTheme.labelSmall?.copyWith(
          color: AppColors.neutral500,
        ),
      ),

      // ─── FloatingActionButton ───────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
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
          color: Colors.white,
        ),
      ),

      // ─── Chip ───────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainer,
        selectedColor: AppColors.primaryContainer,
        disabledColor: AppColors.neutral200,
        surfaceTintColor: Colors.transparent,
        side: const BorderSide(color: AppColors.outlineVariant, width: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelStyle: interTextTheme.labelMedium?.copyWith(
          color: AppColors.onSurface,
        ),
        secondaryLabelStyle: interTextTheme.labelMedium?.copyWith(
          color: AppColors.primary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        showCheckmark: true,
        checkmarkColor: AppColors.primary,
      ),

      // ─── SnackBar ──────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutral800,
        contentTextStyle: interTextTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
        actionTextColor: AppColors.primaryLight,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // ─── BottomSheet ────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        modalElevation: 8,
        showDragHandle: true,
        dragHandleColor: AppColors.neutral300,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(maxWidth: 640),
      ),

      // ─── Dialog ─────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: poppinsTextTheme.titleLarge?.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: interTextTheme.bodyMedium?.copyWith(
          color: AppColors.onSurfaceVariant,
          height: 1.5,
        ),
      ),

      // ─── Divider ────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.neutral200,
        thickness: 1,
        space: 1,
      ),

      // ─── ListTile ──────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        iconColor: AppColors.onSurfaceVariant,
        titleTextStyle: interTextTheme.bodyLarge?.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: interTextTheme.bodySmall?.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),

      // ─── TabBar ─────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.neutral500,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.outlineVariant,
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
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.neutral400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryContainer;
          }
          return AppColors.neutral200;
        }),
      ),

      // ─── Checkbox ───────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: const BorderSide(color: AppColors.outline, width: 1.5),
      ),

      // ─── Radio ──────────────────────────────────────────────────────
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.outline;
        }),
      ),

      // ─── ProgressIndicator ──────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primaryContainer,
        circularTrackColor: AppColors.primaryContainer,
      ),

      // ─── Tooltip ────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.neutral800,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: interTextTheme.bodySmall?.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // ─── Badge ──────────────────────────────────────────────────────
      badgeTheme: const BadgeThemeData(
        backgroundColor: AppColors.error,
        textColor: Colors.white,
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
