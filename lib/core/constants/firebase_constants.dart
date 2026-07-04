class FirebaseConstants {
  FirebaseConstants._();

  // ── COLLECTION NAMES ─────────────────────────────────────────────────
  static const String usersCollection = 'users';
  static const String foodDonationsCollection = 'food_donations';
  static const String bloodRequestsCollection = 'blood_requests';
  static const String volunteerTasksCollection = 'volunteer_tasks';
  static const String emergencyRequestsCollection = 'emergency_requests';
  static const String notificationsCollection = 'notifications';
  static const String reportsCollection = 'reports';
  static const String badgesCollection = 'badges';
  static const String leaderboardCollection = 'leaderboard';
  static const String feedbackCollection = 'feedback';

  // ── SUB-COLLECTION NAMES ─────────────────────────────────────────────
  static const String donorsSubCollection = 'donors';
  static const String volunteersSubCollection = 'volunteers';
  static const String claimsSubCollection = 'claims';
  static const String responsesSubCollection = 'responses';

  // ── STORAGE PATHS ────────────────────────────────────────────────────
  static const String profileImagesPath = 'profile_images';
  static const String foodImagesPath = 'food_images';
  static const String emergencyImagesPath = 'emergency_images';
  static const String taskImagesPath = 'task_images';

  // ── USER FIELDS ──────────────────────────────────────────────────────
  static const String fieldUid = 'uid';
  static const String fieldEmail = 'email';
  static const String fieldDisplayName = 'displayName';
  static const String fieldPhotoUrl = 'photoUrl';
  static const String fieldPhone = 'phone';
  static const String fieldBloodGroup = 'bloodGroup';
  static const String fieldRole = 'role';
  static const String fieldImpactScore = 'impactScore';
  static const String fieldReliabilityScore = 'reliabilityScore';
  static const String fieldIsActive = 'isActive';
  static const String fieldIsSuspended = 'isSuspended';
  static const String fieldFcmToken = 'fcmToken';
  static const String fieldLastActive = 'lastActive';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldUpdatedAt = 'updatedAt';

  // ── FOOD DONATION FIELDS ─────────────────────────────────────────────
  static const String fieldTitle = 'title';
  static const String fieldDescription = 'description';
  static const String fieldCategory = 'category';
  static const String fieldQuantity = 'quantity';
  static const String fieldServings = 'servings';
  static const String fieldImageUrls = 'imageUrls';
  static const String fieldPickupAddress = 'pickupAddress';
  static const String fieldPickupInstructions = 'pickupInstructions';
  static const String fieldExpiryTime = 'expiryTime';
  static const String fieldDonorId = 'donorId';
  static const String fieldDonorName = 'donorName';
  static const String fieldClaimedBy = 'claimedBy';
  static const String fieldClaimedAt = 'claimedAt';
  static const String fieldStatus = 'status';

  // ── BLOOD REQUEST FIELDS ─────────────────────────────────────────────
  static const String fieldPatientName = 'patientName';
  static const String fieldHospitalName = 'hospitalName';
  static const String fieldHospitalAddress = 'hospitalAddress';
  static const String fieldBloodGroupRequired = 'bloodGroupRequired';
  static const String fieldUnitsRequired = 'unitsRequired';
  static const String fieldUnitsFulfilled = 'unitsFulfilled';
  static const String fieldUrgencyLevel = 'urgencyLevel';
  static const String fieldRequiredBy = 'requiredBy';
  static const String fieldRequesterId = 'requesterId';
  static const String fieldRequesterName = 'requesterName';
  static const String fieldRespondents = 'respondents';

  // ── VOLUNTEER TASK FIELDS ────────────────────────────────────────────
  static const String fieldTaskType = 'taskType';
  static const String fieldTaskDate = 'taskDate';
  static const String fieldDuration = 'duration';
  static const String fieldVolunteersNeeded = 'volunteersNeeded';
  static const String fieldVolunteerIds = 'volunteerIds';
  static const String fieldCreatorId = 'creatorId';
  static const String fieldCreatorName = 'creatorName';

  // ── EMERGENCY FIELDS ─────────────────────────────────────────────────
  static const String fieldEmergencyType = 'emergencyType';
  static const String fieldResolvedAt = 'resolvedAt';
  static const String fieldResolvedBy = 'resolvedBy';

  // ── COMMON GEO FIELDS ───────────────────────────────────────────────
  static const String fieldLocation = 'location';
  static const String fieldGeoPoint = 'geoPoint';
  static const String fieldGeohash = 'geohash';
  static const String fieldLatitude = 'latitude';
  static const String fieldLongitude = 'longitude';
  static const String fieldAddress = 'address';
  static const String fieldContactNumber = 'contactNumber';
  static const String fieldNotes = 'notes';

  // ── NOTIFICATION FIELDS ──────────────────────────────────────────────
  static const String fieldNotificationType = 'type';
  static const String fieldNotificationTitle = 'title';
  static const String fieldNotificationBody = 'body';
  static const String fieldNotificationData = 'data';
  static const String fieldNotificationRead = 'isRead';
  static const String fieldNotificationRecipientId = 'recipientId';

  // ── SEARCH RADII (in km) ─────────────────────────────────────────────
  static const double searchRadiusFood = 5.0;
  static const double searchRadiusBlood = 25.0;
  static const double searchRadiusVolunteer = 10.0;
  static const double searchRadiusEmergency = 15.0;

  // ── DEFAULT EXPIRY DURATIONS ─────────────────────────────────────────

  /// Default food donation expiry: 8 hours.
  static const Duration foodDefaultExpiry = Duration(hours: 8);

  /// Default blood request expiry: 72 hours.
  static const Duration bloodDefaultExpiry = Duration(hours: 72);

  /// Default emergency alert expiry: 24 hours.
  static const Duration emergencyDefaultExpiry = Duration(hours: 24);

  /// Default volunteer task expiry: 7 days.
  static const Duration volunteerTaskDefaultExpiry = Duration(days: 7);

  // ── FCM TOPIC PREFIXES ───────────────────────────────────────────────
  static const String topicFoodDonations = 'food_donations';
  static const String topicBloodRequests = 'blood_requests';
  static const String topicVolunteerTasks = 'volunteer_tasks';
  static const String topicEmergency = 'emergency';
  static const String topicBloodGroupPrefix = 'blood_group_';
  static const String topicAreaPrefix = 'area_';
  static const String topicAdminAlerts = 'admin_alerts';
  static const String foodTopicPrefix = 'food_nearby_';
  static const String bloodTopicPrefix = 'blood_';
  static const String emergencyTopicPrefix = 'emergency_nearby_';
  static const String volunteerTopicPrefix = 'volunteer_nearby_';

  // ── ROLES ────────────────────────────────────────────────────────────
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';
  static const String roleModerator = 'moderator';

  // ── LIMITS ───────────────────────────────────────────────────────────
  static const int maxFoodImages = 5;
  static const int maxEmergencyImages = 3;
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const int maxServings = 500;
  static const int maxBloodUnits = 20;
  static const int maxVolunteersPerTask = 100;
}
