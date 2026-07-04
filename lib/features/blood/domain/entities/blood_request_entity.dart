import 'package:cloud_firestore/cloud_firestore.dart';

class BloodRequestEntity {
  final String id;
  final String requesterId;
  final String requesterName;
  final String requesterPhone;
  final String patientName;
  final String bloodGroup;
  final int unitsNeeded;
  final String hospitalName;
  final String hospitalAddress;
  final double latitude;
  final double longitude;
  final String geohash;
  final bool isEmergency;
  final String status; // open | responding | fulfilled | cancelled | expired
  final List<String> respondedBy;
  final DateTime? fulfilledAt;
  final DateTime expiresAt;
  final DateTime createdAt;

  const BloodRequestEntity({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.requesterPhone,
    required this.patientName,
    required this.bloodGroup,
    required this.unitsNeeded,
    required this.hospitalName,
    required this.hospitalAddress,
    required this.latitude,
    required this.longitude,
    required this.geohash,
    required this.isEmergency,
    required this.status,
    required this.respondedBy,
    this.fulfilledAt,
    required this.expiresAt,
    required this.createdAt,
  });

  factory BloodRequestEntity.fromMap(Map<String, dynamic> map) {
    return BloodRequestEntity(
      id: map['id'] as String? ?? '',
      requesterId: map['requesterId'] as String? ?? '',
      requesterName: map['requesterName'] as String? ?? '',
      requesterPhone: map['requesterPhone'] as String? ?? '',
      patientName: map['patientName'] as String? ?? '',
      bloodGroup: map['bloodGroup'] as String? ?? '',
      unitsNeeded: map['unitsNeeded'] as int? ?? 1,
      hospitalName: map['hospitalName'] as String? ?? '',
      hospitalAddress: map['hospitalLocation']?['address'] as String? ?? '',
      latitude: (map['hospitalLocation']?['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['hospitalLocation']?['lng'] as num?)?.toDouble() ?? 0.0,
      geohash: map['hospitalLocation']?['geohash'] as String? ?? '',
      isEmergency: map['isEmergency'] as bool? ?? false,
      status: map['status'] as String? ?? 'open',
      respondedBy: List<String>.from(map['respondedBy'] ?? []),
      fulfilledAt: (map['fulfilledAt'] as Timestamp?)?.toDate(),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterPhone': requesterPhone,
      'patientName': patientName,
      'bloodGroup': bloodGroup,
      'unitsNeeded': unitsNeeded,
      'hospitalName': hospitalName,
      'hospitalLocation': {
        'address': hospitalAddress,
        'lat': latitude,
        'lng': longitude,
        'geohash': geohash,
      },
      'isEmergency': isEmergency,
      'status': status,
      'respondedBy': respondedBy,
      'fulfilledAt': fulfilledAt != null ? Timestamp.fromDate(fulfilledAt!) : null,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  BloodRequestEntity copyWith({
    String? id,
    String? requesterId,
    String? requesterName,
    String? requesterPhone,
    String? patientName,
    String? bloodGroup,
    int? unitsNeeded,
    String? hospitalName,
    String? hospitalAddress,
    double? latitude,
    double? longitude,
    String? geohash,
    bool? isEmergency,
    String? status,
    List<String>? respondedBy,
    DateTime? fulfilledAt,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return BloodRequestEntity(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      requesterPhone: requesterPhone ?? this.requesterPhone,
      patientName: patientName ?? this.patientName,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      unitsNeeded: unitsNeeded ?? this.unitsNeeded,
      hospitalName: hospitalName ?? this.hospitalName,
      hospitalAddress: hospitalAddress ?? this.hospitalAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geohash: geohash ?? this.geohash,
      isEmergency: isEmergency ?? this.isEmergency,
      status: status ?? this.status,
      respondedBy: respondedBy ?? this.respondedBy,
      fulfilledAt: fulfilledAt ?? this.fulfilledAt,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isOpen => status == 'open' && !isExpired;
  bool get isResponding => status == 'responding';
  bool get isFulfilled => status == 'fulfilled';
}
