import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:community_care_hub/features/food/presentation/providers/food_provider.dart';
import 'package:community_care_hub/features/food/presentation/widgets/food_card.dart';
import 'package:community_care_hub/core/widgets/loading_shimmer.dart';
import 'package:community_care_hub/core/widgets/empty_state.dart';
import 'package:community_care_hub/core/widgets/error_state.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/core/utils/geo_utils.dart';

class FoodHistoryScreen extends ConsumerWidget {
  const FoodHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDonationsAsync = ref.watch(userDonationsProvider);
    final acceptedTasksAsync = ref.watch(userAcceptedFoodTasksProvider);
    final userAsync = ref.watch(currentUserProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Food Rescue History', style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Donations', icon: Icon(Icons.outbox_rounded)),
              Tab(text: 'My Deliveries', icon: Icon(Icons.local_shipping_rounded)),
            ],
          ),
        ),
        body: userAsync.when(
          data: (user) {
            if (user == null) {
              return const Center(child: Text('User not signed in.'));
            }

            return TabBarView(
              children: [
                // Tab 1: User's own donations
                userDonationsAsync.when(
                  data: (donations) {
                    if (donations.isEmpty) {
                      return EmptyState(
                        icon: Icons.outbox_rounded,
                        title: 'No Donations Found',
                        subtitle: 'You have not shared any surplus food posts yet.',
                        actionLabel: 'Share Food Now',
                        onAction: () => context.pop(),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(userDonationsProvider);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: donations.length,
                        itemBuilder: (context, index) {
                          final item = donations[index];
                          double? dist;
                          if (user.hasLocation) {
                            dist = GeoUtils.calculateDistance(
                              user.latitude,
                              user.longitude,
                              item.latitude,
                              item.longitude,
                            );
                          }

                          return FoodCard(
                            donation: item,
                            distanceKm: dist,
                            onTap: () {
                              context.push('/food/${item.id}');
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
                    onRetry: () => ref.invalidate(userDonationsProvider),
                  ),
                ),

                // Tab 2: User's accepted delivery tasks
                acceptedTasksAsync.when(
                  data: (tasks) {
                    if (tasks.isEmpty) {
                      return EmptyState(
                        icon: Icons.local_shipping_rounded,
                        title: 'No Deliveries Found',
                        subtitle: 'You have not accepted any food rescue delivery tasks yet.',
                        actionLabel: 'Browse Nearby Posts',
                        onAction: () => context.pop(),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(userAcceptedFoodTasksProvider);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final item = tasks[index];
                          double? dist;
                          if (user.hasLocation) {
                            dist = GeoUtils.calculateDistance(
                              user.latitude,
                              user.longitude,
                              item.latitude,
                              item.longitude,
                            );
                          }

                          return FoodCard(
                            donation: item,
                            distanceKm: dist,
                            onTap: () {
                              context.push('/food/${item.id}');
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
                    onRetry: () => ref.invalidate(userAcceptedFoodTasksProvider),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => ErrorState(message: err.toString()),
        ),
      ),
    );
  }
}
