import 'package:flutter/material.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';

class FoodStatusStepper extends StatelessWidget {

  const FoodStatusStepper({
    super.key,
    required this.currentStatus,
  });
  final String currentStatus;

  int _getCurrentStep() {
    switch (currentStatus) {
      case 'available':
        return 0;
      case 'accepted':
        return 1;
      case 'collected':
        return 2;
      case 'delivered':
        return 3;
      case 'completed':
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeStep = _getCurrentStep();
    final steps = [
      _StepData(label: 'Available', icon: Icons.restaurant_rounded),
      _StepData(label: 'Accepted', icon: Icons.handshake_rounded),
      _StepData(label: 'Collected', icon: Icons.local_shipping_rounded),
      _StepData(label: 'Delivered', icon: Icons.home_work_rounded),
      _StepData(label: 'Completed', icon: Icons.check_circle_rounded),
    ];

    if (currentStatus == 'expired' || currentStatus == 'cancelled') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral300),
        ),
        child: Row(
          children: [
            Icon(
              currentStatus == 'expired' ? Icons.timer_off_rounded : Icons.cancel_rounded,
              color: AppColors.neutral600,
            ),
            const SizedBox(width: 12),
            Text(
              currentStatus == 'expired' ? 'This rescue has expired.' : 'This rescue has been cancelled.',
              style: const TextStyle(
                color: AppColors.neutral800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rescue Coordination Flow',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(steps.length * 2 - 1, (index) {
            if (index.isEven) {
              final stepIndex = index ~/ 2;
              final step = steps[stepIndex];
              final isActive = stepIndex <= activeStep;
              final isCurrent = stepIndex == activeStep;

              return Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.secondary
                            : (isActive ? AppColors.secondary.withValues(alpha: 0.15) : AppColors.neutral200),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive ? AppColors.secondary : AppColors.neutral400,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        step.icon,
                        size: 20,
                        color: isCurrent
                            ? Colors.white
                            : (isActive ? AppColors.secondaryDark : AppColors.neutral600),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      step.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? AppColors.secondaryDark : AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              final stepIndex = index ~/ 2;
              final isPassed = stepIndex < activeStep;

              return Container(
                width: 24,
                height: 3,
                margin: const EdgeInsets.only(bottom: 16),
                color: isPassed ? AppColors.secondary : AppColors.neutral300,
              );
            }
          }),
        ),
      ],
    );
  }
}

class _StepData {

  _StepData({required this.label, required this.icon});
  final String label;
  final IconData icon;
}
