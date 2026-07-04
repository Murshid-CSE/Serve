import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_care_hub/features/blood/presentation/providers/blood_provider.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/core/widgets/app_card.dart';
import 'package:community_care_hub/core/extensions/context_extension.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';

class AvailabilityToggle extends ConsumerStatefulWidget {
  const AvailabilityToggle({super.key});

  @override
  ConsumerState<AvailabilityToggle> createState() => _AvailabilityToggleState();
}

class _AvailabilityToggleState extends ConsumerState<AvailabilityToggle> {
  bool _isToggling = false;

  Future<void> _handleToggle(bool value) async {
    setState(() {
      _isToggling = true;
    });

    try {
      await ref.read(toggleAvailabilityUseCaseProvider).call(isAvailable: value);
      if (!mounted) return;
      context.showSuccessSnackBar(value 
        ? 'You are now marked as AVAILABLE to donate blood. Thank you!'
        : 'You are now marked as UNAVAILABLE for blood donation.');
      ref.invalidate(currentUserProvider);
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isToggling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null || user.bloodGroup == null) {
          return const SizedBox();
        }

        final isAvailable = user.isBloodDonorActive;

        return AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          elevation: 2,
          borderRadius: 16,
          borderColor: isAvailable ? AppColors.primary.withValues(alpha: 0.2) : null,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isAvailable ? AppColors.primarySurface : AppColors.neutral200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bloodtype_rounded,
                  color: isAvailable ? AppColors.primary : AppColors.neutral600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Blood Donor Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAvailable ? 'Available (Compatible Donors can find you)' : 'Unavailable / On Break',
                      style: TextStyle(
                        fontSize: 12,
                        color: isAvailable ? AppColors.success : AppColors.neutral600,
                        fontWeight: isAvailable ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              _isToggling
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.primary)),
                    )
                  : Switch(
                      value: isAvailable,
                      onChanged: _handleToggle,
                      activeThumbColor: AppColors.primary,
                    ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_, _) => const SizedBox(),
    );
  }
}
