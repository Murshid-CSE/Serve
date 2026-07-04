import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:community_care_hub/features/blood/presentation/providers/blood_provider.dart';
import 'package:community_care_hub/features/blood/presentation/widgets/blood_request_card.dart';
import 'package:community_care_hub/features/blood/presentation/widgets/availability_toggle.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/core/widgets/app_button.dart';
import 'package:community_care_hub/core/widgets/loading_shimmer.dart';
import 'package:community_care_hub/core/widgets/empty_state.dart';
import 'package:community_care_hub/core/widgets/error_state.dart';
import 'package:community_care_hub/navigation/app_routes.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';
import 'package:community_care_hub/core/utils/geo_utils.dart';

class BloodHomeScreen extends ConsumerWidget {
  const BloodHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRequestsAsync = ref.watch(activeBloodRequestsProvider);
    final userAsync = ref.watch(currentUserProvider);
    final selectedFilter = ref.watch(bloodGroupQueryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Donation Network', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => context.push(AppRoutes.bloodHistory),
            tooltip: 'Request History',
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User session missing.'));
          }

          final hasDonorProfile = user.bloodGroup != null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Donor status toggle or prompt card
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: hasDonorProfile
                    ? const AvailabilityToggle()
                    : _buildRegisterPromptCard(context),
              ),

              // 2. Active Requests Section Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Active Blood Requests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral900,
                  ),
                ),
              ),

              // 3. Filter chips horizontal list
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  children: [
                    _buildFilterChip(ref, null, 'All Requests'),
                    ...['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map((group) {
                      return _buildFilterChip(ref, group, group);
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 4. Requests List
              Expanded(
                child: activeRequestsAsync.when(
                  data: (requests) {
                    if (requests.isEmpty) {
                      return EmptyState(
                        icon: Icons.water_drop_rounded,
                        title: 'No Blood Requests Found',
                        subtitle: selectedFilter == null
                            ? 'There are no active blood requests listed right now.'
                            : 'No active requests matching blood type "$selectedFilter".',
                        actionLabel: 'Request Blood Support',
                        onAction: () => context.push(AppRoutes.createBloodRequest),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(activeBloodRequestsProvider);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final request = requests[index];
                          double? dist;
                          if (user.hasLocation) {
                            dist = GeoUtils.calculateDistance(
                              user.latitude,
                              user.longitude,
                              request.latitude,
                              request.longitude,
                            );
                          }

                          return BloodRequestCard(
                            request: request,
                            distanceKm: dist,
                            onTap: () {
                              context.push('/blood/${request.id}');
                            },
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: LoadingShimmer.list(count: 3),
                  ),
                  error: (err, stack) => ErrorState(
                    message: err.toString(),
                    onRetry: () => ref.invalidate(activeBloodRequestsProvider),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorState(message: err.toString()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createBloodRequest),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Request Blood', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildRegisterPromptCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.favorite_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Text(
                'Become a Lifesaver',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete your donor profile to make yourself discoverable for compatible blood requests near your area.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.neutral700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Register as Donor',
            onPressed: () => context.push(AppRoutes.donorRegistration),
            variant: AppButtonVariant.filled,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(WidgetRef ref, String? value, String label) {
    final selectedValue = ref.watch(bloodGroupQueryFilterProvider);
    final isSelected = selectedValue == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            ref.read(bloodGroupQueryFilterProvider.notifier).state = value;
          }
        },
        selectedColor: AppColors.primarySurface,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryDark : AppColors.neutral800,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
