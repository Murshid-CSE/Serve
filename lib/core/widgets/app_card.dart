import 'package:flutter/material.dart';

/// A reusable Material 3 card with optional gradient background, ink-well
/// tap feedback, configurable padding, elevation, border radius, and shadow.
///
/// ```dart
/// AppCard(
///   onTap: () {},
///   gradient: AppColors.foodGradient,
///   child: Text('Food Donation'),
/// )
/// ```
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.gradient,
    this.elevation = 2,
    this.borderRadius = 16,
    this.borderColor,
    this.hasShadow = true,
  });

  /// The content rendered inside the card.
  final Widget child;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Inner padding. Defaults to 16 on all sides.
  final EdgeInsets? padding;

  /// Outer margin applied around the card.
  final EdgeInsets? margin;

  /// When provided, draws a linear gradient behind the card content.
  /// Useful for module-specific header cards.
  final List<Color>? gradient;

  /// Card elevation. Defaults to `2`.
  final double elevation;

  /// Corner radius. Defaults to `16`.
  final double borderRadius;

  /// Optional border colour drawn around the card.
  final Color? borderColor;

  /// Whether the card shows a soft drop shadow. Defaults to `true`.
  final bool hasShadow;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: borderColor != null
          ? BorderSide(color: borderColor!)
          : BorderSide.none,
    );

    final effectiveElevation = hasShadow ? elevation : 0.0;

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Card(
        elevation: effectiveElevation,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        shadowColor: hasShadow
            ? Theme.of(context).shadowColor.withAlpha(40)
            : Colors.transparent,
        child: _buildBody(context, shape),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ShapeBorder shape) {
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    final Widget body;

    if (gradient != null && gradient!.length >= 2) {
      body = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient!,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: content,
      );
    } else {
      body = content;
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: body,
      );
    }

    return body;
  }
}
