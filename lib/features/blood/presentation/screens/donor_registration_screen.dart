import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:community_care_hub/features/blood/presentation/providers/blood_provider.dart';
import 'package:community_care_hub/features/blood/presentation/widgets/blood_group_selector.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/core/widgets/app_button.dart';
import 'package:community_care_hub/core/extensions/context_extension.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';

class DonorRegistrationScreen extends ConsumerStatefulWidget {
  const DonorRegistrationScreen({super.key});

  @override
  ConsumerState<DonorRegistrationScreen> createState() => _DonorRegistrationScreenState();
}

class _DonorRegistrationScreenState extends ConsumerState<DonorRegistrationScreen> {
  String? _selectedGroup;
  bool _isAvailable = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate if user has already registered
    final user = ref.read(currentUserProvider).value;
    if (user != null && user.bloodGroup != null) {
      _selectedGroup = user.bloodGroup;
      _isAvailable = user.isBloodDonorActive;
    }
  }

  Future<void> _handleRegister() async {
    if (_selectedGroup == null) {
      context.showErrorSnackBar('Please select your blood group.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(registerBloodDonorUseCaseProvider).call(
            bloodGroup: _selectedGroup!,
            isAvailable: _isAvailable,
          );

      if (!mounted) return;
      context.showSuccessSnackBar('Blood donor preferences saved successfully!');
      ref.invalidate(currentUserProvider);
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
        title: const Text('Donor Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Become a Blood Donor',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Register your blood type so nearby hospitals and requesters can contact you in emergencies.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: 28),

                // Blood group selector grid
                const Text(
                  'Select Blood Group',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                BloodGroupSelector(
                  selectedGroup: _selectedGroup,
                  onSelected: (group) {
                    setState(() {
                      _selectedGroup = group;
                    });
                  },
                ),
                const SizedBox(height: 32),

                // Availability toggle card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.neutral300),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _isAvailable ? AppColors.primarySurface : AppColors.neutral200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bloodtype_rounded,
                          color: _isAvailable ? AppColors.primary : AppColors.neutral600,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Available for Emergency Requests',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.neutral900,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Toggle off to hide your profile temporary.',
                              style: TextStyle(fontSize: 12, color: AppColors.neutral600),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isAvailable,
                        onChanged: (val) {
                          setState(() {
                            _isAvailable = val;
                          });
                        },
                        activeThumbColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Save button
                AppButton(
                  label: 'Save Preferences',
                  onPressed: _isLoading ? null : _handleRegister,
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
