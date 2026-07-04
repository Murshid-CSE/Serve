import 'package:flutter/material.dart';

import 'package:community_care_hub/core/constants/app_colors.dart';
import 'package:community_care_hub/core/constants/app_strings.dart';

/// A centred error-state placeholder displayed when an operation fails.
/// Shows a red icon inside a light-red circle, an error message, and an
/// optional retry button.
///
/// ```dart
/// ErrorState(
///   message: AppStrings.somethingWentWrong,
///   onRetry: () => ref.invalidate(myProvider),
/// )
/// ```
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  /// The error message shown to the user.
  final String message;

  /// Called when the user taps the retry button. When `null` the retry
  /// button is hidden.
  final VoidCallback? onRetry;

  /// The icon displayed inside the circle. Defaults to
  /// [Icons.error_outline_rounded].
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon circle
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.emergencySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.emergency,
              ),
            ),
            const SizedBox(height: 24),

            // Error message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            // Retry button
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text(
                  AppStrings.retry,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.emergency,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
