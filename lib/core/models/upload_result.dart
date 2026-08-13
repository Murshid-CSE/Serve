import 'package:equatable/equatable.dart';

class UploadResult extends Equatable {
  const UploadResult({
    required this.secureUrl,
    required this.publicId,
    this.deleteToken,
  });

  factory UploadResult.fromMap(Map<String, dynamic> map) {
    return UploadResult(
      secureUrl: map['secureUrl'] as String? ?? '',
      publicId: map['publicId'] as String? ?? '',
      deleteToken: map['deleteToken'] as String?,
    );
  }

  final String secureUrl;
  final String publicId;
  final String? deleteToken;

  UploadResult copyWith({
    String? secureUrl,
    String? publicId,
    String? deleteToken,
  }) {
    return UploadResult(
      secureUrl: secureUrl ?? this.secureUrl,
      publicId: publicId ?? this.publicId,
      deleteToken: deleteToken ?? this.deleteToken,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'secureUrl': secureUrl,
      'publicId': publicId,
      'deleteToken': deleteToken,
    };
  }

  @override
  List<Object?> get props => [secureUrl, publicId, deleteToken];
}
