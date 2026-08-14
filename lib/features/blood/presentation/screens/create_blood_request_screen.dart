import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:community_care_hub/features/blood/presentation/providers/blood_provider.dart';
import 'package:community_care_hub/features/blood/presentation/widgets/blood_group_selector.dart';
import 'package:community_care_hub/core/widgets/app_button.dart';
import 'package:community_care_hub/core/widgets/app_text_field.dart';
import 'package:community_care_hub/core/utils/validators.dart';
import 'package:community_care_hub/core/extensions/context_extension.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';

class CreateBloodRequestScreen extends ConsumerStatefulWidget {
  const CreateBloodRequestScreen({super.key});

  @override
  ConsumerState<CreateBloodRequestScreen> createState() => _CreateBloodRequestScreenState();
}

class _CreateBloodRequestScreenState extends ConsumerState<CreateBloodRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _hospitalNameController = TextEditingController();
  final _hospitalAddressController = TextEditingController();
  final _unitsController = TextEditingController(text: '1');

  String? _selectedBloodGroup;
  bool _isEmergency = false;
  double? _latitude;
  double? _longitude;
  bool _isLocating = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _patientNameController.dispose();
    _hospitalNameController.dispose();
    _hospitalAddressController.dispose();
    _unitsController.dispose();
    super.dispose();
  }

  Future<void> _getHospitalLocation() async {
    setState(() {
      _isLocating = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permission denied';
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _hospitalAddressController.text = 'Hospital Locked: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}';
      });

      if (mounted) {
        context.showSuccessSnackBar('Hospital GPS location locked!');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Location Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBloodGroup == null) {
      context.showErrorSnackBar('Please select the required blood group.');
      return;
    }

    if (_latitude == null || _longitude == null) {
      context.showErrorSnackBar('Please lock the hospital GPS location.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final units = int.tryParse(_unitsController.text) ?? 1;

      await ref.read(createBloodRequestUseCaseProvider).call(
            patientName: _patientNameController.text.trim(),
            bloodGroup: _selectedBloodGroup!,
            unitsNeeded: units,
            hospitalName: _hospitalNameController.text.trim(),
            hospitalAddress: _hospitalAddressController.text.trim(),
            latitude: _latitude!,
            longitude: _longitude!,
            isEmergency: _isEmergency,
          );

      if (!mounted) return;
      context.showSuccessSnackBar('Blood request broadcasted! Compatible donors notified.');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Blood Support', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Post Emergency Request',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Broadcast request to compatible blood donors within 25 km of hospital.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: 24),

                // Patient Name
                AppTextField(
                  controller: _patientNameController,
                  label: 'Patient Name',
                  hint: 'e.g. Rahul Sharma',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: Validators.validateName,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),

                // Blood group selector grid
                const Text(
                  'Required Blood Group',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                BloodGroupSelector(
                  selectedGroup: _selectedBloodGroup,
                  onSelected: (group) {
                    setState(() {
                      _selectedBloodGroup = group;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Units needed
                AppTextField(
                  controller: _unitsController,
                  label: 'Units Required',
                  hint: 'e.g. 1, 2, 5',
                  prefixIcon: Icons.water_drop_outlined,
                  keyboardType: TextInputType.number,
                  validator: (val) => Validators.validateRequired(val, 'Units Required'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),

                // Hospital Name
                AppTextField(
                  controller: _hospitalNameController,
                  label: 'Hospital Name',
                  hint: 'e.g. City General Hospital',
                  prefixIcon: Icons.local_hospital_outlined,
                  validator: (val) => Validators.validateRequired(val, 'Hospital Name'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),

                // Hospital Location Address
                AppTextField(
                  controller: _hospitalAddressController,
                  label: 'Hospital Address',
                  hint: 'Address details / landmarks',
                  prefixIcon: Icons.location_on_outlined,
                  validator: (val) => Validators.validateRequired(val, 'Hospital Address'),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: _isLocating ? 'Locking GPS...' : 'Lock Hospital GPS Location',
                  onPressed: _isLocating ? null : _getHospitalLocation,
                  isLoading: _isLocating,
                  icon: Icons.my_location_rounded,
                  variant: AppButtonVariant.tonal,
                  isExpanded: true,
                ),
                const SizedBox(height: 24),

                // Emergency Flag Switch
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _isEmergency ? AppColors.emergencySurface : AppColors.neutral100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isEmergency ? AppColors.emergency.withValues(alpha: 0.3) : AppColors.neutral300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _isEmergency ? AppColors.emergency.withValues(alpha: 0.12) : AppColors.neutral200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bolt_rounded,
                          color: _isEmergency ? AppColors.emergency : AppColors.neutral600,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Critical Emergency',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.neutral900,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Mark true for immediate red notifications to compatible donors.',
                              style: TextStyle(fontSize: 12, color: AppColors.neutral600),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isEmergency,
                        onChanged: (val) {
                          setState(() {
                            _isEmergency = val;
                          });
                        },
                        activeThumbColor: AppColors.emergency,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Submit Button
                AppButton(
                  label: 'Broadcast Blood Request',
                  onPressed: _isLoading ? null : _submitRequest,
                  isLoading: _isLoading,
                  isExpanded: true,
                  variant: AppButtonVariant.filled,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
