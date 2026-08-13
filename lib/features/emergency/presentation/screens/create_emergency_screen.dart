import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:community_care_hub/features/emergency/presentation/providers/emergency_provider.dart';
import 'package:community_care_hub/core/widgets/app_button.dart';
import 'package:community_care_hub/core/widgets/app_text_field.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';
import 'package:community_care_hub/core/utils/validators.dart';
import 'package:community_care_hub/core/utils/geo_utils.dart';
import 'package:community_care_hub/core/extensions/context_extension.dart';

class CreateEmergencyScreen extends ConsumerStatefulWidget {
  const CreateEmergencyScreen({super.key});

  @override
  ConsumerState<CreateEmergencyScreen> createState() => _CreateEmergencyScreenState();
}

class _CreateEmergencyScreenState extends ConsumerState<CreateEmergencyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedLevel = 'warning';
  String _selectedType = 'medical';
  bool _isLoading = false;
  double? _latitude;
  double? _longitude;

  static const _emergencyLevels = [
    {'value': 'critical', 'label': 'Critical', 'icon': Icons.error_rounded, 'color': AppColors.emergency},
    {'value': 'warning', 'label': 'Warning', 'icon': Icons.warning_rounded, 'color': AppColors.warning},
    {'value': 'info', 'label': 'Info', 'icon': Icons.info_rounded, 'color': AppColors.info},
  ];

  static const _emergencyTypes = [
    {'value': 'medical', 'label': 'Medical', 'icon': Icons.local_hospital_rounded},
    {'value': 'fire', 'label': 'Fire', 'icon': Icons.local_fire_department_rounded},
    {'value': 'flood', 'label': 'Flood', 'icon': Icons.water_rounded},
    {'value': 'accident', 'label': 'Accident', 'icon': Icons.car_crash_rounded},
    {'value': 'natural_disaster', 'label': 'Natural Disaster', 'icon': Icons.cyclone_rounded},
    {'value': 'other', 'label': 'Other', 'icon': Icons.more_horiz_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      final position = await GeoUtils.getCurrentPosition();
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
        // Try to get address from coordinates
        final address = await GeoUtils.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (mounted && address.isNotEmpty) {
          _addressController.text = address;
        }
      }
    } catch (_) {
      // Failed to fetch location silently
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submitEmergency() async {
    if (!_formKey.currentState!.validate()) return;

    if (_latitude == null || _longitude == null) {
      context.showErrorSnackBar('Location is required. Please enable location services.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final title = '${_selectedType[0].toUpperCase()}${_selectedType.substring(1)} Emergency: ${_titleController.text.trim()}';
      
      await ref.read(emergencyActionsProvider).createEmergencyAlert(
        title: title,
        description: _descriptionController.text.trim(),
        level: _selectedLevel,
        address: _addressController.text.trim(),
        latitude: _latitude!,
        longitude: _longitude!,
        contactPhone: _phoneController.text.trim(),
      );

      if (!mounted) return;

      // Haptic feedback for emergency
      await HapticFeedback.heavyImpact();
      if (!mounted) return;

      context.showSuccessSnackBar('Emergency alert created successfully!');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar('Failed to create emergency: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Emergency', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.emergencySurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.emergency.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.emergency, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Only report genuine emergencies. False alerts may result in account suspension.',
                        style: TextStyle(
                          color: AppColors.emergency,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Emergency Type Selection
              Text(
                'Emergency Type',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _emergencyTypes.map((type) {
                  final isSelected = _selectedType == type['value'];
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          type['icon'] as IconData,
                          size: 18,
                          color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(type['label'] as String),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.emergency,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedType = type['value'] as String);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Severity Level
              Text(
                'Severity Level',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                children: _emergencyLevels.map((level) {
                  final isSelected = _selectedLevel == level['value'];
                  final color = level['color'] as Color;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => _selectedLevel = level['value'] as String),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? color : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(level['icon'] as IconData, color: color, size: 28),
                              const SizedBox(height: 6),
                              Text(
                                level['label'] as String,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? color : AppColors.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Title
              AppTextField(
                controller: _titleController,
                label: 'Brief Title',
                hint: 'e.g., Building fire on Main Street',
                prefixIcon: Icons.title_rounded,
                validator: Validators.required,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Description
              AppTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Describe the emergency situation in detail...',
                prefixIcon: Icons.description_rounded,
                maxLines: 4,
                validator: Validators.required,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Contact Phone
              AppTextField(
                controller: _phoneController,
                label: 'Emergency Contact Phone',
                hint: '+91 XXXXX XXXXX',
                prefixIcon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Address
              AppTextField(
                controller: _addressController,
                label: 'Location / Address',
                hint: 'Enter the emergency location...',
                prefixIcon: Icons.location_on_rounded,
                validator: Validators.required,
                maxLines: 2,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 8),

              // Location status
              if (_latitude != null && _longitude != null)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Row(
                    children: [
                      Icon(Icons.gps_fixed_rounded, size: 14, color: AppColors.success),
                      SizedBox(width: 6),
                      Text(
                        'GPS location captured',
                        style: TextStyle(fontSize: 12, color: AppColors.success),
                      ),
                    ],
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Row(
                    children: [
                      Icon(Icons.gps_off_rounded, size: 14, color: AppColors.warning),
                      SizedBox(width: 6),
                      Text(
                        'Fetching GPS location...',
                        style: TextStyle(fontSize: 12, color: AppColors.warning),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),

              // Submit Button
              AppButton(
                label: _isLoading ? 'Sending Alert...' : 'Send Emergency Alert',
                onPressed: _isLoading ? null : _submitEmergency,
                isLoading: _isLoading,
                icon: Icons.emergency_share_rounded,
                color: AppColors.emergency,
                isExpanded: true,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
