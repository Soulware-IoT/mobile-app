import 'package:cocina360/features/organization/domain/model/organization.dart';
import 'package:cocina360/shared/data/types/json.dart';

/// Maps the backend `OrganizationResponse` (served through the api-gw) into the
/// [Organization] domain model. Only the fields the mobile screen needs are
/// kept; GPS latitude/longitude are intentionally ignored (reference-point-only).
class OrganizationDto {
  final String id;
  final String name;
  final String? imageUrl;
  final String? addressLineOne;
  final String? addressLineTwo;
  final String? addressReference;
  final String? ownedBy;

  const OrganizationDto({
    required this.id,
    required this.name,
    this.imageUrl,
    this.addressLineOne,
    this.addressLineTwo,
    this.addressReference,
    this.ownedBy,
  });

  factory OrganizationDto.fromJson(JSON json) {
    return OrganizationDto(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      addressLineOne: json['addressLineOne'] as String?,
      addressLineTwo: json['addressLineTwo'] as String?,
      addressReference: json['addressReference'] as String?,
      ownedBy: json['ownedBy'] as String?,
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
    );
  }
}
