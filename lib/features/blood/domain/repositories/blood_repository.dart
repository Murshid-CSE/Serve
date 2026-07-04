import 'package:community_care_hub/features/blood/domain/entities/blood_request_entity.dart';
import 'package:community_care_hub/features/blood/domain/entities/blood_donor_entity.dart';

abstract class BloodRepository {
  Future<void> registerBloodDonor({
    required String bloodGroup,
    required bool isAvailable,
  });

  Future<BloodRequestEntity> createBloodRequest({
    required String patientName,
    required String bloodGroup,
    required int unitsNeeded,
    required String hospitalName,
    required String hospitalAddress,
    required double latitude,
    required double longitude,
    required bool isEmergency,
  });

  Future<List<BloodDonorEntity>> getNearbyDonors({
    required String bloodGroup,
    required double latitude,
    required double longitude,
    required double radiusKm,
  });

  Future<List<BloodRequestEntity>> getActiveRequests();

  Future<void> respondToRequest({
    required String requestId,
    required String userId,
  });

  Future<void> toggleAvailability({required bool isAvailable});

  Future<List<BloodRequestEntity>> getUserRequests(String userId);
}
