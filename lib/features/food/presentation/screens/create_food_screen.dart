import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:community_care_hub/features/food/presentation/providers/food_provider.dart';
import 'package:community_care_hub/core/widgets/app_button.dart';
import 'package:community_care_hub/core/widgets/app_text_field.dart';
import 'package:community_care_hub/core/utils/validators.dart';
import 'package:community_care_hub/core/utils/image_utils.dart';
import 'package:community_care_hub/core/extensions/context_extension.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';

class CreateFoodScreen extends ConsumerStatefulWidget {
  const CreateFoodScreen({super.key});

  @override
  ConsumerState<CreateFoodScreen> createState() => _CreateFoodScreenState();
}

class _CreateFoodScreenState extends ConsumerState<CreateFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();

  String _category = 'cooked';
  int _expiryHours = 4;
  File? _imageFile;
  double? _latitude;
  double? _longitude;
  bool _isLocating = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _quantityController.dispose();
    _descController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
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

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied. Please enable them in settings.';
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _addressController.text = 'GPS Coordinates: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}';
      });

      if (mounted) {
        context.showSuccessSnackBar('GPS location locked successfully!');
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

  Future<void> _pickImage() async {
    try {
      final file = await ImageUtils.showImagePicker(context);
      if (file != null) {
        setState(() {
          _imageFile = file;
        });
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(e.toString());
      }
    }
  }

  Future<void> _submitDonation() async {
    if (!_formKey.currentState!.validate()) return;

    if (_latitude == null || _longitude == null) {
      context.showErrorSnackBar('Please lock your current GPS location first.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(createFoodDonationUseCaseProvider).call(
            title: _titleController.text.trim(),
            description: _descController.text.trim(),
            category: _category,
            quantity: _quantityController.text.trim(),
            pickupAddress: _addressController.text.trim(),
            latitude: _latitude!,
            longitude: _longitude!,
            expiryHours: _expiryHours,
            imagePath: _imageFile?.path,
          );

      if (!mounted) return;
      context.showSuccessSnackBar('Food donation posted successfully! Nearby volunteers notified.');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar(e.toString().replaceAll('AppException(firestore-error): ', ''));
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
        title: const Text('Share Surplus Food', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  'Rescue Surplus Food',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Post fresh surplus food so nearby volunteers can collect and distribute it.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                AppTextField(
                  controller: _titleController,
                  label: 'Food Item Title',
                  hint: 'e.g. Cooked Rice, Mixed Fruits, Sandwiches',
                  prefixIcon: Icons.restaurant_menu_rounded,
                  validator: Validators.validateTitle,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),

                // Category Selection
                const Text(
                  'Category',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: [
                    _buildCategoryChip('cooked', '🍱 Cooked'),
                    _buildCategoryChip('raw', '🌾 Raw / Grains'),
                    _buildCategoryChip('packaged', '📦 Packaged'),
                    _buildCategoryChip('fruits', '🍎 Fruits'),
                    _buildCategoryChip('other', '🍽️ Other'),
                  ],
                ),
                const SizedBox(height: 20),

                // Quantity
                AppTextField(
                  controller: _quantityController,
                  label: 'Quantity / Servings',
                  hint: 'e.g. For 10 people, 5 kg, 2 packets',
                  prefixIcon: Icons.scale_rounded,
                  validator: Validators.validateQuantity,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),

                // Description
                AppTextField(
                  controller: _descController,
                  label: 'Details / Handling Rules',
                  hint: 'e.g. Cooked today at 2 PM, keep refrigerated. Veg only.',
                  prefixIcon: Icons.info_outline_rounded,
                  maxLines: 3,
                  validator: Validators.validateDescription,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),

                // Expiry duration selection
                const Text(
                  'Freshness Duration (Expires In)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildExpiryButton(2, '2 Hours'),
                    _buildExpiryButton(4, '4 Hours'),
                    _buildExpiryButton(6, '6 Hours'),
                    _buildExpiryButton(12, '12 Hours'),
                  ],
                ),
                const SizedBox(height: 24),

                // Image Picker Container
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.neutral300, width: 1),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_rounded, size: 40, color: AppColors.neutral500),
                              SizedBox(height: 8),
                              Text('Add Food Image', style: TextStyle(color: AppColors.neutral600)),
                              SizedBox(height: 4),
                              Text('Compressed below 200KB automatically', style: TextStyle(fontSize: 11, color: AppColors.neutral500)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Location Picker Row
                const Text(
                  'Pickup Location',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _addressController,
                  label: 'Pickup Address',
                  hint: 'Lock GPS coordinates or enter address details',
                  prefixIcon: Icons.location_on_outlined,
                  validator: (val) => Validators.validateRequired(val, 'Pickup Address'),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: _isLocating ? 'Locking GPS...' : 'Lock Current GPS Location',
                  onPressed: _isLocating ? null : _getCurrentLocation,
                  isLoading: _isLocating,
                  icon: Icons.my_location_rounded,
                  variant: AppButtonVariant.tonal,
                  isExpanded: true,
                ),

                const SizedBox(height: 36),

                // Submit Button
                AppButton(
                  label: 'Rescue Food Now',
                  onPressed: _isLoading ? null : _submitDonation,
                  isLoading: _isLoading,
                  isExpanded: true,
                  variant: AppButtonVariant.filled,
                  color: AppColors.secondary,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String value, String label) {
    final isSelected = _category == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _category = value;
          });
        }
      },
      selectedColor: AppColors.secondarySurface,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.secondaryDark : AppColors.neutral800,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildExpiryButton(int hours, String label) {
    final isSelected = _expiryHours == hours;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _expiryHours = hours;
          });
        }
      },
      selectedColor: AppColors.secondarySurface,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.secondaryDark : AppColors.neutral800,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
