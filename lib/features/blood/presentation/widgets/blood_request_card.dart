import 'package:flutter/material.dart';
import 'package:community_care_hub/features/blood/domain/entities/blood_request_entity.dart';
import 'package:community_care_hub/core/widgets/app_card.dart';
import 'package:community_care_hub/core/widgets/status_chip.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';
import 'package:community_care_hub/core/extensions/datetime_extension.dart';

class BloodRequestCard extends StatelessWidget {

  const BloodRequestCard({
    super.key,
    required this.request,
    required this.onTap,
    this.distanceKm,
  });
  final BloodRequestEntity request;
  final VoidCallback onTap;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        elevation: 2,
        borderRadius: 16,
        borderColor: request.isEmergency ? AppColors.primary.withValues(alpha: 0.3) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Blood Group + Emergency + Status
            Row(
              children: [
                // Blood group circle badge
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: request.isEmergency ? AppColors.primary : AppColors.primarySurface,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      request.bloodGroup,
                      style: TextStyle(
                        color: request.isEmergency ? Colors.white : AppColors.primaryDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Patient: ${request.patientName}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.neutral900,
                            ),
                          ),
                          if (request.isEmergency) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.emergencySurface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.emergency.withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bolt_rounded, color: AppColors.emergency, size: 12),
                                  SizedBox(width: 2),
                                  Text(
                                    'URGENT',
                                    style: TextStyle(
                                      color: AppColors.emergencyDark,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.hospitalName,
                        maxLines: 1,
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
            const Divider(height: 24, color: AppColors.neutral200),

            // Details section: Units + Distance + Expiry
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  icon: Icons.water_drop_rounded,
                  color: AppColors.primary,
                  label: 'Units Needed',
                  value: '${request.unitsNeeded} Units',
                ),
                if (distanceKm != null)
                  _buildInfoItem(
                    icon: Icons.location_on_rounded,
                    color: AppColors.neutral600,
                    label: 'Distance',
                    value: '${distanceKm!.toStringAsFixed(1)} km',
                  ),
                _buildInfoItem(
                  icon: Icons.timer_outlined,
                  color: AppColors.neutral600,
                  label: 'Posted',
                  value: request.createdAt.timeAgo,
                ),
              ],
            ),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusChip(status: request.status),
                if (request.respondedBy.isNotEmpty)
                  Text(
                    '${request.respondedBy.length} donors responding',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.neutral500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
