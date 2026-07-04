import 'package:flutter/material.dart';

import 'package:community_care_hub/core/constants/app_colors.dart';

/// A centred empty-state placeholder used when a list or screen has no
/// content to display. Shows a large icon inside a coloured circle,
/// a bold title, a muted subtitle, and an optional action button.
///
/// ```dart
/// EmptyState(
///   icon: Icons.volunteer_activism_outlined,
///   title: AppStrings.emptyFoodDonations,
///   subtitle: AppStrings.emptyFoodDonationsSubtitle,
///   actionLabel: 'Donate Now',
///   onAction: () {},
/// )
/// ```
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  /// The large icon displayed at the top.
  final IconData icon;

  /// Bold headline describing the empty state.
  final String title;

  /// Secondary description guiding the user on what to do next.
  final String subtitle;

  /// Label for the optional call-to-action button. When `null` the button
  /// is hidden.
  final String? actionLabel;

  /// Called when the action button is tapped.
  final VoidCallback? onAction;

  /// Custom icon and circle background tint. Falls back to the theme's
  /// primary colour.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon circle
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: effectiveIconColor.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: effectiveIconColor,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            // Action button
            if (actionLabel != null) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
