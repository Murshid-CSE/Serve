import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:community_care_hub/core/constants/app_colors.dart';

/// A collection of shimmer-effect placeholder widgets used while content
/// is loading. Each factory constructor targets a common layout pattern.
///
/// Shimmer colours automatically adapt to the current theme brightness,
/// using [AppColors] neutral tones.
///
/// ```dart
/// LoadingShimmer.list(count: 5)
/// LoadingShimmer.profile()
/// ```
class LoadingShimmer extends StatelessWidget {
  /// Creates a single shimmer card placeholder.
  const LoadingShimmer.card({super.key})
      : _type = _ShimmerType.card,
        count = 1;

  /// Creates a vertical list of shimmer card placeholders.
  const LoadingShimmer.list({super.key, this.count = 3})
      : _type = _ShimmerType.list;

  /// Creates a profile-style shimmer (circular avatar + text lines).
  const LoadingShimmer.profile({super.key})
      : _type = _ShimmerType.profile,
        count = 1;

  /// Creates a detail-page shimmer (large image block + text lines).
  const LoadingShimmer.detail({super.key})
      : _type = _ShimmerType.detail,
        count = 1;

  final _ShimmerType _type;

  /// Number of cards rendered by [LoadingShimmer.list]. Ignored by
  /// other constructors.
  final int count;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark ? AppColors.neutral800 : AppColors.neutral200;
    final highlightColor = isDark ? AppColors.neutral700 : AppColors.neutral100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: switch (_type) {
        _ShimmerType.card => const _ShimmerCard(),
        _ShimmerType.list => _ShimmerList(count: count),
        _ShimmerType.profile => const _ShimmerProfile(),
        _ShimmerType.detail => const _ShimmerDetail(),
      },
    );
  }
}

enum _ShimmerType { card, list, profile, detail }

// ── Private layout widgets ──────────────────────────────────────────────────

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const _ShimmerBox(width: 56, height: 56, borderRadius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(
                      width: MediaQuery.sizeOf(context).width * 0.45,
                      height: 14,
                    ),
                    const SizedBox(height: 8),
                    _ShimmerBox(
                      width: MediaQuery.sizeOf(context).width * 0.3,
                      height: 12,
                    ),
                    const SizedBox(height: 8),
                    const _ShimmerBox(width: 80, height: 10),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ShimmerProfile extends StatelessWidget {
  const _ShimmerProfile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar
          const _ShimmerBox(width: 80, height: 80, borderRadius: 40),
          const SizedBox(height: 16),
          // Name
          const _ShimmerBox(width: 160, height: 16),
          const SizedBox(height: 10),
          // Subtitle
          const _ShimmerBox(width: 120, height: 12),
          const SizedBox(height: 24),
          // Stat row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (_) {
              return const Column(
                children: [
                  _ShimmerBox(width: 48, height: 14),
                  SizedBox(height: 6),
                  _ShimmerBox(width: 64, height: 10),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ShimmerDetail extends StatelessWidget {
  const _ShimmerDetail();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large image block
          _ShimmerBox(
            width: screenWidth - 32,
            height: 200,
            borderRadius: 16,
          ),
          const SizedBox(height: 20),
          // Title
          _ShimmerBox(width: screenWidth * 0.65, height: 18),
          const SizedBox(height: 12),
          // Subtitle
          _ShimmerBox(width: screenWidth * 0.45, height: 14),
          const SizedBox(height: 20),
          // Body lines
          _ShimmerBox(width: screenWidth - 32, height: 12),
          const SizedBox(height: 8),
          _ShimmerBox(width: screenWidth - 32, height: 12),
          const SizedBox(height: 8),
          _ShimmerBox(width: screenWidth * 0.6, height: 12),
          const SizedBox(height: 20),
          // Action row
          const Row(
            children: [
              _ShimmerBox(width: 100, height: 40, borderRadius: 12),
              SizedBox(width: 12),
              _ShimmerBox(width: 100, height: 40, borderRadius: 12),
            ],
          ),
        ],
      ),
    );
  }
}
