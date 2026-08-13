import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_care_hub/features/food/data/datasources/food_remote_datasource.dart';
import 'package:community_care_hub/features/food/data/repositories/food_repository_impl.dart';
import 'package:community_care_hub/features/food/domain/entities/food_donation_entity.dart';
import 'package:community_care_hub/features/food/domain/repositories/food_repository.dart';
import 'package:community_care_hub/features/food/domain/usecases/create_food_donation.dart';
import 'package:community_care_hub/features/food/domain/usecases/get_nearby_food.dart';
import 'package:community_care_hub/features/food/domain/usecases/accept_food_donation.dart';
import 'package:community_care_hub/features/food/domain/usecases/update_food_status.dart';
import 'package:community_care_hub/features/food/domain/usecases/expire_old_food.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';

// Remote DataSource Provider
final foodRemoteDataSourceProvider = Provider<FoodRemoteDataSource>((ref) {
  return FoodRemoteDataSource();
});

// Repository Provider
final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  return FoodRepositoryImpl(ref.watch(foodRemoteDataSourceProvider));
});

// Use Case Providers
final createFoodDonationUseCaseProvider = Provider<CreateFoodDonation>((ref) {
  return CreateFoodDonation(ref.watch(foodRepositoryProvider));
});

final getNearbyFoodUseCaseProvider = Provider<GetNearbyFood>((ref) {
  return GetNearbyFood(ref.watch(foodRepositoryProvider));
});

final acceptFoodDonationUseCaseProvider = Provider<AcceptFoodDonation>((ref) {
  return AcceptFoodDonation(ref.watch(foodRepositoryProvider));
});

final updateFoodStatusUseCaseProvider = Provider<UpdateFoodStatus>((ref) {
  return UpdateFoodStatus(ref.watch(foodRepositoryProvider));
});

final expireOldFoodUseCaseProvider = Provider<ExpireOldFood>((ref) {
  return ExpireOldFood();
});

// Radius filter provider (5km by default)
final foodSearchRadiusProvider = StateProvider<double>((ref) => 5.0);

// Selected category filter provider
final foodCategoryFilterProvider = StateProvider<String?>((ref) => null);

// Nearby Food Donations Provider
final nearbyFoodDonationsProvider = StreamProvider.autoDispose<List<FoodDonationEntity>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final radius = ref.watch(foodSearchRadiusProvider);
  final categoryFilter = ref.watch(foodCategoryFilterProvider);

  final user = userAsync.value;
  if (user == null || !user.hasLocation) {
    return Stream.value([]);
  }

  return ref.watch(getNearbyFoodUseCaseProvider).call(
        latitude: user.latitude,
        longitude: user.longitude,
        radiusKm: radius,
      ).map((list) {
        if (categoryFilter != null) {
          return list.where((item) => item.category == categoryFilter).toList();
        }
        return list;
      });
});

// User's own donations provider
final userDonationsProvider = StreamProvider.autoDispose<List<FoodDonationEntity>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;
  if (user == null) return Stream.value([]);
  
  return ref.watch(foodRepositoryProvider).getUserDonations(user.uid);
});

// User's accepted delivery tasks provider
final userAcceptedFoodTasksProvider = StreamProvider.autoDispose<List<FoodDonationEntity>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;
  if (user == null) return Stream.value([]);
  
  return ref.watch(foodRepositoryProvider).getAcceptedTasks(user.uid);
});
