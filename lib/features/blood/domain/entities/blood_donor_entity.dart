import 'package:cloud_firestore/cloud_firestore.dart';

class BloodDonorEntity {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final String bloodGroup;
  final bool isAvailable;
  final DateTime? lastDonationDate;
  final double latitude;
  final double longitude;
  final String geohash;
  final double impactScore;

  const BloodDonorEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    required this.bloodGroup,
    required this.isAvailable,
    this.lastDonationDate,
    required this.latitude,
    required this.longitude,
    required this.geohash,
    required this.impactScore,
  });

  factory BloodDonorEntity.fromMap(Map<String, dynamic> map) {
    return BloodDonorEntity(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      bloodGroup: map['bloodGroup'] as String? ?? '',
      isAvailable: map['isBloodDonorActive'] as bool? ?? false,
      lastDonationDate: (map['lastBloodDonationDate'] as Timestamp?)?.toDate(),
      latitude: (map['location']?['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['location']?['lng'] as num?)?.toDouble() ?? 0.0,
      geohash: map['location']?['geohash'] as String? ?? '',
      impactScore: (map['impactScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'bloodGroup': bloodGroup,
      'isBloodDonorActive': isAvailable,
      'lastBloodDonationDate': lastDonationDate != null
          ? Timestamp.fromDate(lastDonationDate!)
          : null,
      'location': {
        'lat': latitude,
        'lng': longitude,
        'geohash': geohash,
      },
      'impactScore': impactScore,
    };
  }
}
