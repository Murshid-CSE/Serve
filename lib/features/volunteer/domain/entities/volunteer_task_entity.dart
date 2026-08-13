import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteerTaskEntity {

  const VolunteerTaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.geohash,
    required this.date,
    required this.volunteersNeeded,
    required this.volunteersJoined,
    required this.creatorId,
    required this.creatorName,
    required this.createdAt,
  });

  factory VolunteerTaskEntity.fromMap(Map<String, dynamic> map) {
    return VolunteerTaskEntity(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      type: map['type'] as String? ?? 'other',
      status: map['status'] as String? ?? 'active',
      address: map['location']?['address'] as String? ?? '',
      latitude: (map['location']?['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['location']?['lng'] as num?)?.toDouble() ?? 0.0,
      geohash: map['location']?['geohash'] as String? ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      volunteersNeeded: map['volunteersNeeded'] as int? ?? 1,
      volunteersJoined: List<String>.from(map['volunteersJoined'] ?? []),
      creatorId: map['creatorId'] as String? ?? '',
      creatorName: map['creatorName'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  final String id;
  final String title;
  final String description;
  final String type; // distribution | rescue | event | other
  final String status; // active | completed | cancelled
  final String address;
  final double latitude;
  final double longitude;
  final String geohash;
  final DateTime date;
  final int volunteersNeeded;
  final List<String> volunteersJoined;
  final String creatorId;
  final String creatorName;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'status': status,
      'location': {
        'address': address,
        'lat': latitude,
        'lng': longitude,
        'geohash': geohash,
      },
      'date': Timestamp.fromDate(date),
      'volunteersNeeded': volunteersNeeded,
      'volunteersJoined': volunteersJoined,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  VolunteerTaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? status,
    String? address,
    double? latitude,
    double? longitude,
    String? geohash,
    DateTime? date,
    int? volunteersNeeded,
    List<String>? volunteersJoined,
    String? creatorId,
    String? creatorName,
    DateTime? createdAt,
  }) {
    return VolunteerTaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geohash: geohash ?? this.geohash,
      date: date ?? this.date,
      volunteersNeeded: volunteersNeeded ?? this.volunteersNeeded,
      volunteersJoined: volunteersJoined ?? this.volunteersJoined,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isActive => status == 'active' && date.isAfter(DateTime.now());
  bool get isCompleted => status == 'completed';
  bool get isFull => volunteersJoined.length >= volunteersNeeded;
}
