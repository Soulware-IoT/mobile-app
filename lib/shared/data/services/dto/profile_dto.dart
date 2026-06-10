import 'package:tcompro/shared/data/types/json.dart';
import 'package:tcompro/shared/domain/model/profile.dart';

class ProfileDto {
  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileDto({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileDto.fromJson(JSON json) {
    return ProfileDto(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Profile toDomain() {
    return Profile(
      id: id,
      fullName: fullName,
      email: email,
      avatarUrl: avatarUrl,
    );
  }
}