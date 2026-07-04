import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/core/widgets/app_button.dart';
import 'package:community_care_hub/core/extensions/context_extension.dart';
import 'package:community_care_hub/navigation/app_routes.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  Future<void> _handleSelection() async {
    if (_selectedRole == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authActionsProvider).updateUserRole(_selectedRole!);
      if (!mounted) return;
      context.showSuccessSnackBar('Preferences saved successfully!');
      context.go(AppRoutes.home);
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'What brings you here?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose how you would like to contribute. You can change this later in your profile.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: 36),
              
              // Role Options
              Expanded(
                child: ListView(
                  children: [
                    _buildRoleCard(
                      role: 'donor',
                      title: 'I am a Donor',
                      subtitle: 'Share food and donate blood to help people in need nearby.',
                      icon: Icons.volunteer_activism_rounded,
                      activeColors: AppColors.foodGradient,
                    ),
                    const SizedBox(height: 20),
                    _buildRoleCard(
                      role: 'volunteer',
                      title: 'I am a Volunteer',
                      subtitle: 'Help with collection, transport, and community coordination.',
                      icon: Icons.people_rounded,
                      activeColors: AppColors.volunteerGradient,
                    ),
                    const SizedBox(height: 20),
                    _buildRoleCard(
                      role: 'both',
                      title: 'I do Both!',
                      subtitle: 'Maximize your impact! Both donate food/blood and volunteer for coordination.',
                      icon: Icons.auto_awesome_rounded,
                      activeColors: AppColors.heroGradient,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              AppButton(
                label: 'Continue',
                onPressed: _selectedRole == null || _isLoading ? null : _handleSelection,
                isLoading: _isLoading,
                isExpanded: true,
                variant: AppButtonVariant.filled,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> activeColors,
  }) {
    final isSelected = _selectedRole == role;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? activeColors.first : AppColors.neutral300,
          width: isSelected ? 2.5 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: activeColors.first.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            setState(() {
              _selectedRole = role;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(colors: activeColors)
                        : const LinearGradient(colors: [AppColors.neutral200, AppColors.neutral300]),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : AppColors.neutral600,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? activeColors.first : AppColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.neutral600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_circle_rounded,
                    color: activeColors.first,
                    size: 24,
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
