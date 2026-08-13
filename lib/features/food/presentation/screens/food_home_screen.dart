import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:community_care_hub/features/food/presentation/providers/food_provider.dart';
import 'package:community_care_hub/features/food/presentation/widgets/food_card.dart';
import 'package:community_care_hub/core/widgets/loading_shimmer.dart';
import 'package:community_care_hub/core/widgets/empty_state.dart';
import 'package:community_care_hub/core/widgets/error_state.dart';
import 'package:community_care_hub/navigation/app_routes.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/core/utils/geo_utils.dart';

class FoodHomeScreen extends ConsumerWidget {
  const FoodHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Food Rescue', style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.go(AppRoutes.home),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.history_rounded),
              onPressed: () => context.push(AppRoutes.foodHistory),
              tooltip: 'Completed History',
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.secondary,
            labelColor: AppColors.secondaryDark,
            unselectedLabelColor: AppColors.neutral500,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
            tabs: [
              Tab(icon: Icon(Icons.explore_rounded, size: 20), text: 'Discover'),
              Tab(icon: Icon(Icons.volunteer_activism_rounded, size: 20), text: 'My Donations'),
              Tab(icon: Icon(Icons.delivery_dining_rounded, size: 20), text: 'My Deliveries'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _DiscoverTab(),
            _MyDonationsTab(),
            _MyDeliveriesTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push(AppRoutes.createFood),
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Share Food', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab 1: Discover — Nearby available food
// ─────────────────────────────────────────────
class _DiscoverTab extends ConsumerWidget {
  const _DiscoverTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyDonationsAsync = ref.watch(nearbyFoodDonationsProvider);
    final userAsync = ref.watch(currentUserProvider);
    final selectedCategory = ref.watch(foodCategoryFilterProvider);
    final searchRadius = ref.watch(foodSearchRadiusProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter section header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rescues Nearby',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral900,
                ),
              ),
              // Radius dropdown selector
              DropdownButton<double>(
                value: searchRadius,
                underline: const SizedBox(),
                icon: const Icon(Icons.tune_rounded, color: AppColors.secondary, size: 18),
                items: const [
                  DropdownMenuItem(value: 2.0, child: Text(' Within 2 km')),
                  DropdownMenuItem(value: 5.0, child: Text(' Within 5 km')),
                  DropdownMenuItem(value: 10.0, child: Text(' Within 10 km')),
                  DropdownMenuItem(value: 25.0, child: Text(' Within 25 km')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    ref.read(foodSearchRadiusProvider.notifier).state = val;
                  }
                },
              ),
            ],
          ),
        ),

        // Horizontal category chips list
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            children: [
              _buildCategoryFilterChip(ref, null, 'All Rescues'),
              _buildCategoryFilterChip(ref, 'cooked', '🍱 Cooked'),
              _buildCategoryFilterChip(ref, 'raw', '🌾 Raw / Grains'),
              _buildCategoryFilterChip(ref, 'packaged', '📦 Packaged'),
              _buildCategoryFilterChip(ref, 'fruits', '🍎 Fruits'),
              _buildCategoryFilterChip(ref, 'other', '🍽️ Other'),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Listings List
        Expanded(
          child: nearbyDonationsAsync.when(
            data: (donations) {
              if (donations.isEmpty) {
                return EmptyState(
                  icon: Icons.restaurant_rounded,
                  title: 'No Surplus Food Found',
                  subtitle: selectedCategory == null
                      ? 'There are no active food rescue posts within $searchRadius km of your locked location.'
                      : 'No food items matching category "$selectedCategory" found within $searchRadius km.',
                  actionLabel: 'Share Surplus Food',
                  onAction: () => context.push(AppRoutes.createFood),
                );
              }

              final user = userAsync.value;

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(nearbyFoodDonationsProvider);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: donations.length,
                  itemBuilder: (context, index) {
                    final item = donations[index];
                    double? dist;
                    if (user != null && user.hasLocation) {
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
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: LoadingShimmer.list(count: 3),
            ),
            error: (err, stack) => ErrorState(
              message: err.toString(),
              onRetry: () => ref.invalidate(nearbyFoodDonationsProvider),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilterChip(WidgetRef ref, String? value, String label) {
    final selectedValue = ref.watch(foodCategoryFilterProvider);
    final isSelected = selectedValue == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            ref.read(foodCategoryFilterProvider.notifier).state = value;
          }
        },
        selectedColor: AppColors.secondarySurface,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.secondaryDark : AppColors.neutral800,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab 2: My Donations — Things I created
// ─────────────────────────────────────────────
class _MyDonationsTab extends ConsumerWidget {
  const _MyDonationsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDonationsAsync = ref.watch(userDonationsProvider);
    final userAsync = ref.watch(currentUserProvider);

    return userDonationsAsync.when(
      data: (donations) {
        if (donations.isEmpty) {
          return EmptyState(
            icon: Icons.volunteer_activism_rounded,
            title: 'No Donations Yet',
            subtitle: 'Food you share will appear here with real-time status tracking.',
            actionLabel: 'Share Surplus Food',
            onAction: () => context.push(AppRoutes.createFood),
          );
        }

        final user = userAsync.value;

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
              if (user != null && user.hasLocation) {
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
        padding: EdgeInsets.all(16),
        child: LoadingShimmer.list(count: 3),
      ),
      error: (err, stack) => ErrorState(
        message: err.toString(),
        onRetry: () => ref.invalidate(userDonationsProvider),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab 3: My Deliveries — Things I accepted
// ─────────────────────────────────────────────
class _MyDeliveriesTab extends ConsumerWidget {
  const _MyDeliveriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acceptedTasksAsync = ref.watch(userAcceptedFoodTasksProvider);
    final userAsync = ref.watch(currentUserProvider);

    return acceptedTasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return const EmptyState(
            icon: Icons.delivery_dining_rounded,
            title: 'No Active Deliveries',
            subtitle: 'When you accept a food rescue task, it will appear here with live status updates.',
          );
        }

        final user = userAsync.value;

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
              if (user != null && user.hasLocation) {
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
        padding: EdgeInsets.all(16),
        child: LoadingShimmer.list(count: 3),
      ),
      error: (err, stack) => ErrorState(
        message: err.toString(),
        onRetry: () => ref.invalidate(userAcceptedFoodTasksProvider),
      ),
    );
  }
}
