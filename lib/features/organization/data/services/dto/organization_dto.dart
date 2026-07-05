import 'package:cocina360/features/organization/domain/model/organization.dart';
import 'package:cocina360/shared/data/types/json.dart';

/// Maps the backend `OrganizationResponse` (served through the api-gw) into the
/// [Organization] domain model. Only the fields the mobile screen needs are
/// kept; GPS latitude/longitude are intentionally ignored (reference-point-only).
///
/// The address travels nested: `address: {lineOne, lineTwo, reference}`, not
/// as flat root-level fields. `owner` (a `ProfileSummary`) is embedded so
/// callers don't need a separate profile fetch to show who owns the org.
class OrganizationDto {
  final String id;
  final String name;
  final String? imageUrl;
  final String? addressLineOne;
  final String? addressLineTwo;
  final String? addressReference;
  final String? ownedBy;
  final String? ownerFullName;
  final String? ownerEmail;
  final String? ownerAvatarUrl;

  const OrganizationDto({
    required this.id,
    required this.name,
    this.imageUrl,
    this.addressLineOne,
    this.addressLineTwo,
    this.addressReference,
    this.ownedBy,
    this.ownerFullName,
    this.ownerEmail,
    this.ownerAvatarUrl,
  });

  factory OrganizationDto.fromJson(JSON json) {
    final address = json['address'] as JSON?;
    final owner = json['owner'] as JSON?;

    return OrganizationDto(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      addressLineOne: address?['lineOne'] as String?,
      addressLineTwo: address?['lineTwo'] as String?,
      addressReference: address?['reference'] as String?,
      ownedBy: json['ownedBy'] as String?,
      ownerFullName: owner?['fullName'] as String?,
      ownerEmail: owner?['email'] as String?,
      ownerAvatarUrl: owner?['avatarUrl'] as String?,
    );
  }

  Organization toDomain() {
    return Organization(
      id: id,
      name: name,
      imageUrl: imageUrl,
      addressLineOne: addressLineOne,
      addressLineTwo: addressLineTwo,
      addressReference: addressReference,
      ownedBy: ownedBy,
      owner: ownerFullName == null
          ? null
          : OrganizationOwner(
              fullName: ownerFullName!,
              email: ownerEmail ?? '',
              avatarUrl: ownerAvatarUrl,
            ),
    );
  }
}
