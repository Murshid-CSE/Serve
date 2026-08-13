import 'package:flutter/material.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';

class FoodCategoryChip extends StatelessWidget {

  const FoodCategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onSelected,
  });
  final String category;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;

  String _getCategoryLabel(String cat) {
    switch (cat.toLowerCase()) {
      case 'cooked':
        return '🍱 Cooked Meals';
      case 'raw':
        return '🌾 Raw / Grains';
      case 'packaged':
        return '📦 Packaged Food';
      case 'fruits':
        return '🍎 Fruits & Veg';
      case 'other':
      default:
        return '🍽️ Other Food';
    }
  }

  Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'cooked':
        return Colors.orange;
      case 'raw':
        return Colors.brown;
      case 'packaged':
        return Colors.blue;
      case 'fruits':
        return Colors.green;
      case 'other':
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _getCategoryLabel(category);
    final color = _getCategoryColor(category);

    if (onSelected != null) {
      return ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: onSelected,
        selectedColor: color.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? color : AppColors.neutral800,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label.split(' ').sublist(1).join(' '), // Strip emoji for chip display
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
