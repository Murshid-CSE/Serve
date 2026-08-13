import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotificationEntity {

  const AppNotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.route,
    this.read = false,
    required this.createdAt,
  });

  factory AppNotificationEntity.fromMap(Map<String, dynamic> map) {
    return AppNotificationEntity(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      route: map['route'] as String?,
      read: map['read'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  final String id;
  final String title;
  final String body;
  final String? route; // Navigation redirect route e.g. /food/donation_123
  final bool read;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'route': route,
      'read': read,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AppNotificationEntity copyWith({
    String? id,
    String? title,
    String? body,
    String? route,
    bool? read,
    DateTime? createdAt,
  }) {
    return AppNotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      route: route ?? this.route,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
