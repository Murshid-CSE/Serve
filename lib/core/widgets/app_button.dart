import 'package:flutter/material.dart';

/// Visual style variant for [AppButton].
enum AppButtonVariant { filled, tonal, outlined, text }

/// Size preset for [AppButton].
enum AppButtonSize { small, medium, large }

/// A versatile, production-quality button widget with support for
/// multiple visual variants, sizes, loading state, and optional icons.
///
/// ```dart
/// AppButton(
///   label: 'Donate Now',
///   variant: AppButtonVariant.filled,
///   onPressed: () {},
/// )
/// ```
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = AppButtonVariant.filled,
    this.isExpanded = false,
    this.color,
    this.size = AppButtonSize.medium,
  });

  /// The text displayed on the button.
  final String label;

  /// Called when the button is tapped. When `null`, the button is disabled.
  final VoidCallback? onPressed;

  /// Optional leading icon displayed before the label.
  final IconData? icon;

  /// When `true`, a [CircularProgressIndicator] replaces the label and
  /// the button is disabled regardless of [onPressed].
  final bool isLoading;

  /// The visual variant of the button.
  final AppButtonVariant variant;

  /// When `true`, the button stretches to fill the available width.
  final bool isExpanded;

  /// Optional colour override applied to the button's background (filled /
  /// tonal) or foreground (outlined / text).
  final Color? color;

  /// Controls the button's min-height, horizontal padding, and font size.
  final AppButtonSize size;

  // ── Size helpers ──────────────────────────────────────────────────────

  double get _minHeight {
    switch (size) {
      case AppButtonSize.small:
        return 36;
      case AppButtonSize.medium:
        return 48;
      case AppButtonSize.large:
        return 56;
    }
  }

  EdgeInsetsGeometry get _padding {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 6);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 10);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 14);
    }
  }

  double get _fontSize {
    switch (size) {
      case AppButtonSize.small:
        return 13;
      case AppButtonSize.medium:
        return 15;
      case AppButtonSize.large:
        return 17;
    }
  }

  double get _iconSize {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 22;
    }
  }

  double get _loaderSize {
    switch (size) {
      case AppButtonSize.small:
        return 14;
      case AppButtonSize.medium:
        return 18;
      case AppButtonSize.large:
        return 22;
    }
  }

  double get _loaderStroke {
    switch (size) {
      case AppButtonSize.small:
        return 2.0;
      case AppButtonSize.medium:
        return 2.5;
      case AppButtonSize.large:
        return 3.0;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    final Widget child = _buildChild(context);

    final Widget button = switch (variant) {
      AppButtonVariant.filled => _buildFilled(context, effectiveOnPressed, child),
      AppButtonVariant.tonal => _buildTonal(context, effectiveOnPressed, child),
      AppButtonVariant.outlined => _buildOutlined(context, effectiveOnPressed, child),
      AppButtonVariant.text => _buildText(context, effectiveOnPressed, child),
    };

    if (isExpanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  // ── Child content ─────────────────────────────────────────────────────

  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      final Color loaderColor = switch (variant) {
        AppButtonVariant.filled => Colors.white,
        AppButtonVariant.tonal =>
          color ?? Theme.of(context).colorScheme.onSecondaryContainer,
        AppButtonVariant.outlined =>
          color ?? Theme.of(context).colorScheme.primary,
        AppButtonVariant.text =>
          color ?? Theme.of(context).colorScheme.primary,
      };

      return SizedBox(
        width: _loaderSize,
        height: _loaderSize,
        child: CircularProgressIndicator(
          strokeWidth: _loaderStroke,
          valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
        ),
      );
    }

    final textWidget = Text(
      label,
      style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.w600),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _iconSize),
          const SizedBox(width: 8),
          Flexible(child: textWidget),
        ],
      );
    }

    return textWidget;
  }

  // ── Variant builders ──────────────────────────────────────────────────

  ButtonStyle _commonStyle(BuildContext context) {
    return ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(0, _minHeight)),
      padding: WidgetStatePropertyAll(_padding),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildFilled(
    BuildContext context,
    VoidCallback? onTap,
    Widget child,
  ) {
    return FilledButton(
      onPressed: onTap,
      style: _commonStyle(context).copyWith(
        backgroundColor: color != null
            ? WidgetStatePropertyAll(color)
            : null,
        foregroundColor: color != null
            ? WidgetStatePropertyAll(_contrastForeground(color!))
            : null,
      ),
      child: child,
    );
  }

  Widget _buildTonal(
    BuildContext context,
    VoidCallback? onTap,
    Widget child,
  ) {
    return FilledButton.tonal(
      onPressed: onTap,
      style: _commonStyle(context).copyWith(
        backgroundColor: color != null
            ? WidgetStatePropertyAll(color!.withAlpha(30))
            : null,
        foregroundColor: color != null
            ? WidgetStatePropertyAll(color)
            : null,
      ),
      child: child,
    );
  }

  Widget _buildOutlined(
    BuildContext context,
    VoidCallback? onTap,
    Widget child,
  ) {
    return OutlinedButton(
      onPressed: onTap,
      style: _commonStyle(context).copyWith(
        foregroundColor: color != null
            ? WidgetStatePropertyAll(color)
            : null,
        side: color != null
            ? WidgetStatePropertyAll(BorderSide(color: color!.withAlpha(128)))
            : null,
      ),
      child: child,
    );
  }

  Widget _buildText(
    BuildContext context,
    VoidCallback? onTap,
    Widget child,
  ) {
    return TextButton(
      onPressed: onTap,
      style: _commonStyle(context).copyWith(
        foregroundColor: color != null
            ? WidgetStatePropertyAll(color)
            : null,
      ),
      child: child,
    );
  }

  // ── Utilities ─────────────────────────────────────────────────────────

  /// Returns a foreground colour that is legible on [background].
  static Color _contrastForeground(Color background) {
    return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }
}
