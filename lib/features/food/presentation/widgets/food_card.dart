import 'package:flutter/material.dart';
import 'package:community_care_hub/features/food/domain/entities/food_donation_entity.dart';
import 'package:community_care_hub/features/food/presentation/widgets/freshness_timer_widget.dart';
import 'package:community_care_hub/core/widgets/app_card.dart';
import 'package:community_care_hub/core/widgets/status_chip.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FoodCard extends StatelessWidget {
  final FoodDonationEntity donation;
  final VoidCallback onTap;
  final double? distanceKm;

  const FoodCard({
    super.key,
    required this.donation,
    required this.onTap,
    this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        elevation: 2,
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Placeholder Header
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: donation.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: donation.imageUrl!,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 140,
                            color: AppColors.neutral200,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                ),
                // Status chip overlay
                Positioned(
                  top: 12,
                  left: 12,
                  child: StatusChip(status: donation.status),
                ),
                // Expiry timer overlay
                if (donation.isAvailable)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: FreshnessTimerWidget(
                      expiresAt: donation.expiresAt,
                      compact: true,
                    ),
                  ),
              ],
            ),

            // Content body
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          donation.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral900,
                          ),
                        ),
                      ),
                      if (distanceKm != null) ...[
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.neutral500,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${distanceKm!.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.neutral600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.neutral100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          donation.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Qty: ${donation.quantity}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.neutral600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    donation.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 140,
      width: double.infinity,
      color: AppColors.secondarySurface,
      child: const Center(
        child: Icon(
          Icons.restaurant_rounded,
          color: AppColors.secondary,
          size: 48,
        ),
      ),
    );
  }
}
