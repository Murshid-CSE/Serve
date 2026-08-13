import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_care_hub/features/blood/data/datasources/blood_remote_datasource.dart';
import 'package:community_care_hub/features/blood/data/repositories/blood_repository_impl.dart';
import 'package:community_care_hub/features/blood/domain/entities/blood_request_entity.dart';
import 'package:community_care_hub/features/blood/domain/entities/blood_donor_entity.dart';
import 'package:community_care_hub/features/blood/domain/repositories/blood_repository.dart';
import 'package:community_care_hub/features/blood/domain/usecases/register_blood_donor.dart';
import 'package:community_care_hub/features/blood/domain/usecases/create_blood_request.dart';
import 'package:community_care_hub/features/blood/domain/usecases/get_nearby_donors.dart';
import 'package:community_care_hub/features/blood/domain/usecases/respond_to_request.dart';
import 'package:community_care_hub/features/blood/domain/usecases/toggle_availability.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';

// Remote DataSource Provider
final bloodRemoteDataSourceProvider = Provider<BloodRemoteDataSource>((ref) {
  return BloodRemoteDataSource();
});

// Repository Provider
final bloodRepositoryProvider = Provider<BloodRepository>((ref) {
  return BloodRepositoryImpl(ref.watch(bloodRemoteDataSourceProvider));
});

// Use Case Providers
final registerBloodDonorUseCaseProvider = Provider<RegisterBloodDonor>((ref) {
  return RegisterBloodDonor(ref.watch(bloodRepositoryProvider));
});

final createBloodRequestUseCaseProvider = Provider<CreateBloodRequest>((ref) {
  return CreateBloodRequest(ref.watch(bloodRepositoryProvider));
});

final getNearbyDonorsUseCaseProvider = Provider<GetNearbyDonors>((ref) {
  return GetNearbyDonors(ref.watch(bloodRepositoryProvider));
});

final respondToRequestUseCaseProvider = Provider<RespondToRequest>((ref) {
  return RespondToRequest(ref.watch(bloodRepositoryProvider));
});

final toggleAvailabilityUseCaseProvider = Provider<ToggleAvailability>((ref) {
  return ToggleAvailability(ref.watch(bloodRepositoryProvider));
});

// Radius filter provider (25km by default for blood)
final bloodSearchRadiusProvider = StateProvider<double>((ref) => 25.0);

// Selected blood group filter provider
final bloodGroupQueryFilterProvider = StateProvider<String?>((ref) => null);

// Active Blood Requests Provider
final activeBloodRequestsProvider = StreamProvider.autoDispose<List<BloodRequestEntity>>((ref) {
  final stream = ref.read(bloodRepositoryProvider).getActiveRequests();
  final groupFilter = ref.watch(bloodGroupQueryFilterProvider);

  if (groupFilter != null) {
    return stream.map((list) => list.where((item) => item.bloodGroup == groupFilter).toList());
  }
  return stream;
});

// Nearby Compatible Donors Provider (for specific blood requests)
final nearbyCompatibleDonorsProvider = FutureProvider.family<List<BloodDonorEntity>, String>((ref, bloodGroup) async {
  final userAsync = ref.watch(currentUserProvider);
  final radius = ref.watch(bloodSearchRadiusProvider);

  final user = userAsync.value;
  if (user == null || !user.hasLocation) {
    return [];
  }

  return ref.read(getNearbyDonorsUseCaseProvider).call(
        bloodGroup: bloodGroup,
        latitude: user.latitude,
        longitude: user.longitude,
        radiusKm: radius,
      );
});

// User's own blood requests history
final userBloodRequestsProvider = StreamProvider.autoDispose<List<BloodRequestEntity>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;
  if (user == null) return Stream.value([]);

  return ref.watch(bloodRepositoryProvider).getUserRequests(user.uid);
});

// User's blood responses history
final userBloodResponsesProvider = StreamProvider.autoDispose<List<BloodRequestEntity>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;
  if (user == null) return Stream.value([]);

  return ref.watch(bloodRepositoryProvider).getUserResponses(user.uid);
});
