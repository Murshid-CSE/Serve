import 'package:flutter/material.dart';
import 'package:community_care_hub/core/widgets/app_card.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';

class StatsBanner extends StatelessWidget {
  final int foodSaved;
  final int bloodDonated;
  final int tasksCompleted;

  const StatsBanner({
    super.key,
    required this.foodSaved,
    required this.bloodDonated,
    required this.tasksCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevation: 2,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context: context,
            icon: Icons.restaurant_rounded,
            color: AppColors.foodModule,
            value: foodSaved.toString(),
            label: 'Food Shared',
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.neutral300,
          ),
          _buildStatItem(
            context: context,
            icon: Icons.bloodtype_rounded,
            color: AppColors.bloodModule,
            value: bloodDonated.toString(),
            label: 'Blood Donated',
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.neutral300,
          ),
          _buildStatItem(
            context: context,
            icon: Icons.volunteer_activism_rounded,
            color: AppColors.volunteerModule,
            value: tasksCompleted.toString(),
            label: 'Tasks Done',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.neutral600,
          ),
        ),
      ],
    );
  }
}
