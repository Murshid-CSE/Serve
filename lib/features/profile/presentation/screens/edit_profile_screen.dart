import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/core/widgets/app_button.dart';
import 'package:community_care_hub/core/widgets/app_text_field.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';
import 'package:community_care_hub/core/constants/firebase_constants.dart';
import 'package:community_care_hub/core/utils/validators.dart';
import 'package:community_care_hub/core/utils/image_utils.dart';
import 'package:community_care_hub/core/utils/geo_utils.dart';
import 'package:community_care_hub/core/extensions/context_extension.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedBloodGroup;
  String? _photoUrl;
  String? _imagePublicId;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  bool _hasChanges = false;

  static const _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _selectedBloodGroup = user.bloodGroup;
      _photoUrl = user.photoUrl;
      _imagePublicId = user.imagePublicId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.tertiary),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512);
      if (pickedFile == null) {
        setState(() => _isUploadingImage = false);
        return;
      }

      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) return;

      final uploadResult = await ImageUtils.uploadImage(
        filePath: pickedFile.path,
        storagePath: '${FirebaseConstants.profileImagesPath}/${user.uid}.jpg',
      );

      setState(() {
        _photoUrl = uploadResult.secureUrl;
        _imagePublicId = uploadResult.publicId;
        _hasChanges = true;
        _isUploadingImage = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        context.showErrorSnackBar('Failed to upload image: $e');
      }
    }
  }

  Future<void> _updateLocation() async {
    try {
      final position = await GeoUtils.getCurrentPosition();
      final address = await GeoUtils.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        final user = ref.read(currentUserProvider).valueOrNull;
        if (user == null) return;

        await FirebaseFirestore.instance
            .collection(FirebaseConstants.usersCollection)
            .doc(user.uid)
            .update({
          'location': {
            'lat': position.latitude,
            'lng': position.longitude,
            'geohash': GeoUtils.encodeGeohash(position.latitude, position.longitude),
          },
        });

        if (!mounted) return;
        context.showSuccessSnackBar('Location updated: $address');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to update location: $e');
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) throw Exception('User not found');

      final updates = <String, dynamic>{
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_selectedBloodGroup != null) {
        updates['bloodGroup'] = _selectedBloodGroup;
      }

      if (_photoUrl != null && _photoUrl != user.photoUrl) {
        updates['photoUrl'] = _photoUrl;
        updates['imagePublicId'] = _imagePublicId;
      }

      await FirebaseFirestore.instance
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .update(updates);

      // Invalidate the user provider to refetch
      ref.invalidate(currentUserProvider);

      if (!mounted) return;
      context.showSuccessSnackBar('Profile updated successfully!');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar('Failed to update profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        onChanged: () => setState(() => _hasChanges = true),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Photo
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: AppColors.primarySurface,
                    backgroundImage: _photoUrl != null ? CachedNetworkImageProvider(_photoUrl!) : null,
                    child: _isUploadingImage
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : (_photoUrl == null
                            ? const Icon(Icons.person_rounded, size: 56, color: AppColors.primary)
                            : null),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _isUploadingImage ? null : _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Name
              AppTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                prefixIcon: Icons.person_rounded,
                validator: Validators.required,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Phone
              AppTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: '+91 XXXXX XXXXX',
                prefixIcon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),

              // Blood Group
              DropdownButtonFormField<String>(
                initialValue: _selectedBloodGroup,
                decoration: InputDecoration(
                  labelText: 'Blood Group',
                  prefixIcon: const Icon(Icons.bloodtype_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _bloodGroups.map((group) {
                  return DropdownMenuItem(
                    value: group,
                    child: Text(group),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBloodGroup = value;
                    _hasChanges = true;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Update Location
              OutlinedButton.icon(
                onPressed: _updateLocation,
                icon: const Icon(Icons.my_location_rounded),
                label: const Text('Update My Location'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              AppButton(
                label: _isLoading ? 'Saving...' : 'Save Changes',
                onPressed: (_isLoading || !_hasChanges) ? null : _saveProfile,
                isLoading: _isLoading,
                icon: Icons.check_rounded,
                isExpanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
