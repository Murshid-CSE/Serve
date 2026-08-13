import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyAlertEntity {

  const EmergencyAlertEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.geohash,
    required this.responders,
    required this.contactPhone,
    required this.creatorId,
    this.imageUrl,
    this.imagePublicId,
    required this.createdAt,
  });

  factory EmergencyAlertEntity.fromMap(Map<String, dynamic> map) {
    return EmergencyAlertEntity(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      level: map['level'] as String? ?? 'warning',
      address: map['location']?['address'] as String? ?? '',
      latitude: (map['location']?['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['location']?['lng'] as num?)?.toDouble() ?? 0.0,
      geohash: map['location']?['geohash'] as String? ?? '',
      responders: List<String>.from(map['responders'] ?? []),
      contactPhone: map['contactPhone'] as String? ?? '',
      creatorId: map['creatorId'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      imagePublicId: map['imagePublicId'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  final String id;
  final String title;
  final String description;
  final String level; // critical | warning | info
  final String address;
  final double latitude;
  final double longitude;
  final String geohash;
  final List<String> responders;
  final String contactPhone;
  final String creatorId;
  final String? imageUrl;
  final String? imagePublicId;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'level': level,
      'location': {
        'address': address,
        'lat': latitude,
        'lng': longitude,
        'geohash': geohash,
      },
      'responders': responders,
      'contactPhone': contactPhone,
      'creatorId': creatorId,
      'imageUrl': imageUrl,
      'imagePublicId': imagePublicId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  EmergencyAlertEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? level,
    String? address,
    double? latitude,
    double? longitude,
    String? geohash,
    List<String>? responders,
    String? contactPhone,
    String? creatorId,
    String? imageUrl,
    String? imagePublicId,
    DateTime? createdAt,
  }) {
    return EmergencyAlertEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      level: level ?? this.level,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geohash: geohash ?? this.geohash,
      responders: responders ?? this.responders,
      contactPhone: contactPhone ?? this.contactPhone,
      creatorId: creatorId ?? this.creatorId,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePublicId: imagePublicId ?? this.imagePublicId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isCritical => level == 'critical';
}
