import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:community_care_hub/features/blood/presentation/providers/blood_provider.dart';
import 'package:community_care_hub/features/blood/presentation/widgets/donor_card.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/core/widgets/app_button.dart';
import 'package:community_care_hub/core/widgets/loading_shimmer.dart';
import 'package:community_care_hub/core/widgets/error_state.dart';
import 'package:community_care_hub/core/extensions/context_extension.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';
import 'package:community_care_hub/core/utils/geo_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodRequestDetailScreen extends ConsumerStatefulWidget {
  final String requestId;

  const BloodRequestDetailScreen({
    super.key,
    required this.requestId,
  });

  @override
  ConsumerState<BloodRequestDetailScreen> createState() => _BloodRequestDetailScreenState();
}

class _BloodRequestDetailScreenState extends ConsumerState<BloodRequestDetailScreen> {
  bool _isActionLoading = false;

  Future<void> _handleRespond(String userId) async {
    final confirmed = await context.showConfirmDialog(
      title: 'Respond to Request',
      message: 'Are you sure you want to respond to this request? This will share your phone contact details with the requester so they can reach you.',
    );

    if (confirmed != true) return;

    setState(() {
      _isActionLoading = true;
    });

    try {
      await ref.read(respondToRequestUseCaseProvider).call(
            requestId: widget.requestId,
            userId: userId,
          );

      if (!mounted) return;
      context.showSuccessSnackBar('Thank you for responding! Requester has been notified.');
      ref.invalidate(activeBloodRequestsProvider);
      ref.invalidate(userBloodRequestsProvider);
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
    final activeRequestsAsync = ref.watch(activeBloodRequestsProvider);
    final userRequestsAsync = ref.watch(userBloodRequestsProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Request Details', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User session missing.'));
          }

          // Search for blood request item
          final allRequests = [
            ...?activeRequestsAsync.value,
            ...?userRequestsAsync.value,
          ];

          final requestIndex = allRequests.indexWhere((r) => r.id == widget.requestId);
          if (requestIndex == -1) {
            return const Center(child: Text('Blood request not found.'));
          }

          final request = allRequests[requestIndex];

          final isRequester = request.requesterId == user.uid;
          final alreadyResponded = request.respondedBy.contains(user.uid);

          // Get compatible donors stream
          final donorsAsync = ref.watch(nearbyCompatibleDonorsProvider(request.bloodGroup));

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Urgency / Emergency Tag Box
                  if (request.isEmergency) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.emergencySurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.emergency.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: AppColors.emergency, size: 24),
                          SizedBox(width: 10),
                          Text(
                            'CRITICAL EMERGENCY BLOOD REQUEST',
                            style: TextStyle(
                              color: AppColors.emergencyDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Patient Card Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.neutral200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              request.bloodGroup,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Patient: ${request.patientName}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.neutral900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Units Needed: ${request.unitsNeeded}',
                                style: const TextStyle(fontSize: 15, color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Hospital Details
                  const Text(
                    'Hospital Location',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_hospital_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              request.hospitalName,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_rounded, color: AppColors.neutral600, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                request.hospitalAddress,
                                style: const TextStyle(fontSize: 13, color: AppColors.neutral700, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Requester contact (only if not self, and responded, or if self)
                  if (!isRequester && alreadyResponded && request.requesterPhone.isNotEmpty) ...[
                    const Text(
                      'Requester Contact Details',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                            child: const Icon(Icons.person_rounded, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Contact Person',
                                  style: TextStyle(fontSize: 11, color: AppColors.neutral600),
                                ),
                                Text(
                                  request.requesterName,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _makeCall(request.requesterPhone),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.successSurface,
                              foregroundColor: AppColors.success,
                            ),
                            icon: const Icon(Icons.phone_in_talk_rounded),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Action Buttons (Respond / I can Donate)
                  if (!isRequester) ...[
                    if (alreadyResponded)
                      Container(
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
                              'You have responded to this request.',
                              style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    else
                      AppButton(
                        label: 'I Can Donate / Respond Now',
                        onPressed: _isActionLoading ? null : () => _handleRespond(user.uid),
                        isLoading: _isActionLoading,
                        isExpanded: true,
                        variant: AppButtonVariant.filled,
                        color: AppColors.primary,
                      ),
                    const SizedBox(height: 24),
                  ],

                  // Compatible Donors Nearby (only visible to requester in self requests)
                  if (isRequester) ...[
                    const Text(
                      'Compatible Donors Nearby',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    donorsAsync.when(
                      data: (donors) {
                        if (donors.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'No compatible active donors found within 25 km of hospital location.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.neutral600, fontSize: 13),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: donors.length,
                          itemBuilder: (context, index) {
                            final donor = donors[index];
                            double? dist;
                            if (request.latitude != 0.0) {
                              dist = GeoUtils.calculateDistance(
                                request.latitude,
                                request.longitude,
                                donor.latitude,
                                donor.longitude,
                              );
                            }

                            return DonorCard(
                              donor: donor,
                              distanceKm: dist,
                            );
                          },
                        );
                      },
                      loading: () => const LoadingShimmer.list(count: 2),
                      error: (err, stack) => Center(child: Text('Error loading donors: $err')),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingShimmer.detail(),
        error: (err, stack) => ErrorState(message: err.toString()),
      ),
    );
  }
}
