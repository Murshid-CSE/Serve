import 'package:cloud_firestore/cloud_firestore.dart';

class UserEntity {

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    this.imagePublicId,
    required this.role,
    this.bloodGroup,
    this.isBloodDonorActive = false,
    this.lastBloodDonationDate,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.geohash = '',
    this.impactScore = 0.0,
    this.reliabilityScore = 0.0,
    this.totalFoodDonations = 0,
    this.totalBloodDonations = 0,
    this.totalVolunteerTasks = 0,
    this.fcmToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      imagePublicId: map['imagePublicId'] as String?,
      role: map['role'] as String? ?? 'donor',
      bloodGroup: map['bloodGroup'] as String?,
      isBloodDonorActive: map['isBloodDonorActive'] as bool? ?? false,
      lastBloodDonationDate: (map['lastBloodDonationDate'] as Timestamp?)?.toDate(),
      latitude: (map['location']?['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['location']?['lng'] as num?)?.toDouble() ?? 0.0,
      geohash: map['location']?['geohash'] as String? ?? '',
      impactScore: (map['impactScore'] as num?)?.toDouble() ?? 0.0,
      reliabilityScore: (map['reliabilityScore'] as num?)?.toDouble() ?? 0.0,
      totalFoodDonations: map['totalFoodDonations'] as int? ?? 0,
      totalBloodDonations: map['totalBloodDonations'] as int? ?? 0,
      totalVolunteerTasks: map['totalVolunteerTasks'] as int? ?? 0,
      fcmToken: map['fcmToken'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final String? imagePublicId;
  final String role; // donor, volunteer, both, admin
  final String? bloodGroup;
  final bool isBloodDonorActive;
  final DateTime? lastBloodDonationDate;
  final double latitude;
  final double longitude;
  final String geohash;
  final double impactScore;
  final double reliabilityScore;
  final int totalFoodDonations;
  final int totalBloodDonations;
  final int totalVolunteerTasks;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'imagePublicId': imagePublicId,
      'role': role,
      'bloodGroup': bloodGroup,
      'isBloodDonorActive': isBloodDonorActive,
      'lastBloodDonationDate': lastBloodDonationDate != null
          ? Timestamp.fromDate(lastBloodDonationDate!)
          : null,
      'location': {
        'lat': latitude,
        'lng': longitude,
        'geohash': geohash,
      },
      'impactScore': impactScore,
      'reliabilityScore': reliabilityScore,
      'totalFoodDonations': totalFoodDonations,
      'totalBloodDonations': totalBloodDonations,
      'totalVolunteerTasks': totalVolunteerTasks,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserEntity copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? imagePublicId,
    String? role,
    String? bloodGroup,
    bool? isBloodDonorActive,
    DateTime? lastBloodDonationDate,
    double? latitude,
    double? longitude,
    String? geohash,
    double? impactScore,
    double? reliabilityScore,
    int? totalFoodDonations,
    int? totalBloodDonations,
    int? totalVolunteerTasks,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      imagePublicId: imagePublicId ?? this.imagePublicId,
      role: role ?? this.role,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      isBloodDonorActive: isBloodDonorActive ?? this.isBloodDonorActive,
      lastBloodDonationDate: lastBloodDonationDate ?? this.lastBloodDonationDate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geohash: geohash ?? this.geohash,
      impactScore: impactScore ?? this.impactScore,
      reliabilityScore: reliabilityScore ?? this.reliabilityScore,
      totalFoodDonations: totalFoodDonations ?? this.totalFoodDonations,
      totalBloodDonations: totalBloodDonations ?? this.totalBloodDonations,
      totalVolunteerTasks: totalVolunteerTasks ?? this.totalVolunteerTasks,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isDonor => role == 'donor' || role == 'both';
  bool get isVolunteer => role == 'volunteer' || role == 'both';
  bool get hasLocation => latitude != 0.0 && longitude != 0.0;
  
  bool get canDonateBlood {
    if (!isBloodDonorActive) return false;
    if (lastBloodDonationDate == null) return true;
    return DateTime.now().difference(lastBloodDonationDate!).inDays >= 90;
  }
}
