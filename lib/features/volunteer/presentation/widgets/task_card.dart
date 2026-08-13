import 'package:flutter/material.dart';
import 'package:community_care_hub/features/volunteer/domain/entities/volunteer_task_entity.dart';
import 'package:community_care_hub/core/widgets/app_card.dart';
import 'package:community_care_hub/core/widgets/status_chip.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';
import 'package:community_care_hub/core/extensions/datetime_extension.dart';

class TaskCard extends StatelessWidget {

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.distanceKm,
  });
  final VolunteerTaskEntity task;
  final VoidCallback onTap;
  final double? distanceKm;

  IconData _getIconForType(String type) {
    return switch (type) {
      'rescue' => Icons.food_bank_rounded,
      'distribution' => Icons.delivery_dining_rounded,
      'event' => Icons.people_rounded,
      _ => Icons.volunteer_activism_rounded,
    };
  }

  Color _getColorForType(String type) {
    return switch (type) {
      'rescue' => AppColors.secondary,
      'distribution' => AppColors.info,
      'event' => AppColors.tertiary,
      _ => AppColors.neutral700,
    };
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getColorForType(task.type);
    final joined = task.volunteersJoined.length;
    final needed = task.volunteersNeeded;
    final progress = needed > 0 ? (joined / needed).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        elevation: 2,
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Type Icon + Title + Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconForType(task.type),
                    color: typeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'By: ${task.creatorName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: AppColors.neutral200),

            // Middle info row: Date + Location + Distance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  icon: Icons.calendar_today_rounded,
                  color: AppColors.neutral600,
                  label: 'Scheduled',
                  value: task.date.formatDate,
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
                  label: 'Time',
                  value: task.date.formatTime,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar and counts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Volunteers: $joined / $needed',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: progress >= 1.0 ? AppColors.success : AppColors.neutral700,
                  ),
                ),
                if (progress >= 1.0)
                  const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Task filled',
                        style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  )
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.neutral200,
                valueColor: AlwaysStoppedAnimation(
                  progress >= 1.0 ? AppColors.success : AppColors.tertiary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusChip(status: task.status),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: typeColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    task.type.toUpperCase(),
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
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
            fontSize: 10,
            color: AppColors.neutral500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
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
