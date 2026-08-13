import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:community_care_hub/features/blood/domain/entities/blood_donor_entity.dart';
import 'package:community_care_hub/core/widgets/app_card.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class DonorCard extends StatelessWidget {

  const DonorCard({
    super.key,
    required this.donor,
    this.distanceKm,
  });
  final BloodDonorEntity donor;
  final double? distanceKm;

  Future<void> _makeCall(BuildContext context) async {
    final Uri url = Uri.parse('tel:${donor.phone}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not dial number: ${donor.phone}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        elevation: 2,
        borderRadius: 16,
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primarySurface,
              backgroundImage: donor.photoUrl != null ? CachedNetworkImageProvider(donor.photoUrl!) : null,
              child: donor.photoUrl == null
                  ? Text(
                      donor.name.isNotEmpty ? donor.name[0].toUpperCase() : 'D',
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Donor Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donor.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          donor.bloodGroup,
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (distanceKm != null) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.location_on_rounded, size: 14, color: AppColors.neutral500),
                        const SizedBox(width: 2),
                        Text(
                          '${distanceKm!.toStringAsFixed(1)} km away',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Call action
            if (donor.phone.isNotEmpty)
              IconButton(
                onPressed: () => _makeCall(context),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.successSurface,
                  foregroundColor: AppColors.success,
                ),
                icon: const Icon(Icons.phone_in_talk_rounded),
              ),
          ],
        ),
      ),
    );
  }
}
