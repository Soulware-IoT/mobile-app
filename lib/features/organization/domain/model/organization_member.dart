import 'package:cocina360/features/organization/domain/model/member_role.dart';

class OrganizationMember {
  final String id;
  final String profileId;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final MemberRole role;

  const OrganizationMember({
    required this.id,
    required this.profileId,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    required this.role,
  });

  /// Up-to-two-letter initials derived from the member's full name, for the
  /// avatar placeholder.
  String get initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
