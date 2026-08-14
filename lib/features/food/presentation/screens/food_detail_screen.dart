import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:community_care_hub/features/food/domain/entities/food_donation_entity.dart';
import 'package:community_care_hub/features/food/presentation/providers/food_provider.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/features/food/presentation/widgets/freshness_timer_widget.dart';
import 'package:community_care_hub/features/food/presentation/widgets/food_status_stepper.dart';
import 'package:community_care_hub/core/widgets/app_button.dart';
import 'package:community_care_hub/core/widgets/loading_shimmer.dart';
import 'package:community_care_hub/core/widgets/error_state.dart';
import 'package:community_care_hub/core/extensions/context_extension.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class FoodDetailScreen extends ConsumerStatefulWidget {

  const FoodDetailScreen({
    super.key,
    required this.donationId,
  });
  final String donationId;

  @override
  ConsumerState<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends ConsumerState<FoodDetailScreen> {
  bool _isActionLoading = false;

  Future<void> _handleAcceptDonation(String userName) async {
    final confirmed = await context.showConfirmDialog(
      title: 'Accept Rescue Task',
      message: 'Are you sure you want to accept this surplus food rescue task? You will be responsible for collecting and delivering it.',
    );

    if (confirmed != true) return;

    setState(() {
      _isActionLoading = true;
    });

    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) throw 'User session missing';

      await ref.read(acceptFoodDonationUseCaseProvider).call(
            donationId: widget.donationId,
            userId: user.uid,
            userName: userName,
          );

      if (!mounted) return;
      context.showSuccessSnackBar('Rescue task accepted! Coordination flow started.');
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isActionLoading = false;
        });
      }
    }
  }

  Future<void> _updateStatus(String status, String successMsg) async {
    setState(() {
      _isActionLoading = true;
    });

    try {
      await ref.read(updateFoodStatusUseCaseProvider).call(
            donationId: widget.donationId,
            status: status,
          );

      if (!mounted) return;
      context.showSuccessSnackBar(successMsg);
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isActionLoading = false;
        });
      }
    }
  }

  Future<void> _makeCall(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        context.showErrorSnackBar('Could not launch dialer for number: $phone');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nearbyDonationsAsync = ref.watch(nearbyFoodDonationsProvider);
    final userDonationsAsync = ref.watch(userDonationsProvider);
    final acceptedTasksAsync = ref.watch(userAcceptedFoodTasksProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rescue Details', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not signed in.'));
          }

          // Search for the donation item in available streams
          final allItems = [
            ...?nearbyDonationsAsync.value,
            ...?userDonationsAsync.value,
            ...?acceptedTasksAsync.value,
          ];

          final itemIndex = allItems.indexWhere((item) => item.id == widget.donationId);
          if (itemIndex == -1) {
            return const Center(child: Text('Donation item not found.'));
          }

          final donation = allItems[itemIndex];

          final isDonor = donation.donorId == user.uid;
          final isVolunteer = donation.acceptedBy == user.uid;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Header
                donation.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: donation.imageUrl!,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 220,
                          color: AppColors.neutral200,
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, url, error) => _buildImagePlaceholder(),
                      )
                    : _buildImagePlaceholder(),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + Category
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  donation.title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.neutral900,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Quantity: ${donation.quantity}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.secondaryDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.secondarySurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              donation.category.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.secondaryDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Countdown timer (only if available)
                      if (donation.isAvailable) ...[
                        FreshnessTimerWidget(expiresAt: donation.expiresAt),
                        const SizedBox(height: 24),
                      ],

                      // Flow Stepper
                      FoodStatusStepper(currentStatus: donation.status),
                      const SizedBox(height: 24),

                      // Details Block
                      const Text(
                        'Details & Guidelines',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        donation.description,
                        style: const TextStyle(fontSize: 14, color: AppColors.neutral700, height: 1.4),
                      ),
                      const SizedBox(height: 20),

                      // Pickup address
                      const Text(
                        'Pickup Location',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_rounded, color: AppColors.secondary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              donation.pickupAddress,
                              style: const TextStyle(fontSize: 14, color: AppColors.neutral700, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Contact Card (If assigned / accepted)
                      if (donation.status != 'available' && donation.status != 'expired') ...[
                        _buildContactCard(donation, isDonor, isVolunteer),
                        const SizedBox(height: 28),
                      ],

                      // Actions Block
                      _buildActionButtons(donation, isDonor, isVolunteer, user.name),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingShimmer.detail(),
        error: (err, stack) => ErrorState(message: err.toString()),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      color: AppColors.secondarySurface,
      child: const Center(
        child: Icon(
          Icons.restaurant_rounded,
          color: AppColors.secondary,
          size: 64,
        ),
      ),
    );
  }

  Widget _buildContactCard(FoodDonationEntity donation, bool isDonor, bool isVolunteer) {
    final title = isDonor ? 'Assigned Volunteer' : 'Donor Contact';
    final name = isDonor ? (donation.acceptedByName ?? 'Volunteer') : donation.donorName;
    final phone = isDonor ? 'Phone Hidden' : donation.donorPhone;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
            child: Icon(
              isDonor ? Icons.local_shipping_rounded : Icons.person_rounded,
              color: AppColors.secondaryDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
                ),
                Text(
                  name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.neutral900),
                ),
                if (phone != 'Phone Hidden' && phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: const TextStyle(fontSize: 13, color: AppColors.neutral700),
                  ),
                ],
              ],
            ),
          ),
          if (!isDonor && donation.donorPhone.isNotEmpty)
            IconButton(
              onPressed: () => _makeCall(donation.donorPhone),
              icon: const Icon(Icons.phone_in_talk_rounded, color: AppColors.success),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(FoodDonationEntity donation, bool isDonor, bool isVolunteer, String userName) {
    if (donation.status == 'available') {
      if (isDonor) {
        return const Center(
          child: Text(
            'Waiting for a volunteer to accept this rescue task...',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.neutral600, fontStyle: FontStyle.italic),
          ),
        );
      } else {
        return AppButton(
          label: 'Accept Food Rescue Task',
          onPressed: _isActionLoading ? null : () => _handleAcceptDonation(userName),
          isLoading: _isActionLoading,
          isExpanded: true,
          variant: AppButtonVariant.filled,
          color: AppColors.secondary,
        );
      }
    }

    if (donation.status == 'accepted') {
      if (isVolunteer) {
        return AppButton(
          label: 'Mark as Collected',
          onPressed: _isActionLoading
              ? null
              : () => _updateStatus(
                    'collected',
                    'Status updated! Food collected from donor.',
                  ),
          isLoading: _isActionLoading,
          isExpanded: true,
          variant: AppButtonVariant.filled,
          color: AppColors.secondary,
        );
      } else if (isDonor) {
        return _buildDonorProgressCard(
          volunteerName: donation.acceptedByName ?? 'A volunteer',
          statusMessage: 'has accepted your rescue task',
          timestamp: donation.acceptedAt,
          steps: const [
            _ProgressStep(label: 'Accepted', isComplete: true),
            _ProgressStep(label: 'Collected', isComplete: false),
            _ProgressStep(label: 'Delivering', isComplete: false),
            _ProgressStep(label: 'Completed', isComplete: false),
          ],
        );
      }
    }

    if (donation.status == 'collected') {
      if (isVolunteer) {
        return AppButton(
          label: 'Mark as Delivered',
          onPressed: _isActionLoading
              ? null
              : () => _updateStatus(
                    'delivered',
                    'Status updated! Delivered to target location.',
                  ),
          isLoading: _isActionLoading,
          isExpanded: true,
          variant: AppButtonVariant.filled,
          color: AppColors.secondary,
        );
      } else if (isDonor) {
        return _buildDonorProgressCard(
          volunteerName: donation.acceptedByName ?? 'Volunteer',
          statusMessage: 'has collected the food and is on the way',
          timestamp: donation.collectedAt,
          steps: const [
            _ProgressStep(label: 'Accepted', isComplete: true),
            _ProgressStep(label: 'Collected', isComplete: true),
            _ProgressStep(label: 'Delivering', isComplete: false),
            _ProgressStep(label: 'Completed', isComplete: false),
          ],
        );
      }
    }

    if (donation.status == 'delivered') {
      if (isDonor) {
        return Column(
          children: [
            _buildDonorProgressCard(
              volunteerName: donation.acceptedByName ?? 'Volunteer',
              statusMessage: 'has delivered the food',
              timestamp: donation.deliveredAt,
              steps: const [
                _ProgressStep(label: 'Accepted', isComplete: true),
                _ProgressStep(label: 'Collected', isComplete: true),
                _ProgressStep(label: 'Delivered', isComplete: true),
                _ProgressStep(label: 'Completed', isComplete: false),
              ],
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Confirm Completion & Rate Reliability',
              onPressed: _isActionLoading
                  ? null
                  : () => _updateStatus(
                        'completed',
                        'Rescue coordination flow completed! Impact scores updated.',
                      ),
              isLoading: _isActionLoading,
              isExpanded: true,
              variant: AppButtonVariant.filled,
              color: AppColors.success,
            ),
          ],
        );
      } else {
        return const Center(
          child: Text(
            'Waiting for Donor to confirm completion...',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.neutral600, fontStyle: FontStyle.italic),
          ),
        );
      }
    }

    if (donation.status == 'completed') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.successSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.success),
            SizedBox(width: 8),
            Text(
              'Rescue Completed Successfully',
              style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildDonorProgressCard({
    required String volunteerName,
    required String statusMessage,
    required List<_ProgressStep> steps,
    DateTime? timestamp,
  }) {
    final timeStr = timestamp != null
        ? '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}'
        : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Volunteer info header
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.secondary,
                child: Text(
                  volunteerName.isNotEmpty ? volunteerName[0].toUpperCase() : 'V',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      volunteerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.neutral900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$statusMessage${timeStr.isNotEmpty ? ' at $timeStr' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress steps
          Row(
            children: steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isLast = index == steps.length - 1;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            step.isComplete
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: step.isComplete
                                ? AppColors.success
                                : AppColors.neutral400,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            step.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: step.isComplete
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: step.isComplete
                                  ? AppColors.neutral900
                                  : AppColors.neutral500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 12,
                        height: 2,
                        color: step.isComplete
                            ? AppColors.success
                            : AppColors.neutral300,
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ProgressStep {
  const _ProgressStep({
    required this.label,
    required this.isComplete,
  });
  final String label;
  final bool isComplete;
}
