import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:community_care_hub/features/blood/presentation/providers/blood_provider.dart';
import 'package:community_care_hub/features/blood/presentation/widgets/blood_request_card.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/core/widgets/loading_shimmer.dart';
import 'package:community_care_hub/core/widgets/empty_state.dart';
import 'package:community_care_hub/core/widgets/error_state.dart';
import 'package:community_care_hub/core/utils/geo_utils.dart';

class BloodHistoryScreen extends ConsumerWidget {
  const BloodHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRequestsAsync = ref.watch(userBloodRequestsProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Blood Requests', style: TextStyle(fontWeight: FontWeight.bold)),
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

          return userRequestsAsync.when(
            data: (requests) {
              if (requests.isEmpty) {
                return EmptyState(
                  icon: Icons.water_drop_rounded,
                  title: 'No Broadcasts Found',
                  subtitle: 'You have not submitted any emergency blood requests yet.',
                  actionLabel: 'Broadcast Request Now',
                  onAction: () => context.pop(),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(userBloodRequestsProvider);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
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
              padding: EdgeInsets.all(16.0),
              child: LoadingShimmer.list(count: 3),
            ),
            error: (err, stack) => ErrorState(
              message: err.toString(),
              onRetry: () => ref.invalidate(userBloodRequestsProvider),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorState(message: err.toString()),
      ),
    );
  }
}
