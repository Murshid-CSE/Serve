import 'package:flutter/material.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';

class BloodGroupSelector extends StatelessWidget {
  final String? selectedGroup;
  final ValueChanged<String> onSelected;

  const BloodGroupSelector({
    super.key,
    required this.selectedGroup,
    required this.onSelected,
  });

  static const List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-',
    'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.3,
      ),
      itemCount: bloodGroups.length,
      itemBuilder: (context, index) {
        final group = bloodGroups[index];
        final isSelected = selectedGroup == group;

        return ChoiceChip(
          label: Container(
            alignment: Alignment.center,
            child: Text(
              group,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.neutral800,
              ),
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              onSelected(group);
            }
          },
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.neutral100,
          showCheckmark: false,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}
