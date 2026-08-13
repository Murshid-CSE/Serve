import 'package:flutter/material.dart';
import 'package:community_care_hub/features/emergency/domain/entities/emergency_alert_entity.dart';
import 'package:community_care_hub/core/widgets/app_card.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';
import 'package:community_care_hub/core/extensions/datetime_extension.dart';

class EmergencyCard extends StatefulWidget {

  const EmergencyCard({
    super.key,
    required this.alert,
    required this.onTap,
    this.distanceKm,
  });
  final EmergencyAlertEntity alert;
  final VoidCallback onTap;
  final double? distanceKm;

  @override
  State<EmergencyCard> createState() => _EmergencyCardState();
}

class _EmergencyCardState extends State<EmergencyCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getAlertColor() {
    return switch (widget.alert.level) {
      'critical' => AppColors.emergency,
      'warning' => AppColors.secondary,
      _ => AppColors.info,
    };
  }

  Color _getAlertSurfaceColor() {
    return switch (widget.alert.level) {
      'critical' => AppColors.emergencySurface,
      'warning' => AppColors.secondarySurface,
      _ => AppColors.infoSurface,
    };
  }

  @override
  Widget build(BuildContext context) {
    final alertColor = _getAlertColor();
    final surfaceColor = _getAlertSurfaceColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        onTap: widget.onTap,
        padding: const EdgeInsets.all(16),
        elevation: widget.alert.isCritical ? 4 : 2,
        borderRadius: 16,
        borderColor: alertColor.withValues(alpha: 0.4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Pulse Anim Icon (for critical)
                widget.alert.isCritical
                    ? ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: alertColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: alertColor.withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.campaign_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: alertColor,
                          size: 20,
                        ),
                      ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.alert.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            widget.alert.level.toUpperCase(),
                            style: TextStyle(
                              color: alertColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.alert.createdAt.timeAgo,
                            style: const TextStyle(
                              color: AppColors.neutral500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: AppColors.neutral200),

            // Location
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_rounded, size: 16, color: AppColors.neutral500),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.alert.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.neutral700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.distanceKm != null)
                  Text(
                    '${widget.distanceKm!.toStringAsFixed(1)} km away',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral600,
                    ),
                  )
                else
                  const SizedBox(),
                Text(
                  '${widget.alert.responders.length} responders active',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.alert.responders.isNotEmpty ? AppColors.success : AppColors.neutral500,
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
}
