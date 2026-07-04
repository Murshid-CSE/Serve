import 'package:cloud_firestore/cloud_firestore.dart';

class FoodDonationEntity {
  final String id;
  final String donorId;
  final String donorName;
  final String donorPhone;
  final String title;
  final String description;
  final String category; // cooked | raw | packaged | fruits | other
  final String quantity;
  final String? imageUrl;
  final String status; // available | accepted | collected | delivered | completed | expired
  final String pickupAddress;
  final double latitude;
  final double longitude;
  final String geohash;
  final DateTime expiresAt;
  final String? acceptedBy;
  final String? acceptedByName;
  final DateTime? acceptedAt;
  final DateTime? collectedAt;
  final DateTime? deliveredAt;
  final DateTime? completedAt;
  final DateTime createdAt;

  const FoodDonationEntity({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.donorPhone,
    required this.title,
    required this.description,
    required this.category,
    required this.quantity,
    this.imageUrl,
    required this.status,
    required this.pickupAddress,
    required this.latitude,
    required this.longitude,
    required this.geohash,
    required this.expiresAt,
    this.acceptedBy,
    this.acceptedByName,
    this.acceptedAt,
    this.collectedAt,
    this.deliveredAt,
    this.completedAt,
    required this.createdAt,
  });

  factory FoodDonationEntity.fromMap(Map<String, dynamic> map) {
    return FoodDonationEntity(
      id: map['id'] as String? ?? '',
      donorId: map['donorId'] as String? ?? '',
      donorName: map['donorName'] as String? ?? '',
      donorPhone: map['donorPhone'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'other',
      quantity: map['quantity'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      status: map['status'] as String? ?? 'available',
      pickupAddress: map['pickupLocation']?['address'] as String? ?? '',
      latitude: (map['pickupLocation']?['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['pickupLocation']?['lng'] as num?)?.toDouble() ?? 0.0,
      geohash: map['pickupLocation']?['geohash'] as String? ?? '',
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      acceptedBy: map['acceptedBy'] as String?,
      acceptedByName: map['acceptedByName'] as String?,
      acceptedAt: (map['acceptedAt'] as Timestamp?)?.toDate(),
      collectedAt: (map['collectedAt'] as Timestamp?)?.toDate(),
      deliveredAt: (map['deliveredAt'] as Timestamp?)?.toDate(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'donorId': donorId,
      'donorName': donorName,
      'donorPhone': donorPhone,
      'title': title,
      'description': description,
      'category': category,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'status': status,
      'pickupLocation': {
        'address': pickupAddress,
        'lat': latitude,
        'lng': longitude,
        'geohash': geohash,
      },
      'expiresAt': Timestamp.fromDate(expiresAt),
      'acceptedBy': acceptedBy,
      'acceptedByName': acceptedByName,
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'collectedAt': collectedAt != null ? Timestamp.fromDate(collectedAt!) : null,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  FoodDonationEntity copyWith({
    String? id,
    String? donorId,
    String? donorName,
    String? donorPhone,
    String? title,
    String? description,
    String? category,
    String? quantity,
    String? imageUrl,
    String? status,
    String? pickupAddress,
    double? latitude,
    double? longitude,
    String? geohash,
    DateTime? expiresAt,
    String? acceptedBy,
    String? acceptedByName,
    DateTime? acceptedAt,
    DateTime? collectedAt,
    DateTime? deliveredAt,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return FoodDonationEntity(
      id: id ?? this.id,
      donorId: donorId ?? this.donorId,
      donorName: donorName ?? this.donorName,
      donorPhone: donorPhone ?? this.donorPhone,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geohash: geohash ?? this.geohash,
      expiresAt: expiresAt ?? this.expiresAt,
      acceptedBy: acceptedBy ?? this.acceptedBy,
      acceptedByName: acceptedByName ?? this.acceptedByName,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      collectedAt: collectedAt ?? this.collectedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isAvailable => status == 'available' && !isExpired;
  bool get isAccepted => status == 'accepted';
  bool get isCollected => status == 'collected';
  bool get isDelivered => status == 'delivered';
  bool get isCompleted => status == 'completed';
}
